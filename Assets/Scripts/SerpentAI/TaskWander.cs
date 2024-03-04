using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

using BehaviorTree;

public class TaskWander : Node
{
    
    public float wanderTime = 5f;
    private float wanderTimer = 0f;

    private NavMeshAgent agent;
    private float wanderRadius;

    public TaskWander(NavMeshAgent agent, float wanderRadius)
    {
        this.agent = agent;
        this.wanderRadius = wanderRadius;
    }

    public override NodeState Evaluate()
    {
        wanderTimer += Time.deltaTime;
        if (wanderTimer >= wanderTime)
        {
            Vector3 newPos = RandomNavSphere(agent.transform.position, wanderRadius, -1);
            agent.SetDestination(newPos);
            wanderTimer = 0f;
        }
        state = NodeState.RUNNING;
        return state;
    }

    public static Vector3 RandomNavSphere (Vector3 origin, float dist, int layermask)
    {
        Vector3 randDirection = Random.insideUnitSphere * dist;

        randDirection += origin;

        NavMeshHit navHit;

        NavMesh.SamplePosition(randDirection, out navHit, dist, layermask);

        return navHit.position;
    }
}
