using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class EmbarquerInteraction : AbstractInteractable
{

    [SerializeField]
    private string targetScene;
    
    protected override void Interaction(InputAction.CallbackContext context)
    {
        if (canInteract)
        {
            StartCoroutine(UIController.instance.StartFadeToScene(targetScene));
            StaticDialogueManager.ValideEvenement("DejaPartie");
        }
    }
    

    //Obsolete
    IEnumerator LoadWorld()
    {
        AsyncOperation asyncLoad = SceneManager.LoadSceneAsync(targetScene);

        while (!asyncLoad.isDone)
        {
            yield return null;
        }
    }

}
