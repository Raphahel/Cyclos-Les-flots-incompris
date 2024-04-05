using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Flottaison : MonoBehaviour
{
    //Rigidbody de l'object affecté par la flottaison
    [SerializeField]
    protected Rigidbody rb;

    [Header("Variables Flottaison")]
    [SerializeField]
    protected float profondeurAvantSubmerger = 1.0f;
    
    //Force de déplacement d'un flotteur complétement immergé
    [SerializeField]
    protected float forceDeplacement = 3f;
    
    //Nombre total de flotteur attaché à l'objet
    [SerializeField]
    protected int nombreFlotteur = 1;
    
    [SerializeField]
    protected float frottementEau = 0.5f;
    [SerializeField]
    protected float frottementAngulaireEau = 0.3f;

    protected float waveheigth;

    private void OnDrawGizmos()
    {
        Gizmos.DrawWireSphere(transform.position, 0.5f);
    }

    protected void FixedUpdate()
    {
        //Application de la gravité divisé par le nombre de flotteur à l'emplacement du flotteur
        rb.AddForceAtPosition(Physics.gravity / nombreFlotteur, transform.position, ForceMode.Acceleration);

        //Appelle le singleton responsable du calcul de vague CPU
        float waveHeight = GestionnaireVagues.instance.HauteurVague(transform.position).y;;


        if (transform.position.y < waveHeight)
        {
            //Variation du mouvmement selon la profondeur du flotteur dans l'eau (varié avec profondeuravantsubmerger)
            float multiplicateurMouvement = Mathf.Clamp01(waveHeight - transform.position.y / profondeurAvantSubmerger) * forceDeplacement;

            //Force verticale correspondant à la poussée
            rb.AddForceAtPosition(new Vector3(0f, Mathf.Abs(-Physics.gravity.y) * multiplicateurMouvement, 0f), transform.position, ForceMode.Acceleration);
            
            //Frottement latéral
            rb.AddForce(multiplicateurMouvement * -rb.velocity * frottementEau * Time.fixedDeltaTime, ForceMode.Acceleration);
            
            //Frottement angulaire
            rb.AddTorque(multiplicateurMouvement * -rb.angularVelocity * frottementAngulaireEau * Time.fixedDeltaTime, ForceMode.Acceleration);
        }
    } 
}
