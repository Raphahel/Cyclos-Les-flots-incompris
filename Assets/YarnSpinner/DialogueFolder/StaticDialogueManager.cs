using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEditor;
using UnityEngine;
using Yarn.Unity;

public class StaticDialogueManager : MonoBehaviour
{
    
    static public Dictionary<string, bool> dictEvenement = new Dictionary<string, bool>();

    static public StaticDialogueManager instance { get; private set; }

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
        DontDestroyOnLoad(this);

        AddEvenement("Nuit");
        if (DayNightManager.isNight)
        {
            ValideEvenement("Nuit");
        }
        else
        {
            FalseEvenement("Nuit");
        }
    }


    [YarnFunction("GetEventState")]
    public static bool GetEventState(string nameEvent)
    {
        nameEvent = nameEvent.ToLower();
        if (dictEvenement.ContainsKey(nameEvent))
        {
            print(nameEvent + " = " + dictEvenement[nameEvent]);
            return dictEvenement[nameEvent];
        }
        else
        {
            Debug.Log("WARNING : reference to a missing event :" + nameEvent);
            return false;
        }
    }


    [YarnCommand("AddEvenement")]
    public static void AddEvenement(string nameEvent)
    {
        nameEvent = nameEvent.ToLower();
        if (dictEvenement.ContainsKey(nameEvent))
        {
            Debug.Log("WARNING : trying to add an already existing event : " + nameEvent);
            //Do Nothing (made to avoid create duplicate)
        }
        else
        {
            dictEvenement.Add(nameEvent, false);
        }
    }

    [YarnCommand("FalseEvenement")]
    public static void FalseEvenement(string nameEvent)
    {
        nameEvent = nameEvent.ToLower();
        if (dictEvenement.ContainsKey(nameEvent))
        {
            dictEvenement[nameEvent] = false;
        }
        else
        {
            dictEvenement.Add(nameEvent, false);
        }
    }


    [YarnCommand("ValideEvenement")]
    public static void ValideEvenement(string nameEvent)
    {
        nameEvent = nameEvent.ToLower();
        if (dictEvenement.ContainsKey(nameEvent))
        {
            dictEvenement[nameEvent] = true;
        }
        else
        {
            dictEvenement.Add(nameEvent, true);
        }
    }

    [YarnCommand("ChangeScene2D")]
    public static void ChangeScene2D(string scene)
    {
        UIController.instance.FadeToScene2D(scene);
    }

    [YarnCommand("ChangeScene")]
    public static void ChangeScene(string scene)
    {
        UIController.instance.FadeToScene(scene);
    }
}