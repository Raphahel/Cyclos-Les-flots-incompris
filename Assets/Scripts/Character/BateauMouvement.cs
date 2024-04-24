using Cinemachine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class BateauMouvement : MonoBehaviour
{
    [Header("Vie")]
    [SerializeField]
    private int vie = 100;

    [Header("Variables de mouvement")]
    [SerializeField]
    private float maxRotationSpeed; 
    [SerializeField]
    private int acceleration = 10;
    [SerializeField]
    private float vitesseMax = 500;

    [Header("Variable batterie")]
    [SerializeField]
    private float batterieMax = 100f;
    [SerializeField]
    private float batterieRecharge;
    [SerializeField]
    private float BatteriePuissance;
    public bool isCharging = false;
    [SerializeField]
    private float BatterieDrain;
    [SerializeField]
    private float RalentissementBattery = 0.5f;

    [Header("Composants")]
    [SerializeField]
    private Transform tranformMoteur;
    [SerializeField]
    private AudioSource audioMoteur;
    [SerializeField]
    private AudioSource audioVague;
    [SerializeField]
    private Slider BatterieSlider;
    [SerializeField]
    private Slider VieSlider;

    private CinemachineVirtualCamera vcam;

    //Constante de dommage
    private const int DOMMAGEFAIBLE = 15;
    private const int DOMMAGEMOYEN = 25;
    private const int DOMMAGEFORT = 40;

    //Constante son et pitch du Moteur
    private const float VOLUMEMAX = 0.5f;
    private const float VOLUMEMIN = 0f;
    private float volume = 0f;
    private const float VOLUMEMAXVAGUE = 0.6f;
    private const float VOLUMEMINVAGUE = 0.1f;
    private float volumeVague = 0f;
    private const float PITCHMAX = 0.9f;
    private const float PITCHMIN = 0.4f;
    private float pitch = 0f;

    //Variables uniquement utilisé pour calculs
    private float forceVitesse = 0;
    private float directionRotation = 0;
    private float rotationSpeed = 5;
    private float sqrVitesseMax;
    private float SaveRotation;
    private float ralentissement = 1f;

    //Variable d'interaction avec les flotteur de rotation
    private int nbFlotteursRota = 0;
    private int nbFlotteurImmergé = 0;
    
    //Composants instanciés ou récupéré à runtime
    private Controles inputMap;
    private Rigidbody rb;

    private float facteurImmertion = 1;

    public bool inTempete = false;
    private float timer = 0f;

    void Awake()
    {
        sqrVitesseMax = vitesseMax * vitesseMax;
        SaveRotation = rotationSpeed;
        rb = gameObject.GetComponent<Rigidbody>();
        BatteriePuissance = batterieMax;
        inputMap = new Controles();
        inputMap.Enable();
        Subscribe();
    }

    private void Update()
    {
        VieSlider.value = vie;
        BatterieSlider.value = BatteriePuissance;

        //Dommmages dus à la tempête
        if (inTempete && timer >= 2f)
        {
            vie -= 1;
            if(vie <= 0)
            {
                Death();
            }
            timer = 0f;
        }
        else if (inTempete)
        {
            timer += Time.deltaTime;
            BatterieDrain = 0.8f;
        }
        else
        {
            timer = 0f;
            BatterieDrain = 0.4f;
        }
    }

    void FixedUpdate()
    {
        //Pour Debug uniquement à retirer pour les build
        //Permet de changer la vitesse max à runtime dans l'éditeur
        //sqrVitesseMax = vitesseMax * vitesseMax;
        SaveRotation = maxRotationSpeed;
        Mouvement();
        //Debug.Log(transform.eulerAngles.z);

    }


    private void Mouvement() 
    {
        if(nbFlotteursRota !=  0)
        {
            float facteurImmertion = nbFlotteurImmergé / nbFlotteursRota;
        }


        //Application des ralentissements si la batterie est vide/Pleine
        if(BatteriePuissance == 0)
        {
            ralentissement = Mathf.Lerp(ralentissement, RalentissementBattery, 1); 
        }
        else
        {
            ralentissement = Mathf.Lerp(ralentissement, 1f, 1);
        }


        //Rechargement/Vide de la batterie
        if (isCharging)
        {
            BatteriePuissance += batterieRecharge * Time.fixedDeltaTime;
            BatteriePuissance = Mathf.Min(BatteriePuissance, batterieMax);
        }
        else if(forceVitesse != 0)
        {
            BatteriePuissance -= BatterieDrain * Time.fixedDeltaTime;
            BatteriePuissance = Mathf.Max(0, BatteriePuissance);
        }

        
        //Calcul du déplacement

        //ajout de la vitesse
        rb.AddForce(transform.forward * forceVitesse * facteurImmertion * ralentissement, ForceMode.Acceleration);
        
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
        rb.AddForceAtPosition(directionRotation * rotationSpeed * -transform.right * facteurImmertion * ralentissement, tranformMoteur.position, ForceMode.Acceleration);
        

        //Changement du son du moteur selon si le joueur accelère ou non
        if(forceVitesse != 0)
        {
            volume = Mathf.Lerp(volume, VOLUMEMAX, 1f * Time.fixedDeltaTime / 2);
        }
        else
        {
            volume = Mathf.Lerp(volume, VOLUMEMIN, 1f * Time.fixedDeltaTime * 2);
        }
        audioMoteur.volume = volume;

        if (forceVitesse != 0)
        {
            pitch = Mathf.Lerp(pitch, PITCHMAX, 1f * Time.fixedDeltaTime / 2);
        }
        else
        {
            pitch = Mathf.Lerp(pitch, PITCHMIN, 1f * Time.fixedDeltaTime);
        }
        audioMoteur.pitch = pitch;

        //Changement du son des vagues selon la vélocité du joueur
        if (Mathf.Abs(Vector3.Normalize(rb.velocity).x) >= 0.1f || Mathf.Abs(Vector3.Normalize(rb.velocity).z) >= 0.1f)
        {
            volumeVague = Mathf.Lerp(volumeVague, VOLUMEMAXVAGUE, 0.5f * Time.fixedDeltaTime / 2);
        }
        else
        {
            volumeVague = Mathf.Lerp(volumeVague, VOLUMEMINVAGUE, 1f * Time.fixedDeltaTime);
        }
        audioVague.volume = volumeVague;

    }

    //Detection de collision et application de dommage
    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.layer == LayerMask.NameToLayer("Bordures"))
        {
            switch (rb.velocity.sqrMagnitude)
            {
                case < 7:
                    break;
                case < 13:
                    SubirDommage(DOMMAGEFAIBLE);
                    break;
                case < 25:
                    SubirDommage(DOMMAGEMOYEN);
                    break;
                default:
                    SubirDommage(DOMMAGEFORT);
                    break;
            }
     
        }
    }

    public void SubirDommage(int dommages)
    {
        vie -= dommages;
        Mathf.Max(0, vie);
        if(vie <= 0)
        {
            Death();
        }
    }

    //Fonction Mort
    public void Death()
    {
        StartCoroutine(UIController.instance.StartFadeToScene("Ile_2D"));
    }




    //Fonction de modifiaction des paramètre de la batterie
    public void EntrerRecharge() { isCharging = true; }

    public void leaveRecharge() { isCharging = false; }

    public void ChangeDrain(float drain)
    {
        if(drain >= 0) 
        {
            BatterieDrain = drain;
        }
        else
        {
            drain = 0f;
        }
    }




    //Fonction de modification des flotteurs de Rotation
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

    //Input and UI functions

    public void HideUi()
    {
        BatterieSlider.gameObject.SetActive(false);
        VieSlider.gameObject.SetActive(false);
    }

    public void ShowUi()
    {
        BatterieSlider.gameObject.SetActive(true);
        VieSlider.gameObject.SetActive(true);
    }

    public void AugmenterDrag()
    {
        rb.velocity = Vector3.zero;
    }


    public void Subscribe()
    {
        inputMap.MovementBateau.Accelerer.performed += StartMove;
        inputMap.MovementBateau.Accelerer.canceled += StopMove;
        inputMap.MovementBateau.Tourner.performed += StartTourner;
        inputMap.MovementBateau.Tourner.canceled += StopTourner;
    }

    public void Unsubscribe()
    {
        inputMap.MovementBateau.Accelerer.performed -= StartMove;
        inputMap.MovementBateau.Accelerer.canceled -= StopMove;
        inputMap.MovementBateau.Tourner.performed -= StartTourner;
        inputMap.MovementBateau.Tourner.canceled -= StopTourner;
    }
}
