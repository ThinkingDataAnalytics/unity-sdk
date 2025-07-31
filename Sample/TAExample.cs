using UnityEngine;
using UnityEngine.SceneManagement;
using ThinkingAnalytics;
using System.Collections.Generic;
using System;

public class TAExample : MonoBehaviour, IDynamicSuperProperties, IAutoTrackEventCallback
{


    public GUISkin skin;
    private Vector2 scrollPosition = Vector2.zero;
    //private static Color MainColor = new Color(0, 0,0);
    private static Color MainColor = new Color(84f / 255, 116f / 255, 241f / 255);
    private static Color TextColor = new Color(153f / 255, 153f / 255, 153f / 255);
    static int Margin = 20;
    static int Height = 60;
    static float ContainerWidth = Screen.width - 2 * Margin;
    // dynamic super properties interface implementation
    public Dictionary<string, object> GetDynamicSuperProperties()
    {
        return new Dictionary<string, object>() 
        {
            {"dynamic_property", DateTime.Now}
        };
    }
    // auto-tracking events interface implementation
    public Dictionary<string, object> AutoTrackEventCallback(int type, Dictionary<string, object>properties)
    {
        return new Dictionary<string, object>() 
        {
            {"auto_track_dynamic", DateTime.Today}
        };
    }

    private void Awake()
    {
    }
    private void Start()
    {
        // When automatically initializing ThinkingAnalytics, you can call EnableAutoTrack() in Start() to enable auto-tracking events
        // enable auto-tracking events
        // ThinkingAnalyticsAPI.EnableAutoTrack(AUTO_TRACK_EVENTS.ALL);
    }

