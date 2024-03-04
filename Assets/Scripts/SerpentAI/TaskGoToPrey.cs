using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using BehaviorTree;
using UnityEngine.AI;

public class TaskGoToPrey : Node
{
    private Transform _transform;
    private NavMeshAgent _agent;

    public TaskGoToPrey(Transform transform, NavMeshAgent agent)
    {
        _transform = transform;
        _agent = agent;
    }

    public override NodeState Evaluate()
    {
        Transform prey = (Transform)GetData("prey");
            
        if (Vector3.Distance(_transform.position, prey.position) > 0.01f)
            {
                _agent.SetDestination(prey.position);
            }
        
        
        state = NodeState.RUNNING;
        return state;
    }
}
