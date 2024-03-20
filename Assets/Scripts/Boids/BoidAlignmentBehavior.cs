using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Boid))]
public class BoidAlignmentBehavior : MonoBehaviour
{
    private Boid boid;

    public float radius;

    public float forceModifier;

    // Start is called before the first frame update
    void Start()
    {
        boid = GetComponent<Boid>();
    }

    // Update is called once per frame
    void Update()
    {
        HashSet<Boid> neighboringBoids = boid.linkedQuadTree.FindDataInRange(boid.position2D, radius);
        Vector3 average = Vector3.zero;
        int found = 0;

        /*foreach (var boid in neighboringBoids)
        {
            if (boid != this.boid)
            {
                var diff = boid.transform.position - transform.position;
                if (diff.magnitude < radius)
                {
                    average += boid.velocity;
                    found += 1;
                }
            }
        }*/ 

        foreach (var boid in neighboringBoids)
        {
            if (boid.position2D != this.boid.position2D)
            {
                var diff = boid.position2D - this.boid.position2D;
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
            boid.velocity += Vector3.Lerp(boid.velocity, average, 1f);
        }
    }
}
