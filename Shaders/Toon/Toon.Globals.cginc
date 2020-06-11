#pragma once
//general IO with Semantics
struct IO
{
	float4 position : POSITION;
	float3 normal : NORMAL;
	float2 uv : TEXCOORD0;
	uint id : SV_VertexID;
	float4 tangent : TANGENT;
};

//processed IO to be used by submethods
struct PIO
{
	float4 position : SV_POSITION; //the Position relative to the screen
	float3 normal : NORMAL; //The normal in screen space.
	float2 uv : TEXCOORD0; //uv coordinates
	float4 objectPosition : TEXCOORD1; //The position relative to the mesh origin.
	float3 worldNormal : TEXCOORD2; //The normal in world space.
	float3 worldPosition : TEXCOORD3; //the position relative to world origin.
	float3 viewDirection : TEXCOORD4; //The direction the camera is looking at the mesh.
	float4 tangent : TEXCOORD5;//for bump mapping.
	float3 binormal : TEXCOORD6; //also for bump mapping.
	float4 extras : TEXCOORD8;
};

struct Light
{
	float brightness;
	half3 color;
};

//shading properties
float _ShadeRange;
float _ShadeSoftness;
float _ShadeMax;
float _ShadeMin;
float _ShadePivot;

//Base Layer paramters
sampler2D _MainTex;
sampler2D _MainTex_ST;
float4 _FresnelColor;
float4 _Color;
float _FresnelRetract;
float _TCut;

//Mask Layer Paramters
sampler2D _MaskTex;
sampler2D _MaskTex_ST;
float _MaskGlow;
float4 _MaskGlowColor;
float _MaskRainbow;
float _MaskGlowSpeed;
float _MaskGlowSharpness;

PIO vert ( IO vertex ){
	PIO process;
	process.uv = vertex.uv;//TRANSFORM_TEX( vertex.uv, _MainTex );
	process.normal = normalize( vertex.normal );
	process.objectPosition = vertex.position;
	process.position = UnityObjectToClipPos(vertex.position);
	//reverse the draw position for the screen back to the world position for calculating view Direction.
	process.worldPosition = mul(unity_ObjectToWorld,vertex.position);
	process.worldNormal = normalize( UnityObjectToWorldNormal( process.normal ));
	process.extras.x = vertex.id;

	half4 color;

	return process;
}

PIO adjustProcess(PIO process, uint isFrontFace)
{
	if (!isFrontFace){
		process.normal = -process.normal;
		process.worldNormal = -process.worldNormal;
	}
	//get the camera position to calculate view direction and then get the direction from the camera to the pixel.
	process.viewDirection = normalize(process.worldPosition - _WorldSpaceCameraPos);

	return process;
}

float applyToonEdge( PIO process, float brightness){
	//the attenuation should be the max amount of color value. 
	//To determine the end color value, All we need to do is determine the brightness.
	//attenuation is only meaningful for pixel lights.
#ifndef FOWARDBASE
	UNITY_LIGHT_ATTENUATION(attenuation,process,process.worldPosition);
#else
	attenuation = 1
#endif
	
	//apply faux ramp:
	if ( _ShadeSoftness > 0 ){
		brightness -= _ShadePivot;
		brightness *= 1/_ShadeSoftness;
		brightness += _ShadePivot;
	} else {
		if (brightness > _ShadePivot){
			brightness = 1;
		} else {
			brightness = 0;
		}
	}

	//apply range, min and max:
	brightness = max(_ShadeMin,brightness);
	brightness = brightness * _ShadeRange + (1 - _ShadeRange);
	brightness = min(_ShadeMax,brightness);

	brightness = saturate(brightness * attenuation);
	return brightness;
}

fixed4 applyCut( fixed4 color ){
	if (color.a <= _TCut){
		color = -1;
	}
	return color;
}

fixed4 applyFresnel( PIO process, fixed4 inColor ){
	float val = saturate(-dot(process.viewDirection, process.worldNormal));
	float rim = 1 - val * _FresnelRetract;
	rim= max(0,rim);
	rim *= _FresnelColor.a;
	float orim = 1 - rim;
	fixed4 color;
	inColor.rgb = (_FresnelColor * rim) + (inColor * orim);
	return inColor;
}

fixed4 shiftColor( fixed4 inColor, float shift )
{
	float r = shift * 0.01745329251994329576923690768489;
	float u = cos(r);
	float w = sin(r);
	fixed4 ret;
	ret.r = (.299+.701 * u+.168 * w)*inColor.r
		+ (.587-.587 * u+.330 * w)*inColor.g
		+ (.114-.114 * u-.497 * w)*inColor.b;
	ret.g = (.299-.299 * u-.328 * w)*inColor.r
		+ (.587+.413 * u+.035 * w)*inColor.g
		+ (.114-.114 * u+.292 * w)*inColor.b;
	ret.b = (.299-.3 * u+1.25 * w)*inColor.r
		+ (.587-.588 * u-1.05 * w)*inColor.g
		+ (.114+.886 * u-.203 * w)*inColor.b;	
	ret[3] = inColor[3];
	ret.a = 1;
	return ret;
}

fixed4 applyMaskLayer( PIO process, fixed4 inColor )
{
	fixed4 outColor = inColor;
	float2 uv = process.uv;
	float4 maskColor = tex2D(_MaskTex, uv);
	float alphaDifference = 1 - maskColor.a;
	float3 rainbowColor;

	if ( _MaskGlow ){
		int time = ( _Time * (_MaskGlowSpeed*1000) );
		float gp = ( time % 120 ) / 100.0f - .1;

		float igv = (gp - uv[1]);
		if (igv < 0 ) igv = 0 - igv;
		igv = igv * _MaskGlowSharpness;
		if (igv > 1 ) igv = 1;
		if (igv < 0 ) igv = 0;
		float gv = 1-igv;
		if (_MaskRainbow){
			int rt = _Time * 7000;
			_MaskGlowColor = normalize(shiftColor(half4(1,0,0,1),rt));
		}
		maskColor.rgb = (maskColor.rgb * igv) + (_MaskGlowColor.rgb * gv);
	}
	outColor.rgb = ( outColor.rgb * alphaDifference ) + (maskColor.rgb * maskColor.a);

	return outColor;
}

//keep in mind to always add lights. But multiply the sum to the final color. 
//This method applies ambient light from directional and lightprobes.
fixed4 applyLight(PIO process, fixed4 color) {
	/************************
	* Brightness / toon edge:
	************************/
	//Calculate Brightness:
	float3 ambientDirection = normalize(unity_SHAr + unity_SHAg + unity_SHAb);
	float ambientBrightness = saturate(dot(ambientDirection, process.worldNormal));
	float directionalBrightness = saturate(dot(_WorldSpaceLightPos0, process.worldNormal));
	float brightness = max(ambientBrightness, directionalBrightness);
	brightness = applyToonEdge(process, brightness);


	/************************
	* Color:
	************************/
	//get ambient color (lightprobes):
	half3 ambientColor = ShadeSH9(float4(0, 0, 0, 1));
	//get directional color:
	half3 directionalColor = _LightColor0.rgb;
	//apply to final color:
	color.rgb *= max(directionalColor + ambientColor, 0);
	//apply the brightness:
	color.rgb = max(color.rgb * brightness, 0);
	return color;
}