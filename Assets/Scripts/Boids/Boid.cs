using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Boid : MonoBehaviour
{
    public Vector3 velocity;
    public Vector2 position2D;
    public float maxVelocity;

    public Quadtree linkedQuadTree;

    private void Awake()
    {
        linkedQuadTree = FindObjectOfType<Quadtree>();
    }

    // Update is called once per frame
    void Update()
    {
        velocity.y = 0;
        position2D = new Vector2(transform.position.x, transform.position.z);

        if (velocity.magnitude > maxVelocity)
        {
            velocity = velocity.normalized * maxVelocity;
        }
        transform.position += velocity * Time.deltaTime;
        transform.rotation = Quaternion.LookRotation(velocity);
    }

    /*private void OnDrawGizmos()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawSphere(transform.position, 25f);
    }*/

}
