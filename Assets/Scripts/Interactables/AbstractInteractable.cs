using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;

public abstract class AbstractInteractable : MonoBehaviour
{
    [Header("Texte interaction")]
    [SerializeField]
    protected string texteInteraction = "E : intéragir";
    [SerializeField]
    protected TextMeshProUGUI textMesh;


    private Collider trigger;
    protected bool isInterating = false;
    protected bool canInteract = false;
    private Controles inputMap;
    protected PlayerMovement player;

    protected void Start()
    {
        trigger = gameObject.GetComponent<Collider>();
        inputMap = new Controles();
        inputMap.Enable();
        Subscribe();
        textMesh.enabled = false;
        textMesh.text = texteInteraction;
    }

    private void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.CompareTag("Player"))
        { 
            textMesh.enabled = true;
            player = collision.gameObject.GetComponent<PlayerMovement>();
            canInteract = true;
        }
    }

    private void OnTriggerExit2D(Collider2D collision)
    {
        if (collision.CompareTag("Player"))
        {
            textMesh.enabled = false;
            canInteract = false;
        }
    }

    public void HidePrompt() { textMesh.enabled = false; }
    public void ShowPrompt() { textMesh.enabled = true; }

    protected abstract void Interaction(InputAction.CallbackContext context);

    private void Subscribe()
    {
        inputMap.Interact.Interact.performed += Interaction;
    }

}
