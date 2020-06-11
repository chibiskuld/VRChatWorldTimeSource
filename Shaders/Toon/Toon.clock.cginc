sampler2D _HandTex;
float _HandWidth;
float4 _HandColor;
float4 _HandOffset;
float tor;
float _MinuteHandSize;
float _HourHandSize;

float2 rotate2(float2 inCoords, float rot)
{
	float sinRot;
	float cosRot;
	sincos(rot, sinRot, cosRot);
	return mul(float2x2(cosRot, -sinRot, sinRot, cosRot), inCoords);
}

fixed4 DrawHour(fixed4 col, PIO p, float h) {
	float2 muv = p.uv;
	muv -= .5f;
	muv = rotate2(muv, h * 5 * tor);
	muv *= 1 / _HourHandSize;
	muv += _HandOffset.xy;
	float4 col2 = tex2D(_HandTex, muv);
	if (muv.y < 0.0f) return col;
	if (muv.x < 0.0f) return col;
	col = lerp(col, col2, col2.a);
	return col;
}

fixed4 DrawMinute(fixed4 col, PIO p, float m) {
	float2 muv = p.uv;
	muv -= .5f;
	muv = rotate2(muv, m * tor);
	muv *= 1 / _MinuteHandSize;
	muv += _HandOffset.xy;
	float4 col2 = tex2D(_HandTex, muv);
	if (muv.y < 0.0f) return col;
	if (muv.x < 0.0f) return col;
	col = lerp(col, col2, col2.a);
	return col;
}

fixed4 DrawSeconds(fixed4 col, PIO p, float s) {
	float2 suv = p.uv;
	suv -= .5f;
	suv = rotate2(suv, s * tor);
	suv += .5f;
	if ( suv.x < .5f+ _HandWidth && suv.x > .5f- _HandWidth) {
		if (suv.y > .5f && suv.y < .97f) {
			col = _HandColor;
		}
	}
	return col;
}

fixed4 frag_clock( PIO process, uint isFrontFace : SV_IsFrontFace ) : SV_Target
{
	tor = 0.10471975511965977461542144610932;
	//get the uv coordinates and set the base color.
	fixed4 color = tex2D( _MainTex, process.uv ) * _Color;

	process = adjustProcess(process, isFrontFace);

	float3 time = GetTime();

	color = DrawSeconds(color, process, time.b);
	color = DrawMinute(color, process, time.g);
	color = DrawHour(color, process, time.r);


#ifndef FORWARD_ADD
	//Apply baselights
	color = applyLight(process, color);
#else 
	float3 lightDirection = -normalize(UnityWorldSpaceLightDir(process.worldPosition));
	float brightness = dot(lightDirection, process.worldNormal);// * unity_4LightAtten0;
	brightness = applyToonEdge(process, brightness);
	color.rgb = max(color.rgb * _LightColor0.rgb * brightness, 0);
#endif
	color.a = 1;
	return color;
}