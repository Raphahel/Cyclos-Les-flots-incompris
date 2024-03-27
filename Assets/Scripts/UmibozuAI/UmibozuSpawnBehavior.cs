using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class UmibozuSpawnBehavior : MonoBehaviour
{
    private SphereCollider trigger;
    private Camera mainCamera;
    public GameObject Umibozu;

    private void Start()
    {
        trigger = GetComponent<SphereCollider>();
        mainCamera = FindObjectOfType<Camera>();
    }
    
    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            Vector3 spawnPosition = getSpawnPosition();
            GameObject umibozu = Instantiate(Umibozu);
            umibozu.transform.position = spawnPosition; 
        }
    }

    public Vector3 getSpawnPosition()
    {
        while(true)
        {
            Rect r = mainCamera.rect;
            Vector3 spawnPosition = RandomNavSphere(transform.position, trigger.radius, -1);
            if (!r.Contains(spawnPosition))
            {
                return spawnPosition;
            }
        }
    }

    public static Vector3 RandomNavSphere(Vector3 origin, float dist, int layermask)
    {
        Vector3 randDirection = Random.insideUnitSphere * dist;

        randDirection += origin;

        NavMeshHit navHit;

        NavMesh.SamplePosition(randDirection, out navHit, dist, layermask);

        return navHit.position;
    }
}
