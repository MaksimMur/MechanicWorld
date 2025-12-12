Shader "Hidden/EdgeDetectionFilter"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float2 _MainTex_TexelSize;

            //возвращает значение €ркости пиксел€
            float getLum(float2 uv, float2 offset, float m)
            {
                fixed3 col = tex2D(_MainTex, uv+offset);
                float lum = col.r*0.3+col.g*0.59 +col.b*0.11;
                return lum * m;
            }


            //функци€ котора€ будет возврашать rgb цвет без альфы на основе —обел€
            float3 sobel(float2 uv)
            {
                float x = 0;
                float y = 0;
                float2 _texelSize = _MainTex_TexelSize;
                x+= getLum(uv, float2(-_texelSize.x, -_texelSize.y), -1.0);
                x+= getLum(uv, float2(-_texelSize.x,            0), -2.0);
                x+= getLum(uv, float2(-_texelSize.x,  _texelSize.y), -1.0);

                x+= getLum(uv, float2(_texelSize.x, -_texelSize.y), 1.0);
                x+= getLum(uv, float2(_texelSize.x,            0), 2.0);
                x+= getLum(uv, float2(_texelSize.x,  _texelSize.y), 1.0);

                y+= getLum(uv, float2(-_texelSize.x, -_texelSize.y), -1.0);
                y+= getLum(uv, float2(            0, -_texelSize.y), -2.0);
                y+= getLum(uv, float2( _texelSize.x, -_texelSize.y), -1.0);

                y+= getLum(uv, float2(-_texelSize.x, _texelSize.y), 1.0);
                y+= getLum(uv, float2(            0, _texelSize.y), 2.0);
                y+= getLum(uv, float2( _texelSize.x, _texelSize.y), 1.0);

                return sqrt(x*x +y*y);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 s = sobel(i.uv);
                return fixed4(s, 1.0);
                
            }
            ENDCG
        }
    }
}
