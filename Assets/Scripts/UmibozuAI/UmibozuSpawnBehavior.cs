using System.Collections;
using System.Collections.Generic;
using System.Security.Cryptography;
using UnityEngine;
using UnityEngine.AI;

public class UmibozuSpawnBehavior : MonoBehaviour
{
    [SerializeField] private BoxCollider trigger;
    [SerializeField] private Camera mainCamera;
    public GameObject UmibozuPrefab;
    private GameObject umibozuInst = null;
    float spawnSpeed = 1f;
    
    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            Debug.Log("ouga bouga");
            Vector3 spawnPosition = getSpawnPosition();
            spawnPosition.y = -100f;
            if(umibozuInst == null)
            {
                umibozuInst = Instantiate(UmibozuPrefab);
                umibozuInst.transform.position = spawnPosition;
                //StartCoroutine(SpawnAnimation());
            }
            GestionnaireVagues.instance.SetVague("tempete");
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            Destroy(umibozuInst);
            umibozuInst = null;
            GestionnaireVagues.instance.SetVague("calme");
        }
    }

    public IEnumerator SpawnAnimation()
    {
        while (transform.position.y < 0)
        {
            transform.position += Vector3.up * spawnSpeed * Time.deltaTime;
            yield return null;
        }
    }

    public Vector3 getSpawnPosition()
    {
        while(true)
        {
            Rect r = mainCamera.rect;
            Vector3 spawnPosition = RandomNavSphere(transform.position, trigger.size.x, -1);
            //spawnPosition.y = -100f;
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
