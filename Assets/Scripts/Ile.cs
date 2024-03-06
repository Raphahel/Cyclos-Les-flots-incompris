using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.SceneManagement;
using UnityEngine.InputSystem;

public class Ile : MonoBehaviour
{
    public TextMeshProUGUI cadreNom;
    [SerializeField] public string nom;

    private Controles inputMap;

    private bool dockingEnabled = false;


    private void Start()
    {
        cadreNom.enabled = false;
        inputMap = new Controles();
        inputMap.Enable();
        Subscribe();
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            cadreNom.enabled = true;
            cadreNom.text = nom;
            dockingEnabled = true;
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            cadreNom.enabled = false;
            dockingEnabled = false;
        }
    }

    private void changeScene(InputAction.CallbackContext context)
    {
        if (dockingEnabled)
        {
            SceneManager.LoadScene(nom);
        }
    }

    private void Subscribe()
    {
        inputMap.Interact.Interact.performed += changeScene;
    }

}
