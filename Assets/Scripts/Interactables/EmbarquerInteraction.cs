using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class EmbarquerInteraction : AbstractInteractable
{

    [SerializeField]
    private Image fadeToBlack;
    [SerializeField]
    private string targetScene;
    
    protected override void Interaction(InputAction.CallbackContext context)
    {
        if (canInteract)
        {
            StartCoroutine(LoadWorld());
        }
    }
    
    IEnumerator LoadWorld()
    {
        AsyncOperation asyncLoad = SceneManager.LoadSceneAsync(targetScene);

        while (!asyncLoad.isDone)
        {
            yield return null;
        }
    }

}
