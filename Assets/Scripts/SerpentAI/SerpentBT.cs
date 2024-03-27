using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

using BehaviorTree;

public class SerpentBT : AITree
{

    public static float fovRange = 6f;
    public float wanderRadius;
    public static NavMeshAgent agent;
    public static float speed = 15f;
    public static float rotateSpeed = 1f;

    // Start is called before the first frame update
    void Awake()
    {
        agent = GetComponent<NavMeshAgent>();
    }

    protected override Node SetupTree()
    {
        Node root = new Selector(new List<Node> {
                new Sequence ( new List<Node> {
                    new CheckPreyInFOVRange(gameObject.transform),
                    new TaskGoToPrey(gameObject.transform, agent)
                }),
                new TaskWander(agent, wanderRadius)
            });
        return root;
    }
}
