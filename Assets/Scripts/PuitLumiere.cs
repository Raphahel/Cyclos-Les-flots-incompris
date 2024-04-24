using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PuitLumière : MonoBehaviour
{
    private Light lumiere;
    private ParticleSystem particle;
    private Collider coll;
    private float targetIntensity = 40000f;

    private BateauMouvement boat = null;


    private void Start()
    {
        DayNightManager.e_Day.AddListener(Allume);
        DayNightManager.e_Night.AddListener(Eteint);
        lumiere = gameObject.GetComponentInChildren<Light>();
        particle = gameObject.GetComponent<ParticleSystem>();
        coll = gameObject.GetComponent<Collider>();
    }

    private void Update()
    {
        lumiere.intensity = Mathf.Lerp(lumiere.intensity, targetIntensity, 1f * Time.deltaTime);
    }

    private void Allume()
    {
        targetIntensity = 40000f;
        particle.Play();
        coll.enabled = true;
    }

    private void Eteint()
    {
        targetIntensity = 0f;
        particle.Stop();
        coll.enabled = false;
        if(boat != null)
        {
            boat.isCharging = false;
            boat = null;
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            boat = other.gameObject.GetComponent<BateauMouvement>();
            boat.isCharging = true;
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            boat.isCharging = false;
            boat = null;
        }
    }
}
