#if UNITY_ANDROID && !(UNITY_EDITOR) && !TE_DISABLE_ANDROID_JAVA
using System;
using System.Collections.Generic;
using ThinkingAnalytics.Utils;
using UnityEngine;

namespace ThinkingAnalytics.Wrapper
{
    public partial class ThinkingAnalyticsWrapper
    {
        private static readonly string JSON_CLASS = "org.json.JSONObject";
        private static readonly AndroidJavaClass sdkClass = new AndroidJavaClass("cn.thinkingdata.android.ThinkingAnalyticsSDK");
        private static readonly AndroidJavaClass configClass = new AndroidJavaClass("cn.thinkingdata.android.TDConfig");

        private static readonly AndroidJavaObject unityAPIInstance = new AndroidJavaObject("cn.thinkingdata.engine.ThinkingAnalyticsUnityAPI");

        private static Dictionary<string, AndroidJavaObject> light_instances = null;

        /// <summary>
        /// Convert Dictionary object to JSONObject in Java.
        /// </summary>
        /// <returns>The JSONObject instance.</returns>
        /// <param name="data">The Dictionary containing some data </param>
        private static AndroidJavaObject getJSONObject(string dataString)
        {
            if (dataString.Equals("null"))
            {
                return null;
            }

            try
            {
                return new AndroidJavaObject(JSON_CLASS, dataString);
            }
            catch (Exception e)
            {
                TD_Log.w("ThinkingAnalytics: unexpected exception: " + e);
            }
            return null;
        }

        private static string getTimeString(DateTime dateTime) {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;

            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;

            AndroidJavaObject date = new AndroidJavaObject("java.util.Date", currentMillis);
            return getInstance(default_appId).Call<string>("getTimeString", date);
        }

        private static AndroidJavaObject getInstance(string appId) {
            AndroidJavaObject context = new AndroidJavaClass("com.unity3d.player.UnityPlayer").GetStatic<AndroidJavaObject>("currentActivity");
            AndroidJavaObject currentInstance;

            if (string.IsNullOrEmpty(appId))
            {
                appId = default_appId;
            }

            if (light_instances != null && light_instances.ContainsKey(appId))
            {
                currentInstance = light_instances[appId];
            }
            else
            {
                currentInstance = sdkClass.CallStatic<AndroidJavaObject>("sharedInstance", context, appId);
            }

            if (currentInstance == null)
            {
                currentInstance = sdkClass.CallStatic<AndroidJavaObject>("sharedInstance", context, default_appId);
            }

            return currentInstance;
        }


        private static void enableLog(bool enable) {
            sdkClass.CallStatic("enableTrackLog", enable);
        }
        private static void setVersionInfo(string libName, string version) {
            sdkClass.CallStatic("setCustomerLibInfo", libName, version);
        }

        private static void init(ThinkingAnalyticsAPI.Token token)
        {
            AndroidJavaObject context = new AndroidJavaClass("com.unity3d.player.UnityPlayer").GetStatic<AndroidJavaObject>("currentActivity");
            // AndroidJavaObject config = null;
            // if (!string.IsNullOrEmpty(token.GetInstanceName()))
            // {
            //     config = configClass.CallStatic<AndroidJavaObject>("getInstance", context, token.appid, token.serverUrl, token.GetInstanceName());
            //     if (string.IsNullOrEmpty(default_appId)) default_appId = token.GetInstanceName();
            // }
            // else
            // {
            //     config = configClass.CallStatic<AndroidJavaObject>("getInstance", context, token.appid, token.serverUrl);
            //     if (string.IsNullOrEmpty(default_appId)) default_appId = token.appid;
            // }
            // config.Call("setModeInt", (int) token.mode);

            // string timeZoneId = token.getTimeZoneId();
            // if (null != timeZoneId && timeZoneId.Length > 0)
            // {
            //     AndroidJavaObject timeZone = new AndroidJavaClass("java.util.TimeZone").CallStatic<AndroidJavaObject>("getTimeZone", timeZoneId);
            //     if (null != timeZone)
            //     {
            //         config.Call("setDefaultTimeZone", timeZone);
            //     }
            // }

            // if (token.enableEncrypt == true)
            // {
            //     config.Call("enableEncrypt", true);
            //     AndroidJavaObject secreteKey = new AndroidJavaObject("cn.thinkingdata.android.encrypt.TDSecreteKey", token.encryptPublicKey, token.encryptVersion, "AES", "RSA");
            //     config.Call("setSecretKey", secreteKey);
            // }

            // sdkClass.CallStatic<AndroidJavaObject>("sharedInstance", config);

            if (string.IsNullOrEmpty(default_appId)) default_appId = token.appid;
            Dictionary<string, object> configDic = new Dictionary<string, object>();
            configDic["appId"] = token.appid;
            configDic["serverUrl"] = token.serverUrl;
            configDic["mode"] = (int) token.mode;
            if (!string.IsNullOrEmpty(token.GetInstanceName()))
            {
                // if (string.IsNullOrEmpty(default_appId)) default_appId = token.GetInstanceName();
                configDic["instanceName"] = token.GetInstanceName();
            }
            else
            {
                // if (string.IsNullOrEmpty(default_appId)) default_appId = token.appid;
            }
            string timeZoneId = token.getTimeZoneId();
            if (null != timeZoneId && timeZoneId.Length > 0)
            {
                configDic["timeZone"] = timeZoneId;
            }
            if (token.enableEncrypt == true)
            {
                configDic["enableEncrypt"] = true;
                configDic["secretKey"] = new Dictionary<string, object>() {
                    {"publicKey", token.encryptPublicKey},
                    {"version", token.encryptVersion},
                    {"symmetricEncryption", "AES"},
                    {"asymmetricEncryption", "RSA"},
                };
            }

            unityAPIInstance.Call("sharedInstance", context, TD_MiniJSON.Serialize(configDic));
        }

