#ifndef TERRAIN_LIT
#define TERRAIN_LIT

Varyings vert(Attributes input)
{
    Varyings output;
    uint instanceID = input.instanceID;
    //将resultPatchMap中的数据读取出来
    uint y = instanceID * 2 / 512;
    uint x = instanceID * 2 - y * 512;
    float2 uv0 = (1.0 / 512) * (uint2(x, y) + 0.5);
    float2 uv1 = (1.0 / 512) * (uint2 (x + 1, y) + 0.5);

    float4 pix0 = SAMPLE_TEXTURE2D_LOD(_ResultPatchMap, sampler_ResultPatchMap, uv0, 0);
    float4 pix1 = SAMPLE_TEXTURE2D_LOD(_ResultPatchMap, sampler_ResultPatchMap, uv1, 0);

    BaseData baseData = GenerateBaseData(_GlobalValues);
    float3 vexWorldPos = CalTerrainVertexPos(baseData, input.positionOS, pix0, pix1);
    float2 terrainUV = vexWorldPos.xz / baseData.worldSize + 0.5;
    float terrainHeight = SAMPLE_TEXTURE2D_LOD(_HeightMap, sampler_HeightMap, terrainUV, 0);
    vexWorldPos.y = (terrainHeight - 0.5) * 2 * baseData.worldHeightScale;
    input.positionOS.xyz = vexWorldPos;


    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    output.positionCS = vertexInput.positionCS;
    output.uv = TRANSFORM_TEX(terrainUV, _BaseMap);
    output.normalUV = terrainUV;
    output.positionWS = vertexInput.positionWS;
    output.viewDirWS = GetWorldSpaceViewDir(output.positionWS);
    return output;
}


