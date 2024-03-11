using System.Collections;
using System.Collections.Generic;
using Unity.AI.Navigation;
using UnityEngine;
using UnityEngine.AI;

public class PoissonSpawner : MonoBehaviour
{
    private float yOffset = 0.5f;
    [SerializeField] private float radius = 50f;
    [SerializeField] private int fishesToSpawn = 15;
    [SerializeField] private GameObject prefab;
    private NavMeshSurface navMeshSurface;

    // Start is called before the first frame update
    void Start()
    {
        navMeshSurface = FindObjectOfType<NavMeshSurface>();
        for (int i = 0; i < fishesToSpawn; i++)
        {
            Vector3 spawnPoint = RandomNavSphere(navMeshSurface.center, radius, -1);
            spawnPoint.y += yOffset;
            GameObject poisson = Instantiate(prefab);
            poisson.transform.position = spawnPoint;
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
