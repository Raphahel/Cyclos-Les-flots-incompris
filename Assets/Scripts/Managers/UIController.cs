using System.Collections;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using Yarn.Unity;

public class UIController : MonoBehaviour
{
    [SerializeField] public Image blackOutBox;

    public static UIController instance { get; private set; }

    private void Awake()
    {
        if (instance == null)
        {
            instance = this;
            
        }
        else if (instance != this)
        {
            Debug.Log("Instance already exists.");
            Destroy(gameObject);
        }
    }

    // Start is called before the first frame update
    void Start()
    {
        //blackOutBox = GetComponentInChildren<Image>();
        StartCoroutine(FadeToBlack(false));
    }

    public void StartFade(bool fadeToBlack = true, int fadeSpeed = 1)
    {
        StartCoroutine(FadeToBlack(fadeToBlack, fadeSpeed));
    }


    public void FadeToScene2D(string scene)
    {
        DayNightManager.StopTime();
        StartCoroutine(StartFadeToScene2D(scene));
    }

    public void FadeToScene(string scene)
    { 
        StartCoroutine(StartFadeToScene(scene));
    }

    public IEnumerator StartFadeToScene(string scene, bool fadeToBlack = true, int fadeSpeed = 1)
    {
        AsyncOperation loading = SceneManager.LoadSceneAsync(scene);
        loading.allowSceneActivation = false;
        yield return StartCoroutine(FadeToBlack(fadeToBlack, fadeSpeed));
        DayNightManager.StartTime();
        loading.allowSceneActivation = true;
    }

    public IEnumerator StartFadeToScene2D(string scene, bool fadeToBlack = true, int fadeSpeed = 1)
    {
        AsyncOperation loading = SceneManager.LoadSceneAsync(scene);
        loading.allowSceneActivation = false;
        yield return StartCoroutine(FadeToBlack(fadeToBlack, fadeSpeed));
        loading.allowSceneActivation = true;
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

    public void QuitGame()
    {
        Application.Quit();
    }
}
