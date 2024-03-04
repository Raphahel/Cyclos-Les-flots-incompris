using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Boid))]
public class BoidObstacleAvoidanceBehavior : MonoBehaviour
{
    private Boid boid;

    public float radius;

    public float repulsionForce;

    private LayerMask layerMask = -1;

    // Start is called before the first frame update
    void Start()
    {
        boid = GetComponent<Boid>();
        layerMask &= ~(1 << 6); // J'enlève la layer "poissons" 
    }

    // Update is called once per frame
    void Update()
    {
        var colliders = Physics.OverlapSphere(transform.position, radius, layerMask); 
        var average = Vector3.zero;
        var found = 0;

        foreach (var c in colliders)
        {
            var diff = c.transform.position - this.transform.position;
            average += diff;
            found += 1;
        }

        if (found > 0)
        {
            average = average / found;
            boid.velocity -= Vector3.Lerp(Vector3.zero, average, boid.velocity.magnitude / radius) * repulsionForce;
        }
    }
}