float4 frag(Varyings input) : SV_Target
{
    // sample the texture
    //float4 col = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap,input.uv);
    //float4 normal = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap,input.normalUV);
    //float4 splatMask= SAMPLE_TEXTURE2D(_SplatMap, sampler_SplatMap,input.normalUV);
    //normal = 2.0 * normal - 1.0;
    //Light lightData=GetMainLight();
    //

    //float3 diffuseColor =lightData.color*(max(0,dot( lightData.direction,normal))*0.5+0.5)*col.xyz;
    //float3 viewDir = normalize(_WorldSpaceCameraPos.xyz-input.positionWS);

    //float halfDir = normalize(lightData.direction+viewDir);

    //float3 specularColor = 0;//lightData.color* pow(saturate(dot(normal , halfDir)),1000);
    //float4 finalColor = float4(diffuseColor+specularColor,1);
    //return finalColor;

    //1024认为是albedo贴图的尺寸
    float2 texUV = input.normalUV * 1024 / 30 * 3;
    float texSize = _AlphaMapSize.x;//高度图的宽度
    float texNei = _AlphaMapSize.y;//高度图宽度分之一

    //转化为纹理坐标
    float2 orignUV = input.normalUV * texSize;
    int2 uvInt1 = floor(orignUV);

    //构建采样三角形
    int2 uvInt2 = uvInt1 + uint2(0, 1);
    if (orignUV.x - uvInt1.x > orignUV.y - uvInt1.y) {
        uvInt2 = uvInt1 + uint2(1, 0);
    }

    uint2 uvInt3 = uvInt1 + uint2(1, 1);
    // _BlendTexArray.Load(int3(uvInt1, 0)).r相当于纹理采样返回float类型数据
    //由于blenderTex中我们只存储了16位数据（且是低16位）而float是32数据，因此我们通过将其结果呈上0xFFFF来获取低16位信息
    uint blendData1 = _BlendTexArray.Load(uint3(uvInt1, 0)).r * 0xFFFF;
    uint blendData2 = _BlendTexArray.Load(uint3(uvInt2, 0)).r * 0xFFFF;
    uint blendData3 = _BlendTexArray.Load(uint3(uvInt3, 0)).r * 0xFFFF;

    int and5 = (1 << 5) - 1;
    //blend.x存储权重大的材质索引，y存储权重低的材质索引
    int2 blend1 = int2(blendData1 >> 11, (blendData1 >> 6) & and5);
    int2 blend2 = int2(blendData2 >> 11, (blendData2 >> 6) & and5);
    int2 blend3 = int2(blendData3 >> 11, (blendData3 >> 6) & and5);
    float2 uv1 = uvInt1 * texNei;//将其重新映射回uv坐标
    float2 uv2 = uvInt2 * texNei;//将其重新映射回uv坐标
    float2 uv3 = uvInt3 * texNei;//将其重新映射回uv坐标
    //重心差值计算当前像素权重
    float w3 = ((uv1.y - uv2.y) * input.uv.x + (uv2.x - uv1.x) * input.uv.y + uv1.x * uv2.y - uv2.x * uv1.y) / ((uv1.y - uv2.y) * uv3.x + (uv2.x - uv1.x) * uv3.y + uv1.x * uv2.y - uv2.x * uv1.y);
    float w2 = ((uv1.y - uv3.y) * input.uv.x + (uv3.x - uv1.x) * input.uv.y + uv1.x * uv3.y - uv3.x * uv1.y) / ((uv1.y - uv3.y) * uv2.x + (uv3.x - uv1.x) * uv2.y + uv1.x * uv3.y - uv3.x * uv1.y);
    float w1 = 1 - w2 - w3;

    //获得三角形三个顶点所在像素的权重信息
    int and6 = (1 << 6) - 1;
    float inv64 = 0.015625;//1/64
    float diff1 = ((blendData1 & and6) + 1) * inv64;
    float2 weight1 = float2(0.5 * (1 + diff1), 0.5 * (1 - diff1)) * w1;
    float diff2 = ((blendData2 & and6) + 1) * inv64;
    float2 weight2 = float2(0.5 * (1 + diff2), 0.5 * (1 - diff2)) * w2;
    float diff3 = ((blendData3 & and6) + 1) * inv64;
    float2 weight3 = float2(0.5 * (1 + diff3), 0.5 * (1 - diff3)) * w3;


    float2 m[8];
    int i, j;
    for (i = 0; i < 8; i++)
        m[i] = float2(i, 0);
#if _HeightBlend
                float dis = distance(input.positionWS, _WorldSpaceCameraPos);
                float blendA = saturate((_HeightBlendEnd - dis) / _HeightBlendEnd);
                //return blendA;
                float height0, height1, bf1, bf2, bf12;
                if (blend1.x != blend1.y)
                {
                    height0 = SAMPLE_TEXTURE2D_ARRAY(_MinMaxHeightMap, sampler_MinMaxHeightMap, texUV, blend1.x).a;//此处应该使用alpha8的HeightMap,测试暂用AlbedoArray
                    height1 = SAMPLE_TEXTURE2D_ARRAY(_MinMaxHeightMap, sampler_MinMaxHeightMap, texUV, blend1.y).a;//此处应该使用alpha8的HeightMap,测试暂用AlbedoArray
                    bf1 = saturate((blendA * (height0 - height1) + (weight1.x - 0.5) * _BlendScaleArrayShader[blend1.x]) * _BlendSharpnessArrayShader[blend1.x] + 0.5);
                    bf2 = saturate((blendA * (height1 - height0) + (weight1.y - 0.5) * _BlendScaleArrayShader[blend1.y]) * _BlendSharpnessArrayShader[blend1.y] + 0.5);
                    bf12 = max(bf1 + bf2, 0.001); bf1 /= bf12; bf2 /= bf12;
                    weight1.x *= bf1;
                    weight1.y *= bf2;
                }

                if (blend2.x != blend2.y)
                {
                    height0 = SAMPLE_TEXTURE2D_ARRAY(_MinMaxHeightMap, sampler_MinMaxHeightMap, texUV, blend2.x).a;//此处应该使用alpha8的HeightMap,测试暂用AlbedoArray
                    height1 = SAMPLE_TEXTURE2D_ARRAY(_MinMaxHeightMap, sampler_MinMaxHeightMap, texUV, blend2.y).a;//此处应该使用alpha8的HeightMap,测试暂用AlbedoArray
                    bf1 = saturate((blendA * (height0 - height1) + (weight2.x - 0.5) * _BlendScaleArrayShader[blend2.x]) * _BlendSharpnessArrayShader[blend2.x] + 0.5);
                    bf2 = saturate((blendA * (height1 - height0) + (weight2.y - 0.5) * _BlendScaleArrayShader[blend2.y]) * _BlendSharpnessArrayShader[blend2.y] + 0.5);
                    bf12 = max(bf1 + bf2, 0.001); bf1 /= bf12; bf2 /= bf12;
                    weight2.x *= bf1;
                    weight2.y *= bf2;
                }

                if (blend3.x != blend3.y)
                {
                    height0 = SAMPLE_TEXTURE2D_ARRAY(_MinMaxHeightMap, sampler_MinMaxHeightMap, texUV, blend3.x).a;//此处应该使用alpha8的HeightMap,测试暂用AlbedoArray
                    height1 = SAMPLE_TEXTURE2D_ARRAY(_MinMaxHeightMap, sampler_MinMaxHeightMap, texUV, blend3.y).a;//此处应该使用alpha8的HeightMap,测试暂用AlbedoArray
                    bf1 = saturate((blendA * (height0 - height1) + (weight3.x - 0.5) * _BlendScaleArrayShader[blend3.x]) * _BlendSharpnessArrayShader[blend3.x] + 0.5);
                    bf2 = saturate((blendA * (height1 - height0) + (weight3.y - 0.5) * _BlendScaleArrayShader[blend3.y]) * _BlendSharpnessArrayShader[blend3.y] + 0.5);
                    bf12 = max(bf1 + bf2, 0.001); bf1 /= bf12; bf2 /= bf12;
                    weight3.x *= bf1;
                    weight3.y *= bf2;
                }
#endif
                m[blend1.x].y += weight1.x;
                m[blend1.y].y += weight1.y;
                m[blend2.x].y += weight2.x;
                m[blend2.y].y += weight2.y;
                m[blend3.x].y += weight3.x;
                m[blend3.y].y += weight3.y;


                float2 temp;
                for (j = 0; j < 3; j++)
                {
                    for (i = 0; i < 7 - j; i++)
                    {
                        if (m[i].y > m[i + 1].y)
                        {
                            temp = m[i + 1];
                            m[i + 1] = m[i];
                            m[i] = temp;
                        }
                    }
                }
                int index1 = round(m[7].x);
                int index2 = round(m[6].x);
                int index3 = round(m[5].x);

                half4 albedo1 = SAMPLE_TEXTURE2D_ARRAY(_AlbedoTexArray, sampler_AlbedoTexArray, texUV, index1);
                half4 albedo2 = SAMPLE_TEXTURE2D_ARRAY(_AlbedoTexArray, sampler_AlbedoTexArray, texUV, index2);
                half4 albedo3 = SAMPLE_TEXTURE2D_ARRAY(_AlbedoTexArray, sampler_AlbedoTexArray, texUV, index3);
                //float aveHeight = (albedo1.a + albedo2.a + albedo3.a) * 0.333333;

                //w1 = saturate((_BlendA[index1] * (albedo1.a - aveHeight) + (m[7].y - 0.5) * _BlendScaleArrayShader[index1]) * _BlendSharpnessArrayShader[index1] + 0.5);
                //w2 = saturate((_BlendA[index2] * (albedo2.a - aveHeight) + (m[6].y - 0.5) * _BlendScaleArrayShader[index2]) * _BlendSharpnessArrayShader[index2] + 0.5);
                //w3 = saturate((_BlendA[index3] * (albedo3.a - aveHeight) + (m[5].y - 0.5) * _BlendScaleArrayShader[index3]) * _BlendSharpnessArrayShader[index3] + 0.5);
                w1 = m[7].y;
                w2 = m[6].y;
                w3 = m[5].y;
                float tt = 1.0 / (w1 + w2 + w3);
                w1 *= tt; w2 *= tt; w3 *= tt;
                half3 albedo = albedo1.rgb * w1 + albedo2.rgb * w2 + albedo3 * w3;
                half3 normal1 = SAMPLE_TEXTURE2D_ARRAY(_NormalTexArray, sampler_NormalTexArray, texUV, index1);
                half3 normal2 = SAMPLE_TEXTURE2D_ARRAY(_NormalTexArray, sampler_NormalTexArray, texUV, index2);
                half3 normal3 = SAMPLE_TEXTURE2D_ARRAY(_NormalTexArray, sampler_NormalTexArray, texUV, index3);
                half3 normal = normal1.rgb * w1 + normal2.rgb * w2 + normal3 * w3;

                normal.xy = normal.xy * 2 - 1;
                normal.z = sqrt(1.0 - saturate(dot(normal.xy, normal.xy)));
                normal = normalize(normal);

                BRDFData brdfData;
                half alpha = 1;
                InitializeBRDFData(albedo, 0, half3(0, 0, 0), 0, alpha, brdfData);
                half4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
                Light mainLight = GetMainLight(shadowCoord, input.positionWS, 0);

                BRDFData brdfDataClearCoat = (BRDFData)0;
                half3 color = LightingPhysicallyBased(brdfData, brdfDataClearCoat,
                    mainLight,
                    normal.xzy, input.viewDirWS,
                    0, false);
                return  half4(color, 1);

}
#endif