using System.Collections;
using System.Collections.Generic;
using System.Threading.Tasks;
using Unity.Burst;
using Unity.Collections;
using Unity.Jobs;
using UnityEngine;

public class Poissons : MonoBehaviour
{
    [SerializeField]
    Mesh mesh;

    [SerializeField]
    Material material;

    [SerializeField]
    int maxPopulation;

    [SerializeField]
    float maxSpeed;

    [SerializeField]
    float cohesionRadius;

    [SerializeField]
    float alignmentRadius;

    [SerializeField]
    float inverseMagnetismRadius;
    [SerializeField]
    float repulsionForce;

    [SerializeField]
    float obstacleAvoidanceRadius;
    [SerializeField]
    float obstacleRepulsionForce;

    [SerializeField, Min(0.0001f)]
    float tickDelay;


    List<Matrix4x4> fishTRS; //The TRS stands from translation, rotation, scale
    List<Vector3> fishVelocity;

    NativeList<Matrix4x4> fish_cont;
    NativeList<Vector3> fish_velocity;

    JobHandle handle;
    JobHandle cohesionHandle;
    JobHandle alignmentHandle;
    JobHandle magnetismHandle;
    JobHandle obstacleHandle;

    private void Awake()
    {
        float position = 0;
        fishTRS = new List<Matrix4x4>();
        fishVelocity = new List<Vector3>();

        for (int i = 0; i < maxPopulation; i++)
        {
            AddFish(new Vector3(position, 0, position), Quaternion.identity, 1f);
            fishVelocity.Add(new Vector3(1, 0, 0));
            position += 2f;
        }
        fish_cont = new NativeList<Matrix4x4>(1, Allocator.Persistent);
        fish_velocity = new NativeList<Vector3>(1, Allocator.Persistent);
        StartCoroutine(Tick());
    }

    private void OnDestroy()
    {
        handle.Complete();
        cohesionHandle.Complete();
        alignmentHandle.Complete();
        magnetismHandle.Complete();
        if (fish_cont.IsCreated)
        {
            fish_cont.Dispose();
        }
        if (fish_velocity.IsCreated)
        {
            fish_velocity.Dispose();
        }
    }

    void AddFish(Vector3 position, Quaternion rotation, float fishSize)
    {
        fishTRS.Add(Matrix4x4.TRS(position, rotation, Vector3.one * fishSize));
    }

    // Update is called once per frame
    void Update()
    {
        if (fishTRS.Count > 0)
        {
            Graphics.DrawMeshInstanced(mesh, 0, material, fishTRS);
        }

    }

    /*void Tick()
    {
        for (int i = 0; i < fishTRS.Count; i++ )
        {
            Matrix4x4 trs = fishTRS[i];
            Vector3 position = trs.GetPosition();
            Vector3 scale = trs.lossyScale;
            Vector3 velocity = fishVelocity[i];

            velocity += Cohesion(position)
                + Alignment(position, velocity)
                + InverseMagnetism(position)
                + ObstacleAvoidance(position);

            if (velocity.magnitude > maxSpeed)
            {
                velocity = velocity.normalized * maxSpeed;
            }

            position += velocity * Time.deltaTime;

            Quaternion rotation = Quaternion.LookRotation(velocity);

            fishTRS[i] = Matrix4x4.TRS(position, rotation, scale);
            fishVelocity[i] = velocity;
        }
    }*/

