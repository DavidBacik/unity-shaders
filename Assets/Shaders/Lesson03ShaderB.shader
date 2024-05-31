Shader "Learning/Lesson03ShaderB"
{
    Properties
    {
        _DiffuseColor("Diffuse color", Color) = (1, 0, 0, 1)
        
        _SpecularColor("Specular color", Color) = (1,1,1,1)
        _SpecularPower("Specular power", Range(1,1000)) = 10

        _MainTex("Main texture", 2D) = "white" {}
        _NoiseTex("Noise texture", 2D) = "white" {}
        _NoiseStrength("Noise strength", Range(0,1)) = 0.5
        [HideInInspector] _Noise("Noise", Vector) = (0,0,0,0)
    }

    SubShader
    {
        Tags
        {
            "RenderType"       = "Transparent"
            "PerformanceChecks"= "False"
            "RenderPipeline"   = "UniversalPipeline"
            "Queue"            = "Transparent"
            "IgnoreProjector"  = "True"
        }

        LOD 150

        // ------------------------------------------------------------------
        //  Base forward pass
        Pass
        {
            Name "ForwardBase"
            Tags { "LightMode" = "UniversalForward" }

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            ZTest LEqual
            Cull Back
        
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

            #include "HLSL/Lesson03DefaultPassB.hlsl"
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