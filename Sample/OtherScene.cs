using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using ThinkingData.Analytics;

public class OtherScene : MonoBehaviour
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
        if (GUI.Button(new Rect(20, 40, 300, 50), "Back To TDAnalyticsDemo"))
        {
            SceneManager.LoadScene("TDAnalyticsDemo", LoadSceneMode.Single);
        }
        if (GUI.Button(new Rect(20*2+300, 40, 300, 50), "TrackEvent"))
        {
            TDAnalytics.Track("TA", new Dictionary<string, object>() { { "other_scene", "OtherScene" } });
        }
    }
}
