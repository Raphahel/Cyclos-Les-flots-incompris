using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PuitLumière : MonoBehaviour
{
    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            other.gameObject.GetComponent<BateauMouvement>().isCharging = true;
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            other.gameObject.GetComponent<BateauMouvement>().isCharging = false;
        }
    }
}
