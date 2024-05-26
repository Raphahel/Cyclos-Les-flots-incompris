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
    private float timer = 0f;
    private bool timerGoing = false;

    private void Update()
    {
        if (timerGoing)
        {
            timer += Time.deltaTime;

            if(timer >= 10f)
            {
                //GetSpawnPosition a été modifié temporairement pour faire fonctionner le proto (bug d'infinity)
                Vector3 spawnPosition = getSpawnPosition();
                if (umibozuInst == null)
                {
                    umibozuInst = Instantiate(UmibozuPrefab);
                    
                    umibozuInst.transform.position = spawnPosition;
                }
            }

        }
        else
        {
            timer = 0f;
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            timerGoing = true;
            other.gameObject.GetComponent<BateauMouvement>().inTempete = true;
            
            GestionnaireVagues.instance.SetVague("tempete");
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            other.gameObject.GetComponent<BateauMouvement>().inTempete = false;
            timerGoing = false;

            if(umibozuInst != null)
            {
                Destroy(umibozuInst);
                umibozuInst = null;
            }

            GestionnaireVagues.instance.SetVague("calme");
        }
    }

    public Vector3 getSpawnPosition()
    {

        while(true)
        {
            Rect r = mainCamera.rect;
            //Augmenter un peu la taille de la trigger semble fix le bug d'infinité à tester plus rigoureusement
            Vector3 spawnPosition = RandomNavSphere(transform.position, trigger.size.x + 10, -1);
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
