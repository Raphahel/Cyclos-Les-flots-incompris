using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Head : MonoBehaviour
{
    private MarkerManager markerManager;
    List<Transform> bodyParts;

    // Start is called before the first frame update
    void Start()
    {
        markerManager = MarkerManager.Instance;
        StartCoroutine(AddMarkers());
    }

    IEnumerator AddMarkers()
    {
        while (true)
        {
            Marker marker = new Marker(transform.position, transform.rotation);
            markerManager.Add(marker);
            yield return new WaitForSeconds(5f);
        }
    }

    private void Update()
    {
        for (int i = 0; i < bodyParts.Count; i++)
        {
            if (i == 0)
            {

            }
            else if (i != bodyParts.Count -1)
            {

            }
            else
            {

            }
        }
    }
}