        private static void flush(string appId)
        {
            getInstance(appId).Call("flush");
        }

        private static AndroidJavaObject getDate(DateTime dateTime)
        {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;

            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            return new AndroidJavaObject("java.util.Date", currentMillis);
        }

        private static void track(string eventName, string properties, DateTime dateTime, string appId)
        {
            AndroidJavaObject date = getDate(dateTime);
            AndroidJavaClass tzClass = new AndroidJavaClass("java.util.TimeZone");
            AndroidJavaObject tz = null;
            getInstance(appId).Call("track", eventName, getJSONObject(properties), date, tz);
        }

        private static void track(string eventName, string properties, DateTime dateTime, TimeZoneInfo timeZone, string appId)
        {
            AndroidJavaObject date = getDate(dateTime);
            AndroidJavaObject tz = null;
            if (null != timeZone && null != timeZone.Id && timeZone.Id.Length > 0)
            {
                if ("Local" == timeZone.Id) {
                    tz = new AndroidJavaClass("java.util.TimeZone").CallStatic<AndroidJavaObject>("getDefault");
                }
                else {
                    tz = new AndroidJavaClass("java.util.TimeZone").CallStatic<AndroidJavaObject>("getTimeZone", timeZone.Id);
                }
            }
            getInstance(appId).Call("track", eventName, getJSONObject(properties), date, tz);
        }

        private static void trackForAll(string eventName, string properties)
        {
            string appId = "";
            track(eventName, properties, appId);
        }

        private static void track(ThinkingAnalyticsEvent taEvent, string appId)
        {
            AndroidJavaObject javaEvent = null;
            switch(taEvent.EventType)
            {
                case ThinkingAnalyticsEvent.Type.FIRST:
                    javaEvent = new AndroidJavaObject("cn.thinkingdata.android.TDFirstEvent", 
                        taEvent.EventName, getJSONObject(getFinalEventProperties(taEvent.Properties)));

                    string extraId = taEvent.ExtraId;
                    if (!string.IsNullOrEmpty(extraId))
                    {
                        javaEvent.Call("setFirstCheckId", extraId);
                    }
                    
                    break;
                case ThinkingAnalyticsEvent.Type.UPDATABLE:
                    javaEvent = new AndroidJavaObject("cn.thinkingdata.android.TDUpdatableEvent", 
                        taEvent.EventName, getJSONObject(getFinalEventProperties(taEvent.Properties)), taEvent.ExtraId); 
                    break;
                case ThinkingAnalyticsEvent.Type.OVERWRITABLE:
                    javaEvent = new AndroidJavaObject("cn.thinkingdata.android.TDOverWritableEvent", 
                        taEvent.EventName, getJSONObject(getFinalEventProperties(taEvent.Properties)), taEvent.ExtraId); 
                    break;
            }
            if (null == javaEvent) {
                TD_Log.w("Unexpected java event object. Returning...");
                return;
            }

            if (taEvent.EventTime != null && taEvent.EventTime != DateTime.MinValue) {
                AndroidJavaObject date = getDate(taEvent.EventTime);
                AndroidJavaClass tzClass = new AndroidJavaClass("java.util.TimeZone");
                AndroidJavaObject tz = null;
                if (taEvent.EventTimeZone != null) {
                    if ("Local" == taEvent.EventTimeZone.Id) {
                        tz = new AndroidJavaClass("java.util.TimeZone").CallStatic<AndroidJavaObject>("getDefault");
                    }
                    else {
                        tz = new AndroidJavaClass("java.util.TimeZone").CallStatic<AndroidJavaObject>("getTimeZone", taEvent.EventTimeZone.Id);
                    }
                    javaEvent.Call("setEventTime", date, tz);
                }
                else
                {
                    javaEvent.Call("setEventTime", date);
                }
                
            }

            getInstance(appId).Call("track", javaEvent);
        }

