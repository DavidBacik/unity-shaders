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

    half _Speed;
    half _Displace;

    TEXTURE2D(_MainTex);
    SAMPLER(sampler_MainTex);
    float4 _MainTex_ST;
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
    float2 uvShift : TEXCOORD1;
    DECLARE_SHADOW_COORD(7)
};

// Vertex shader
VertexOutput VertexShaderMain(VertexInput v)
{
    VertexOutput o = (VertexOutput)0;

    float2 uvShift = v.uv + float2(frac(_Time.y * _Speed), -frac(_Time.y * _Speed));
    float3 posWorld = TransformObjectToWorld(v.position.xyz);

    posWorld += v.normal * _Displace * SAMPLE_TEXTURE2D_LOD(_MainTex, sampler_MainTex, uvShift, 0);
    
    o.posClip = TransformWorldToHClip(posWorld);
    o.posWorld = posWorld;
    o.normal = v.normal.xyz;
    o.uv = v.uv;

    // o.uv.x += frac(_Time.y);
    
    // float displacement = sin(_Time.y + v.normal.y) * 25;
    // v.normal.xyz += v.normal * displacement;
    
    //---
    // float rotationSpeed = 1.0;
    // float angle = _Time.y * rotationSpeed;
    // float c = cos(angle);
    // float s = sin(angle);
    // float2x2 rotationMatrix = float2x2(c, -s, s, c);
    // float2 centeredUV = o.uv - float2(0.5, 0.5);
    // float2 rotatedUV = mul(rotationMatrix, centeredUV) + float2(0.5, 0.5);
    //
    // o.uv = rotatedUV;
    //---
    
    INIT_SHADOW_COORD(o, posWorld);
    return o;
}

// Fragment shader
half4 FragmentShaderMain(VertexOutput v) : SV_Target
{
    // sample surface color from texture
    half4 surfaceColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, v.uv * _MainTex_ST.xy + _MainTex_ST.zw);
    // clip(surfaceColor.x - 0.5);
    
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
    return half4(finalColor, 1);
}
#endif