    void OnGUI() 
    {
        GUILayout.BeginArea(new Rect(Margin, Screen.height * 0.15f, Screen.width-2*Margin, Screen.height));
        scrollPosition = GUILayout.BeginScrollView(new Vector2(0, 0), GUILayout.Width(Screen.width - 2 * Margin), GUILayout.Height(Screen.height - 100));
        GUIStyle style = GUI.skin.label;
        style.fontSize = 25;
        GUILayout.Label("Initialization / UserIDSetting",style);

        GUIStyle buttonStyle = GUI.skin.button;
        buttonStyle.fontSize = 20;
        GUILayout.BeginHorizontal(GUI.skin.box,GUILayout.Height(Height));
        if (GUILayout.Button("ManualInitialization", GUILayout.Height(Height)))
        {
            // 1. Manual initialization (ThinkingAnalytics prefab loaded)
            // ThinkingAnalyticsAPI.StartThinkingAnalytics();


            // 2. Manual initialization (dynamically loading ThinkingAnalyticsAPI script)
            new GameObject("ThinkingAnalytics", typeof(ThinkingAnalyticsAPI));

            // 2.1 Set instance parameters
            string appId = "22e445595b0f42bd8c5fe35bc44b88d6";
            string serverUrl = "https://receiver-ta-dev.thinkingdata.cn";
            ThinkingAnalyticsAPI.StartThinkingAnalytics(appId, serverUrl);

            // 2.1 Set personalized instance parameters
            // string appId = "22e445595b0f42bd8c5fe35bc44b88d6";
            // string serverUrl = "https://receiver-ta-dev.thinkingdata.cn";
            // ThinkingAnalyticsAPI.TAMode mode = ThinkingAnalyticsAPI.TAMode.NORMAL;
            // ThinkingAnalyticsAPI.TATimeZone timeZone = ThinkingAnalyticsAPI.TATimeZone.Local;
            // ThinkingAnalyticsAPI.Token token = new ThinkingAnalyticsAPI.Token(appId, serverUrl, mode, timeZone);
            // Enable encrypted transmission (only iOS/Android)
            // token.enableEncrypt = true;
            // token.encryptVersion = 0;
            // token.encryptPublicKey = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCIPi6aHymT1jdETRci6f1ck535n13IX3p9XNLFu5xncfzNFl6kFVMiMSXMIwWSW2lF6ELtIlDJ0B00qE9C02n6YbIAV+VvVkchydbWrm8VdnEJk/6tIydoUxGyM9pDT6U/PaoEiItl/BawDj3/+KW6U7AejYPij9uTQ4H3bQqj1wIDAQAB";
            // ThinkingAnalyticsAPI.StartThinkingAnalytics(token);

            // 2.2 Multi-project support
            // string appId_2 = "1b1c1fef65e3482bad5c9d0e6a823356";
            // string serverUrl_2 = "https://receiver-ta-dev.thinkingdata.cn";
            // ThinkingAnalyticsAPI.TAMode mode_2 = ThinkingAnalyticsAPI.TAMode.NORMAL;
            // ThinkingAnalyticsAPI.TATimeZone timeZone_2 = ThinkingAnalyticsAPI.TATimeZone.Local;
            // ThinkingAnalyticsAPI.Token token_2 = new ThinkingAnalyticsAPI.Token(appId_2, serverUrl_2, mode_2, timeZone_2);

            // ThinkingAnalyticsAPI.Token[] tokens = new ThinkingAnalyticsAPI.Token[2];
            // tokens[0] = token;
            // tokens[1] = token_2;
            // ThinkingAnalyticsAPI.StartThinkingAnalytics(tokens);

            // Multi-item track events
            // ThinkingAnalyticsAPI.Track("test_event");
            // ThinkingAnalyticsAPI.Track("test_event_2", appId:appId_2);


            // Enable auto-tracking events
            // ThinkingAnalyticsAPI.EnableAutoTrack(AUTO_TRACK_EVENTS.ALL);
            // Enable auto-tracking events, and set properties
            // ThinkingAnalyticsAPI.SetAutoTrackProperties(AUTO_TRACK_EVENTS.ALL, new Dictionary<string, object>()
            //  {
            //      {"auto_track_static_1", "value_1"}
            //  });
            // ThinkingAnalyticsAPI.EnableAutoTrack(AUTO_TRACK_EVENTS.ALL, new Dictionary<string, object>()
            //  {
            //      {"auto_track_static_2", "value_2"}
            //  });
            // Enable auto-tracking events, and set callback
            // ThinkingAnalyticsAPI.EnableAutoTrack(AUTO_TRACK_EVENTS.ALL, this);
        }
        GUILayout.Space(20);
        if (GUILayout.Button("SetAccountID", GUILayout.Height(Height)))
        {
            ThinkingAnalyticsAPI.Login("TA");
        }
        GUILayout.Space(20);
        if (GUILayout.Button("SetDistinctID", GUILayout.Height(Height)))
        {
            ThinkingAnalyticsAPI.Identify("TA_DistinctID");
            Debug.Log("DistinctID: " + ThinkingAnalyticsAPI.GetDistinctId());
        }
        GUILayout.Space(20);
        if (GUILayout.Button("ClearAccountID", GUILayout.Height(Height)))
        {
            ThinkingAnalyticsAPI.Logout();
        }
        GUILayout.EndHorizontal();

        GUILayout.Space(20);
        GUILayout.Label("EventTracking", GUI.skin.label);
        GUILayout.BeginHorizontal(GUI.skin.textArea, GUILayout.Height(Height));
        if (GUILayout.Button("TrackEvent", GUILayout.Height(Height)))
        {
            Dictionary<string, object> properties = new Dictionary<string, object>();
            properties["channel"] = "ta";//string
            properties["age"] = 1;//number - int
            properties["weight"] = 5.46;//number - float
            properties["balance"] = -0.4;//number - negative
            properties["isVip"] = true;//bool
            properties["birthday"] = new DateTime(2022,01,01);//date
            properties["object"] = new Dictionary<string, object>() { { "key", "value" } };//object
            properties["object_arr"] = new List<object>() { new Dictionary<string, object>() { { "key", "value" } } };//object array
            properties["arr"] = new List<object>() { "value" };//array

            ThinkingAnalyticsAPI.Track("TA", properties);
        }
        GUILayout.Space(20);
        if (GUILayout.Button("TrackFirstEvent", GUILayout.Height(Height)))
        {
            Dictionary<string, object> properties = new Dictionary<string, object>();
            properties["status"] = 1;
            TDFirstEvent firstEvent = new TDFirstEvent("DEVICE_FIRST", properties);
            ThinkingAnalyticsAPI.Track(firstEvent);
        }
        GUILayout.Space(20);
        if (GUILayout.Button("TrackUpdateEvent", GUILayout.Height(Height)))
        {
            Dictionary<string, object> properties = new Dictionary<string, object>();
            properties["status"] = 2;
            TDUpdatableEvent updatableEvent = new TDUpdatableEvent("UPDATABLE_EVENT", properties, "test_event_id");
            updatableEvent.EventTime = DateTime.Now;
            updatableEvent.EventTimeZone = TimeZoneInfo.Local;
            ThinkingAnalyticsAPI.Track(updatableEvent);
        }

        GUILayout.Space(20);
        if (GUILayout.Button("TrackOverwriteEvent", GUILayout.Height(Height)))
        {
            Dictionary<string, object> properties = new Dictionary<string, object>();
            properties["status"] = 3;
            TDOverWritableEvent overWritableEvent = new TDOverWritableEvent("OVERWRITABLE_EVENT", properties, "test_event_id");
            overWritableEvent.EventTime = DateTime.Now;
            overWritableEvent.EventTimeZone = TimeZoneInfo.Utc;
            ThinkingAnalyticsAPI.Track(overWritableEvent);
        }

        GUILayout.EndHorizontal();
        GUILayout.BeginHorizontal(GUI.skin.textArea, GUILayout.Height(Height));
        if (GUILayout.Button("TimeEvent", GUILayout.Height(Height)))
        {
            ThinkingAnalyticsAPI.TimeEvent("TATimeEvent");
        }

        GUILayout.Space(20);
        if (GUILayout.Button("Track-TimeEvent", GUILayout.Height(Height)))
        {
            ThinkingAnalyticsAPI.Track("TATimeEvent");
        }

        GUILayout.Space(20);
        if (GUILayout.Button("TrackEventWithDate", GUILayout.Height(Height)))
        {
            Dictionary<string, object> properties = new Dictionary<string, object>();
            ThinkingAnalyticsAPI.Track("TA_Utc", properties, DateTime.Now.AddDays(1), TimeZoneInfo.Utc);
            ThinkingAnalyticsAPI.Track("TA_Local", properties, DateTime.Now.AddDays(1), TimeZoneInfo.Local);
        }

        GUILayout.Space(20);
        if (GUILayout.Button("TrackEventWithLightInstance", GUILayout.Height(Height)))
        {
            string lightToken = ThinkingAnalyticsAPI.CreateLightInstance();
            ThinkingAnalyticsAPI.Login("light_account", lightToken);
            ThinkingAnalyticsAPI.Track("light_event", lightToken);
        }
        GUILayout.EndHorizontal();




        GUILayout.Space(20);
        GUILayout.Label("UserProperty", GUI.skin.label);
        GUILayout.BeginHorizontal(GUI.skin.textArea, GUILayout.Height(Height));
        if (GUILayout.Button("UserSet", GUILayout.Height(Height)))
        {
            Dictionary<string, object> userProperties = new Dictionary<string, object>();
            userProperties["age"] = 1;
            ThinkingAnalyticsAPI.UserSet(userProperties);
        }

        GUILayout.Space(20);
        if (GUILayout.Button("UserSetOnce", GUILayout.Height(Height)))
        {
            Dictionary<string, object> userProperties = new Dictionary<string, object>();
            userProperties["gender"] = 1;
            ThinkingAnalyticsAPI.UserSetOnce(userProperties);

        }
        GUILayout.Space(20);
        if (GUILayout.Button("UserAdd", GUILayout.Height(Height)))
        {
            ThinkingAnalyticsAPI.UserAdd("usercoin", 1);
        }
        GUILayout.Space(20);
        if (GUILayout.Button("UserUnset", GUILayout.Height(Height)))
        {
            ThinkingAnalyticsAPI.UserUnset("usercoin");
        }
        GUILayout.Space(20);
        if (GUILayout.Button("UserDelete", GUILayout.Height(Height)))
        {
            ThinkingAnalyticsAPI.UserDelete();
        }
        GUILayout.Space(20);
        if (GUILayout.Button("UserAppend", GUILayout.Height(Height)))
        {
            List<string> propList = new List<string>();
            propList.Add("ball");
            Dictionary<string, object> userProperties = new Dictionary<string, object>();
            userProperties["prop"] = propList;
            ThinkingAnalyticsAPI.UserAppend(userProperties);
        }
        GUILayout.Space(20);
        if (GUILayout.Button("UserUniqAppend", GUILayout.Height(Height)))
        {
            List<string> propList = new List<string>();
            propList.Add("apple");
            Dictionary<string, object> userProperties = new Dictionary<string, object>();
            userProperties["prop"] = propList;
            ThinkingAnalyticsAPI.UserUniqAppend(userProperties);
        }
        GUILayout.EndHorizontal();

   

        GUILayout.Space(20);
        GUILayout.Label("OtherSetting", GUI.skin.label);
        GUILayout.BeginHorizontal(GUI.skin.textArea, GUILayout.Height(Height));
        if (GUILayout.Button("Flush", GUILayout.Height(Height)))
        {
            ThinkingAnalyticsAPI.Flush();
        }
        GUILayout.Space(20);
        if (GUILayout.Button("GetDeviceID", GUILayout.Height(Height)))
        {
            Debug.Log("DeviceID: " + ThinkingAnalyticsAPI.GetDeviceId());
        }
        GUILayout.Space(20);
        if (GUILayout.Button("Pause", GUILayout.Height(Height)))
        {
            ThinkingAnalyticsAPI.SetTrackStatus(TA_TRACK_STATUS.PAUSE);
        }
        GUILayout.Space(20);
        if (GUILayout.Button("Stop", GUILayout.Height(Height)))
        {
            ThinkingAnalyticsAPI.SetTrackStatus(TA_TRACK_STATUS.STOP);
        }
        GUILayout.Space(20);
        if (GUILayout.Button("SaveOnly", GUILayout.Height(Height)))
        {
            ThinkingAnalyticsAPI.SetTrackStatus(TA_TRACK_STATUS.SAVE_ONLY);
        }
        GUILayout.Space(20);
        if (GUILayout.Button("Normal", GUILayout.Height(Height)))
        {
            ThinkingAnalyticsAPI.SetTrackStatus(TA_TRACK_STATUS.NORMAL);
        }
        GUILayout.Space(20);
        if (GUILayout.Button("CalibrateTime", GUILayout.Height(Height)))
        {
            //currnt Unix timestamp, units Ms, e.g: 1608782412000 -> 2020-12-24 12:00:12
            ThinkingAnalyticsAPI.CalibrateTime(1608782412000);

            //NTP server, e.g: time.apple.com
            ThinkingAnalyticsAPI.CalibrateTimeWithNtp("time.apple.com");
            //ThinkingAnalyticsAPI.CalibrateTimeWithNtp("time1.google.com");
        }
        GUILayout.EndHorizontal();

        GUILayout.Space(20);
        GUILayout.Label("PropertiesSetting", GUI.skin.label);
        GUILayout.BeginHorizontal(GUI.skin.textArea, GUILayout.Height(Height));
        if (GUILayout.Button("SetSuperProperties", GUILayout.Height(Height)))
        {
            Dictionary<string, object> superProperties = new Dictionary<string, object>();
            superProperties["VipLevel"] = 1;
            superProperties["VipTitle"] = "Supreme King";
            ThinkingAnalyticsAPI.SetSuperProperties(superProperties);
        }
        GUILayout.Space(20);
        if (GUILayout.Button("UpdateSuperProperties", GUILayout.Height(Height)))
        {
            Dictionary<string, object> superProperties = new Dictionary<string, object>();
            superProperties["VipLevel"] = 2;
            ThinkingAnalyticsAPI.SetSuperProperties(superProperties);
        }
       
        GUILayout.Space(20);
        if (GUILayout.Button("ClearSuperProperties", GUILayout.Height(Height)))
        {
            ThinkingAnalyticsAPI.UnsetSuperProperty("VipLevel");
        }

        GUILayout.Space(20);
        if (GUILayout.Button("ClearAllSuperProperties", GUILayout.Height(Height)))
        {
            ThinkingAnalyticsAPI.ClearSuperProperties();
        }

        GUILayout.EndHorizontal();
        GUILayout.BeginHorizontal(GUI.skin.textArea, GUILayout.Height(Height));
        if (GUILayout.Button("SetDynamicSuperProperties", GUILayout.Height(Height)))
        {
            ThinkingAnalyticsAPI.SetDynamicSuperProperties(this);
        }

        GUILayout.Space(20);
        if (GUILayout.Button("GetSuperProperties", GUILayout.Height(Height)))
        {
            Dictionary<string, object> eventSuperProperties = ThinkingAnalyticsAPI.GetSuperProperties();
            string propertiesStr = "  ";
            foreach (KeyValuePair<string, object> kv in eventSuperProperties)
            {
                propertiesStr = propertiesStr + kv.Key + " = " + kv.Value + "\n  ";
            }
            Debug.Log("SuperProperties: \n" + propertiesStr);
        }
        GUILayout.Space(20);
        if (GUILayout.Button("GetPresetProperties", GUILayout.Height(Height)))
        {
            TDPresetProperties presetProperties = ThinkingAnalyticsAPI.GetPresetProperties();
            string deviceModel = presetProperties.DeviceModel;
            Debug.Log("TDPresetProperties DeviceModel is " + deviceModel);
            Dictionary<string, object> eventPresetProperties = presetProperties.ToEventPresetProperties();
            string propertiesStr = "  ";
            foreach (KeyValuePair<string, object> kv in eventPresetProperties)
            {
                propertiesStr = propertiesStr + kv.Key + " = " + kv.Value + "\n  ";
            }
            Debug.Log("PresetProperties: \n" + propertiesStr);
        }

        GUILayout.Space(20);
        if (GUILayout.Button("LoadScene", GUILayout.Height(Height)))
        {
            SceneManager.LoadScene("OtherScene", LoadSceneMode.Single);
        }
        GUILayout.EndHorizontal();
        GUILayout.EndScrollView();
        GUILayout.EndArea();
    }    
}
