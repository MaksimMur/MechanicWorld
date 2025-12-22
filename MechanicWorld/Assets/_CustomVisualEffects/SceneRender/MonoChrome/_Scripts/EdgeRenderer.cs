using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeRenderer : MonoBehaviour
{
    [SerializeField] private float _sensitivityDepth = 1.0f;
    [SerializeField] private float _sensirivityNormals = 1.0f;
    [SerializeField, Range(0, 1)] private float _edgesOnly = 1.0f;
    [SerializeField] private Color _edgesOnlyBgColor = Color.black;
    [SerializeField] private Color _edgesColor = Color.white;

    private Material _robertMat;
    private Material _sobelMat;

    private void Awake()
    {
        _sobelMat = new Material(Shader.Find("Hidden/EdgeDetectionFilter"));
        _robertMat = new Material(Shader.Find("Hidden/EdgeDetectColors"));

        var camera = GetComponent<Camera>();
        camera.depthTextureMode |= DepthTextureMode.DepthNormals;
    }
    public void RenderByRobert(RenderTexture src, RenderTexture dst)
    {
        _robertMat.SetVector("_Sensitivity", new Vector4(_sensitivityDepth, _sensirivityNormals, 1.0f, _sensirivityNormals));
        _robertMat.SetFloat("_BgFade", _edgesOnly);
        _robertMat.SetVector("_BgColor", _edgesOnlyBgColor);
        _robertMat.SetVector("_Color", _edgesColor);
        Graphics.Blit(src, dst, _robertMat);
    }
    public void RenderBySobel(RenderTexture src, RenderTexture dst)
    { 
        Graphics.Blit(src, dst, _sobelMat);    
    }
}
