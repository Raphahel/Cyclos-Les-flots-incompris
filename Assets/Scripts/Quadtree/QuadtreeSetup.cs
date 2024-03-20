using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class QuadtreeSetup : MonoBehaviour
{

    [SerializeField] private Rect _bounds; 
    public Quadtree _quadtree;


    // Start is called before the first frame update
    void Start()
    {
        _bounds = new Rect(-5000, -5000, 10000, 10000);
        _quadtree = GetComponent<Quadtree>();
        _quadtree.PrepareTree(_bounds);
        Boid[] boids = FindObjectsOfType<Boid>();
        foreach (Boid b in boids)
        {
            _quadtree.AddData(b);
        }
    }
    //Pas besoin d'update le quadtree à chaque frame? 
}
