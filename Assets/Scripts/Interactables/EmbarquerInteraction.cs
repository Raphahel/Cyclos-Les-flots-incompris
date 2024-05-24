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

    private bool isloading = false;
    
    protected override void Interaction(InputAction.CallbackContext context)
    {
        if (canInteract && !isloading)
        {
            isloading = true;
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
