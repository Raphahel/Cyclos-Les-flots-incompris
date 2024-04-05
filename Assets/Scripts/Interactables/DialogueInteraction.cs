using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using Yarn;
using Yarn.Unity;

public class DialogueInteraction : AbstractInteractable
{
    [Header("Dialogue")]
    [SerializeField]
    private DialogueRunner dialogue;
    [SerializeField]
    private string nomNode;

    new private void Start()
    {
        base.Start();
    }

    protected override void Interaction(InputAction.CallbackContext context)
    {
        if (!isInterating)
        {
            dialogue.onDialogueComplete.AddListener(EndDialogue);
            HidePrompt();
            dialogue.StartDialogue(nomNode);
            player.Unsubscribe();
        }
    }

    public void EndDialogue()
    {
        ShowPrompt();
        dialogue.onDialogueComplete.RemoveListener(EndDialogue);
        player.Subscribe();
    }
}
