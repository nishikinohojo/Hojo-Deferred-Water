 #include "UnityCG.cginc"
 #include "Tessellation.cginc"
 #include "UnityStandardCore.cginc"

//-------------------------------------------------------------------------------------
//Tessellation

#ifdef UNITY_CAN_COMPILE_TESSELLATION

struct InternalTessInterp_appdata {
  float4 vertex : INTERNALTESSPOS;
  float3 normal : NORMAL;
  float4 tangent : TANGENT;
  float4 texcoord : TEXCOORD0;
};

inline appdata_full phongTessellationForAppData_Full(const OutputPatch<InternalTessInterp_appdata,3> vi, float3 bary, float _Phong){
 	appdata_full v;
 	v.tangent = vi[0].tangent*bary.x + vi[1].tangent*bary.y + vi[2].tangent*bary.z;
	v.vertex = vi[0].vertex*bary.x + vi[1].vertex*bary.y + vi[2].vertex*bary.z;
	float3 pp[3];
	for (int i = 0; i < 3; ++i)
	  pp[i] = v.vertex.xyz - vi[i].normal * (dot(v.vertex.xyz, vi[i].normal) - dot(vi[i].vertex.xyz, vi[i].normal));
	v.vertex.xyz = _Phong * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-_Phong) * v.vertex.xyz;
	v.normal = vi[0].normal*bary.x + vi[1].normal*bary.y + vi[2].normal*bary.z;
	v.texcoord = vi[0].texcoord*bary.x + vi[1].texcoord*bary.y + vi[2].texcoord*bary.z;
	return v;
 }



 #endif

 //-------------------------------------------------------------------------------------
 //NormalMap

 //接空間上の法線は正式なノーマルマップであればそれをアンパックするだけで求まる
 half3 Hojo_NormalInTangentSpace(sampler2D _BumpMap,float2 uv)
{
    half3 normalTangent = UnpackNormal(tex2D (_BumpMap, uv.xy));
    return normalTangent;
}

half3x3 Hojo_CreateTangentToWorldPerVertex(half3 normal, half3 tangent, half tangentSign)
{
    half sign = tangentSign * unity_WorldTransformParams.w;
    half3 binormal = cross(normal, tangent) * sign;
    return half3x3(tangent, binormal, normal);
}


float3 Hojo_PerPixelWorldNormal(sampler2D _BumpMap,float2 uv, float4 tangentToWorld[3])
{
	    half3 tangent = tangentToWorld[0].xyz;
	    half3 binormal = tangentToWorld[1].xyz;
	    half3 normal = tangentToWorld[2].xyz;

	    float3 normalTangent = Hojo_NormalInTangentSpace(_BumpMap,uv);
	    float3 normalWorld = NormalizePerPixelNormal(tangent * normalTangent.x + binormal * normalTangent.y + normal * normalTangent.z);
	    return normalWorld;
}

float3 Hojo_PerPixelWorldNormalByTwinTexture(sampler2D _BumpMap,float2 uv,sampler2D _BumpMap2,float2 uv2, float4 tangentToWorld[3])
{
	    half3 tangent = tangentToWorld[0].xyz;
	    half3 binormal = tangentToWorld[1].xyz;
	    half3 normal = tangentToWorld[2].xyz;

	    float3 normalTangent = (Hojo_NormalInTangentSpace(_BumpMap,uv) + Hojo_NormalInTangentSpace(_BumpMap2,uv2))/2;
	    float3 normalWorld = NormalizePerPixelNormal(tangent * normalTangent.x + binormal * normalTangent.y + normal * normalTangent.z);
	    return normalWorld;
}