    IEnumerator Tick()
    {
        float lastTime = Time.time;
        while(true)
        {
            #region Update Fish Container
            {
                fish_cont.SetCapacity(fishTRS.Count);
                fish_velocity.SetCapacity(fishTRS.Count);
                NativeArray<Matrix4x4> temp = new NativeArray<Matrix4x4>(fishTRS.ToArray(), Allocator.TempJob);
                NativeArray<Vector3> tempV = new NativeArray<Vector3>(fishVelocity.ToArray(), Allocator.TempJob);
                fish_cont.CopyFrom(temp);
                temp.Dispose();
                fish_velocity.CopyFrom(tempV);
                tempV.Dispose();
                yield return new WaitForFixedUpdate();
            }
            #endregion

            #region Boid Jobs
            //Obstacle avoidance (not a job because Physics.Overlaps)
            for (int i = 0; i < fish_cont.Length; i++)
            {
                Matrix4x4 trs = fish_cont[i];
                Vector3 velocity = fish_velocity[i];
                Vector3 position = trs.GetPosition();

                velocity -= ObstacleAvoidance(position);
                fish_velocity[i] = velocity;
            }

            #region Cohesion Job
            CohesionJob cohesionJob = new CohesionJob()
            {
                fish_cont = fish_cont,
                fish_velocity = fish_velocity,
                cohesionRadius = cohesionRadius,
                maxSpeed = maxSpeed
            };
            cohesionHandle = cohesionJob.Schedule(fishTRS.Count, 8);
            yield return new WaitUntil(() => cohesionHandle.IsCompleted);
            cohesionHandle.Complete();
            #endregion

            #region Alignment Job
            AlignmentJob alignmentJob = new AlignmentJob()
            {
                fish_cont = fish_cont,
                fish_velocity = fish_velocity,
                alignmentRadius = alignmentRadius,
                maxSpeed = maxSpeed
            };
            alignmentHandle = alignmentJob.Schedule(fishTRS.Count, 8);
            yield return new WaitUntil(() => alignmentHandle.IsCompleted);
            alignmentHandle.Complete();
            #endregion

            #region Inverse Magnetism Job
            InverseMagnetismJob magnetismJob = new InverseMagnetismJob()
            {
                fish_cont = fish_cont,
                fish_velocity = fish_velocity,
                inverseMagnetismRadius = inverseMagnetismRadius,
                repulsionForce = repulsionForce
            };
            magnetismHandle = magnetismJob.Schedule(fishTRS.Count, 8);
            yield return new WaitUntil(() => magnetismHandle.IsCompleted);
            magnetismHandle.Complete();
            #endregion

            #region Obstacle Avoidance Job
            /*ObstacleAvoidanceJob obstacleJob = new ObstacleAvoidanceJob()
            {
                fish_cont = fish_cont,
                fish_velocity = fish_velocity,
                obstacleAvoidanceRadius = obstacleAvoidanceRadius,
                obstacleRepulsionForce = obstacleRepulsionForce
            };
            obstacleHandle = obstacleJob.Schedule(fishTRS.Count, 8);
            yield return new WaitUntil(() => obstacleHandle.IsCompleted);
            obstacleHandle.Complete();*/
            #endregion
            #endregion

            #region Update Job
            UpdateJob job = new UpdateJob()
            {
                deltaTime = Time.time - lastTime,
                fish_cont = fish_cont,
                fish_velocity = fish_velocity,
                maxSpeed = maxSpeed
            };

            lastTime = Time.time;

            handle = job.Schedule(fishTRS.Count, 8);
            yield return new WaitUntil(() => handle.IsCompleted);
            handle.Complete();
            #endregion

            #region Update Render List
            Parallel.For(0, fishTRS.Count, (i) =>
            {
                fishTRS[i] = fish_cont[i];
                fishVelocity[i] = fish_velocity[i];
            });
            #endregion
            yield return new WaitForSeconds(tickDelay);
        }
    }

    [BurstCompile]
    struct UpdateJob : IJobParallelFor
    {
        [NativeDisableParallelForRestriction] public NativeList<Matrix4x4> fish_cont;
        [NativeDisableParallelForRestriction] public NativeList<Vector3> fish_velocity;
        public float deltaTime;
        public float maxSpeed;
        public void Execute(int i)
        {
            Matrix4x4 trs = fish_cont[i];
            Vector3 position = trs.GetPosition();
            Vector3 scale = trs.lossyScale;
            Vector3 velocity = fish_velocity[i];

            /*velocity += Cohesion(position)
                + Alignment(position, velocity)
                + InverseMagnetism(position)
                + ObstacleAvoidance(position);*/

            if (velocity.magnitude > maxSpeed)
            {
                velocity = velocity.normalized * maxSpeed;
            }


            position += velocity * deltaTime;

            Quaternion rotation = Quaternion.LookRotation(velocity);

            fish_cont[i] = Matrix4x4.TRS(position, rotation, scale);
            fish_velocity[i] = velocity;
        }
    }

