using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[Serializable]
public class ShaderValue
{
    public float WaveSteepness;
    public float WaveLength;
    public Vector3 WaveDirection;

    public float WaveSteepness2;
    public float WaveLength2;
    public Vector3 WaveDirection2;

    public float WaveSteepness3;
    public float WaveLength3;
    public Vector3 WaveDirection3;
};

[CreateAssetMenu]
public class ConstanteVagues : ScriptableObject
{

    //Ces chaines des caractères sont définit dans le scriptable object situé dans Assets/Scripts/Eau
    [SerializeField]
    public ShaderValue vaguesCalme;
    [SerializeField]
    public ShaderValue vaguesAgite;
    [SerializeField]
    public ShaderValue vaguesTempete;

    //Renvois le preset de vagues correspondant à la chaine de caractère
    public ShaderValue chooseWave(string nom)
    {
        switch (nom)
        {
            case "calme":
                return vaguesCalme;
            case "agite":
                return vaguesAgite;
            case "tempete":
                return vaguesTempete;
            default:
                Debug.Log("WARNING : Unknown wave ! Defaulted to calme.");
                return vaguesCalme;
        }
    }
}
