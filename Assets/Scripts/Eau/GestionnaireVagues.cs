using System;
using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
using Unity.VisualScripting;
using UnityEngine;

public class GestionnaireVagues : MonoBehaviour
{
    public static GestionnaireVagues instance;

    private float actualTime;
    private const float PI = 3.14159265f;

    [SerializeField]
    private Renderer WaveShader;

    [Header("Wave 1")]
    [SerializeField]
    private float WaveSteepness;
    [SerializeField]
    private float WaveLength;
    [SerializeField]
    private Vector3 WaveDirection;
    [SerializeField]
    private float speed;

    [Header("Wave 2")]
    [SerializeField]
    private float WaveSteepness2;
    [SerializeField]
    private float WaveLength2;
    [SerializeField]
    private Vector3 WaveDirection2;

    [Header("Wave 3")]
    [SerializeField]
    private float WaveSteepness3;
    [SerializeField]
    private float WaveLength3;
    [SerializeField]
    private Vector3 WaveDirection3;

    private void Awake()
    {
        if (instance == null)
        {
            instance = this;
        }
        else if(instance != this) 
        {
            Debug.Log("Instance already exists.");
            Destroy(this);
        }
    }

    /*private void UpdateShaderData()
    {
       
    }*/

    public Vector3 HauteurVague(Vector3 pos)
    {
        Vector3 vagueHauteur = Vector3.zero;
        vagueHauteur += CalculatePosition(WaveSteepness, WaveLength, WaveDirection, pos);
        vagueHauteur += CalculatePosition(WaveSteepness2, WaveLength2, WaveDirection2, pos);
        vagueHauteur += CalculatePosition(WaveSteepness3, WaveLength3, WaveDirection3, pos);

        return vagueHauteur;
    }

    private Vector3 CalculatePosition(float Ws, float Wl, Vector3 Wd, Vector3 pos)
    {
        float k = (2 * 3.141593f / Wl);
        float c = Mathf.Sqrt(9.806f / k);
        Vector3 d = Vector3.Normalize(Wd);
        float f = k * (Vector3.Dot(d, pos) - c * actualTime);
        float a = Ws / k;

        return new Vector3(
            (d.x * (a * Mathf.Cos(f))),
            (a * Mathf.Sin(f)),
            (d.y * (a * Mathf.Cos(f))) 
            );
    }
    
    private void Start()
    {
        WaveSteepness = WaveShader.sharedMaterial.GetFloat("_WaveSteepness");
        WaveLength = WaveShader.sharedMaterial.GetFloat("_WaveLength");
        WaveDirection = WaveShader.sharedMaterial.GetVector("_WaveDirection");

        WaveSteepness2 = WaveShader.sharedMaterial.GetFloat("_WaveSteepness2");
        WaveLength2 = WaveShader.sharedMaterial.GetFloat("_WaveLength2");
        WaveDirection2 = WaveShader.sharedMaterial.GetVector("_WaveDirection2");

        WaveSteepness3 = WaveShader.sharedMaterial.GetFloat("_WaveSteepness3");
        WaveLength3 = WaveShader.sharedMaterial.GetFloat("_WaveLength3");
        WaveDirection3 = WaveShader.sharedMaterial.GetVector("_WaveDirection3");
    }
    private void FixedUpdate()
    {
        actualTime = Time.time;
        WaveShader.sharedMaterial.SetFloat("_ActualTime", actualTime);
    }
}
