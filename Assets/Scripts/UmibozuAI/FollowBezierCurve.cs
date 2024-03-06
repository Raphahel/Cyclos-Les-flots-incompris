using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using UnityEngine.AI;

public class FollowBezierCurve : MonoBehaviour
{
    [SerializeField] private Transform[] routes;
    //private int routeToGo;
    private float tParam;
    private Vector3 objectPosition;
    [SerializeField] private float speedModifier;
    //private bool coroutineAllowed;

    private float radius;

    void Start()

    {
        //routeToGo = 0;
        tParam = 0f;
        //coroutineAllowed = true;
        radius = 100f;
        StartCoroutine(GoByTheRoute());
    }

    /*void Update()

    {
        if (coroutineAllowed)
        {
            StartCoroutine(GoByTheRoute(routeToGo));
        }

    }*/



    private IEnumerator GoByTheRoute()

    {

        Vector3 p0 = RandomNavSphere(transform.position, radius, -1);
        Vector3 p1 = RandomNavSphere(transform.position, radius, -1);
        Vector3 p2 = RandomNavSphere(transform.position, radius, -1);
        Vector3 p3 = RandomNavSphere(transform.position, radius, -1);

        while (tParam < 1)
        {
            tParam += Time.deltaTime * speedModifier;
            objectPosition = Mathf.Pow(1 - tParam, 3) * p0 + 3 * Mathf.Pow(1 - tParam, 2) * tParam * p1 + 3 * (1 - tParam) * Mathf.Pow(tParam, 2) * p2 + Mathf.Pow(tParam, 3) * p3;
            transform.position = objectPosition;
            yield return new WaitForEndOfFrame();
        }

        tParam = 0;
        /*routeToGo += 1;

        if (routeToGo > routes.Length - 1)

        {

            routeToGo = 0;

        }*/

        StartCoroutine(GoByTheRoute(p3));
    }

    private IEnumerator GoByTheRoute(Vector3 startPosition)
    {
        Vector3 p0 = startPosition;
        Vector3 p1 = RandomNavSphere(transform.position, radius, -1);
        Vector3 p2 = RandomNavSphere(transform.position, radius, -1);
        Vector3 p3 = RandomNavSphere(transform.position, radius, -1);

        while (tParam < 1)
        {
            tParam += Time.deltaTime * speedModifier;
            objectPosition = Mathf.Pow(1 - tParam, 3) * p0 + 3 * Mathf.Pow(1 - tParam, 2) * tParam * p1 + 3 * (1 - tParam) * Mathf.Pow(tParam, 2) * p2 + Mathf.Pow(tParam, 3) * p3;
            transform.position = objectPosition;
            yield return new WaitForEndOfFrame();
        }

        tParam = 0;
        /*routeToGo += 1;

        if (routeToGo > routes.Length - 1)

        {

            routeToGo = 0;

        }*/

        StartCoroutine(GoByTheRoute(p3));
    }

    public static Vector3 RandomNavSphere(Vector3 origin, float dist, int layermask)
    {
        Vector3 randDirection = Random.insideUnitSphere * dist;

        randDirection += origin;

        NavMeshHit navHit;

        NavMesh.SamplePosition(randDirection, out navHit, dist, layermask);

        return navHit.position;
    }
}
