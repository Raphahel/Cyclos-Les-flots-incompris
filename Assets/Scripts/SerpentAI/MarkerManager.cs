using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Marker
{
    public Vector3 position;
    public Quaternion rotation;

    public Marker(Vector3 pos, Quaternion rot)
    {
        position = pos;
        rotation = rot;
    }
}

public class MarkerManager : MonoBehaviour
{
    public List<Marker> markerList = new List<Marker>();

    public static MarkerManager Instance; 

    // Start is called before the first frame update
    void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Destroy(this);
        } else
        {
            Instance = this;
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void UpdateMarkerList()
    {
        markerList.Add(new Marker(transform.position, transform.rotation));
    }

    public void ClearMarkerList()
    {
        markerList.Clear();
        markerList.Add(new Marker(transform.position, transform.rotation));
    }

    public void Add(Marker marker)
    {
        markerList.Add(marker);
    }

    public int Length()
    {
        return markerList.Count;
    }
}
