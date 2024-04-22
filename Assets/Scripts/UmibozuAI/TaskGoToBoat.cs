using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BehaviorTree;

public class TaskGoToBoat : Node
{
    private Transform _transform;
    private UnityEngine.AI.NavMeshAgent _agent;

    public TaskGoToBoat(Transform transform, UnityEngine.AI.NavMeshAgent agent)
    {
        _transform = transform;
        _agent = agent;
    }

    public override NodeState Evaluate()
    {
        Transform boat = (Transform)GetData("boat");
        if (Vector3.Distance(_transform.position, boat.position) > 35f)
        {
            _agent.SetDestination(boat.position);
        }
        else if(Vector3.Distance(_transform.position, boat.position) < 35f)
        {
            DialogueLauncher.LaunchDialogueFreeze("Umibozu");
            _agent.SetDestination(_transform.position);
        }

        state = NodeState.RUNNING;
        return state;
    }
}
