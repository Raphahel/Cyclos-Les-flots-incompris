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

    //Variable d'interaction avec les flotteur de rotation
    private int nbFlotteursRota = 0;
    private int nbFlotteurImmergé = 0;
    
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
        Mouvement();
    }


    private void Mouvement() 
    {
        Debug.Log("nbFlotteurRota = " + nbFlotteursRota + " nb Flotteur immergé = " + nbFlotteurImmergé);
        float facteurImmertion = nbFlotteurImmergé / nbFlotteursRota;


        //ajout de la vitesse
        rb.AddForce(transform.forward * forceVitesse * facteurImmertion, ForceMode.Acceleration);
        
        //Vérification que la vitesse max n'est pas dépassée
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

        
        //Modification de la vitesse de rotation si le navire est à l'arrêt ou en mouvement
        if(Vector3.Dot(transform.forward, rb.velocity) < 2)
        {
            rotationSpeed = Mathf.Lerp(rotationSpeed, 0, 0.1f);
        }
        else
        {
            rotationSpeed = Mathf.Lerp(rotationSpeed, SaveRotation, 0.5f);
        }

        //Application de la rotation
        rb.AddForceAtPosition(directionRotation * rotationSpeed * -transform.right * facteurImmertion, tranformMoteur.position, ForceMode.Acceleration);
    }

    //Fonction de modifiaction des flotteurs de Rotation
    public void AddFlotteur() { nbFlotteursRota++; }
    public void FlottImmerge() { nbFlotteurImmergé++; }
    public void FlottEmerge() { nbFlotteurImmergé--; }  
    
    
    //Section de gestion des inputs :
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
