using System.Collections;
using System.Collections.Generic;
using Unity.Loading;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Events;

public class DayNightManager : MonoBehaviour
{
    public static DayNightManager instance { get; private set; }
    public static UnityEvent e_Night { get; private set; }
    public static UnityEvent e_Day { get; private set; }

    private static DayNight sun;
    public static bool isNight { get; private set; }

    private void Awake()
    {
        if (instance == null)
        {
            instance = this;
            isNight = false;
            e_Night = new UnityEvent();
            e_Day = new UnityEvent();
        }
        else if (instance != this)
        {
            Debug.Log("Instance already exists.");
            Destroy(gameObject);
        }
        DontDestroyOnLoad(this);
    }

    private void Start()
    {
        sun = gameObject.GetComponentInChildren<DayNight>();
    }


    public static void ChangeDayNight()
    {
        isNight = !isNight;
        if(isNight)
        {
            e_Night.Invoke();
            Debug.Log("Night");
        }
        else
        {
            e_Day.Invoke();
            Debug.Log("Day");
        }
    }

    public static void StopTime()
    {
        sun.timePass = false;
    }

    public static void StartTime()
    {
        sun.timePass = true;
    }

}
