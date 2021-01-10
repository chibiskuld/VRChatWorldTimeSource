Shader "Skuld/Time Source/Unlit Clock"
{
	Properties {
		[space]
		_ShadeRange("Shade Range",Range(0,1)) = 1.0
		_ShadeSoftness("Edge Softness", Range(0,1)) = 0
		_ShadePivot("Center",Range(0,1)) = .5
		_ShadeMax("Max Brightness", Range(0,1)) = 1.0
		_ShadeMin("Min Brightness",Range(0,1)) = 0.0

		[space]
		[Enum(UnityEngine.Rendering.CullMode)] _CullMode("Cull Mode", Float) = 2                     // "Back"
		[Toggle] _ZWrite("Z-Write",Float) = 1

		[space]
		_MainTex("Base Layer", 2D) = "white" {}
		_Color("Base Color",Color) = (1,1,1,1)
		_HandTex("Hand", 2D) = "white" {}
		_HandColor("Second Hand Color",color) = (1,0,0,0)
		_HandWidth("Second Hand Size",Float) = .01
		_HandOffset("Hand Offset",Vector) = (0,0,0,0)
		_MinuteHandSize("Minute Hand Size",Float) = .5
		_HourHandSize("Hour Hand Size",Float) = .5
	}

	SubShader {
		Tags { "RenderType"="Opaque" "Queue"="Geometry+1"}

        Cull[_CullMode]
		Lighting Off
		SeparateSpecular Off
		ZWrite [_ZWrite]
		Pass {
			Tags { "LightMode" = "ForwardBase"}
			CGPROGRAM
			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"
			#include "AutoLight.cginc"
			#include "UnityPBSLighting.cginc"
			
			#pragma target 3.5
			#pragma vertex vert
			#pragma fragment frag_clock
			#pragma multi_compile _ VERTEXLIGHT_ON

			#define MODE_OPAQUE

			#include "Toon.Globals.cginc"
			#include "../VRChatTimeSource.cginc"
			#include "Unlit.clock.cginc"

			ENDCG
		}
		
		Pass {
			Tags { "LightMode" = "ShadowCaster"}

			CGPROGRAM
			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"
			#include "AutoLight.cginc"
			#include "UnityPBSLighting.cginc"
			
			#pragma target 5.0
			
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma multi_compile_fwdadd_fullshadows

			#define MODE_OPAQUE

			#include "Toon.Globals.cginc"
			#include "Toon.shadows.cginc"

			ENDCG
		}
	} 
	//FallBack "Diffuse"
}