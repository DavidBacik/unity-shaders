Shader "UI/CylinderEffect"
{
    Properties
    {
        _MainTex ("Base Texture", 2D) = "white" {}
        _MaskTex ("Mask Texture", 2D) = "white" {}
        _ScrollSpeedX ("Scroll Speed X", Float) = 0.1
        _ScrollSpeedY ("Scroll Speed Y", Float) = 0.1
        
    }
    SubShader
    {
        Tags { "Queue"="Transparent" }

        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex VertexShaderMain
            #pragma fragment FragmentShaderMain
            #include "UnityCG.cginc"

            struct VertexInput
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct VertexOutput
            {
                float2 uv : TEXCOORD0;
                // float2 maskUv : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _MaskTex;
            float _ScrollSpeedX;
            float _ScrollSpeedY;

            VertexOutput VertexShaderMain(VertexInput v)
            {
                VertexOutput o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                // float2 scrollUV = float2(_Time.y * _ScrollSpeedX, _Time.y * _ScrollSpeedY);
                // o.uv = v.uv + scrollUV;
                // o.uv = v.uv;

                float2 scrollUV = float2(_Time.y * _ScrollSpeedX, _Time.y * _ScrollSpeedY);
                o.uv = v.uv + scrollUV;
                
                // o.maskUv = v.uv;
                return o;
            }
            
            half4 FragmentShaderMain(VertexOutput i) : SV_Target
            {
                // Color mixing
                // fixed4 col = lerp(_BackgroundColor, _StripeColor, stripePattern);

                fixed4 col = tex2D(_MainTex, i.uv);
                fixed maskValue = tex2D(_MaskTex, i.uv).r;
                col *= maskValue;
                
                return col;
            }
            ENDCG
        }
    }
}

