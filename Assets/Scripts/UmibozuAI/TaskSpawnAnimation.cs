using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BehaviorTree;

public class TaskSpawnAnimation : Node
{
    bool hasSpawned = false;
    Transform _transform;
    float spawnSpeed = 15f;

    public TaskSpawnAnimation(Transform transform)
    {
        _transform = transform;
    }

    public override NodeState Evaluate()
    {
        if (hasSpawned)
        {
            state = NodeState.SUCCESS;
            return state;
        }
        Vector3 position = _transform.position;
        if (position.y < 0)
        {
            position += Vector3.up * spawnSpeed * Time.deltaTime;
            _transform.position = position;
            state = NodeState.RUNNING;
            return state;
        }
        hasSpawned = true;
        state = NodeState.SUCCESS;
        return state;
    }
}
