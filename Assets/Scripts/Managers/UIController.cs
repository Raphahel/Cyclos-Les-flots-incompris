using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class UIController : MonoBehaviour
{
    [SerializeField] public Image blackOutBox;

    // Start is called before the first frame update
    void Start()
    {
        blackOutBox = GetComponentInChildren<Image>();
        StartCoroutine(FadeToBlack(false));
    }

    public void StartFade(bool fadeToBlack = true, int fadeSpeed = 1)
    {
        StartCoroutine(FadeToBlack(fadeToBlack, fadeSpeed));
    }

    public IEnumerator FadeToBlack(bool fadeToBlack = true, int fadeSpeed = 1)
    {
        Color objectColor = blackOutBox.color;
        float fadeAmount;

        if (fadeToBlack)
        {
            while (blackOutBox.color.a < 1)
            {
                fadeAmount = objectColor.a + (fadeSpeed * Time.deltaTime);

                objectColor = new Color(objectColor.r, objectColor.g, objectColor.b, fadeAmount);
                blackOutBox.color = objectColor;
                yield return null;
            }
        } else
        {
            while (blackOutBox.color.a > 0)
            {
                fadeAmount = objectColor.a - (fadeSpeed * Time.deltaTime);
                objectColor = new Color(objectColor.r, objectColor.g, objectColor.b, fadeAmount);
                blackOutBox.color = objectColor;
                yield return null;
            }
        }
    }
}
