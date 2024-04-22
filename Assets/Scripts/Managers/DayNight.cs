using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DayNight : MonoBehaviour
{
    [SerializeField]
    private float degreSecond = 0.3f;
    [SerializeField]
    private Transform referencePoint;

    private bool canChange = true;

    [HideInInspector]
    public bool timePass = true;

    private void Update()
    {
        if (timePass)
        {
            transform.Rotate(degreSecond * Time.deltaTime, 0,0);
            float angle = Vector3.Angle(transform.forward, referencePoint.position);
            if (angle >= 85f && angle <= 90f)
            {
                if (canChange)
                {
                    DayNightManager.ChangeDayNight();
                    canChange = false;
                }
            }
            else
            {
                canChange = true;
            }
        }
    }
}
