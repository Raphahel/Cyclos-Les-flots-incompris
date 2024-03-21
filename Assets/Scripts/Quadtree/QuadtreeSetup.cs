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
        _bounds = new Rect(-3000, -3000, 6000, 6000);
        _quadtree = GetComponent<Quadtree>();
        _quadtree.PrepareTree(_bounds);
        Boid[] boids = FindObjectsOfType<Boid>();
        foreach (Boid b in boids)
        {
            _quadtree.AddData(b);
        }
    }

    private void Update()
    {
        _quadtree.RemoveAllData();
        Boid[] boids = FindObjectsOfType<Boid>();
        foreach (Boid b in boids)
        {
            _quadtree.AddData(b);
        }
    }
    //Pas besoin d'update le quadtree � chaque frame? 
}
