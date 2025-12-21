using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FpsCounter : MonoBehaviour
{
    //отвечает за длину массива буффера нашего fps
    [SerializeField]
    private int _frameRange = 60;

    private int[] _fpsBuffer;
    private int _fpsBufferIndex;

    public int AverageFPS { get; private set; }
    public int HighestFPS { get; private set; }
    public int LowestFPS { get; private set; }

    private void Update()
    {
        if (_fpsBuffer == null || _frameRange != _fpsBuffer.Length)
        {
            InitializedBuffer();
        }
        UpdateBuffer();
        CalculateFps();
    }

    private void InitializedBuffer()
    {
        if (_frameRange <= 0)
        {
            _frameRange = 1;
        }

        _fpsBuffer = new int[_frameRange];
        _fpsBufferIndex = 0;
    }

    private void UpdateBuffer()
    {
        //Time.deltaTime сильно зависит от текущего масштаба времени time scale
        //Это значит что fps будет неправильным по какой-то причине шкала времени не установлена в 1
        // поэтому следует использовать немасштабируеммую дельту времени Time.unscaledDeltaTime
        _fpsBuffer[_fpsBufferIndex++] = (int)(1f / Time.unscaledDeltaTime);
        if (_fpsBufferIndex >= _frameRange)
        {
            _fpsBufferIndex = 0;
        }

    }

    private void CalculateFps()
    {
        int sum = 0;
        int lowest = int.MaxValue;
        int highest = 0;
        for (int i = 0; i < _frameRange; i++)
        {
            int fps = _fpsBuffer[i];
            sum += fps;
            if (fps > highest)
            { 
                highest = fps;
            }

            if (fps < lowest)
            { 
                lowest = fps;
            }
        }
        HighestFPS = highest;
        LowestFPS = lowest;
        AverageFPS = sum / _frameRange;
    }
}
