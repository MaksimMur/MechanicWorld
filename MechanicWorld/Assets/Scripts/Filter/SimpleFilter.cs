using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SimpleFilter : MonoBehaviour
{
    [SerializeField]
    private Shader _shader;

    private Material _mat;

    private void Awake()
    {
        _mat = new Material(_shader);
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        Graphics.Blit(src, dst, _mat);
    }
}
