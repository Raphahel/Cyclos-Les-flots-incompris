using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FlottaisonRotation : Flottaison
{
    [Header("Rotation controler")]
    [SerializeField]
    private BateauMouvement bateau;
    [SerializeField]
    private float sensibiliteHauteur;

    private bool inWater;

    private void Start()
    {
        bateau.AddFlotteur();
        Vector3 waveHeight = GestionnaireVagues.instance.HauteurVague(transform.position);
        if(transform.position.y < waveHeight.y)
        {
            inWater = true;
            bateau.FlottImmerge();
        }
        else
        {
            inWater = false;
        }
    }

    new private void FixedUpdate()
    {
        base.FixedUpdate();
        if(!inWater && waveheigth > transform.position.y - sensibiliteHauteur)
        {
            inWater = true;
            bateau.FlottImmerge();
        }
        else if(inWater && waveheigth < transform.position.y - sensibiliteHauteur)
        {
            inWater = false;
            bateau.FlottEmerge();
        }
    }

}
