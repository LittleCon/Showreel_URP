using Unity.Mathematics;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

[ExecuteAlways]
public class PlaneReflectionV2 : MonoBehaviour
{
    public float ClipOffset;


    private Camera m_reflectionCamera;
    private RenderTexture m_reflectionTexture;

    private int m_reflectionRTID = Shader.PropertyToID("_ReflectionRT");

    private void OnEnable()
    {
        RenderPipelineManager.beginCameraRendering += ExecutePlanarReflections;
    }

    private void OnDisable()
    {
        Cleanup();
    }

    private void Cleanup()
    {
        RenderPipelineManager.beginCameraRendering -= ExecutePlanarReflections;

        if (m_reflectionCamera)
        {
            m_reflectionCamera.targetTexture = null;
            SafeDestroy(m_reflectionCamera.gameObject);
        }
        if (m_reflectionTexture)
        {
            RenderTexture.ReleaseTemporary(m_reflectionTexture);
        }
    }
    private int2 ReflectionResolution(Camera cam, float scale)
    {
        var x = (int)(cam.pixelWidth * scale * 0.33);
        var y = (int)(cam.pixelHeight * scale * 0.33);
        return new int2(x, y);
    }
    private void PlanarReflectionTexture(Camera cam)
    {
        if (m_reflectionTexture == null)
        {
            var res = ReflectionResolution(cam, UniversalRenderPipeline.asset.renderScale);
            const bool useHdr10 = true;
            const RenderTextureFormat hdrFormat = useHdr10 ? RenderTextureFormat.RGB111110Float : RenderTextureFormat.DefaultHDR;
            m_reflectionTexture = RenderTexture.GetTemporary(res.x, res.y, 16,
                GraphicsFormatUtility.GetGraphicsFormat(hdrFormat, true));
        }
        m_reflectionCamera.targetTexture = m_reflectionTexture;
    }
    void SafeDestroy(Object obj) 
    {
        if (Application.isEditor)
        {
            DestroyImmediate(obj);
        }
        else
        {
            Destroy(obj);
        }
    }

    private void ExecutePlanarReflections(ScriptableRenderContext context, Camera camera)
    {
        if (camera.cameraType == CameraType.Reflection || camera.cameraType == CameraType.Preview)
            return;

        UpdateReflectionCamera(camera); // creat
        PlanarReflectionTexture(camera);
        UniversalRenderPipeline.RenderSingleCamera(context, m_reflectionCamera);
        Shader.SetGlobalTexture(m_reflectionRTID,m_reflectionTexture);
    }

    Camera CreateReflectCamera() 
    {
        var go = new GameObject("ReflectCamera", typeof(Camera));
        var cameraData = go.AddComponent<UniversalAdditionalCameraData>();

        cameraData.requiresColorOption = CameraOverrideOption.Off;
        cameraData.requiresDepthOption = CameraOverrideOption.Off;

        var t = transform;
        var reflectionCamera = go.GetComponent<Camera>();
        reflectionCamera.transform.SetPositionAndRotation(t.position, t.rotation);
        reflectionCamera.depth = -10;
        reflectionCamera.enabled = false;
        go.hideFlags = HideFlags.HideAndDontSave;
        return reflectionCamera;
    }

    void UpdateCamera(Camera src,Camera dst) 
    {
        if (dst == null) return;
        dst.CopyFrom(src);
        dst.useOcclusionCulling = false;
    }

    Vector3 MirrorPosition(Vector3 pos) 
    {
        Vector3 newPos = Vector3.zero;
        newPos.x = pos.x;
        newPos.y = -pos.y;
        newPos.z = pos.z;
        return newPos;
    }

    private Vector4 CameraSpacePlane(Camera cam, Vector3 pos, Vector3 normal, float sideSign)
    {
        var offsetPos = pos + normal * ClipOffset;
        var m = cam.worldToCameraMatrix;
        var cameraPosition = m.MultiplyPoint(offsetPos);
        var cameraNormal = m.MultiplyVector(normal).normalized * sideSign;
        return new Vector4(cameraNormal.x, cameraNormal.y, cameraNormal.z, -Vector3.Dot(cameraPosition, cameraNormal));
    }

    void UpdateReflectionCamera(Camera mainCamera) 
    {
        if(m_reflectionCamera==null)
            m_reflectionCamera = CreateReflectCamera();

        Vector3 pos = transform.position;
        Vector3 normal = Vector3.up;
        UpdateCamera(mainCamera, m_reflectionCamera);

        var d = -Vector3.Dot(normal, pos) - ClipOffset;
        Vector4 data = new Vector4(normal.x, normal.y, normal.z, d);

        Matrix4x4 reflectMatrix = Matrix4x4.identity;
        CalculateReflectionMatrix(ref reflectMatrix, data);


        var tempPos = mainCamera.transform.position-new Vector3(0,pos.y*2,0);
        var mirrorPos = MirrorPosition(tempPos);

        m_reflectionCamera.transform.forward = Vector3.Scale(mainCamera.transform.forward, new Vector3(1, -1, 1));
        m_reflectionCamera.worldToCameraMatrix = mainCamera.worldToCameraMatrix*reflectMatrix;

        var clipPlane = CameraSpacePlane(m_reflectionCamera, pos - Vector3.up * 0.1f, normal, 1.0f);
        var projection = mainCamera.CalculateObliqueMatrix(clipPlane);
        m_reflectionCamera.projectionMatrix = projection;
        m_reflectionCamera.cullingMask = LayerMask.GetMask("HideLayer");
        m_reflectionCamera.transform.position = mirrorPos;
    }

    private static void CalculateReflectionMatrix(ref Matrix4x4 reflectionMat, Vector4 plane)
    {
        reflectionMat.m00 = (1F - 2F * plane[0] * plane[0]);
        reflectionMat.m01 = (-2F * plane[0] * plane[1]);
        reflectionMat.m02 = (-2F * plane[0] * plane[2]);
        reflectionMat.m03 = (-2F * plane[3] * plane[0]);

        reflectionMat.m10 = (-2F * plane[1] * plane[0]);
        reflectionMat.m11 = (1F - 2F * plane[1] * plane[1]);
        reflectionMat.m12 = (-2F * plane[1] * plane[2]);
        reflectionMat.m13 = (-2F * plane[3] * plane[1]);

        reflectionMat.m20 = (-2F * plane[2] * plane[0]);
        reflectionMat.m21 = (-2F * plane[2] * plane[1]);
        reflectionMat.m22 = (1F - 2F * plane[2] * plane[2]);
        reflectionMat.m23 = (-2F * plane[3] * plane[2]);

        reflectionMat.m30 = 0F;
        reflectionMat.m31 = 0F;
        reflectionMat.m32 = 0F;
        reflectionMat.m33 = 1F;
    }

}
