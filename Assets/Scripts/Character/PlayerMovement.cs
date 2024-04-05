using System.Collections;
using System.Collections.Generic;
using UnityEditor.Rendering.Universal;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerMovement : MonoBehaviour
{
    [Header("Déplacement")]
    [SerializeField]
    private float vitesseSol;
    [SerializeField]
    private float vitesseAir;

    [Header("Saut")]
    [SerializeField]
    private float hauteurSaut;
    [SerializeField]
    private float detectionHauteur;
    [SerializeField]
    private float vitesseChute;

    [Header("Debug Value")]
    [SerializeField]
    private bool debugHauteur;
    [SerializeField]
    private float vitesse;


    private Rigidbody2D rb;
    private Animator animator;
    private SpriteRenderer sprite;

    private Vector2 ordreMouvemement = new Vector2 (0, 0);
    bool wantJump = false;
    bool canJump = false;


    private Controles inputMap;

    void Start()
    {
        rb = gameObject.GetComponent<Rigidbody2D>();
        animator = gameObject.GetComponent<Animator>();
        sprite = gameObject.GetComponent<SpriteRenderer>();

        inputMap = new Controles();
        inputMap.Enable();
        Subscribe();
        vitesse = vitesseSol;
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        //Vérifier si le personnage est au sol
        if (EstAuSol())
        {
            canJump = true;
            vitesse = vitesseSol;
        }

        //Si le personnage peut sauter et veut sauter
        if(wantJump)
        {
            if (canJump)
            {
                rb.AddForce(hauteurSaut * transform.up, ForceMode2D.Impulse);
                canJump = false;
                vitesse = vitesseAir;
            }
            else
            {
                rb.AddForce(vitesseChute / 3 * -transform.up);
            }
        }
        else
        {
            rb.AddForce(vitesseChute * -transform.up);
        }


        if (ordreMouvemement != Vector2.zero)
        {
            transform.Translate (ordreMouvemement * vitesse * Time.deltaTime);
            if(ordreMouvemement.x == 1)
            {
                animator.Play("WalkCycle");
                sprite.flipX = true;
            }
            else
            {
                animator.Play("WalkCycle");
                sprite.flipX = false;
            }
        }
        else
        {
            animator.Play("Idle");
        }


    }

    private bool EstAuSol()
    {
        if (debugHauteur)
        {
            Debug.DrawRay(transform.position, -Vector3.up * detectionHauteur, Color.black, 1f);
        }
        return Physics2D.Raycast(transform.position, -Vector3.up, detectionHauteur);
    }

    private void StartMove(InputAction.CallbackContext context)
    {
        ordreMouvemement.x = context.ReadValue<Vector2>().x;
    }
    private void StopMove(InputAction.CallbackContext context)
    {
        ordreMouvemement = Vector2.zero;
    }

    private void Jump(InputAction.CallbackContext context)
    {
        if (canJump)
        {
            wantJump = true;
            canJump = false;
        }
    }

    private void JumpReleased(InputAction.CallbackContext context)
    {
        wantJump = false;
    }

    public void Subscribe()
    {
        inputMap.MovementChar.Move.performed += StartMove;
        inputMap.MovementChar.Move.canceled += StopMove;
        inputMap.MovementChar.Jump.performed += Jump;
        inputMap.MovementChar.Jump.canceled += JumpReleased;
    }

    public void Unsubscribe()
    {
        inputMap.MovementChar.Move.performed -= StartMove;
        inputMap.MovementChar.Move.canceled -= StopMove;
        inputMap.MovementChar.Jump.performed -= Jump;
        inputMap.MovementChar.Jump.canceled -= JumpReleased;
    }
}
