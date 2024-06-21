Shader "Custom/PlaneEffect"
{
    Properties
    {
        _MainTex ("Base Texture", 2D) = "white" {}
        _MaskTex ("Mask Texture", 2D) = "white" {}
        _RotationSpeed ("Rotation Speed", float) = 0
        _TwirlAmount ("Twirl Amount", float) = 0
        
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
            float _RotationSpeed;
            float _TwirlAmount;

            VertexOutput VertexShaderMain(VertexInput v)
            {
                // VertexOutput o;
                // o.vertex = UnityObjectToClipPos(v.vertex);
                //
                //  // Výpočet rotácie
                // float2 centeredUV = v.uv - 0.5; // Posunutie UV súradníc do stredu
                // float angle = _Time.y * _RotationSpeed; // Aktuálny uhol rotácie
                // float cosAngle = cos(angle);
                // float sinAngle = sin(angle);
                // // Rotácia UV súradníc
                // o.uv.x = centeredUV.x * cosAngle - centeredUV.y * sinAngle + 0.5;
                // o.uv.y = centeredUV.x * sinAngle + centeredUV.y * cosAngle + 0.5;
                // return o;

                VertexOutput o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                // Center the UVs
                float2 centeredUV = v.uv - 0.5;

                // Calculate distance from the center
                float distance = length(centeredUV);

                // Calculate twirl effect based on distance from center
                float twirlAngle = distance * _TwirlAmount;
                
                // Incorporate rotation speed
                float totalAngle = _Time.y * _RotationSpeed + twirlAngle;

                float cosAngle = cos(totalAngle);
                float sinAngle = sin(totalAngle);

                // Apply twirl and rotation
                o.uv.x = cosAngle * centeredUV.x - sinAngle * centeredUV.y + 0.5;
                o.uv.y = sinAngle * centeredUV.x + cosAngle * centeredUV.y + 0.5;
                
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

