#ifndef QC_MATH_INCLUDE
#define QC_MATH_INCLUDE

//重映射(对应ShaderGraph中Remap节点)
float4 Remap(float4 value,float2 inMinMax,float2 outMinMax)
{
    return outMinMax.x+(value-inMinMax.x)*(outMinMax.y-outMinMax.x)/(inMinMax.y-inMinMax.x);
}

#endif