#pragma once
sampler2D _VRChat_EnterWorldTime;
float4 _VRChat_EnterWorldTime_TexelSize;

//Returns time available in 24hr time.
//If the world prefab is available, then system time is shown. 
//If not, the fall back is time present in the world.
//Output = (hours, minutes, seconds);
//The output is in float format, for special animation purpose (See the clock example), feel free to cast it to an int or floor it if you need a whole number.
float3 GetTime() {
	float3 retVal;
	float time = _Time.y;
	if ( _VRChat_EnterWorldTime_TexelSize.z != 0 ) {
		float4 enterTime = tex2D(_VRChat_EnterWorldTime, float2(.5f, .5f));
		if (enterTime.a == 1) {
			enterTime.rgb = LinearToGammaSpace(enterTime.rgb);
			enterTime.r *= 24.0f;
			enterTime.g *= 60.0f;
			enterTime.b *= 60.0f;
			time += enterTime.r*3600.0f + enterTime.g * 60.0f + enterTime.b;
		}
	}
	retVal.r = (time / 3600) % 24;
	retVal.g = (time / 60) % 60;
	retVal.b = time % 60;
	return retVal;
}