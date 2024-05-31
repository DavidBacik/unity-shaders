#ifndef DEFAULT_PASS
#define DEFAULT_PASS

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

//======================================================
// constants
CBUFFER_START(UnityPerMaterial)
    half4 _Color;
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
};

// Vertex shader
VertexOutput VertexShaderMain(VertexInput v)
{
    VertexOutput o = (VertexOutput)0;

    float3 posWorld = TransformObjectToWorld(v.position.xyz);

    o.posClip = TransformWorldToHClip(posWorld);
    o.posWorld = posWorld;
    o.normal = v.normal.xyz;

    return o;
}

// Fragment shader
half4 FragmentShaderMain(VertexOutput v) : SV_Target
{
    Light mainLight = GetMainLight();
    half ndotl = saturate(dot(v.normal.xyz, mainLight.direction)); // Lambertian lighting
    half3 lighting = ndotl * mainLight.color;

    return half4(_Color.xyz * lighting, 1);
}
#endif
