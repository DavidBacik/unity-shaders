Shader "Learning/Lesson01Shader"
{
    Properties
    {
        _Color("Color", Color) = (1, 0, 0, 1)
    }

    SubShader
    {
        Tags
        {
            "RenderType"       = "Opaque"
            "PerformanceChecks"= "False"
            "RenderPipeline"   = "UniversalPipeline"
            "Queue"            = "Geometry+1"
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
        
            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 3.0

            #pragma multi_compile_fwdbase
                        
            //--------------------------------------
            // Shader points
            #pragma vertex VertexShaderMain
            #pragma fragment FragmentShaderMain

            #include "HLSL/Lesson01DefaultPass.hlsl"
            ENDHLSL
        }
    }
}