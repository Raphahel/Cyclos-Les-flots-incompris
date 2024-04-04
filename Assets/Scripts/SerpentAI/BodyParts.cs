using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BodyParts : MonoBehaviour
{
    /*MarkerManager markerManager;
    int currentMarker = 0;
    Marker targetMarker;
    Vector3 velocity;

    [SerializeField] float speed = 5f;

    // Start is called before the first frame update
    void Start()
    {
        markerManager = MarkerManager.Instance;
    }

    // Update is called once per frame
    void Update()
    {
        targetMarker = markerManager.markerList[currentMarker];
        velocity = Vector3.Lerp(velocity, targetMarker.position, speed * Time.deltaTime);
        transform.rotation = Quaternion.Lerp(transform.rotation, targetMarker.rotation, speed * Time.deltaTime);
        transform.position += velocity;
        if (Vector3.Distance(transform.position, targetMarker.position) < 2f && currentMarker < markerManager.Length())
        {
            currentMarker += 1;
        } 
    }*/

    private Transform parent;
    [SerializeField] float turnSpeed = 5f;

    private void Start()
    {
        parent = GetComponentInParent<Transform>();
    }

    private void FixedUpdate()
    {
        Vector3 lookVector = Vector3.Lerp(transform.position, parent.position, Time.deltaTime * turnSpeed);
        transform.rotation = Quaternion.LookRotation(lookVector);
    }
}
