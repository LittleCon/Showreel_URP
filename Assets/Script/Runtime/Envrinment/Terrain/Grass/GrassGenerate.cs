using UnityEngine;
using UnityEngine.Rendering;

namespace FC.Terrain
{
    public class GrassGenerate 
    {
        //lod0的草网格
        public Mesh grassMesh=>environmentSettings.grassMesh;

        public Material grassMat=>environmentSettings.grassMat;

        public Texture grassSplatMap=>environmentSettings.grassSplatMap;

        private EnvironmentSettings environmentSettings;
        private ComputeShader grassCS;
        private int generateGrassDataKernelID;
        #region ComputeBuffer及对应数据
        /// <summary>
        /// 模型顶点色Buffer
        /// </summary>
        private ComputeBuffer vertexColorsBuffer;

        private Color[] vertexColors;

        /// <summary>
        /// 顶点位置信息Buffer
        /// </summary>
        private ComputeBuffer vertexPosBuffer;

        private Vector3 []vertexPos;

        /// <summary>
        /// 顶点索引数组
        /// </summary>
        private ComputeBuffer trainglesBuffer;

        private int[] traingles;

        /// <summary>
        /// UVBuffer
        /// </summary>
        private ComputeBuffer uvsBuffer;

        private Vector2[] uvs;

        /// <summary>
        /// 绘制数量
        /// </summary>
        private ComputeBuffer instanceBuffer;


        private ComputeBuffer grassBladeBuffer;
        private GrassBlade[] grassBlades;

        private ComputeBuffer clumpParamtersBuffer;
        private ClumpParametersStruct []clumpParametersStruct;
        #endregion
        struct GrassBlade
        {
            public Vector3 position;
            public Vector3 surfaceNorm;
            public Vector3 color;
            public Vector2 facing;
            public float windStrength;
            public float hash;
            public float height;
            public float width;
            public float tile;
            public float bend;
            public float sideCurve;
            public float rotAngle;
            public float clumpColorDistanceFade;

            public static int GetSize()
            {
                return sizeof(float) * (3 + 3 + 3 + 2 + 9);
            }
        };

        
        public GrassGenerate(EnvironmentSettings environmentSettings)
        {
            this.environmentSettings = environmentSettings;
            grassCS = environmentSettings.grassCS;
        }


        public void InitBuffer()
        {
            vertexPos = grassMesh.vertices;
            vertexPosBuffer = new ComputeBuffer(vertexPos.Length, sizeof(float) * 3);
            vertexPosBuffer.SetData(vertexPos);

            vertexColors = grassMesh.colors;
            vertexColorsBuffer = new ComputeBuffer(vertexColors.Length, sizeof(float) * 4);
            vertexColorsBuffer.SetData(vertexColors);

            traingles = grassMesh.triangles;
            trainglesBuffer = new ComputeBuffer(traingles.Length, sizeof(int));
            trainglesBuffer.SetData(traingles);

            uvs = grassMesh.uv;
            uvsBuffer = new ComputeBuffer(uvs.Length, sizeof(float) * 2);
            uvsBuffer.SetData(uvs);

            instanceBuffer = new ComputeBuffer(4, sizeof(int), ComputeBufferType.IndirectArguments);
            instanceBuffer.SetData(new int[] { trainglesBuffer.count, 1, 0, 0 });

            //grassBladeBuffer = new ComputeBuffer(environmentSettings.grassNums, GrassBlade.GetSize(),ComputeBufferType.Append);

            grassMat.SetBuffer(ShaderProperties.Grass.vertexPosBuffer, vertexPosBuffer);
            grassMat.SetBuffer(ShaderProperties.Grass.vertexColorsBuffer, vertexColorsBuffer);
            grassMat.SetBuffer(ShaderProperties.Grass.vertexIndexBuffer, trainglesBuffer);
            grassMat.SetBuffer(ShaderProperties.Grass.vertexUVsBuffer, uvsBuffer);
            grassMat.SetBuffer(ShaderProperties.Grass.grassBladeBuffer, grassBladeBuffer);

            clumpParametersStruct = environmentSettings.clumpParametersStructs.ToArray();
            clumpParamtersBuffer = new ComputeBuffer(clumpParamtersBuffer.count, ClumpParametersStruct.GetSize());
            clumpParamtersBuffer.SetData(clumpParametersStruct);
            generateGrassDataKernelID = grassCS.FindKernel("GenerateGrassData");
        }

        private void DrawGrass(CommandBuffer cmd,ComputeBuffer patchBuffer)
        {

            cmd.SetComputeBufferParam(grassCS, generateGrassDataKernelID, ShaderProperties.GPUTerrain.consumeListID, patchBuffer);
            cmd.SetComputeBufferParam(grassCS, generateGrassDataKernelID, ShaderProperties.Grass.grassBladeBuffer, grassBladeBuffer);
            cmd.SetComputeBufferParam(grassCS, generateGrassDataKernelID, ShaderProperties.Grass.clumpParametersID, clumpParamtersBuffer);
            cmd.SetComputeIntParam(grassCS,  ShaderProperties.Grass.patchGrassNumsID, environmentSettings.perPatchGrassNums);
            cmd.SetComputeFloatParam(grassCS, ShaderProperties.Grass.jitterStrengthID, environmentSettings.jitterStrength);
            cmd.SetComputeFloatParam(grassCS, ShaderProperties.Grass.clumpScaleID, environmentSettings.clumpScale);
            Graphics.DrawProceduralIndirect(grassMat, new Bounds(Vector3.zero, Vector3.one * 100), MeshTopology.Triangles, instanceBuffer);
        }

        public void Dispose()
        {
            vertexColorsBuffer.Dispose();
            vertexPosBuffer.Dispose();
            uvsBuffer.Dispose();
            trainglesBuffer.Dispose();
            instanceBuffer.Dispose();
            grassBladeBuffer.Dispose();
        }
    }
}
