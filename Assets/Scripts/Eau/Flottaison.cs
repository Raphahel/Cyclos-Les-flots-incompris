using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Flottaison : MonoBehaviour
{
    [SerializeField]
    private Rigidbody rb;
    
    [Header("Variables Flottaison")]
    [SerializeField]
    private float profondeurAvantSubmerger = 1.0f;
    [SerializeField]
    private float forceDeplacement = 3f;
    [SerializeField]
    private int nombreFlotteur = 1;
    [SerializeField]
    private float frottementEau = 0.5f;
    [SerializeField]
    private float frottementAngulaireEau = 0.3f;

    private void OnDrawGizmos()
    {
        Gizmos.DrawWireSphere(transform.position, 0.5f);
    }

    void FixedUpdate()
    {
        rb.AddForceAtPosition(Physics.gravity / nombreFlotteur, transform.position, ForceMode.Acceleration);

        Vector3 wave = GestionnaireVagues.instance.HauteurVague(transform.position);
        float waveHeight = wave.y;


        if(transform.position.y < waveHeight)
        {
            float multiplicateurMouvement = Mathf.Clamp01(waveHeight - transform.position.y / profondeurAvantSubmerger) * forceDeplacement;
            rb.AddForceAtPosition(new Vector3(0f, Mathf.Abs(-Physics.gravity.y) * multiplicateurMouvement, 0f), transform.position, ForceMode.Acceleration);
            rb.AddForce(multiplicateurMouvement * -rb.velocity * frottementEau * Time.fixedDeltaTime, ForceMode.Acceleration);
            rb.AddTorque(multiplicateurMouvement * -rb.angularVelocity * frottementAngulaireEau * Time.fixedDeltaTime, ForceMode.Acceleration);
        }
    } 
}
