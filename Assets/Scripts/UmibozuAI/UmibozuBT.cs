using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BehaviorTree;
using UnityEngine.AI;

public class UmibozuBT : AITree
{
    public float fovRange;
    public static NavMeshAgent agent;
    private Transform rendererTransform;

    private void Awake()
    {
        agent = GetComponent<NavMeshAgent>();
        rendererTransform = GetComponentInChildren<SkinnedMeshRenderer>().transform;
        Vector3 position = rendererTransform.position;
        position.y = -50;
        rendererTransform.position = position;
    }

    protected override Node SetupTree()
    {
        Node root = new Sequence(new List<Node>() {new TaskSpawnAnimation(rendererTransform), new CheckBoat(transform, fovRange), new TaskGoToBoat(transform, agent) });
        return root;
    }
}
