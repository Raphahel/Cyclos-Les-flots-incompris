using System;
using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
using Unity.VisualScripting;
using UnityEngine;

public class GestionnaireVagues : MonoBehaviour
{
    public static GestionnaireVagues instance { get; private set;  }
    private ShaderValue ValeursCibles = new ShaderValue();

    private bool changeValeur = false;
    private float actualTime;
    private const float PI = 3.14159265f;

    [SerializeField]
    private Renderer WaveShader;
    [SerializeField]
    private ConstanteVagues VagueData;

    [Header("Wave 1")]
    [SerializeField]
    private float WaveSteepness;
    [SerializeField]
    private float WaveLength;
    [SerializeField]
    private Vector3 WaveDirection;

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

        //Applique les valeurs actuelles du shader au gestionnaire
        WaveSteepness = WaveShader.sharedMaterial.GetFloat("_WaveSteepness");
        WaveLength = WaveShader.sharedMaterial.GetFloat("_WaveLength");
        WaveDirection = WaveShader.sharedMaterial.GetVector("_WaveDirection");

        WaveSteepness2 = WaveShader.sharedMaterial.GetFloat("_WaveSteepness2");
        WaveLength2 = WaveShader.sharedMaterial.GetFloat("_WaveLength2");
        WaveDirection2 = WaveShader.sharedMaterial.GetVector("_WaveDirection2");

        WaveSteepness3 = WaveShader.sharedMaterial.GetFloat("_WaveSteepness3");
        WaveLength3 = WaveShader.sharedMaterial.GetFloat("_WaveLength3");
        WaveDirection3 = WaveShader.sharedMaterial.GetVector("_WaveDirection3");


        //Applique les valeurs actuelles du shader à valeursCibles afin de ne pas dévier
        ValeursCibles.WaveSteepness = WaveShader.sharedMaterial.GetFloat("_WaveSteepness");
        ValeursCibles.WaveLength = WaveShader.sharedMaterial.GetFloat("_WaveLength");
        ValeursCibles.WaveDirection = WaveShader.sharedMaterial.GetVector("_WaveDirection");

        ValeursCibles.WaveSteepness2 = WaveShader.sharedMaterial.GetFloat("_WaveSteepness2");
        ValeursCibles.WaveLength2 = WaveShader.sharedMaterial.GetFloat("_WaveLength2");
        ValeursCibles.WaveDirection2 = WaveShader.sharedMaterial.GetVector("_WaveDirection2");

        ValeursCibles.WaveSteepness3 = WaveShader.sharedMaterial.GetFloat("_WaveSteepness3");
        ValeursCibles.WaveLength3 = WaveShader.sharedMaterial.GetFloat("_WaveLength3");
        ValeursCibles.WaveDirection3 = WaveShader.sharedMaterial.GetVector("_WaveDirection3");
    }

    private void FixedUpdate()
    {
        ValeursCibles = VagueData.vaguesCalme;
        lerpShader(ValeursCibles);
        actualTime = Time.time;
        WaveShader.sharedMaterial.SetFloat("_ActualTime", actualTime);
    }

    //change les valeur de façon linéaire entre les nouvelles valeurs et les valleurs actuelles.
    private void lerpShader(ShaderValue newValue)
    {
        WaveSteepness = Mathf.Lerp(WaveSteepness, newValue.WaveSteepness, 0.1f * Time.fixedDeltaTime);
        WaveLength = Mathf.Lerp(WaveLength, newValue.WaveLength, 0.1f * Time.fixedDeltaTime);
        WaveDirection = Vector3.Lerp(WaveDirection, newValue.WaveDirection, 0.1f * Time.fixedDeltaTime);

        WaveSteepness2 = Mathf.Lerp(WaveSteepness2, newValue.WaveSteepness2, 0.1f * Time.fixedDeltaTime);
        WaveLength2 = Mathf.Lerp(WaveLength2, newValue.WaveLength2, 0.1f * Time.fixedDeltaTime);
        WaveDirection2 = Vector3.Lerp(WaveDirection2, newValue.WaveDirection2, 0.1f * Time.fixedDeltaTime);

        WaveSteepness3 = Mathf.Lerp(WaveSteepness3, newValue.WaveSteepness3, 0.1f * Time.fixedDeltaTime);
        WaveLength3 = Mathf.Lerp(WaveLength3, newValue.WaveLength3, 0.1f * Time.fixedDeltaTime);
        WaveDirection3 = Vector3.Lerp(WaveDirection3, newValue.WaveDirection3, 0.1f * Time.fixedDeltaTime);

        WaveShader.sharedMaterial.SetFloat("_WaveSteepness", WaveSteepness);
        WaveShader.sharedMaterial.SetFloat("_WaveLength", WaveLength);
        WaveShader.sharedMaterial.SetVector("_WaveDirection", WaveDirection);

        WaveShader.sharedMaterial.SetFloat("_WaveSteepness2", WaveSteepness2);
        WaveShader.sharedMaterial.SetFloat("_WaveLength2", WaveLength2);
        WaveShader.sharedMaterial.SetVector("_WaveDirection2", WaveDirection2);

        WaveShader.sharedMaterial.SetFloat("_WaveSteepness3", WaveSteepness3);
        WaveShader.sharedMaterial.SetFloat("_WaveLength3", WaveLength3);
        WaveShader.sharedMaterial.SetVector("_WaveDirection3", WaveDirection3);
    }
}
