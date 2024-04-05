using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class effets_tempete : MonoBehaviour
{
    [SerializeField]
    private GameObject pluie, fog;
    [SerializeField]
    ParticleSystem pluieEffect;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            Debug.Log("saucisse");
            pluie.SetActive(true);
            //fog.SetActive(true);

        }


    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            Debug.Log("saucisse");
            pluie.SetActive(false);
            //fog.SetActive(false);

        }


    }
}
