Shader "Skuld/Toon Opaque"
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
		_FresnelColor("Fresnel Color", Color)=(1, 1, 1, 1)
		_FresnelRetract("Fresnel Retract", Range(0,10)) = 0.5

		[space]
		_MaskTex("Mask Layer", 2D) = "black" {}
		[Toggle] _MaskGlow("Mask Glow", Float) = 0
		_MaskGlowColor("Glow Color", Color)=(1, 1, 1, 1)
		[Toggle] _MaskRainbow("Rainbow Effect", Float) = 0
		_MaskGlowSpeed("Glow Speed",Range(0,10)) = 1
		_MaskGlowSharpness("Glow Sharpness",Range(1,200)) = 1.0
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
			#pragma fragment frag
			#pragma multi_compile

			#define MODE_OPAQUE

			#include "Toon.Globals.cginc"
			#include "Toon.FowardBase.cginc"

			ENDCG
		}
		Pass {
			Tags { "LightMode" = "ForwardAdd"}
			Blend One One

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
			#include "Toon.FowardAdd.cginc"

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