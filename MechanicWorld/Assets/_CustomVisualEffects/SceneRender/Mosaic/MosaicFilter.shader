Shader "Hidden/MosaicFilter"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OverlayTex("Overlay tex", 2D) = "white" {}
        _OverlayColor("Overlay color", Color) = (1,1,1,1)
        _xTileCount("x tile count", int) = 100
        _yTileCount("y tile count", int) = 100
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
            sampler2D _OverlayTex;
            float4 _OverlayColor;
            int _xTileCount;
            int _yTileCount;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                float2 overlayUV = i.uv * float2(_xTileCount, _yTileCount);
                float4 overlayCol = tex2D(_OverlayTex, overlayUV) * _OverlayColor;
                col = lerp(col, overlayCol, overlayCol.a);
                
                return col;
            }
            ENDCG
        }
    }
}
