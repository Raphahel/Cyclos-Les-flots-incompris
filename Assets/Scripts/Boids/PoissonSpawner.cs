using System;
using System.Collections;
using System.Collections.Generic;
using Unity.AI.Navigation;
using UnityEngine;
using UnityEngine.AI;

public class PoissonSpawner : MonoBehaviour
{
    private float yOffset = 0.5f;
    public float radius;
    [SerializeField] private int fishesToSpawn = 15;
    [SerializeField] private GameObject prefab;
    private NavMeshSurface navMeshSurface;

    // Start is called before the first frame update
    void Start()
    {
        navMeshSurface = FindObjectOfType<NavMeshSurface>();
        /*radius = navMeshSurface.size.x / 2;
        radius = 2500f;*/
        for (int i = 0; i < fishesToSpawn; i++)
        {
                Vector3 spawnPoint = RandomNavSphere(navMeshSurface.center, radius, -1);
                spawnPoint.y += yOffset;
                Instantiate(prefab, spawnPoint, UnityEngine.Random.rotation);
        }
    }

    public static Vector3 RandomNavSphere(Vector3 origin, float dist, int layermask)
    {
        Vector3 randDirection = UnityEngine.Random.insideUnitSphere * dist;

        randDirection += origin;

        NavMeshHit navHit;

        NavMesh.SamplePosition(randDirection, out navHit, dist, layermask);

        return navHit.position;
    }
}
