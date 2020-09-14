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

	//default to time being time since world load.
	float time = _Time.y;

	//attempt to get time from global render texture.
	if ( _VRChat_EnterWorldTime_TexelSize.z != 0 ) {
		float4 enterTime = tex2D(_VRChat_EnterWorldTime, float2(.5f, .5f));
		if (enterTime.a == 1) {
#if UNITY_COLORSPACE_GAMMA
			enterTime.rgb = enterTime.rgb;
#else
			enterTime.rgb = LinearToGammaSpace(enterTime.rgb);
#endif
			int h = round(enterTime.r * 24.0f);
			int m = round(enterTime.g * 60.0f);
			int s = round(enterTime.b * 60.0f);
			time += h * 3600;
			time += m * 60;
			time += s;
		}
	}
	
	//attempt to get time from time encoded light.
	for (int i = 0; i < 4; i++)
	{
		if (unity_LightColor[i].w == 795)
		{
			float4 p;
			int h = round(unity_4LightPosX0[i]);
			int m = round(unity_4LightPosY0[i]);
			int s = round(unity_4LightPosZ0[i]);
			time += h * 3600;
			time += m * 60;
			time += s;
			break;
		}
	}

	retVal.r = (time / 3600.0f) % 24.0f;
	retVal.g = (time / 60.0f) % 60.0f;
	retVal.b = time % 60.0f;
	return retVal;
}