        private static void track(string eventName, string properties, string appId)
        {
            getInstance(appId).Call("track", eventName, getJSONObject(properties));
        }

        private static void setSuperProperties(string superProperties, string appId)
        {
            getInstance(appId).Call("setSuperProperties", getJSONObject(superProperties));
        }

        private static void unsetSuperProperty(string superPropertyName, string appId)
        {
            getInstance(appId).Call("unsetSuperProperty", superPropertyName);
        }

        private static void clearSuperProperty(string appId)
        {
            getInstance(appId).Call("clearSuperProperties");
        }

        private static Dictionary<string, object> getSuperProperties(string appId)
        {
            Dictionary<string, object> result = null;
            AndroidJavaObject superPropertyObject = getInstance(appId).Call<AndroidJavaObject>("getSuperProperties");
            if (null != superPropertyObject)
            {
                string superPropertiesString = superPropertyObject.Call<string>("toString");
                result = TD_MiniJSON.Deserialize(superPropertiesString);
            }
            return result;
        }

        private static Dictionary<string, object> getPresetProperties(string appId)
        {
            Dictionary<string, object> result = null;
            AndroidJavaObject presetPropertyObject = getInstance(appId).Call<AndroidJavaObject>("getPresetProperties").Call<AndroidJavaObject>("toEventPresetProperties");
            if (null != presetPropertyObject)
            {
                string presetPropertiesString = presetPropertyObject.Call<string>("toString");
                result = TD_MiniJSON.Deserialize(presetPropertiesString);
            }
            return result;
        }

        private static void timeEvent(string eventName, string appId)
        {
            getInstance(appId).Call("timeEvent", eventName);
        }

        private static void timeEventForAll(string eventName)
        {
            getInstance("").Call("timeEvent", eventName);
        }

        private static void identify(string uniqueId, string appId)
        {
            getInstance(appId).Call("identify", uniqueId);
        }

        private static string getDistinctId(string appId)
        {
            return getInstance(appId).Call<string>("getDistinctId");
        }

        private static void login(string uniqueId, string appId)
        {
            getInstance(appId).Call("login", uniqueId);
        }

        private static void userSetOnce(string properties, string appId)
        {
            getInstance(appId).Call("user_setOnce", getJSONObject(properties));
        }

        private static void userSetOnce(string properties, DateTime dateTime, string appId)
        {
            getInstance(appId).Call("user_setOnce", getJSONObject(properties), getDate(dateTime));
        }

        private static void userSet(string properties, string appId)
        {
            getInstance(appId).Call("user_set", getJSONObject(properties));
        }

        private static void userSet(string properties, DateTime dateTime, string appId)
        {
            getInstance(appId).Call("user_set", getJSONObject(properties), getDate(dateTime));
        }

        private static void userUnset(List<string> properties, string appId)
        {
            userUnset(properties, DateTime.Now, appId);
        }

        private static void userUnset(List<string> properties, DateTime dateTime, string appId)
        {
            Dictionary<string, object> finalProperties = new Dictionary<string, object>();
            foreach(string s in properties)
            {
                finalProperties.Add(s, 0);
            }

            getInstance(appId).Call("user_unset", getJSONObject(TD_MiniJSON.Serialize(finalProperties)), getDate(dateTime));
        }

        private static void userAdd(string properties, string appId)
        {
            getInstance(appId).Call("user_add", getJSONObject(properties));
        }

