using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class NewScene : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void OnGUI()
    {
        if (GUI.Button(new Rect(10, 20, 300, 50), "Back To TAExample Scene"))
        {
            SceneManager.LoadScene("Sample", LoadSceneMode.Single);
        }
    }
}
