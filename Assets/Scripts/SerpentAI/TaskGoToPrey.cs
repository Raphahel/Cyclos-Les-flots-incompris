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
                Vector3 target = new Vector3(prey.position.x, _transform.position.y, prey.position.z);
                LookToward(target);
                Vector3 movement = _transform.forward * Time.deltaTime * SerpentBT.speed;
                _agent.Move(movement);
        }
        
        
        state = NodeState.RUNNING;
        return state;
    }

    public void LookToward(Vector3 target)
    {
        Vector3 targetDirection = target - _transform.position;
        float singleStep = SerpentBT.rotateSpeed * Time.deltaTime;
        Vector3 newDirection = Vector3.RotateTowards(_transform.forward, targetDirection, singleStep, 0.0f);
        Debug.DrawRay(_transform.position, target, Color.red);
        _transform.rotation = Quaternion.LookRotation(newDirection);
    }
}