        private static void userAdd(string properties, DateTime dateTime, string appId)
        {
            getInstance(appId).Call("user_add", getJSONObject(properties), getDate(dateTime));
        }

        private static void userAppend(string properties, string appId)
        {
            getInstance(appId).Call("user_append", getJSONObject(properties));
        }

        private static void userAppend(string properties, DateTime dateTime, string appId)
        {
            getInstance(appId).Call("user_append", getJSONObject(properties), getDate(dateTime));
        }

        private static void userUniqAppend(string properties, string appId)
        {
            getInstance(appId).Call("user_uniqAppend", getJSONObject(properties));
        }

        private static void userUniqAppend(string properties, DateTime dateTime, string appId)
        {
            getInstance(appId).Call("user_uniqAppend", getJSONObject(properties), getDate(dateTime));
        }

        private static void userDelete(string appId)
        {
            getInstance(appId).Call("user_delete");
        }

        private static void userDelete(DateTime dateTime, string appId)
        {
            getInstance(appId).Call("user_delete", getDate(dateTime));
        }

        private static void logout(string appId)
        {
            getInstance(appId).Call("logout");
        }

        private static string getDeviceId()
        {
            return getInstance(default_appId).Call<string>("getDeviceId");
        }

        private static void setDynamicSuperProperties(IDynamicSuperProperties dynamicSuperProperties, string appId)
        {
            DynamicListenerAdapter listenerAdapter = new DynamicListenerAdapter();
            if (string.IsNullOrEmpty(appId))
            {
                appId = default_appId;
            }
            unityAPIInstance.Call("setDynamicSuperPropertiesTrackerListener", appId, listenerAdapter);
        }

        private static void setNetworkType(ThinkingAnalyticsAPI.NetworkType networkType) {
            Dictionary<string, object> properties = new Dictionary<string, object>() { };
            switch (networkType)
            {
                case ThinkingAnalyticsAPI.NetworkType.DEFAULT:
                    properties["network_type"] = 0;
                    break;
                case ThinkingAnalyticsAPI.NetworkType.WIFI:
                    properties["network_type"] = 1;
                    break;
                case ThinkingAnalyticsAPI.NetworkType.ALL:
                    properties["network_type"] = 2;
                    break;
            }
            unityAPIInstance.Call("setNetworkType", TD_MiniJSON.Serialize(properties));
        }

        private static void enableAutoTrack(AUTO_TRACK_EVENTS events, string properties, string appId)
        {
            if (string.IsNullOrEmpty(appId))
            {
                appId = default_appId;
            }
            Dictionary<string, object> propertiesNew = new Dictionary<string, object>() {
                { "appId", appId},
                { "autoTrackType", (int)events}
            };
            unityAPIInstance.Call("enableAutoTrack", TD_MiniJSON.Serialize(propertiesNew));
            propertiesNew["properties"] = TD_MiniJSON.Deserialize(properties);
            unityAPIInstance.Call("setAutoTrackProperties", TD_MiniJSON.Serialize(propertiesNew));
        }

        private static void enableAutoTrack(AUTO_TRACK_EVENTS events, IAutoTrackEventCallback eventCallback, string appId)
        {
            AutoTrackListenerAdapter listenerAdapter = new AutoTrackListenerAdapter();
            if (string.IsNullOrEmpty(appId))
            {
                appId = default_appId;
            }
            Dictionary<string, object> properties = new Dictionary<string, object>() {
                { "appId", appId},
                { "autoTrackType", (int)events}
            };
            unityAPIInstance.Call("enableAutoTrack", TD_MiniJSON.Serialize(properties), listenerAdapter);
        }

        private static void setAutoTrackProperties(AUTO_TRACK_EVENTS events, string properties, string appId)
        {
            if (string.IsNullOrEmpty(appId))
            {
                appId = default_appId;
            }
            Dictionary<string, object> propertiesNew = new Dictionary<string, object>() {
                { "appId", appId},
                { "autoTrackType", (int)events}
            };
            propertiesNew["properties"] = TD_MiniJSON.Deserialize(properties);
            unityAPIInstance.Call("setAutoTrackProperties", TD_MiniJSON.Serialize(propertiesNew));
        }

