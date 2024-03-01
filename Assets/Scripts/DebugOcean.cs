using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DebugOcean : MonoBehaviour
{

    Collider coll;

    // Start is called before the first frame update
    void Start()
    {
        coll = gameObject.GetComponent<Collider>();
    }

    private void OnCollisionStay(Collision collision)
    {
        Debug.Log("PLOUF");
    }
}
