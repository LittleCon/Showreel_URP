using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

public class ShaderCreator : Editor
{
    //Shader模板路径
    public static string shaderTemplatePath = "Assets/Shader/Editor/Template/FCShaderTemplate.txt";
    public static string shaderInputPath = "Assets/Shader/Editor/Template/FCShaderInput.txt";
    public static string shaderPassPath = "Assets/Shader/Editor/Template/FCShaderPass.txt";
    [MenuItem("Assets/Create/Shader/Create FCShader")]
    public static void CreateShader()
    {
        string currentPath = AssetDatabase.GetAssetPath(Selection.activeObject);
        string savePath = EditorUtility.SaveFilePanelInProject(
            "Create New Shader", 
            "NewShader", 
            "shader", 
            "Specify the name and location for the new Shader.",currentPath);
        string basePath = Path.GetDirectoryName(savePath);
        string baseFileName = Path.GetFileNameWithoutExtension(savePath);
        if (!string.IsNullOrEmpty(savePath))
        {
            // 读取模板内容
            string templateShaderContent = File.ReadAllText(shaderTemplatePath);
            string templateShaderInputContent = File.ReadAllText(shaderInputPath);
            string templateShaderPassContent = File.ReadAllText(shaderPassPath);
            
            // 写入到新文件
            templateShaderContent = templateShaderContent.Replace("#FILENAME#", baseFileName);
            File.WriteAllText(savePath, templateShaderContent);
            templateShaderInputContent = templateShaderInputContent.Replace("#FILENAME#", baseFileName);
            File.WriteAllText(Path.Combine(basePath,$"{baseFileName}Input.hlsl"), templateShaderInputContent);
            templateShaderPassContent = templateShaderPassContent.Replace("#FILENAME#", baseFileName);
            File.WriteAllText(Path.Combine(basePath,$"{baseFileName}Pass.hlsl"), templateShaderPassContent);
            // 刷新项目窗口
            AssetDatabase.Refresh();
            // 选中新创建的文件
            Selection.activeObject = AssetDatabase.LoadAssetAtPath<Shader>(savePath);
        }
    }
}
