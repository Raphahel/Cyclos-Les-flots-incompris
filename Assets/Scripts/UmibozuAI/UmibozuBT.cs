using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BehaviorTree;
using UnityEngine.AI;

public class UmibozuBT : AITree
{
    public float fovRange;
    public static NavMeshAgent agent;

    private void Awake()
    {
        agent = GetComponent<NavMeshAgent>();
    }

    protected override Node SetupTree()
    {
        Node root = new Sequence(new List<Node>() { new CheckBoat(transform, fovRange), new TaskGoToBoat(transform, agent) });
        return root;
    }
}
