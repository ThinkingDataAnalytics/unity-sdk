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
        if (GUI.Button(new Rect(20, 40, 300, 50), "Back To TAExample"))
        {
            SceneManager.LoadScene("Sample", LoadSceneMode.Single);
        }
        if (GUI.Button(new Rect(20*2+300, 40, 300, 50), "Track"))
        {
            ThinkingAnalytics.ThinkingAnalyticsAPI.Track("TA", new Dictionary<string, object>() { { "new_scene", "NewScene"} });
        }
    }
}
