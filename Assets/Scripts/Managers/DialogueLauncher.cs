using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Yarn;
using Yarn.Unity;

public class DialogueLauncher : MonoBehaviour
{

    public static DialogueLauncher instance = null;

    private bool dialogueRunning = false;

    [SerializeField]
    public BateauMouvement boatScript;

    [SerializeField]
    private DialogueRunner runner;

    private void Awake()
    {
        if (instance == null)
        {
            instance = this;
        }
        else if (instance != this)
        {
            Debug.Log("Instance already exists.");
            Destroy(gameObject);
        }
    }

    public static void LaunchDialogueFreeze(string filename)
    {
        instance.LaunchDialogue(filename);
    }

    public void LaunchDialogue(string filename)
    {
        if (!dialogueRunning)
        {
            boatScript.Unsubscribe();
            boatScript.HideUi();
            runner.onDialogueComplete.AddListener(EndDialogue);
            runner.StartDialogue(filename);
            dialogueRunning = true;
        }
    }

    public void EndDialogue()
    {
        runner.onDialogueComplete.RemoveListener(EndDialogue);
        dialogueRunning = false;
        boatScript.Subscribe();
        boatScript.ShowUi();
    }

}
