using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
using UnityEngine;
using static UnityEngine.Mesh;

namespace FC.Terrain
{
    public class GrassGenerate : MonoBehaviour
    {
        //lod0的草网格
        public Mesh grassMesh;

        public Material grassMat;

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

        
        private void Start()
        {
            TestData();
            InitBuffer();
        }

        private void TestData()
        {
            grassBlades = new GrassBlade[1];
            var grassBlade = new GrassBlade() { position=Vector3.zero,windStrength=1,hash=0.25f,height=0.8f,width=0.05f,tile=0.95f,bend=0.4f};
            grassBlades[0] = grassBlade;
            
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

            grassBladeBuffer = new ComputeBuffer(grassBlades.Length, GrassBlade.GetSize());
            grassBladeBuffer.SetData(grassBlades);

            grassMat.SetBuffer(ShaderProperties.Grass.vertexPosBuffer, vertexPosBuffer);
            grassMat.SetBuffer(ShaderProperties.Grass.vertexColorsBuffer, vertexColorsBuffer);
            grassMat.SetBuffer(ShaderProperties.Grass.vertexIndexBuffer, trainglesBuffer);
            grassMat.SetBuffer(ShaderProperties.Grass.vertexUVsBuffer, uvsBuffer);
            grassMat.SetBuffer(ShaderProperties.Grass.grassBladeBuffer, grassBladeBuffer);
        }

        private void Update()
        {
            Graphics.DrawProceduralIndirect(grassMat, new Bounds(Vector3.zero, Vector3.one * 100), MeshTopology.Triangles, instanceBuffer);
        }

        private void OnDestroy()
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
