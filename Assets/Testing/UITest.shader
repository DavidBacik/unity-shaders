Shader "UI/ScrollingTexture"
{
    Properties
    {
        _MainTex ("Base Texture", 2D) = "white" {}
        _MaskTex ("Mask Texture", 2D) = "white" {}
        _StripeColor ("Stripe Color", Color) = (1,1,1,1)
        _BackgroundColor ("Background Color", Color) = (0,0,0,1)
        _StripeWidth ("Stripe Width", Float) = 0.1
        _StripeDensity ("Stripe Density", Float) = 10.0
        _StripeAngle ("Stripe Angle", Float) = 45.0
        _ScrollSpeedX ("Scroll Speed X", Float) = 0.1
        _ScrollSpeedY ("Scroll Speed Y", Float) = 0.1
        [Toggle] _Antialiasing("_Antialiasing", Float) = 0
        
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
                float2 maskUv : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _MaskTex;
            fixed4 _StripeColor;
            fixed4 _BackgroundColor;
            float _StripeWidth;
            float _StripeDensity;
            float _StripeAngle;
            float _ScrollSpeedX;
            float _ScrollSpeedY;
            float _Antialiasing;

            VertexOutput VertexShaderMain(VertexInput v)
            {
                VertexOutput o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                float2 scrollUV = float2(_Time.y * _ScrollSpeedX, _Time.y * _ScrollSpeedY);
                o.uv = v.uv + scrollUV;
                o.maskUv = v.uv;
                return o;
            }
            
            half4 FragmentShaderMain(VertexOutput i) : SV_Target
            {
                // Rotation and stripe pattern calculation
                float angleRad = _StripeAngle * 3.14 / 180.0;
                float2 rotatedUV = float2(
                    cos(angleRad) * (i.uv.x - 0.5) + sin(angleRad) * (i.uv.y - 0.5),
                    cos(angleRad) * (i.uv.y - 0.5) - sin(angleRad) * (i.uv.x - 0.5)
                ) + 0.5;

                float stripePattern;
                if (_Antialiasing == 1)
                {
                    float stripeCenter = abs(sin(rotatedUV.x * 2.0 * 3.14 * _StripeDensity));
                    float edgeWidth = fwidth(stripeCenter) * _StripeWidth;
                    stripePattern = smoothstep(_StripeWidth - edgeWidth, _StripeWidth + edgeWidth, stripeCenter);
                }
                else
                {
                    stripePattern = step(_StripeWidth, abs(sin(rotatedUV.x * 2.0 * 3.14 * _StripeDensity)));
                }
                
                // float stripePattern = step(_StripeWidth, abs(sin(rotatedUV.x * 2.0 * 3.14 * _StripeDensity)));
                
                // Color mixing
                fixed4 col = lerp(_BackgroundColor, _StripeColor, stripePattern);

                fixed maskValue = tex2D(_MaskTex, i.maskUv).r;
                col *= maskValue;
                
                return col;
            }
            ENDCG
        }
    }
}

