Shader "Hojo/Environment/DeferredWater"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_WaterNormalTexture ("WaterNormalTexture", 2D) = "white" {}
		_WaterNormalTexture2 ("WaterNormalTexture2", 2D) = "white" {}
		_WaterNormalTexture_Flow("WaterNormal Flow(UV/sec) xy:1 zw:2", Vector) = (0.1,0.1,0.1,0.1)
		_AlbedoAlpha ("Albedo Alpha", Range(0,1)) = 0.1
		_MetalicSmoothNessAlpha ("Metalic Smoothness Alpha", Range(0,1)) = 0.1
		_NormalAlpha ("Normal Alpha", Range(0,1)) = 0.1
		_EmissionAlpha ("Emission Alpha", Range(0,1)) = 0.1
		_NormalScale ("Normal Scale", Range(1,500)) = 10
	}
	SubShader
	{
		Pass
		{
		Name "DEFERRED"
		// No culling or depth
		Tags { "LightMode" = "Deferred"}
		Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma exclude_renderers nomrt
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#pragma multi_compile_prepassfinal noshadow
			#include "HLSLSupport.cginc"
			#include "UnityShaderVariables.cginc"
			#include "AutoLight.cginc"
			#include "UnityShaderUtilities.cginc"
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			#include "UnityDeferredLibrary.cginc"
			#include "HojoCharacterShaderLibrary.cginc"

			#define UNITY_PASS_DEFERRED

			struct v2f_surf {
			  UNITY_POSITION(pos);
			  float2 pack0 : TEXCOORD0;
			  half3 worldNormal : TEXCOORD1;
			  float4 tangentToWorldAndPackedData[3] : TEXCOORD2;
			};

			v2f_surf vert (appdata_full v)
			{
				v2f_surf o;
			 	UNITY_INITIALIZE_OUTPUT(v2f_surf,o);
				o.pos = UnityObjectToClipPos(v.vertex);
				#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
				#else
				float scale = 1.0;
				#endif

				o.pack0 = v.texcoord;
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				//節約、wにworldPosを入れてる
				o.tangentToWorldAndPackedData[0].w = worldPos.x;
	            o.tangentToWorldAndPackedData[1].w = worldPos.y;
	            o.tangentToWorldAndPackedData[2].w = worldPos.z;

	            float4 tangentWorld = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
		        float3x3 tangentToWorld = Hojo_CreateTangentToWorldPerVertex(o.worldNormal, tangentWorld.xyz, tangentWorld.w);

	            //tangent　X軸
	   		 	//binormal Y軸
	    		//normal Z軸という感じ
	    		//最終的にこれら値を使って法線マップのローカルな方向定義をワールド空間での正式な方向に変える
		        o.tangentToWorldAndPackedData[0].xyz = tangentToWorld[0];
		        o.tangentToWorldAndPackedData[1].xyz = tangentToWorld[1];
		        o.tangentToWorldAndPackedData[2].xyz = tangentToWorld[2];
				return o;
			}

			sampler2D _WaterNormalTexture;
			sampler2D _WaterNormalTexture2;
			float4 _WaterNormalTexture_Flow;

	        float _AlbedoAlpha;
	        float _MetalicSmoothNessAlpha;
	        float _NormalAlpha;
	        float _EmissionAlpha;
	        float _NormalScale;

			void frag (v2f_surf i,
			out float4 outGBuffer0 : COLOR0,
    		out float4 outGBuffer1 : COLOR1,
    		out float4 outGBuffer2 : COLOR2,
    		out float4 outGBuffer3 : COLOR3)
			{

			  #ifdef UNITY_COMPILER_HLSLS
			  SurfaceOutputStandard o = (SurfaceOutputStandard)0;
			  #else
			  SurfaceOutputStandard o;
			  #endif
			  float3 worldPos = float3(
			  i.tangentToWorldAndPackedData[0].w,
			  i.tangentToWorldAndPackedData[1].w,
			  i.tangentToWorldAndPackedData[2].w);
			  fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));

			  //基本パラメータ
			  o.Albedo = _Color;
			  o.Emission = 0;
			  o.Alpha = 1.0;
			  o.Occlusion = 1.0;
			  o.Smoothness = 1.0;
			  o.Metallic = 0.0;
			  float3 perPixelWorldNormal = Hojo_PerPixelWorldNormalByTwinTexture(_WaterNormalTexture,(_WaterNormalTexture_Flow.xy * _Time.y) +(i.pack0 * _NormalScale),_WaterNormalTexture2, (_WaterNormalTexture_Flow.zw * _Time.y) +(i.pack0 * _NormalScale),i.tangentToWorldAndPackedData);
			  perPixelWorldNormal = (perPixelWorldNormal + 1) / 2;//UnityStandardDataToGbufferを使わない為ここで手動で適切な基準(0.5が中心==0）になるように調整
			  o.Normal = perPixelWorldNormal;
			  //////////////////////////////////////////


			  half oneMinusReflectivity;
		      half3 specColor;
		      o.Albedo = DiffuseAndSpecularFromMetallic (o.Albedo, o.Metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);

			  UnityGI gi;
			  UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
    		  half4 c = UNITY_BRDF_PBS (o.Albedo, specColor, oneMinusReflectivity, o.Smoothness, o.Normal, worldViewDir, gi.light, gi.indirect);

			  outGBuffer0 = float4(o.Albedo,_AlbedoAlpha);
			  outGBuffer1 = half4(specColor, _MetalicSmoothNessAlpha) ;
			  outGBuffer2 = half4(o.Normal, _NormalAlpha );

			  o.Emission = c.rgb;
			  #ifndef UNITY_HDR_ON
			  o.Emission.rgb = exp2(o.Emission );
			  #endif

			  outGBuffer3 = float4(o.Emission,_EmissionAlpha);
			}
			ENDCG
		}

	}
}
