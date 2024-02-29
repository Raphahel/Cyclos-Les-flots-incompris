using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Boid))]

public class BoidInverseMagnetismBehavior : MonoBehaviour
{
    private Boid boid;

    public float radius;

    public float repulsionForce;

    // Start is called before the first frame update
    void Start()
    {
        boid = GetComponent<Boid>();
    }

    // Update is called once per frame
    void Update()
    {
        var boids = FindObjectsOfType<Boid>();
        var average = Vector3.zero;
        var found = 0;

        foreach (var boid in boids)
        {
            if (boid != this.boid)
            {
                var diff = boid.transform.position - this.transform.position;
                if (diff.magnitude < radius)
                {
                    average += diff;
                    found += 1;
                }
            }
        }

        if (found > 0)
        {
            average = average / found;
            boid.velocity -= Vector3.Lerp(Vector3.zero, average, boid.velocity.magnitude / radius) * repulsionForce;
        }
    }
}
