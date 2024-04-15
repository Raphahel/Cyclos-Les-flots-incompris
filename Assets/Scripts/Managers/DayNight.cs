using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;

public class DayNight : MonoBehaviour
{
    [SerializeField]
    private float degreSecond = 0.3f;
    [SerializeField]
    private Transform referencePoint;

    private void Update()
    {
        transform.Rotate(degreSecond * Time.deltaTime, 0,0);
        float angle = Vector3.Angle(transform.position, referencePoint.position);
        Debug.Log(angle);
        if (angle < 90f)
        {
            Debug.Log("DAY");
        }
        else
        {
            Debug.Log("Night");
        }
    }
}
