using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VieuxNuit : MonoBehaviour
{
    private void Awake()
    {
        if (DayNightManager.isNight)
        {
            gameObject.SetActive(false);
        }
    }
}
