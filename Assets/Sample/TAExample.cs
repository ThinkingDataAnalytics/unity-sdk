using UnityEngine;
using ThinkingAnalytics;
using System.Collections.Generic;
using System;
using System.Threading;
using ThinkingSDK.PC.Storage;
using ThinkingAnalytics.Utils;
using ThinkingSDK.PC.Utils;

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
    // 动态公共属性接口
    public Dictionary<string, object> GetDynamicSuperProperties()
    {
        return new Dictionary<string, object>() 
        {
            {"DynamicProperty", DateTime.Now}
        };
    }
    // 自动采集事件回调接口
    public Dictionary<string, object> AutoTrackEventCallback(int type, Dictionary<string, object>properties)
    {
        return new Dictionary<string, object>() 
        {
            {"AutoTrackEventProperty", DateTime.Today}
        };
    }

    private void Awake()
    {
    }
    private void Start()
    {
        // 自动初始化 ThinkingAnalytics 时，可以在 Start() 中调用 EnableAutoTrack() 开启自动采集事件
        // 开启自动采集事件
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
            // 1. 手动初始化（已加载 ThinkingAnalytics 预置体）
            ThinkingAnalyticsAPI.StartThinkingAnalytics();


            // 2. 手动初始化（动态挂载 ThinkingAnalyticsAPI 脚本）
            // new GameObject("ThinkingAnalytics", typeof(ThinkingAnalyticsAPI));

            // 2.1 设置实例参数
            // string appId = "22e445595b0f42bd8c5fe35bc44b88d6";
            // string serverUrl = "https://receiver-ta-dev.thinkingdata.cn";
            // ThinkingAnalyticsAPI.StartThinkingAnalytics(appId, serverUrl);

            // 2.1 个性化设置实例参数
            // string appId = "22e445595b0f42bd8c5fe35bc44b88d6";
            // string serverUrl = "https://receiver-ta-dev.thinkingdata.cn";
            // ThinkingAnalyticsAPI.TAMode mode = ThinkingAnalyticsAPI.TAMode.NORMAL;
            // ThinkingAnalyticsAPI.TATimeZone timeZone = ThinkingAnalyticsAPI.TATimeZone.Local;
            // ThinkingAnalyticsAPI.Token token = new ThinkingAnalyticsAPI.Token(appId, serverUrl, mode, timeZone);
            // 开启加密传输（仅支持iOS/Android）
            // token.enableEncrypt = true;
            // token.encryptVersion = 0;
            // token.encryptPublicKey = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCIPi6aHymT1jdETRci6f1ck535n13IX3p9XNLFu5xncfzNFl6kFVMiMSXMIwWSW2lF6ELtIlDJ0B00qE9C02n6YbIAV+VvVkchydbWrm8VdnEJk/6tIydoUxGyM9pDT6U/PaoEiItl/BawDj3/+KW6U7AejYPij9uTQ4H3bQqj1wIDAQAB";
            // ThinkingAnalyticsAPI.StartThinkingAnalytics(token);

            // 2.2 多项目支持
            // string appId_2 = "1b1c1fef65e3482bad5c9d0e6a823356";
            // string serverUrl_2 = "https://receiver-ta-dev.thinkingdata.cn";
            // ThinkingAnalyticsAPI.TAMode mode_2 = ThinkingAnalyticsAPI.TAMode.NORMAL;
            // ThinkingAnalyticsAPI.TATimeZone timeZone_2 = ThinkingAnalyticsAPI.TATimeZone.Local;
            // ThinkingAnalyticsAPI.Token token_2 = new ThinkingAnalyticsAPI.Token(appId_2, serverUrl_2, mode_2, timeZone_2);

            // ThinkingAnalyticsAPI.Token[] tokens = new ThinkingAnalyticsAPI.Token[2];
            // tokens[0] = token;
            // tokens[1] = token_2;
            // ThinkingAnalyticsAPI.StartThinkingAnalytics(tokens);
            
            // 多项目发送事件
            // ThinkingAnalyticsAPI.Track("test_event");
            // ThinkingAnalyticsAPI.Track("test_event_2", appId:appId_2);


            // 开启自动采集事件
            ThinkingAnalyticsAPI.EnableAutoTrack(AUTO_TRACK_EVENTS.ALL);
            // 开启自动采集事件，并设置自定属性
            // ThinkingAnalyticsAPI.EnableAutoTrack(AUTO_TRACK_EVENTS.ALL, new Dictionary<string, object>() 
            // {
            //     {"auto_track_key", "auto_track_value"}
            // });
            // 开启自动采集，并设置事件回调
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
            ThinkingAnalyticsAPI.Identify("TA_Distinct1");
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
            List<object> listProperties = new List<object>() {
                "C1",
                true,
                30.03,
                DateTime.Now.AddHours(2),
            };
            Dictionary<string, object> complexProperties = new Dictionary<string, object>(){
                {"key_string", "B1"},
                {"key_bool", true},
                {"key_number", 20.02},
                {"key_date", DateTime.Now.AddHours(1)},
                {"key_array",listProperties}
            };
            List<object> listComplexProperties = new List<object>() {
                complexProperties,
            };
            Dictionary<string, object> properties = new Dictionary<string, object>(){
                {"key_string", "A1"},
                {"key_bool", true},
                {"key_number", 10.01},
                {"key_date", DateTime.Now},
                {"key_array",listProperties},                
                {"key_complex",complexProperties},
                {"key_complex_array",listComplexProperties}
            };
            ThinkingAnalyticsAPI.Track("TA",properties);
        }
        GUILayout.Space(20);
        if (GUILayout.Button("TrackFirstEvent", GUILayout.Height(Height)))
        {
            Dictionary<string, object> properties = new Dictionary<string, object>(){
                {"key_string", "B1"},
                {"key_bool", true},
                {"key_number", 50.65}
            };
            TDFirstEvent firstEvent = new TDFirstEvent("DEVICE_FIRST", properties);
            ThinkingAnalyticsAPI.Track(firstEvent);
        }
        GUILayout.Space(20);
        if (GUILayout.Button("TrackUpdateEvent", GUILayout.Height(Height)))
        {
            // 示例： 上报可被更新的事件，假设事件名为 UPDATABLE_EVENT
            TDUpdatableEvent updatableEvent = new TDUpdatableEvent("UPDATABLE_EVENT",
                new Dictionary<string, object>{
                    {"status", 3},
                    {"price", 100}},
                "test_event_id");
            ThinkingAnalyticsAPI.Track(updatableEvent);

        }

        GUILayout.Space(20);
        if (GUILayout.Button("TrackOverwriteEvent", GUILayout.Height(Height)))
        {
            TDOverWritableEvent overWritableEvent = new TDOverWritableEvent("OVERWRITABLE_EVENT",
                new Dictionary<string, object>{
                    {"status", 3},
                    {"super1",100},
                    {"price", 100}},
                "test_event_id");
            ThinkingAnalyticsAPI.Track(overWritableEvent);
        }

        GUILayout.EndHorizontal();
        GUILayout.BeginHorizontal(GUI.skin.textArea, GUILayout.Height(Height));
        // GUILayout.Space(20);
        if (GUILayout.Button("TrackEventWithTimeTravel", GUILayout.Height(Height)))
        {
            ThinkingAnalyticsAPI.TimeEvent("TATimeEvent");
            #if !(UNITY_WEBGL)
            Thread.Sleep(1000);
            #endif
            ThinkingAnalyticsAPI.Track("TATimeEvent");
        }

        GUILayout.Space(20);
        if (GUILayout.Button("TrackEventWithDate", GUILayout.Height(Height)))
        {
            Dictionary<string, object> properties = new Dictionary<string, object>();
            properties["proper1"] = 1;
            properties["proper2"] = "proString";
            properties["proper3"] = true;
            properties["proper4"] = DateTime.Now;
            ThinkingAnalyticsAPI.Track("TA_001", properties, DateTime.Now.AddHours(-1));
        }

        GUILayout.Space(20);
        if (GUILayout.Button("TrackEventWithLightInstance", GUILayout.Height(Height)))
        {
            // 创建轻实例，返回轻实例的 token （类似于 APP ID）
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
            userProperties["userproperty1"] = 1;
            userProperties["userproperty2"] = false;
            userProperties["userproperty3"] = DateTime.Now;
            userProperties["userproperty4"] = "UserStrProperty";
            ThinkingAnalyticsAPI.UserSet(userProperties,DateTime.Now.AddHours(-1));
        }

        GUILayout.Space(20);
        if (GUILayout.Button("UserSetOnce", GUILayout.Height(Height)))
        {
            Dictionary<string, object> userProperties = new Dictionary<string, object>();
            userProperties["userproperty1"] = 1;
            userProperties["userproperty2"] = false;
            userProperties["userproperty3"] = DateTime.Now;
            userProperties["userproperty4"] = "UserStrProperty";
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
            ThinkingAnalyticsAPI.UserUnset("userproperty1");
        }
        GUILayout.Space(20);
        if (GUILayout.Button("UserDelete", GUILayout.Height(Height)))
        {
            ThinkingAnalyticsAPI.UserDelete();
        }
        GUILayout.Space(20);
        if (GUILayout.Button("UserAppend", GUILayout.Height(Height)))
        {
            List<string> stringList = new List<string>();
            stringList.Add("apple");
            stringList.Add("ball");
            stringList.Add("cat");
            ThinkingAnalyticsAPI.UserAppend(
                new Dictionary<string, object>
                {
                    {"user_list", stringList }
                }
            );
        }
        GUILayout.Space(20);
        if (GUILayout.Button("UserUniqAppend", GUILayout.Height(Height)))
        {
            List<string> stringList = new List<string>();
            stringList.Add("ball");
            stringList.Add("banana");
            ThinkingAnalyticsAPI.UserUniqAppend(
                new Dictionary<string, object>
                {
                    {"user_list", stringList }
                }
            );
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
            ThinkingAnalyticsAPI.EnableTracking(false);
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
            //时间戳,单位毫秒 对应时间为1608782412000 2020-12-24 12:00:12
            ThinkingAnalyticsAPI.CalibrateTime(1608782412000);

            //NTP 时间服务器校准，如：time.apple.com
            //ThinkingAnalyticsAPI.CalibrateTimeWithNtp("time.apple.com");
        }
        GUILayout.EndHorizontal();

        GUILayout.Space(20);
        GUILayout.Label("PropertiesSetting", GUI.skin.label);
        GUILayout.BeginHorizontal(GUI.skin.textArea, GUILayout.Height(Height));
        if (GUILayout.Button("SetSuperProperties", GUILayout.Height(Height)))
        {
            Dictionary<string, object> superProperties = new Dictionary<string, object>();
            List<object> listProperties = new List<object>();
            superProperties["super1"] = 1;
            superProperties["super2"] = "superstring";
            superProperties["super3"] = false;
            superProperties["super4"] = DateTime.Now;
            listProperties.Add(2);
            listProperties.Add("superStr");
            listProperties.Add(true);
            listProperties.Add(DateTime.Now);
            superProperties["super5"] = listProperties;
            ThinkingAnalyticsAPI.SetSuperProperties(superProperties);
        }
        GUILayout.Space(20);
        if (GUILayout.Button("UpdateSuperProperties", GUILayout.Height(Height)))
        {
            Dictionary<string, object> superProperties = new Dictionary<string, object>();
            superProperties["super1"] = 2;
            superProperties["super6"] = "super6";
            ThinkingAnalyticsAPI.SetSuperProperties(superProperties);
        }
       
        GUILayout.Space(20);
        if (GUILayout.Button("ClearSuperProperties", GUILayout.Height(Height)))
        {
            ThinkingAnalyticsAPI.UnsetSuperProperty("super1");
            ThinkingAnalyticsAPI.UnsetSuperProperty("superx");
        }

        GUILayout.Space(20);
        if (GUILayout.Button("ClearAllSuperProperties", GUILayout.Height(Height)))
        {
            ThinkingAnalyticsAPI.ClearSuperProperties();
        }

        GUILayout.EndHorizontal();
        GUILayout.BeginHorizontal(GUI.skin.textArea, GUILayout.Height(Height));
        // GUILayout.Space(20);
        if (GUILayout.Button("SetDynamicSuperProperties", GUILayout.Height(Height)))
        {
            ThinkingAnalyticsAPI.SetDynamicSuperProperties(this);
        }

        GUILayout.Space(20);
        if (GUILayout.Button("GetPresetProperties", GUILayout.Height(Height)))
        {
            TDPresetProperties presetProperties = ThinkingAnalyticsAPI.GetPresetProperties();
            string deviceModel = presetProperties.DeviceModel;
            Debug.Log("TDPresetProperties DeviceModel is " + deviceModel);
            Dictionary<string, object> eventPresetProperties = presetProperties.ToEventPresetProperties();
            string propertiesStr = "";
            foreach (KeyValuePair<string, object> kv in eventPresetProperties)
            {
                propertiesStr = propertiesStr + kv.Key + " = " + kv.Value + ", ";
            }
                Debug.Log("eventPresetProperties: " + propertiesStr);
        }
        GUILayout.EndHorizontal();
        GUILayout.EndScrollView();
        GUILayout.EndArea();
    }
}
