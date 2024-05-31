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
CBUFFER_END

// IO structures
struct VertexInput
{
    float4 position : POSITION;
    float4 normal : NORMAL;
};

struct VertexOutput
{
    float4 posClip : SV_POSITION;
    half3 normal : NORMAL;
    float3 posWorld : TANGENT;
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

    INIT_SHADOW_COORD(o, posWorld);
    return o;
}

// Fragment shader
half4 FragmentShaderMain(VertexOutput v) : SV_Target
{
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
    half3 diffuseColor = _DiffuseColor.rgb * ndotl;
    half3 specularColor = _SpecularColor * specular;
    half3 finalColor = mainLight.color * saturate(attenuation) * (diffuseColor + specularColor);

    // final color
    return half4(finalColor, 1);
}
#endif
