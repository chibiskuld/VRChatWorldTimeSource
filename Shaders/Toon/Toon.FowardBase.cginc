fixed4 frag( PIO process, uint isFrontFace : SV_IsFrontFace ) : SV_Target
{
	//get the uv coordinates and set the base color.
	fixed4 color = tex2D( _MainTex, process.uv ) * _Color;
	#ifdef MODE_TCUT
		clip(color.a - _TCut);
	#endif

	process = adjustProcess(process, isFrontFace);
	color = applyFresnel(process, color);

	if ( !_MaskGlow ){
		color = applyMaskLayer(process, color);
	}

	//Apply baselights
	color = applyLight(process, color);

	if ( _MaskGlow ){
		color = applyMaskLayer(process, color);
	}

	#ifdef MODE_TCUT 
		color.a = 1;
	#endif
	#ifdef MODE_OPAQUE
		color.a = 1;
	#endif

	return color;
}