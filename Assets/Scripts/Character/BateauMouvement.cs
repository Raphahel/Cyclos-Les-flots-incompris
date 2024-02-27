using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.ProBuilder.Shapes;

public class BateauMouvement : MonoBehaviour
{
    [Header("Variables de mouvement")]
    [SerializeField]
    int rotationSpeed = 5;
    [SerializeField]
    int acceleration = 10;
    [SerializeField]
    float vitesseMax = 500;

    [Header("Game objets")]
    [SerializeField]
    private Transform tranformMoteur;

    //Variables uniquement utilisé pour calculs
    private float forceVitesse = 0;
    private float forceRotation = 0;
    private float sqrVitesseMax;
    
    //Composants instanciés ou récupéré à runtime
    private Controles inputMap;
    private Rigidbody rb;


    void Start()
    {
        sqrVitesseMax = vitesseMax * vitesseMax;
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


        Mouvement();
    }


    private void Mouvement() 
    {
        //Cimetière des essais de rotation (This is fine)
        //transform.RotateAround(tranformMoteur.position, Vector3.up, forceRotation * Time.deltaTime);
        //Debug.DrawLine(transform.right, transform.right * 3, new Color(0, 0, 1.0f));
        //rb.AddRelativeTorque(Vector3.up * forceRotation);
        //Vector3 force = transform.right * forceRotation;
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
        /*if (forceRotation != 0)
        {
            forceRotation -= rb.velocity.sqrMagnitude/10;
            Debug.Log(rb.velocity.sqrMagnitude);
        }
*/
        if(rb.velocity.sqrMagnitude > 1)
        {
            transform.Rotate(0, forceRotation * Time.deltaTime, 0);
        }



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
        forceRotation = vect.x * rotationSpeed; 
    }

    private void StopTourner(InputAction.CallbackContext context)
    {
        forceRotation = 0;
    }

    private void Subscribe()
    {
        inputMap.MovementBateau.Accelerer.performed += StartMove;
        inputMap.MovementBateau.Accelerer.canceled += StopMove;
        inputMap.MovementBateau.Tourner.performed += StartTourner;
        inputMap.MovementBateau.Tourner.canceled += StopTourner;
    }
}
