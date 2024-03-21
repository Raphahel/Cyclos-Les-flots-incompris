using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Boid : MonoBehaviour
{
    
    public Vector3 velocity;
    public Vector2 position2D;
    public float maxVelocity;

    public Quadtree linkedQuadTree;
    private Quadtree.Node parent;

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

        if (HasMoved())
        {
            OnMove();
        }
    }

    private void FixedUpdate()
    {
        
    }

    public void OnMove()
    {
            parent._data.Remove(this);
            linkedQuadTree.AddData(this);
    }
    
    public void SetParent(Quadtree.Node parent)
    {
        this.parent = parent;
    }

    public bool HasMoved()
    {
        if (parent == null)
        {
            return false;
        }
        return !parent.Contains(position2D);
    }
}
