Shader "Hidden/GaussBlurFilter"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Kernel ("Kernel (N)", int) = 21
        _Spread ("Spread (sigma)", float) = 5
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            Name "GaussBlurPass"
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

            static const float TWO_PI = 6.28319;
            static const float E = 2.71828;

            sampler2D _MainTex;
            int _Kernel;
            float _Spread;
            float2 _MainTex_TexelSize;

            float gaussian(int x, int y)
            {
                float sigmaSqu = _Spread * _Spread;
                return (1 / sqrt(TWO_PI * sigmaSqu)) * pow(E, -((x*x) + (y*y)) / (2 *sigmaSqu));    
            }

            fixed4 frag (v2f i) : SV_Target
            {
                 fixed originAlpha = tex2D(_MainTex, i.uv).a;
                // переменная хранящая трехканальную информацию
                fixed3 col = fixed3(0.0,0.0,0.0);
                float _kernelSum =0.0;
                
                //границы для средневзвешенного значения
                int upper = ((_Kernel-1))/2;
                int lower = -upper;

                for(int x = lower; x<= upper;++x)
                {
                    for(int y = lower; y<= upper;++y)
                    {
                        float gaus = gaussian(x,y);
                        _kernelSum+= gaus;
                        fixed2 offset = fixed2(_MainTex_TexelSize.x*x,_MainTex_TexelSize.y);    
                        col+=gaus * tex2D(_MainTex, i.uv+offset);
                    }
                }
                
                col /=_kernelSum;
                return fixed4(col, originAlpha);
            }
            ENDCG
        }
    }
}
