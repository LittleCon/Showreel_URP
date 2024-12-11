#ifndef QC_SURFACE_DATA_INCLUDED
#define QC_SURFACE_DATA_INCLUDED

// Must match Universal ShaderGraph master node
struct SurfaceData
{
    half3 albedo;
    half3 normalTS;
    half3 emission;
    half  roughness;
    half  smoothness;
    half  metallic;
    half  occlusion;
    half  alpha;
};

#endif
