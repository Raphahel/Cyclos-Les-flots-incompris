using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BehaviorTree;
using UnityEngine.AI;

public class UmibozuBT : AITree
{
    public float wanderRadius;
    public static NavMeshAgent agent;

    private void Awake()
    {
        agent = GetComponent<NavMeshAgent>();
    }

    protected override Node SetupTree()
    {
        Node root = new TaskWander(agent, wanderRadius);
        return root;
    }
}
