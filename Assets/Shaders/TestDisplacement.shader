Shader "Custom/NoiseDisplacementShader" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _Displacement ("Displacement", Range(0, 1)) = 0.5
        _Color ("Color", Color) = (1,1,1,1) // Define color property
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        // Use surface shader syntax for Unity's lighting and shadowing
        CGPROGRAM
        #pragma surface surf Standard vertex:vert
        #include "UnityCG.cginc"

        sampler2D _MainTex;
        float _Displacement;
        fixed4 _Color; // Define color variable

        struct Input {
            float2 uv_MainTex;
        };

        void vert (inout appdata_full v) {
            // Simple noise function can go here for displacement, such as Perlin noise
            // Note: Unity doesn't have a built-in noise function in HLSL, so you'd need a custom implementation or texture
            float noise = _Displacement * (sin(v.texcoord.x * _Time.y) + cos(v.texcoord.y * _Time.y)); // Placeholder for noise
            v.vertex.xyz += v.normal * noise;
        }

        void surf (Input IN, inout SurfaceOutputStandard o) {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color; // Use _Color
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}