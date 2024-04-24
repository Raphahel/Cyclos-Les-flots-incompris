using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BehaviorTree;

public class CheckBoat : Node
{
    Transform _transform;
    float _fovRange;
    int _boatLayerMask;
    public CheckBoat(Transform transform, float fovRange)
    {
        _transform = transform;
        _fovRange = fovRange;
        _boatLayerMask = LayerMask.GetMask("Boat");
    }

    public override NodeState Evaluate()
    {
        object b = GetData("boat");
        if (b == null)
        {
            Collider[] colliders = Physics.OverlapSphere(_transform.position, _fovRange, _boatLayerMask);
            if (colliders.Length > 0)
            {
                parent.SetData("boat", colliders[0].transform);
                Debug.Log(colliders[0].name);
                state = NodeState.SUCCESS;
                return state;
            }
            state = NodeState.FAILURE;
            return state;
        }
        state = NodeState.SUCCESS;
        return state;
    }
}