        private static void setTrackStatus(TA_TRACK_STATUS status, string appId)
        {
            AndroidJavaClass javaClass = new AndroidJavaClass("cn.thinkingdata.android.ThinkingAnalyticsSDK$TATrackStatus");
            AndroidJavaObject trackStatus;
            switch (status)
            {
                case TA_TRACK_STATUS.PAUSE:
                    trackStatus = javaClass.GetStatic<AndroidJavaObject>("PAUSE");
                    break;
                case TA_TRACK_STATUS.STOP:
                    trackStatus = javaClass.GetStatic<AndroidJavaObject>("STOP");
                    break;
                case TA_TRACK_STATUS.SAVE_ONLY:
                    trackStatus = javaClass.GetStatic<AndroidJavaObject>("SAVE_ONLY");
                    break;
                case TA_TRACK_STATUS.NORMAL:
                default:
                    trackStatus = javaClass.GetStatic<AndroidJavaObject>("NORMAL");
                    break;
            }
            getInstance(appId).Call("setTrackStatus", trackStatus);
        }

        private static void optOutTracking(string appId)
        {
            getInstance(appId).Call("optOutTracking");
        }

        private static void optOutTrackingAndDeleteUser(string appId)
        {
            getInstance(appId).Call("optOutTrackingAndDeleteUser");
        }

        private static void optInTracking(string appId)
        {
            getInstance(appId).Call("optInTracking");
        }

        private static void enableTracking(bool enabled, string appId)
        {
            getInstance(appId).Call("enableTracking", enabled);
        }

        private static string createLightInstance()
        {
            string randomID = System.Guid.NewGuid().ToString("N");
            AndroidJavaObject lightInstance = getInstance(default_appId).Call<AndroidJavaObject>("createLightInstance");
            if (light_instances == null) {
                light_instances = new Dictionary<string, AndroidJavaObject>();
            }
            light_instances.Add(randomID, lightInstance);
            return randomID;
        }

        private static void calibrateTime(long timestamp)
        {
            sdkClass.CallStatic("calibrateTime", timestamp);
        }

        private static void calibrateTimeWithNtp(string ntpServer)
        {
            unityAPIInstance.Call("calibrateTimeWithNtp", ntpServer);
        }

        private static void enableThirdPartySharing(TAThirdPartyShareType shareType, string properties, string appId)
        {
            Dictionary<string, object> obj = new Dictionary<string, object>() {
                { "appId", appId },
                { "type", (int)shareType }
            };
            obj["properties"] = TD_MiniJSON.Deserialize(properties);
            unityAPIInstance.Call("enableThirdPartySharing", TD_MiniJSON.Serialize(obj));
        }

        //dynamic super properties
        public interface IDynamicSuperPropertiesTrackerListener
        {
            string getDynamicSuperPropertiesString();
        }

        private class DynamicListenerAdapter : AndroidJavaProxy {
            public DynamicListenerAdapter() : base("cn.thinkingdata.engine.ThinkingAnalyticsUnityAPI$DynamicSuperPropertiesTrackerListener") {}
            public string getDynamicSuperPropertiesString()
            {
                Dictionary<string, object> ret;
                if (ThinkingAnalyticsWrapper.mDynamicSuperProperties != null) {
                    ret = ThinkingAnalyticsWrapper.mDynamicSuperProperties.GetDynamicSuperProperties();
                } 
                else {
                    ret = new Dictionary<string, object>();
                }
                return TD_MiniJSON.Serialize(ret);
            }
        }

        //auto-tracking
        public interface IAutoTrackEventTrackerListener
        {
            string eventCallback(int type, string appId, string properties);
        }

        private class AutoTrackListenerAdapter : AndroidJavaProxy {
            public AutoTrackListenerAdapter() : base("cn.thinkingdata.engine.ThinkingAnalyticsUnityAPI$AutoTrackEventTrackerListener") {}
            string eventCallback(int type, string appId, string properties)
            {
                Dictionary<string, object> ret;
                if (string.IsNullOrEmpty(appId)) appId = default_appId;
                if (ThinkingAnalyticsWrapper.mAutoTrackEventCallbacks.ContainsKey(appId))
                {
                    Dictionary<string, object> propertiesDic = TD_MiniJSON.Deserialize(properties);
                    ret = ThinkingAnalyticsWrapper.mAutoTrackEventCallbacks[appId].AutoTrackEventCallback(type, propertiesDic);
                } 
                else {
                    ret = new Dictionary<string, object>();
                }
                return TD_MiniJSON.Serialize(ret);
            }
        }
    }
}
#endif