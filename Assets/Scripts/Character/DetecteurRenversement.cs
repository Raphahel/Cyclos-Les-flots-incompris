using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DetecteurRenversement : MonoBehaviour
{
    [SerializeField]
    private BateauMouvement boat;

    private GestionnaireVagues gVague;
    private float timerRenv = 0.5f;
    private bool loading = false;

    private void Awake()
    {
        gVague = GestionnaireVagues.instance;
    }

    private void FixedUpdate()
    {
        float vague = GestionnaireVagues.instance.HauteurVague(transform.position).y;
        if(transform.position.y < vague)
        {
            timerRenv -= Time.fixedDeltaTime;

            if(timerRenv <= 0 && loading != true)
            {
                boat.Death();
                loading = true;
            }
        }
        else
        {
            timerRenv = 0.5f;
        }
    }
}
