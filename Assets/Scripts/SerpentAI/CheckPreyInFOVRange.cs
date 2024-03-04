using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using BehaviorTree;

public class CheckPreyInFOVRange : Node
{
    private Transform _transform;
    private static LayerMask _preyLayerMask = 1 << 6; //changer cet int quand j'aurai déterminé le layermask des poissons et du bateau

    public CheckPreyInFOVRange(Transform transform)
    {
        _transform = transform;
    }

    public override NodeState Evaluate()
    {
        object p = GetData("prey");
        if (p == null)
        {
            Collider[] colliders = Physics.OverlapSphere(_transform.position, SerpentBT.fovRange, _preyLayerMask);
            if (colliders.Length > 0)
            {
                parent.parent.SetData("prey", colliders[0].transform);
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
