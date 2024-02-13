using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.Events;

public class Ile : MonoBehaviour
{
    public TextMeshProUGUI cadreNom;
    [SerializeField] public string nom;

    private void Start()
    {
        cadreNom.enabled = false;
    }

    private void OnTriggerEnter(Collider other)
    {
        cadreNom.enabled = true;
        cadreNom.text = nom;
    }
}
