using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.ProBuilder.Shapes;

public class BateauMouvement : MonoBehaviour
{
    [Header("Variables de mouvement")]
    [SerializeField]
    float maxRotationSpeed; 
    [SerializeField]
    int acceleration = 10;
    [SerializeField]
    float vitesseMax = 500;

    [Header("Game objets")]
    [SerializeField]
    private Transform tranformMoteur;

    //Variables uniquement utilisé pour calculs
    private float forceVitesse = 0;
    private float directionRotation = 0;
    private float forceRotation;
    float rotationSpeed = 5;
    private float sqrVitesseMax;
    private float SaveRotation;
    
    //Composants instanciés ou récupéré à runtime
    private Controles inputMap;
    private Rigidbody rb;


    void Awake()
    {
        sqrVitesseMax = vitesseMax * vitesseMax;
        SaveRotation = rotationSpeed;
        rb = gameObject.GetComponent<Rigidbody>();
        inputMap = new Controles();
        inputMap.Enable();
        Subscribe();
    }

    void FixedUpdate()
    {
        //Pour Debug uniquement à retirer pour les build
        //Permet de changer la vitesse max à runtime dans l'éditeur
        sqrVitesseMax = vitesseMax * vitesseMax;
        SaveRotation = maxRotationSpeed;

        Debug.Log(directionRotation);
        Mouvement();
    }


    private void Mouvement() 
    {
        //Cimetière des essais de rotation (This is fine)
        //transform.RotateAround(tranformMoteur.position, Vector3.up, directionRotation * Time.deltaTime);
        //Debug.DrawLine(transform.right, transform.right * 3, new Color(0, 0, 1.0f));
        //rb.AddRelativeTorque(Vector3.up * directionRotation);
        //Vector3 force = transform.right * directionRotation;
        //rb.AddForceAtPosition(force, tranformMoteur.position, ForceMode.Acceleration);


        //ajout de la vitesse
        rb.AddForce(transform.forward * forceVitesse, ForceMode.Acceleration);
        
        //V2rification que la vitesse max n'est pas déplacée
        //Test sur la moitié de la vitesse max pour le déplacement à reculon
        if (rb.velocity.sqrMagnitude > sqrVitesseMax / 2)
        {
            Vector3 contreForce = transform.forward * -forceVitesse;
            rb.AddForce(contreForce, ForceMode.Acceleration);
        }
        //Test sur vitesse complète pour l'avancée
        else if (rb.velocity.sqrMagnitude > sqrVitesseMax)
        {
            Vector3 contreForce = transform.forward * -forceVitesse;
            rb.AddForce(contreForce, ForceMode.Acceleration);
        }

        //Rotation
        /*if (directionRotation != 0)
        {
            directionRotation -= rb.velocity.sqrMagnitude/10;
            Debug.Log(rb.velocity.sqrMagnitude);
        }
*/

        if(rb.velocity.sqrMagnitude < 1)
        {
            rotationSpeed = Mathf.Lerp(rotationSpeed, 0, 0.1f);
        }
        else
        {
            rotationSpeed = Mathf.Lerp(rotationSpeed, SaveRotation, 0.5f);
        }

        Debug.Log("directionRotation : " + directionRotation);
        if (directionRotation != 0)
        {
            forceRotation = directionRotation * rotationSpeed;

            float velocityFront = Vector3.Dot(rb.velocity, transform.forward);
            rb.AddForce((-velocityFront / 2) * transform.right);
        }
        else if(directionRotation == 0)
        {
            forceRotation = Mathf.Lerp(forceRotation,0, 0.95f);
        }
        Debug.Log("forceRotation : " + forceRotation);

        transform.Rotate(0, forceRotation * Time.deltaTime, 0);


        //Réduction de l'inertie latérale
        float velocityInDirection = Vector3.Dot(rb.velocity, transform.right);
        rb.AddForce((-velocityInDirection / 2) * transform.right);


    }

    private void StartMove(InputAction.CallbackContext context)
    {
        Vector2 vect = context.ReadValue<Vector2>();
        forceVitesse = vect.y * acceleration;
    }

    private void StopMove(InputAction.CallbackContext context)
    {
        forceVitesse = 0;
    } 

    private void StartTourner(InputAction.CallbackContext context)
    {
        Vector2 vect = context.ReadValue<Vector2>();
        directionRotation = vect.x; 
    }

    private void StopTourner(InputAction.CallbackContext context)
    {
        Debug.Log("FEZAEBFEAESDGFNDAEfxn htzecqf wbdgyfttcqfxzr");
        directionRotation = 0;
    }

    private void Subscribe()
    {
        inputMap.MovementBateau.Accelerer.performed += StartMove;
        inputMap.MovementBateau.Accelerer.canceled += StopMove;
        inputMap.MovementBateau.Tourner.performed += StartTourner;
        inputMap.MovementBateau.Tourner.canceled += StopTourner;
    }
}
