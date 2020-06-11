
fixed4 frag( PIO process, uint isFrontFace : SV_IsFrontFace ) : SV_Target
{
	fixed4 color = tex2D( _MainTex, process.uv ) * _Color;
	#ifdef MODE_TCUT
		clip(color.a - _TCut);
	#endif

	process = adjustProcess(process, isFrontFace);
	color = applyFresnel(process, color);

	process = adjustProcess(process, 0);
	//float3 lightDirection = normalize(process.worldPosition - _WorldSpaceLightPos0.xyz);
	float3 lightDirection = -normalize(UnityWorldSpaceLightDir(process.worldPosition));
	float brightness = dot(lightDirection,process.worldNormal);// * unity_4LightAtten0;
	brightness = applyToonEdge(process, brightness);
	color.rgb =  max(color.rgb * _LightColor0.rgb * brightness,0);

	#ifdef MODE_TCUT
		color.a = 1;
	#endif
	#ifdef MODE_OPAQUE
		color.a = 1;
	#endif
	
	return color;
}