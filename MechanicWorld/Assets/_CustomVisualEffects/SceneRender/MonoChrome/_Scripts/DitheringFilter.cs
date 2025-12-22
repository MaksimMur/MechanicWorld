using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(EdgeRenderer))]
public class DitheringFilter : SimpleFilter
{
    [SerializeField] private Texture2D _noiseTexture;
    [SerializeField] private Texture2D _rampTexture;

    private EdgeRenderer _edgeRenderer;

    protected override void Init()
    {
        _edgeRenderer = GetComponent<EdgeRenderer>();
    }

    protected override void UseFilter(RenderTexture src, RenderTexture dst)
    {
        _mat.SetTexture("_NoiseTex", _noiseTexture);
        _mat.SetTexture("_ColorRampTex", _rampTexture);

        RenderTexture big = RenderTexture.GetTemporary(src.width * 2, src.height * 2);
        RenderTexture half = RenderTexture.GetTemporary(src.width / 2, src.height / 2);

        RenderTexture edge = RenderTexture.GetTemporary(src.width, src.height);
        _edgeRenderer.RenderByRobert(src, edge);
        _mat.SetTexture("_EdgedTex", edge);

        Graphics.Blit(src, big);
        Graphics.Blit(big, half, _mat);
        Graphics.Blit(half, dst);

        RenderTexture.ReleaseTemporary(big);
        RenderTexture.ReleaseTemporary(half);
        RenderTexture.ReleaseTemporary(edge);
    }
}
