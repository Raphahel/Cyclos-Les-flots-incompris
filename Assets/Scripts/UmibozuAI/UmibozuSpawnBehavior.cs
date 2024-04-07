using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class UmibozuSpawnBehavior : MonoBehaviour
{
    [SerializeField] private BoxCollider trigger;
    [SerializeField] private Camera mainCamera;
    public GameObject Umibozu;
    
    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            Debug.Log("ouga bouga");
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
            Vector3 spawnPosition = RandomNavSphere(transform.position, trigger.size.x, -1);
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
