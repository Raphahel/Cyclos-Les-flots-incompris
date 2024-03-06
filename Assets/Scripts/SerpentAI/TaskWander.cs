using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

using BehaviorTree;

public class TaskWander : Node
{

    private float wanderTime = Random.Range(1f, 15f);
    private float wanderTimer = 0f;

    private NavMeshAgent agent;
    private float wanderRadius;
    private Vector3 destination;

    public TaskWander(NavMeshAgent agent, float wanderRadius)
    {
        this.agent = agent;
        this.wanderRadius = wanderRadius;
        this.destination = agent.transform.position;
    }

    public override NodeState Evaluate()
    {
        /*wanderTimer += Time.deltaTime;
        if (wanderTimer >= wanderTime)
        {
            destination = RandomNavSphere(agent.transform.position, wanderRadius, -1);
            agent.SetDestination(destination);
            wanderTimer = 0f;
            wanderTime = Random.Range(1f, 10f);
        }*/
        if (agent.remainingDistance < 0.1f)
        {
            destination = RandomNavSphere(agent.transform.position, wanderRadius, -1);
            agent.SetDestination(destination);
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
