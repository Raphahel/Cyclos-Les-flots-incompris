using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Boid))]

public class BoidCohesionBehavior : MonoBehaviour
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
        /*var boids = FindObjectsOfType<Boid>();
        var average = Vector3.zero;
        var found = 0;*/

        HashSet<Boid> neighboringBoids = boid.linkedQuadTree.FindDataInRange(boid.position2D, radius);
        Vector2 average = Vector2.zero;
        int found = 0;

        foreach (var boid in neighboringBoids)
        {
            if (boid.position2D != this.boid.position2D)
            {
                var diff = boid.position2D - this.boid.position2D;
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
            boid.velocity += Vector3.Lerp(Vector3.zero, new Vector3(average.x, 0, average.y), (boid.velocity.magnitude * forceModifier) / radius);
        }
    }
}
