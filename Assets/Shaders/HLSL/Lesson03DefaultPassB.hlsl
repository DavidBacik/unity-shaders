#ifndef DEFAULT_PASS
#define DEFAULT_PASS

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "IncludeLWRPUnityShadows.hlsl"

//======================================================
// constants
CBUFFER_START(UnityPerMaterial)
    half4 _DiffuseColor;
    half4 _SpecularColor;
    half _SpecularPower;

    TEXTURE2D(_MainTex);
    SAMPLER(sampler_MainTex);
    float4 _MainTex_ST;

    TEXTURE2D(_NoiseTex);
    SAMPLER(sampler_NoiseTex);
    float4 _NoiseTex_ST;
    half _NoiseStrength;
    float4 _Noise;
CBUFFER_END

// IO structures
struct VertexInput
{
    float4 position : POSITION;
    float4 normal : NORMAL;
    float2 uv : TEXCOORD0;
};

struct VertexOutput
{
    float4 posClip : SV_POSITION;
    half3 normal : NORMAL;
    float3 posWorld : TANGENT;
    float2 uv : TEXCOORD0;
    DECLARE_SHADOW_COORD(7)
};

// Vertex shader
VertexOutput VertexShaderMain(VertexInput v)
{
    VertexOutput o = (VertexOutput)0;

    float3 posWorld = TransformObjectToWorld(v.position.xyz);

    o.posClip = TransformWorldToHClip(posWorld);
    o.posWorld = posWorld;
    o.normal = v.normal.xyz;
    o.uv = v.uv;

    // o.uv.x += frac(_Time.y);
    
    INIT_SHADOW_COORD(o, posWorld);
    return o;
}

// Fragment shader
half4 FragmentShaderMain(VertexOutput v) : SV_Target
{
    // sample noise
    float4 noiseTextureU = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, v.uv * _NoiseTex_ST.xy + _NoiseTex_ST.zw);
    float noiseShiftU = dot(noiseTextureU, _Noise);

    float4 noiseTextureV = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, (v.uv + float2(0.5f,0)) * _NoiseTex_ST.xy + _NoiseTex_ST.zw);
    float noiseShiftV = dot(noiseTextureV, _Noise);

    float2 noiseShift = float2(noiseShiftU, noiseShiftV) * _NoiseStrength;

    // sample surface color from texture
    half4 surfaceColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, (v.uv + noiseShift) * _MainTex_ST.xy + _MainTex_ST.zw);

    // main light
    Light mainLight = GetMainLight();
    half attenuation = CALCULATE_SHADOW_ATTENUATION(v, v.posWorld, mainLight.shadowAttenuation);

    // Lambertian lighting
    half ndotl = saturate(dot(v.normal.xyz, mainLight.direction));

    // Blinn-Phong specular lighting
    half3 cameraDirection = normalize(_WorldSpaceCameraPos - v.posWorld);
    half3 lightDirection = mainLight.direction;
    half3 blinnNormal = normalize(cameraDirection + lightDirection);
    half specular = pow(saturate(dot(blinnNormal, normalize(v.normal))), _SpecularPower);

    // calculate final color
    half3 diffuseColor = surfaceColor * _DiffuseColor.rgb * ndotl;
    half3 specularColor = _SpecularColor * specular;
    half3 finalColor = mainLight.color * saturate(attenuation) * (diffuseColor + specularColor);

    // final color
    return half4(finalColor, _DiffuseColor.a);
}
#endif
