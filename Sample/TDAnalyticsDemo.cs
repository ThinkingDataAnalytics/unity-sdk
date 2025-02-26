using UnityEngine;
using UnityEngine.SceneManagement;
using ThinkingData.Analytics;
using System.Collections.Generic;
using System;
using System.Threading;
using System.Collections;
//using ThinkingAnalytics;
public class TDAnalyticsDemo : MonoBehaviour, TDDynamicSuperPropertiesHandler, TDAutoTrackEventHandler
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
        Thread currentThread = Thread.CurrentThread;
        // 输出当前线程的信息
        Debug.Log("当前线程ID: " + currentThread.ManagedThreadId);
        return new Dictionary<string, object>() 
        {
            {"dynamic_property", DateTime.Now},
            {"dynamic_property1", DateTime.Now},
            {"dynamic_property2", DateTime.Now},
            {"dynamic_property3", DateTime.Now},
            {"dynamicTime4", DateTime.Now}
        };
    }
    // auto-tracking events interface implementation
    public Dictionary<string, object> GetAutoTrackEventProperties(int type, Dictionary<string, object>properties)
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
        // TDAnalytics.EnableAutoTrack(TDAutoTrackEventType.ALL);
    }
    private void Update()
    {

    }

    private void SampleDemo()
    {
        //Init SDK
        string appId = "your-app-id";
        string serverUrl = "https://your.server.url";
        TDAnalytics.Init(appId, serverUrl);

        //Login SDK
        TDAnalytics.Login("Tiki");

        //Set Super Properties
        //Dictionary<string, object> superProperties = new Dictionary<string, object>() {
        //    { "channel", "Apple Store" },
        //    { "vip_level", 10 },
        //    { "is_svip", true }
        //};
        //TDAnalytics.SetSuperProperties(superProperties);


        //Track Event
        Dictionary<string, object> eventProperties = new Dictionary<string, object>()
        {
            { "product_name", "Majin Taito" },
            { "product_price", 6 },
            { "is_on_sale", true },
            { "begin_time", DateTime.Now },
            { "skins_name", new List<string>() {
                "Master Alchemist",
                "Knights of the Round Table",
                "Taotie",
                "Glam Rock"
            } }
        };
        TDAnalytics.Track("product_buy", eventProperties);


        //Track User Properties
        Dictionary<string, object> userProperties = new Dictionary<string, object>()
        {
            { "email", "tiki@thinkingdata.cn" },
            { "diamond", 888 },
            { "is_svip", true },
            { "last_payment_time", DateTime.Now },
            { "owned_skins", new List<string>() {
                "Gun of Travel",
                "Bow of Demigods",
                "Golden Sagittarius"
            } }
        };
        TDAnalytics.UserSet(userProperties);

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
            //TDAnalytics.Init();


            // 2. Manual initialization (dynamically loading TDAnalytics script)
            //this.gameObject.AddComponent<TDAnalytics>();

            // 2.1 Set instance parameters
            //string appId = "22e445595b0f42bd8c5fe35bc44b88d6";
            //string serverUrl = "https://receiver-ta-dev.thinkingdata.cn";
            //TDAnalytics.Init(appId, serverUrl);


            // 2.1 Set personalized instance parameters
            string appId = "1b1c1fef65e3482bad5c9d0e6a823356";
            string serverUrl = "https://receiver.ta.thinkingdata.cn";
            TDConfig tDConfig = new TDConfig(appId, serverUrl);
            //tDConfig.mode = TDMode.Normal;
            tDConfig.timeZone = TDTimeZone.Asia_Shanghai;
            //Enable encrypted transmission(only iOS / Android)
            int encryptVersion = 0;
            string encryptPublicKey = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCIPi6aHymT1jdETRci6f1ck535n13IX3p9XNLFu5xncfzNFl6kFVMiMSXMIwWSW2lF6ELtIlDJ0B00qE9C02n6YbIAV+VvVkchydbWrm8VdnEJk/6tIydoUxGyM9pDT6U/PaoEiItl/BawDj3/+KW6U7AejYPij9uTQ4H3bQqj1wIDAQAB";
            tDConfig.EnableEncrypt(encryptPublicKey, encryptVersion);
            tDConfig.reportingToTencentSdk = 2;
            TDAnalytics.Init(tDConfig);
            TDAnalytics.SetNetworkType(TDNetworkType.Wifi);
            //TDAnalytics.SetDynamicSuperProperties(this);
            //TDAnalytics.EnableAutoTrack(TDAutoTrackEventType.AppInstall | TDAutoTrackEventType.AppStart | TDAutoTrackEventType.AppEnd);
            TDAnalytics.EnableAutoTrack(TDAutoTrackEventType.All);


            //new GameObject("ThinkingAnalytics", typeof(ThinkingAnalyticsAPI));
            //string appId = "40eddce753cd4bef9883a01e168c3df0";
            //string serverUrl = "https://receiver-ta-preview.thinkingdata.cn";
            //ThinkingAnalyticsAPI.StartThinkingAnalytics(appId, serverUrl);
            //ThinkingAnalyticsAPI.SetNetworkType(ThinkingAnalyticsAPI.NetworkType.WIFI);
            //ThinkingAnalyticsAPI.EnableAutoTrack(AUTO_TRACK_EVENTS.ALL);

            // 2.2 Multi-project support
            // string appId_2 = "cf918051b394495ca85d1b7787ad7243";
            // string serverUrl_2 = "https://receiver-ta-dev.thinkingdata.cn";
            // TDConfig tDConfig_2 = new TDConfig(appId_2, serverUrl_2);

            // TDAnalytics.Init(tDConfig_2);

            // Multi-item track events
            // TDAnalytics.Track("test_event");
            // TDAnalytics.Track("test_event_2", appId:appId_2);


            // Enable auto-tracking events
            //TDAnalytics.EnableAutoTrack(TDAutoTrackEventType.All);
            // Enable auto-tracking events, and set properties
            // TDAnalytics.SetAutoTrackProperties(TDAutoTrackEventType.All, new Dictionary<string, object>()
            //  {
            //      {"auto_track_static_1", "value_1"}
            //  });
            // TDAnalytics.EnableAutoTrack(TDAutoTrackEventType.All, new Dictionary<string, object>()
            //  {
            //      {"auto_track_static_2", "value_2"}
            //  });
            // Enable auto-tracking events, and set callback
            // TDAnalytics.EnableAutoTrack(TDAutoTrackEventType.All, this);
        }
        GUILayout.Space(20);
        if (GUILayout.Button("SetAccountID", GUILayout.Height(Height)))
        {
            TDAnalytics.Login("TA");
        }
        GUILayout.Space(20);
        if (GUILayout.Button("SetDistinctID", GUILayout.Height(Height)))
        {
            TDAnalytics.SetDistinctId("TD_DistinctID");
            string distinctId = TDAnalytics.GetDistinctId();
            Debug.Log("Current Distinct ID is : " + distinctId);
        }
        GUILayout.Space(20);
        if (GUILayout.Button("ClearAccountID", GUILayout.Height(Height)))
        {
            TDAnalytics.Logout();
        }
        GUILayout.EndHorizontal();

        GUILayout.Space(20);
        GUILayout.Label("EventTracking", GUI.skin.label);
        GUILayout.BeginHorizontal(GUI.skin.textArea, GUILayout.Height(Height));
        if (GUILayout.Button("TrackEvent", GUILayout.Height(Height)))
        {
            //Dictionary<string, object> properties = new Dictionary<string, object>();
            //properties["channel"] = "ta";//string
            //properties["age"] = 1;//number - int
            //properties["weight"] = 5.46;//number - float
            //properties["balance"] = -0.4;//number - negative
            //properties["isVip"] = true;//bool
            //properties["birthday"] = new DateTime(2022,01,01);//date
            //properties["birthday1"] = new DateTime();//date
            //properties["birthday2"] = new DateTime(2023, 05, 01);//date
            //properties["birthday3"] = new DateTime(2023, 05, 03);//date
            //properties["object"] = new Dictionary<string, object>() { { "key", "value" },{ "key1", DateTime.Now }, { "key2", DateTime.Now } };//object
            //properties["object_arr"] = new List<object>() { new Dictionary<string, object>() { { "key", "value" }, { "key3", DateTime.Now }, { "key4", DateTime.Now } } };//object array
            //properties["arr"] = new List<object>() { "value" };//array
            //TDAnalytics.Track("TA", properties);
            //for (int i = 0; i < 1; i++)
            //{
            //    Dictionary<string, object> properties = new Dictionary<string, object>();
            //    properties["channel"] = "ta";//string
            //    properties["age"] = 1;//number - int
            //    properties["weight"] = 5.46;//number - float
            //    properties["balance"] = -0.4;//number - negative
            //    properties["isVip"] = true;//bool
            //    properties["date1"] = new DateTime();
            //    properties["date2"] = new DateTime();
            //    properties["date3"] = new DateTime();
            //    properties["date4"] = new DateTime();
            //    properties["date5"] = new DateTime();
            //    properties["date6"] = DateTime.Now;
            //    properties["num"] = a;
            //    properties["birthday"] = new DateTime(2022, 01, 01);//date
            //    properties["object"] = new Dictionary<string, object>() { { "key", "value" }, { "data1", new DateTime() }, { "data2", new DateTime() }, { "data3", new DateTime() }, { "data4", new DateTime() }, { "data5", new DateTime() } };//object
            //    properties["object_arr"] = new List<object>() { new Dictionary<string, object>() { { "key", "value" }, { "data1", new DateTime() }, { "data2", new DateTime() }, { "data3", new DateTime() }, { "data4", new DateTime() }, { "data5", new DateTime() } } };//object array
            //    properties["arr"] = new List<object>() { "value", new DateTime(), new DateTime(), new DateTime(), new DateTime(), new DateTime() };//array
            //    TDAnalytics.Track("TA_"+i, properties, new DateTime(2022, 01, 01),TimeZoneInfo.Utc);
            //}
            Debug.Log("======2" + DateTimeOffset.UtcNow.ToUnixTimeMilliseconds());
            //TDAnalytics.TrackStr("sss","{}",null);
            TDAnalytics.Track("ssss");
            //TDAnalytics.TrackStr("test_event", "{\"game_name\":\"海外正式\",\"rom\":\"125830144.000000\",\"device_name\":\"H030_T5\",\"puid\":\"558513179\",\"role_id\":\"710280887\",\"sdk_version\":\"1.9.2h\",\"dpi\":\"1920x1080\",\"pkg_id\":\"A1730\",\"game_id\":\"G153\",\"ram\":\"66945980.000000\",\"win_serial\":\"0000_0000_0000_0000_4868_3400_0000_0000\",\"channel_name\":\"kuroPC\",\"game_version\":\"1.2.0\",\"login_id\":\"567ec296-70f4-473c-9bb4-ab561205b5b9\",\"os\":\"win\",\"cpu_ghz\":\"2350080\",\"os_version\":\"win10\",\"event_uuid\":\"PC-567ec296-70f4-473c-9bb4-ab561205b5b964\",\"server_id\":\"86d52186155b148b5c138ceb41be9650\",\"event_time_ms\":\"1724774441952\",\"role_name\":\"PIZoY\",\"cpu_hardware\":\"Intel(R) Xeon(R) CPU E5-2696 v3 @ 2.30GHz\",\"pkg_name\":\"com.kurogame.wutheringwaves.global.sign\",\"event_id\":\"90003\",\"user_id\":\"558513179\",\"channel_op\":\"0\",\"event_name\":\"from_game\",\"last_phone_open_ts\":\"1724618745\",\"channel_id\":\"240\",\"did\":\"03000200-0400-0500-0006-000700080009\",\"win_uuid\":\"03000200-0400-0500-0006-000700080009\"}");
            Debug.Log("======3" + DateTimeOffset.UtcNow.ToUnixTimeMilliseconds());
        }
        GUILayout.Space(20);
        if (GUILayout.Button("TrackFirstEvent", GUILayout.Height(Height)))
        {
            Dictionary<string, object> properties = new Dictionary<string, object>() { { "status", 1 } };
            TDFirstEventModel firstEvent = new TDFirstEventModel("first_event");
            //firstEvent.Properties = properties;
            TDAnalytics.Track(firstEvent);
            //Dictionary<string, object> properties_2 = new Dictionary<string, object>() { { "status", 11 } };
            //TDFirstEventModel firstEvent_2 = new TDFirstEventModel("first_event", "first_check_id");
            //firstEvent_2.Properties = properties_2;
            //firstEvent_2.StrProperties = "{\"prop\":[\"aa\",\"nb\"]}";
            //firstEvent_2.SetTime(new DateTime(2024, 03, 04), TimeZoneInfo.Utc);
            //TDAnalytics.Track(firstEvent_2);
        }
        GUILayout.Space(20);
        if (GUILayout.Button("TrackUpdateEvent", GUILayout.Height(Height)))
        {
            Dictionary<string, object> properties = new Dictionary<string, object>() { { "status", 2 } };
            TDUpdatableEventModel updatableEvent = new TDUpdatableEventModel("updatable_event", "test_event_id");
            updatableEvent.Properties = properties;
            updatableEvent.SetTime(DateTime.Now, TimeZoneInfo.Local);
            TDAnalytics.Track(updatableEvent);
        }

        GUILayout.Space(20);
        if (GUILayout.Button("TrackOverwriteEvent", GUILayout.Height(Height)))
        {
            Dictionary<string, object> properties = new Dictionary<string, object>() { { "status", 3 } };
            TDOverwritableEventModel overWritableEvent = new TDOverwritableEventModel("overwritable_event", "test_event_id");
            overWritableEvent.Properties = properties;
            overWritableEvent.SetTime(DateTime.Now, TimeZoneInfo.Utc);
            TDAnalytics.Track(overWritableEvent);
        }

        GUILayout.EndHorizontal();
        GUILayout.BeginHorizontal(GUI.skin.textArea, GUILayout.Height(Height));
        if (GUILayout.Button("TimeEvent", GUILayout.Height(Height)))
        {
            TDAnalytics.TimeEvent("TATimeEvent");
        }

        GUILayout.Space(20);
        if (GUILayout.Button("Track-TimeEvent", GUILayout.Height(Height)))
        {
            TDAnalytics.Track("TATimeEvent");
        }

        GUILayout.Space(20);
        if (GUILayout.Button("TrackEventWithDate", GUILayout.Height(Height)))
        {
            Dictionary<string, object> properties = new Dictionary<string, object>();
            TDAnalytics.Track("TA_Utc", properties, DateTime.Now.AddDays(1), TimeZoneInfo.Utc);
            TDAnalytics.Track("TA_Local", properties, DateTime.Now.AddDays(1), TimeZoneInfo.Local);
        }

        GUILayout.Space(20);
        if (GUILayout.Button("TrackEvent-LightInstance", GUILayout.Height(Height)))
        {
            string lightToken = TDAnalytics.LightInstance();
            TDAnalytics.Login("light_account", lightToken);
            TDAnalytics.Track("light_event", lightToken);
            TDAnalytics.Flush();
        }
        GUILayout.Space(20);
        if (GUILayout.Button("TrackEvent-MultiInstance", GUILayout.Height(Height)))
        {
            string appId_2 = "cf918051b394495ca85d1b7787ad7243";
            string serverUrl_2 = "https://receiver-ta-dev.thinkingdata.cn";
            TDConfig token_2 = new TDConfig(appId_2, serverUrl_2);
            token_2.mode = TDMode.Normal;
            token_2.timeZone = TDTimeZone.UTC;
            // initial multi-instance
            TDAnalytics.Init(token_2);
            // login account
            TDAnalytics.Login("Tiki", appId_2);
            // track normal event
            TDAnalytics.Track("TA", appId_2);
            // track user properties
            TDAnalytics.UserSet(new Dictionary<string, object>() { { "age", 18 } }, appId_2);
            // flush data
            TDAnalytics.Flush(appId_2);

            string instanceName = "ThinkingData";
            TDConfig token_3 = new TDConfig(appId_2, serverUrl_2);
            token_3.name = instanceName;
            // initial multi-instance
            TDAnalytics.Init(token_3);
            // login account
            TDAnalytics.Login("Thinker", instanceName);
            // track normal event
            TDAnalytics.Track("TA", instanceName);
            // track user properties
            TDAnalytics.UserSet(new Dictionary<string, object>() { { "age", 18 } }, instanceName);
            // flush data
            TDAnalytics.Flush(instanceName);
        }
        GUILayout.EndHorizontal();
 
        GUILayout.Space(20);
        GUILayout.Label("UserProperty", GUI.skin.label);
        GUILayout.BeginHorizontal(GUI.skin.textArea, GUILayout.Height(Height));
        if (GUILayout.Button("UserSet", GUILayout.Height(Height)))
        {
            Dictionary<string, object> userProperties = new Dictionary<string, object>() { { "age", 18 } };
            //TDAnalytics.UserSet(userProperties);
            //TDAnalytics.UserSet("{\"age\":19}");
            TDAnalytics.UserSet("}");
        }

        GUILayout.Space(20);
        if (GUILayout.Button("UserSetOnce", GUILayout.Height(Height)))
        {
            Dictionary<string, object> userProperties = new Dictionary<string, object>() { { "gender", 1 } };
            //TDAnalytics.UserSetOnce(userProperties);
            //TDAnalytics.UserSetOnce(userProperties,new DateTime(2024,6,7));
            //TDAnalytics.UserSetOnce("{\"age\":34}");
            TDAnalytics.UserSetOnce("1234");
        }
        GUILayout.Space(20);
        if (GUILayout.Button("UserAdd", GUILayout.Height(Height)))
        {
            //TDAnalytics.UserAdd("user_coin", 1);

            //TDAnalytics.UserAddStr("{\"user_coin\":19}");
            TDAnalytics.UserAddStr("1234");
        }
        GUILayout.Space(20);
        if (GUILayout.Button("UserUnset", GUILayout.Height(Height)))
        {
            TDAnalytics.UserUnset("user_coin");
            TDAnalytics.UserUnset(new List<string>() { "user_coin", "user_vip" },new DateTime(2024,4,5));
        }
        GUILayout.Space(20);
        if (GUILayout.Button("UserDelete", GUILayout.Height(Height)))
        {
            TDAnalytics.UserDelete();
        }
        GUILayout.Space(20);
        if (GUILayout.Button("UserAppend", GUILayout.Height(Height)))
        {
            List<string> propList = new List<string>() { "apple", "ball" };
            Dictionary<string, object> userProperties = new Dictionary<string, object>() { { "prop", propList } };
            //TDAnalytics.UserAppend(userProperties);
            //TDAnalytics.UserAppend(userProperties,new DateTime(2024,7,8));
            //TDAnalytics.UserAppend("{\"prop\":[\"aa\",\"nb\"]}");
            TDAnalytics.UserAppend("]]]]");
        }
        GUILayout.Space(20);
        if (GUILayout.Button("UserUniqAppend", GUILayout.Height(Height)))
        {
            List<string> propList = new List<string>() { "apple", "banana" };
            Dictionary<string, object> userProperties = new Dictionary<string, object>() { { "prop", propList } };
            //TDAnalytics.UserUniqAppend(userProperties);
            //TDAnalytics.UserUniqAppend(userProperties,new DateTime(2024,9,8));
            TDAnalytics.UserUniqAppend("{\"prop\":[\"aa\",\"nb\"]}");
            TDAnalytics.UserUniqAppend("344");
        }
        GUILayout.EndHorizontal();

   

        GUILayout.Space(20);
        GUILayout.Label("OtherSetting", GUI.skin.label);
        GUILayout.BeginHorizontal(GUI.skin.textArea, GUILayout.Height(Height));
        if (GUILayout.Button("Flush", GUILayout.Height(Height)))
        {
            TDAnalytics.Flush();
        }
        GUILayout.Space(20);
        if (GUILayout.Button("GetDeviceID", GUILayout.Height(Height)))
        {
            string deviceId = TDAnalytics.GetDeviceId();
            Debug.Log("Current Device ID is : " + deviceId);
        }
        GUILayout.Space(20);
        if (GUILayout.Button("Pause", GUILayout.Height(Height)))
        {
            TDAnalytics.SetTrackStatus(TDTrackStatus.Pause);
        }
        GUILayout.Space(20);
        if (GUILayout.Button("Stop", GUILayout.Height(Height)))
        {
            TDAnalytics.SetTrackStatus(TDTrackStatus.Stop);
        }
        GUILayout.Space(20);
        if (GUILayout.Button("SaveOnly", GUILayout.Height(Height)))
        {
            TDAnalytics.SetTrackStatus(TDTrackStatus.SaveOnly);
        }
        GUILayout.Space(20);
        if (GUILayout.Button("Normal", GUILayout.Height(Height)))
        {
            TDAnalytics.SetTrackStatus(TDTrackStatus.Normal);
        }
        GUILayout.Space(20);
        if (GUILayout.Button("CalibrateTime", GUILayout.Height(Height)))
        {
            //currnt Unix timestamp, units Ms, e.g: 1672531200000 -> 2023-01-01 08:00:00
            TDAnalytics.CalibrateTime(1672531200000);
        }
        GUILayout.Space(20);
        if (GUILayout.Button("CalibrateTime-NTP", GUILayout.Height(Height)))
        {
            //NTP server, e.g: time.apple.com
            TDAnalytics.CalibrateTimeWithNtp("time.apple.com");
        }
        GUILayout.EndHorizontal();

        GUILayout.Space(20);
        GUILayout.Label("PropertiesSetting", GUI.skin.label);
        GUILayout.BeginHorizontal(GUI.skin.textArea, GUILayout.Height(Height));
        if (GUILayout.Button("SetSuperProperties", GUILayout.Height(Height)))
        {
            //Dictionary<string, object> superProperties = new Dictionary<string, object>() {
            //    { "vip_level", 1 },
            //    { "vip_title", "Supreme King" }
            //};
            //TDAnalytics.SetSuperProperties(superProperties);
            //TDAnalytics.SetSuperProperties("{\"vip_level\":10,\"vip_title\":\"haha\"}");
            TDAnalytics.SetSuperProperties("0000");
        }
        GUILayout.Space(20);
        if (GUILayout.Button("UpdateSuperProperties", GUILayout.Height(Height)))
        {
            Dictionary<string, object> superProperties = new Dictionary<string, object>() {
                { "vip_level", 2 }
            };
            TDAnalytics.SetSuperProperties(superProperties);
        }
       
        GUILayout.Space(20);
        if (GUILayout.Button("ClearSuperProperties", GUILayout.Height(Height)))
        {
            //TDAnalytics.UnsetSuperProperty("vip_level");
            TDAnalytics.ClearSuperProperties();
        }

        GUILayout.Space(20);
        if (GUILayout.Button("ClearAllSuperProperties", GUILayout.Height(Height)))
        {
            TDAnalytics.ClearSuperProperties();
        }

        GUILayout.EndHorizontal();
        GUILayout.BeginHorizontal(GUI.skin.textArea, GUILayout.Height(Height));
        if (GUILayout.Button("SetDynamicSuperProperties", GUILayout.Height(Height)))
        {
            //TDAnalytics.SetDynamicSuperProperties(this);
            //TDAnalytics.EnableThirdPartySharing(ThinkingData.Analytics.Utils.TDThirdPartyType.APPSFLYER | ThinkingData.Analytics.Utils.TDThirdPartyType.ADJUST);
            //TDAnalytics.SetAutoTrackProperties(TDAutoTrackEventType.AppStart | TDAutoTrackEventType.AppEnd, new Dictionary<string, object>
            //{
            //    { "key1","kk"}
            //});
            TDAnalytics.EnableAutoTrack(TDAutoTrackEventType.AppStart, this);
        }

        GUILayout.Space(20);
        if (GUILayout.Button("GetSuperProperties", GUILayout.Height(Height)))
        {
            Dictionary<string, object> eventSuperProperties = TDAnalytics.GetSuperProperties();
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
            TDPresetProperties presetProperties = TDAnalytics.GetPresetProperties();
            string deviceModel = presetProperties.DeviceModel;
            Debug.Log("TDPresetProperties: DeviceModel is " + deviceModel);
            Dictionary<string, object> eventPresetProperties = presetProperties.ToDictionary();
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
