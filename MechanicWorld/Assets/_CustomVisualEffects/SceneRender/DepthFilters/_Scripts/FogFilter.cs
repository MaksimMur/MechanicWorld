using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FogFilter : SimpleFilter
{
    [SerializeField]
    private Color _farColor;

    protected override void OnUpdate()
    {
        _mat.SetColor("FarColor", _farColor);
    }
}
