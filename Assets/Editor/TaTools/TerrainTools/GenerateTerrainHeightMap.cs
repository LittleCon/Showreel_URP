using FC.Terrain;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using static UnityEditor.Rendering.CameraUI;

namespace FC.TerrainTools 
{
    public class GenerateTerrainHeightMap : EditorWindow
    {
        public TerrainData terrainData;
        public EnvironmentSettings environmentSettings;
        private string fileName;
        private Vector2Int heightMapSize=new Vector2Int(1024,1024);
        private int mipmapLevel;

        [MenuItem("TATools/TerrainTools/BuildMinMaxHeightMap")]
        public static void CreateEditorWindow()
        {
            EditorWindow.GetWindow(typeof(GenerateTerrainHeightMap));
        }


        public void OnGUI()
        {
            EditorGUILayout.BeginVertical();
            terrainData = EditorGUILayout.ObjectField(new GUIContent("地形数据"), terrainData, typeof(TerrainData), true) as TerrainData;
            fileName = EditorGUILayout.TextField(new GUIContent("输出高度图名称", "路径：Assets/TerrainSource"), fileName);
            heightMapSize = EditorGUILayout.Vector2IntField(new GUIContent("输出MinMaxHeighMap mip0的分辨率"), heightMapSize);
            mipmapLevel = EditorGUILayout.IntField(new GUIContent("输出的mip层数"), mipmapLevel);
            if (GUILayout.Button("生成"))
            {
                BuildMinMaxMap();
            }
            EditorGUILayout.EndVertical();

            EditorGUILayout.BeginVertical();
            environmentSettings = EditorGUILayout.ObjectField(new GUIContent("地形数据"), terrainData, typeof(EnvironmentSettings), true) as EnvironmentSettings;
            if (GUILayout.Button("生成"))
            {
                CreateBlendTex();
            }
            EditorGUILayout.EndVertical();
        }


        private void CreateBlendTex()
        {
            if (environmentSettings == null) return;

        }

        RenderTexture outputRT;

        private void BuildMinMaxMap()
        {
            var terrainTexSize = new Vector2Int(terrainData.heightmapResolution, terrainData.heightmapResolution);
            Texture2D texture2D = new Texture2D(terrainTexSize.x, terrainTexSize.y, TextureFormat.RG32, false);
            RenderTexture.active = terrainData.heightmapTexture;
            texture2D.ReadPixels(new Rect(0, 0, terrainTexSize.x, terrainTexSize.y), 0, 0);
            texture2D.Apply();
            RenderTexture.active = null;
            byte[] pngData = texture2D.EncodeToPNG();
            System.IO.File.WriteAllBytes("Assets/Textures/Environment/savedTexture.png", pngData);
        }
    }

}