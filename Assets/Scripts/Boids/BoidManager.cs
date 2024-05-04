using System.Collections;
using System.Collections.Generic;
using System.Threading.Tasks;
using Unity.Burst;
using Unity.Collections;
using Unity.Jobs;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

public class BoidManager : MonoBehaviour
{
    [Header("Mesh")]
    [SerializeField]
    Mesh mesh;
    //ALWAYS MAKE SURE the mesh is readable. If not open the mesh as a text file and change m_isReadable from 0 to 1

    [SerializeField]
    Material material;

    [Header("Settings")]
    [SerializeField]
    int maxPopulation;

    [SerializeField]
    float radius;

    [SerializeField]
    float maxSpeed;

    [SerializeField]
    float positionY;

    [SerializeField, Min(0.0001f)]
    float tickDelay;


    [Header("Cohésion")]
    [SerializeField]
    float cohesionRadius;

    [Header("Alignement")]
    [SerializeField]
    float alignmentRadius;

    [Header("Magnétisme")]
    [SerializeField]
    float inverseMagnetismRadius;
    [SerializeField]
    float repulsionForce;

    [Header("Obstacles")]
    [SerializeField]
    float obstacleAvoidanceRadius;
    [SerializeField]
    float obstacleRepulsionForce;




    List<Matrix4x4> fishTRS; //The TRS stands from translation, rotation, scale
    List<Vector3> fishVelocity;

    NativeList<Matrix4x4> fish_cont;
    NativeList<Vector3> fish_velocity;

    JobHandle handle;
    JobHandle cohesionHandle;
    JobHandle alignmentHandle;
    JobHandle magnetismHandle;
    //JobHandle obstacleHandle;
    
    private void Awake()
    {
        fishTRS = new List<Matrix4x4>();
        fishVelocity = new List<Vector3>();

        //SerializedObject s = new SerializedObject(mesh); //Don't uncomment that !
        //s.FindProperty("m_IsReadable").boolValue = true;
        //The mesh is supposed to be readable by default, but you can't be too sure I guess

        for (int i = 0; i < maxPopulation; i++)
        {
            Vector3 spawnPoint = RandomSpawnPoint(radius, positionY);
            AddFish(spawnPoint, Quaternion.Euler(0, 0, 90), 100f) ;
            fishVelocity.Add(new Vector3(1, 0, 0));
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

#if false
    private void OnDrawGizmos()
    {
        Gizmos.color = Color.blue;
        for (int i = 0; i < fishTRS.Count; i++)
        {
            Gizmos.DrawMesh(mesh, 0, fishTRS[i].GetPosition(), Quaternion.identity, new Vector3(100, 100, 100));
        }
    } 
#endif

    public Vector3 RandomSpawnPoint(float radius, float yoffset, Vector3 origin = new Vector3())
    {
        Vector3 randPos = Random.insideUnitSphere * radius;
        randPos += origin;
        randPos.y = yoffset;
        return randPos;
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
            #region Update Fish Container & Velocity
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

            //Obstacle avoidance (not a job because Physics.Overlaps)
            for (int i = 0; i < fish_cont.Length; i++)
            {
                Matrix4x4 trs = fish_cont[i];
                Vector3 velocity = fish_velocity[i];
                Vector3 position = trs.GetPosition();

                velocity -= ObstacleAvoidance(position);
                fish_velocity[i] = velocity;
            }

            #region Jobs (delete?)
            /*
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
            obstacleHandle.Complete();
            #endregion
            #endregion
            */
            #endregion

            #region Update Job
            UpdateJob job = new UpdateJob()
            {
                deltaTime = Time.time - lastTime,
                fish_cont = fish_cont,
                fish_velocity = fish_velocity,
                maxSpeed = maxSpeed,
                cohesionRadius = cohesionRadius,
                inverseMagnetismRadius = inverseMagnetismRadius,
                repulsionForce = repulsionForce,
                alignmentRadius = alignmentRadius
            };

            lastTime = Time.time;

            handle = job.Schedule(fishTRS.Count, 64);
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
        public float cohesionRadius;
        public float inverseMagnetismRadius;
        public float repulsionForce;
        public float alignmentRadius;

        public void Execute(int i)
        {
            Matrix4x4 trs = fish_cont[i];
            Vector3 position = trs.GetPosition();
            //Quaternion rotation = trs.rotation;
            Vector3 scale = trs.lossyScale;
            Vector3 oldVelocity = fish_velocity[i];
            Vector3 newVelocity = oldVelocity;

            Vector3 average = Vector3.zero;
            int found = 0;

            /*velocity += Cohesion(position)
                + Alignment(position, velocity)
                + InverseMagnetism(position)
                + ObstacleAvoidance(position);*/
            #region Cohesion
            for (int j = 0; j < fish_cont.Length; j++)
            {
                Matrix4x4 newFish = fish_cont[j];
                Vector3 newPosition = newFish.GetPosition();
                Vector3 diff = newPosition - position;
                if (diff.magnitude < cohesionRadius && i != j)
                {
                    average += diff;
                    found += 1;
                }
            }
            if (found > 0)
            {
                average = average / found;
                newVelocity += Vector3.Lerp(Vector3.zero, average, average.magnitude / cohesionRadius);
            }
            #endregion

            #region Alignment
            average = Vector3.zero;
            found = 0;

            for (int j = 0; j < fish_cont.Length; j++)
            {
                Matrix4x4 otherFish = fish_cont[j];
                Vector3 otherPosition = otherFish.GetPosition();
                Vector3 diff = otherPosition - position;
                Vector3 otherVelocity = fish_velocity[j];
                if (diff.magnitude < alignmentRadius && i != j)
                {
                    average += otherVelocity;
                    found += 1;
                }
            }
            if (found > 0)
            {
                average = average / found;
                newVelocity += Vector3.Lerp(oldVelocity, average, average.magnitude / alignmentRadius);
            }


            #endregion

            #region InverseMagnetism
            average = Vector3.zero;
            found = 0;

            for (int j = 0; j < fish_cont.Length; j++)
            {
                Matrix4x4 newFish = fish_cont[j];
                Vector3 newPosition = newFish.GetPosition();
                Vector3 diff = newPosition - position;
                if (diff.magnitude < inverseMagnetismRadius && i != j)
                {
                    average += diff;
                    found += 1;
                }
            }
            if (found > 0)
            {
                average = average / found;
                newVelocity -= Vector3.Lerp(Vector3.zero, average, oldVelocity.magnitude / inverseMagnetismRadius) * repulsionForce;
            }
            #endregion

            if (newVelocity.magnitude > maxSpeed)
            {
                newVelocity = newVelocity.normalized * maxSpeed;
            }

            position += newVelocity * deltaTime;

            Quaternion rotation = Quaternion.LookRotation(newVelocity);
            rotation *= Quaternion.Euler(0, -90, 90);

            fish_cont[i] = Matrix4x4.TRS(position, rotation, scale);
            fish_velocity[i] = newVelocity;
        }
    }

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