    [BurstCompile]
    struct CohesionJob : IJobParallelFor
    {
        [NativeDisableParallelForRestriction] public NativeList<Matrix4x4> fish_cont;
        [NativeDisableParallelForRestriction] public NativeList<Vector3> fish_velocity;
        public float cohesionRadius;
        public float maxSpeed;

        public void Execute(int i)
        {
            Matrix4x4 trs = fish_cont[i];
            Vector3 velocity = fish_velocity[i];
            Vector3 position = trs.GetPosition();

            Vector3 average = Vector3.zero;
            int found = 0;

            for (int j = 0; j < fish_cont.Length; j++)
            {
                Matrix4x4 newFish = fish_cont[j];
                Vector3 newPosition = newFish.GetPosition();
                Vector3 diff = position - newPosition;
                if (diff.sqrMagnitude < cohesionRadius * cohesionRadius && i != j)
                {
                    average += diff;
                    found += 1;
                }
            }
            if (found > 0)
            {
                average = average / found;
            }
            velocity += Vector3.Lerp(Vector3.zero, average, average.magnitude / cohesionRadius);

            /*if (velocity.magnitude > maxSpeed)
            {
                velocity = velocity.normalized * maxSpeed;
            }*/

            Debug.Log("Cohesion : " + velocity);
            fish_velocity[i] = velocity;
        }
    }

    public Vector3 Cohesion(Vector3 position)
    {
        Vector3 average = Vector3.zero;
        int found = 0;
        for (int i = 0; i < fishTRS.Count; i++)
        {
            Matrix4x4 newFish = fishTRS[i];
            Vector3 newPosition = newFish.GetPosition();
            Vector3 diff = position - newPosition;
            if (diff.sqrMagnitude < cohesionRadius * cohesionRadius && diff.magnitude > 0)
            {
                average += diff;
                found += 1;
            }
        }
        if (found > 0)
        {
            average = average / found;
        }

        Vector3 result = Vector3.Lerp(Vector3.zero, average, average.magnitude / cohesionRadius);
        return result;
    }

    [BurstCompile]
    struct AlignmentJob : IJobParallelFor
    {
        [NativeDisableParallelForRestriction] public NativeList<Matrix4x4> fish_cont;
        [NativeDisableParallelForRestriction] public NativeList<Vector3> fish_velocity;
        public float alignmentRadius;
        public float maxSpeed;

        public void Execute(int i)
        {
            Matrix4x4 trs = fish_cont[i];
            Vector3 velocity = fish_velocity[i];
            Vector3 position = trs.GetPosition();

            Vector3 average = Vector3.zero;
            int found = 0;

            for (int j = 0; j < fish_cont.Length; j++)
            {
                Matrix4x4 newFish = fish_cont[j];
                Vector3 newPosition = newFish.GetPosition();
                Vector3 diff = position - newPosition;
                Vector3 newVelocity = fish_velocity[j];
                if (diff.sqrMagnitude < alignmentRadius * alignmentRadius && i != j)
                {
                    average += newVelocity;
                    found += 1;
                }
            }
            if (found > 0)
            {
                average = average / found;
            }
            velocity += Vector3.Lerp(velocity, average, average.magnitude / alignmentRadius);
            Debug.Log("Alignement : " + velocity);

            /*if (velocity.magnitude > maxSpeed)
            {
                velocity = velocity.normalized * maxSpeed;
            }*/
            fish_velocity[i] = velocity;
        }
    }

    Vector3 Alignment(Vector3 position, Vector3 velocity)
    {
        Vector3 average = Vector3.zero;
        int found = 0;

        for (int i = 0; i < fishTRS.Count; i++)
        {
            Matrix4x4 newFish = fishTRS[i];
            Vector3 newPosition = newFish.GetPosition();
            Vector3 newVelocity = fishVelocity[i];
            Vector3 diff = position - newPosition;
            if (diff.sqrMagnitude < alignmentRadius * alignmentRadius && diff.magnitude > 0)
            {
                average += newVelocity;
                found += 1;
            }
        }
        if (found > 0)
        {
            average = average / found;
        }

        return Vector3.Lerp(velocity, average, average.magnitude / alignmentRadius);
    }

