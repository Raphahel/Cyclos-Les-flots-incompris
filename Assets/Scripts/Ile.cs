using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.SceneManagement;

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
        Debug.Log("Trigger enter");
        if (other.CompareTag("Player"))
        {
            cadreNom.enabled = true;
            cadreNom.text = nom;
            changeScene();
        }
    }

    private void changeScene()
    {
        SceneManager.LoadScene(nom);
    }
}
