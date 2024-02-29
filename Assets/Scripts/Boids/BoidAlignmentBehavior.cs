using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Boid))]
public class BoidAlignmentBehavior : MonoBehaviour
{
    private Boid boid;

    public float radius;

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
                    average += boid.velocity;
                    found += 1;
                }
            }
        }

        if (found > 0)
        {
            average = average / found;
            boid.velocity += Vector3.Lerp(boid.velocity, average, Time.deltaTime);
        }
    }
}