    [BurstCompile]
    struct InverseMagnetismJob : IJobParallelFor
    {
        [NativeDisableParallelForRestriction] public NativeList<Matrix4x4> fish_cont;
        [NativeDisableParallelForRestriction] public NativeList<Vector3> fish_velocity;
        public float inverseMagnetismRadius;
        public float repulsionForce;

        public void Execute(int i)
        {
            Matrix4x4 trs = fish_cont[i];
            Vector3 velocity = fish_velocity[i];
            Vector3 position = trs.GetPosition();

            Vector3 average = Vector3.zero;
            int found = 0;

            for (int j = 0; j < fish_cont.Length; j++)
            {
                Matrix4x4 newFish = fish_cont[j];
                Vector3 newPosition = newFish.GetPosition();
                Vector3 diff = position - newPosition;
                if (diff.sqrMagnitude < inverseMagnetismRadius * inverseMagnetismRadius && i != j)
                {
                    average += diff;
                    found += 1;
                }
            }
            if (found > 0)
            {
                average = average / found;
            }
            velocity -= Vector3.Lerp(Vector3.zero, average, inverseMagnetismRadius / average.magnitude) * repulsionForce;
            Debug.Log("Magnétisme " + velocity);
            fish_velocity[i] = velocity;
        }
    }

    Vector3 InverseMagnetism(Vector3 position)
    {
        Vector3 average = Vector3.zero;
        int found = 0;
        for (int i = 0; i < fishTRS.Count; i++)
        {
            Matrix4x4 newFish = fishTRS[i];
            Vector3 newPosition = newFish.GetPosition();
            Vector3 diff = position - newPosition;
            if (diff.sqrMagnitude < inverseMagnetismRadius * inverseMagnetismRadius && diff.magnitude > 0)
            {
                average += diff;
                found += 1;
            }
        }
        if (found > 0)
        {
            average = average / found;
        }

        return -Vector3.Lerp(Vector3.zero, average, inverseMagnetismRadius / average.magnitude) * repulsionForce;
    }

    Vector3 ObstacleAvoidance(Vector3 position)
    {
        var colliders = Physics.OverlapSphere(position, obstacleAvoidanceRadius);
        Vector3 average = Vector3.zero;
        int found = 0;

        foreach(Collider c in colliders)
        {
            var diff = c.ClosestPoint(transform.position) - transform.position;
            average += diff;
            found += 1;
        }

        if (found > 0)
        {
            average = average / found;
        }

        return Vector3.Lerp(Vector3.zero, new Vector3(average.x, 0, average.z), average.magnitude / obstacleAvoidanceRadius) * obstacleRepulsionForce;
    }

    [BurstCompile]
    struct ObstacleAvoidanceJob : IJobParallelFor
    {
        [NativeDisableParallelForRestriction] public NativeList<Matrix4x4> fish_cont;
        [NativeDisableParallelForRestriction] public NativeList<Vector3> fish_velocity;
        public float obstacleAvoidanceRadius;
        public float obstacleRepulsionForce;

        public void Execute(int i)
        {
            Matrix4x4 trs = fish_cont[i];
            Vector3 position = trs.GetPosition();
            Vector3 velocity = fish_velocity[i];

            Vector3 average = Vector3.zero;
            int found = 0;

            Collider[] colliders = Physics.OverlapSphere(position, obstacleAvoidanceRadius);
            

            foreach (Collider c in colliders)
            {
                Vector3 diff = c.ClosestPoint(position) - position;
                average += diff;
                found += 1;
            }

            if (found > 0)
            {
                average = average / found;
            }

            velocity -= Vector3.Lerp(Vector3.zero, average, average.magnitude / obstacleAvoidanceRadius) * obstacleRepulsionForce;
            fish_velocity[i] = velocity;
        }       
    }
}
