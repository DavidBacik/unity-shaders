Shader "Learning/Lesson03ShaderA"
{
    Properties
    {
        _DiffuseColor("Diffuse color", Color) = (1, 0, 0, 1)
        
        _SpecularColor("Specular color", Color) = (1,1,1,1)
        _SpecularPower("Specular power", Range(1,1000)) = 10
        
        _Displace("_Displace power", Range(0,5)) = 1
        _Speed("Speed", Range(0,5)) = 1

        _MainTex("Main texture", 2D) = "white" {}
    }

    SubShader
    {
        Tags
        {
            "RenderType"       = "Opaque"
            "PerformanceChecks"= "False"
            "RenderPipeline"   = "UniversalPipeline"
            "Queue"            = "Geometry"
            "IgnoreProjector"  = "True"
        }

        LOD 150

        // ------------------------------------------------------------------
        //  Base forward pass
        Pass
        {
            Name "ForwardBase"
            Tags { "LightMode" = "UniversalForward" }

            Blend One Zero
            ZWrite On
            ZTest LEqual
            Cull Back
            //AlphaTest Greater 0.8 // legacy
        
            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 3.0

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            
            #pragma multi_compile_fwdbase
                        
            //--------------------------------------
            // Shader points
            #pragma vertex VertexShaderMain
            #pragma fragment FragmentShaderMain

            #include "HLSL/Lesson03DefaultPassA.hlsl"
            ENDHLSL
        }
        
        // ------------------------------------------------------------------
        //  Shadow rendering pass
        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            Cull Back

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            
            #include "HLSL/ShadowPass.hlsl"
            ENDHLSL
        }
    }
}