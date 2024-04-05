using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Yarn.Unity;

public class Test_YarnStart : MonoBehaviour
{
    [SerializeField]
    private DialogueRunner YarnTest;
    // Start is called before the first frame update
    void Start()
    {
        YarnTest.StartDialogue("Marchande");
        //YarnTest.Stop();

    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.O))
        {
            YarnTest.Stop();
        }
        
        if (Input.GetKeyDown(KeyCode.M))

        {
            YarnTest.StartDialogue("Marchande");
        }
    }


}
