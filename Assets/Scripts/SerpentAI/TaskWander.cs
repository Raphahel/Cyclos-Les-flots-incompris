using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

using BehaviorTree;

public class TaskWander : Node
{

    /*private float wanderTime = Random.Range(1f, 15f);
    private float wanderTimer = 0f;*/

    private NavMeshAgent agent;
    private float wanderRadius;
    private Vector3 destination;
    //private float speed = 15f;
    //private float rotateSpeed = 1f;

    public TaskWander(NavMeshAgent agent, float wanderRadius)
    {
        this.agent = agent;
        this.wanderRadius = wanderRadius;
        destination = agent.transform.position;
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
        if (Vector2.Distance(agent.transform.position, destination) < 2f)
        {
            destination = RandomNavSphere(agent.transform.position, wanderRadius, -1);
            destination.y = agent.transform.position.y;
            //agent.SetDestination(destination);
        } else
        {
            Debug.DrawLine(agent.transform.position, destination, Color.green);
            //Debug.Log(Vector2.Distance(agent.transform.position, destination));
            //agent.transform.LookAt(new Vector3(destination.x, agent.transform.position.y, destination.z));*$
            Vector3 target = new Vector3(destination.x, agent.transform.position.y, destination.z);
            LookToward(target);
            //float speedModifier = GetRotationBasedSpeedModifier(target);
            Vector3 movement = agent.transform.forward * Time.deltaTime * SerpentBT.speed;

            agent.Move(movement);
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

    public float GetRotationBasedSpeedModifier(Vector3 target)
    {
        Vector3 targetDirection = target - agent.transform.position;
        float rotationDiff = Vector3.Angle(agent.transform.forward, targetDirection);
        float speedModifier = SerpentBT.speed / rotationDiff;
        return speedModifier;
    }

    public void LookToward(Vector3 target)
    {
        Vector3 targetDirection = target - agent.transform.position;
        float singleStep = SerpentBT.rotateSpeed * Time.deltaTime;
        Vector3 newDirection = Vector3.RotateTowards(agent.transform.forward, targetDirection, singleStep, 0.0f);
        Debug.DrawRay(agent.transform.position, target, Color.red);
        agent.transform.rotation = Quaternion.LookRotation(newDirection);
    }
}
