Shader "Skuld/Time As Color"
{
    Properties
    {
		_SystemTime("Time in Seconds", float) = 0
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

			float _SystemTime;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 col;
				col.r = ( (_SystemTime / 3600) % 24 ) / 24;
				col.g = ( (_SystemTime / 60) % 60 ) / 60;
				col.b = ( _SystemTime % 60 ) / 60;
                
                return col;
            }
            ENDCG
        }
    }
}
