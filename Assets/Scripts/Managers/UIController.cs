using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UIElements;

public class UIController : MonoBehaviour
{
    public static UIController instance;

    // Start is called before the first frame update
    void Start()
    {
        if (instance != null & instance != this)
        {
            Destroy(gameObject);
        } else
        {
            instance = this;
        }
    }
}
