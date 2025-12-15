Shader "Hidden/PaintingFilter"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Kernel("Kernel size", int) = 15
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
            int _Kernel;
            float2 _MainTex_TexelSize;
            
            //хранение дисперсии и усредненого цвета
            struct region
            {
                float3 mean;     
                float variance;
            };

            //lower - минимальная точка матрицы относительно uv, upper - максимальная точка матрицы относительно uv, samples - количество пикселей в секторе, uv - текстурные коорлинаты
            region calculateRegion(int2 lower, int2 upper, int samples, float2 uv)
            {
                //хранение результата
                region r;
                float3 sum = 0.0;
                float3 squareSum = 0.0;

                for(int x = lower.x; x <= upper.x; ++x)
                {
                    for(int y = lower.y; y <= upper.y; ++y)
                    {
                        //вычисление offset относительно uv координат
                        fixed2 offset = fixed2(_MainTex_TexelSize.x * x,_MainTex_TexelSize.y * y);

                        //вычисление цвета в точке
                        fixed3 col = tex2D(_MainTex,uv +  offset);

                        sum += col;
                        squareSum += col * col;
                    }
                }
                //вычисление средневзвешенного значения
                r.mean = sum / samples;

                //abs берет абсолютное значение, чтобы избежать отрицательных чисел,
                float3 variance = abs(( squareSum / samples) - (r.mean * r.mean));

                //береме длину вектора
                r.variance = length(variance);

                return r;
            }

            
            float3 rgb2hsv(float3 c)
            {
                float4 K = float4(0.0, -1.0/3.0, 2.0/3.0, -1.0);
                float4 p = c.g < c.b ? float4(c.bg, K.wz) : float4(c.gb, K.xy);
                float4 q = c.r < p.x ? float4(p.xyw, c.r) : float4(c.r, p.yzx);

                float d = q.x -min(q.w, q.y);
                float e = 1.0e-10;
                return float3(abs(q.z +(q.w - q.y) / (6.0 * d +e)), d / (q.x +e), q.x );
            }

            float3 hsv2rgb(float3 c)
            {
                float4 K = float4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
                float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
                return c.z *lerp(K.xxx, saturate(p- K.xxx), c.y);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                int upper = (_Kernel - 1) / 2;
                int lower = -upper;

                //число ячеек каждого из секторов изображения
                int samples = (upper + 1) * (upper + 1);
                
                region regionA = calculateRegion(int2(lower,lower), int2(0,0), samples, i.uv);
                region regionB = calculateRegion(int2(0,lower), int2(upper,0), samples, i.uv);
                region regionC = calculateRegion(int2(lower,0), int2(0,upper), samples, i.uv);
                region regionD = calculateRegion(int2(0,0), int2(upper,upper), samples, i.uv);
                
                //вычисление наименьшего значения дисперсии
                fixed3 col = regionA.mean;
                fixed minVar = regionA.variance;

                float testVal;

                //step возвращает 0, если второй параметр меньше, чем первый, в другом случае 1
                testVal = step(regionB.variance, minVar);
                col = lerp(col, regionB.mean, testVal);
                minVar = lerp(minVar, regionB.variance, testVal);

                testVal = step(regionC.variance, minVar);
                col = lerp(col, regionC.mean, testVal);
                minVar = lerp(minVar, regionC.variance, testVal);

                testVal = step(regionD.variance, minVar);
                col = lerp(col, regionD.mean, testVal);

                //промодифицируем значение нассыщенности
                fixed3 hsvCol = rgb2hsv(col);
                hsvCol.y *=2;
                col = hsv2rgb(hsvCol);

                return fixed4(col, 1.0);
            }
            ENDCG
        }
    }
}
