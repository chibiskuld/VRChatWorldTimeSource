Shader "Skuld/Time From Udon"
{
	Properties
	{
		_Hour("Hour",float) = 0
		_Minute("Minute", float) = 0
		_Second("Second", float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

			float _Hour;
			float _Minute;
			float _Second;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 col;
				col.r = _Hour / 24.0f;
				col.g = _Minute / 60.0f;
				col.b = _Second / 60.0f;
				col.a = 1;
#ifndef UNITY_COLORSPACE_GAMMA
				col.rgb = GammaToLinearSpace(col.rgb);
#endif
                return col;
            }
            ENDCG
        }
    }
}
