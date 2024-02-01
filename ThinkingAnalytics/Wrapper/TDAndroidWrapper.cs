#if UNITY_ANDROID && !(UNITY_EDITOR) && !TE_DISABLE_ANDROID_JAVA
using System;
using System.Collections.Generic;
using ThinkingData.Analytics.Utils;
using UnityEngine;

namespace ThinkingData.Analytics.Wrapper
{
    public partial class TDWrapper
    {
        private static readonly string JSON_CLASS = "org.json.JSONObject";
        private static readonly AndroidJavaClass sdkClass = new AndroidJavaClass("cn.thinkingdata.analytics.ThinkingAnalyticsSDK");
        //private static readonly AndroidJavaClass configClass = new AndroidJavaClass("cn.thinkingdata.android.TDConfig");

        private static readonly AndroidJavaObject unityAPIInstance = new AndroidJavaObject("cn.thinkingdata.engine.ThinkingAnalyticsUnityAPI");

        private static Dictionary<string, AndroidJavaObject> light_instances = null;
        private static TimeZoneInfo defaultTimeZone = null;

        /// <summary>
        /// Convert Dictionary object to JSONObject in Java.
        /// </summary>
        /// <returns>The JSONObject instance.</returns>
        /// <param name="data">The Dictionary containing some data </param>
        private static AndroidJavaObject getJSONObject(Dictionary<string, object> data)
        {
            if (data == null)
            {
                return null;
            }

            string dataString = serilize(data);

            try
            {
                return new AndroidJavaObject(JSON_CLASS, dataString);
            }
            catch (Exception e)
            {
                if(TDLog.GetEnable()) TDLog.w("ThinkingAnalytics: unexpected exception: " + e);
            }
            return null;
        }

        private static string getTimeString(DateTime dateTime) {
            //long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;

            //DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            //long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;

            //AndroidJavaObject date = new AndroidJavaObject("java.util.Date", currentMillis);

            //return getInstance(default_appId).Call<string>("getTimeString", date);
            return TDCommonUtils.FormatDate(dateTime, defaultTimeZone);
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

        private static void init(TDConfig token)
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

            if (string.IsNullOrEmpty(default_appId)) default_appId = token.appId;
            Dictionary<string, object> configDic = new Dictionary<string, object>();
            configDic["appId"] = token.appId;
            configDic["serverUrl"] = token.serverUrl;
            configDic["mode"] = (int) token.mode;
            if (!string.IsNullOrEmpty(token.name))
            {
                // if (string.IsNullOrEmpty(default_appId)) default_appId = token.GetInstanceName();
                configDic["instanceName"] = token.name;
            }
            else
            {
                // if (string.IsNullOrEmpty(default_appId)) default_appId = token.appid;
            }
            string timeZoneId = token.getTimeZoneId();
            if (null != timeZoneId && timeZoneId.Length > 0)
            {
                configDic["timeZone"] = timeZoneId;
                if (defaultTimeZone == null)
                {
                    defaultTimeZone = TimeZoneInfo.FindSystemTimeZoneById(timeZoneId);
                }
            }
            else {
                if (defaultTimeZone == null) {
                    defaultTimeZone = TimeZoneInfo.Local;
                }
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
            unityAPIInstance.Call("sharedInstance", context, TDMiniJson.Serialize(configDic));
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

        private static void track(string eventName, Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
            AndroidJavaObject date = getDate(dateTime);
            AndroidJavaClass tzClass = new AndroidJavaClass("java.util.TimeZone");
            AndroidJavaObject tz = null;
            getInstance(appId).Call("track", eventName, getJSONObject(properties), date, tz);
        }

        private static void track(string eventName, Dictionary<string, object> properties, DateTime dateTime, TimeZoneInfo timeZone, string appId)
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

        private static void trackForAll(string eventName, Dictionary<string, object> properties)
        {
            string appId = "";
            track(eventName, properties, appId);
        }

        private static void track(TDEventModel taEvent, string appId)
        {
            AndroidJavaObject javaEvent = null;
            switch(taEvent.EventType)
            {
                case TDEventModel.TDEventType.First:
                    javaEvent = new AndroidJavaObject("cn.thinkingdata.analytics.TDFirstEvent", 
                        taEvent.EventName, getJSONObject(getFinalEventProperties(taEvent.Properties)));

                    string extraId = taEvent.GetEventId();
                    if (!string.IsNullOrEmpty(extraId))
                    {
                        javaEvent.Call("setFirstCheckId", extraId);
                    }
                    
                    break;
                case TDEventModel.TDEventType.Updatable:
                    javaEvent = new AndroidJavaObject("cn.thinkingdata.analytics.TDUpdatableEvent", 
                        taEvent.EventName, getJSONObject(getFinalEventProperties(taEvent.Properties)), taEvent.GetEventId()); 
                    break;
                case TDEventModel.TDEventType.Overwritable:
                    javaEvent = new AndroidJavaObject("cn.thinkingdata.analytics.TDOverWritableEvent", 
                        taEvent.EventName, getJSONObject(getFinalEventProperties(taEvent.Properties)), taEvent.GetEventId()); 
                    break;
            }
            if (null == javaEvent) {
                if(TDLog.GetEnable()) TDLog.w("Unexpected java event object. Returning...");
                return;
            }

            if (taEvent.GetEventTime() != null && taEvent.GetEventTime() != DateTime.MinValue) {
                AndroidJavaObject date = getDate(taEvent.GetEventTime());
                AndroidJavaClass tzClass = new AndroidJavaClass("java.util.TimeZone");
                AndroidJavaObject tz = null;
                if (taEvent.GetEventTimeZone() != null) {
                    if ("Local" == taEvent.GetEventTimeZone().Id) {
                        tz = new AndroidJavaClass("java.util.TimeZone").CallStatic<AndroidJavaObject>("getDefault");
                    }
                    else {
                        tz = new AndroidJavaClass("java.util.TimeZone").CallStatic<AndroidJavaObject>("getTimeZone", taEvent.GetEventTimeZone().Id);
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

        private static void track(string eventName, Dictionary<string, object> properties, string appId)
        {
            getInstance(appId).Call("track", eventName, getJSONObject(properties));
        }

        private static void setSuperProperties(Dictionary<string, object> superProperties, string appId)
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
                result = TDMiniJson.Deserialize(superPropertiesString);
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
                result = TDMiniJson.Deserialize(presetPropertiesString);
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

        private static void userSetOnce(Dictionary<string, object> properties, string appId)
        {
            getInstance(appId).Call("user_setOnce", getJSONObject(properties));
        }

        private static void userSetOnce(Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
            getInstance(appId).Call("user_setOnce", getJSONObject(properties), getDate(dateTime));
        }

        private static void userSet(Dictionary<string, object> properties, string appId)
        {
            getInstance(appId).Call("user_set", getJSONObject(properties));
        }

        private static void userSet(Dictionary<string, object> properties, DateTime dateTime, string appId)
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

            getInstance(appId).Call("user_unset", getJSONObject(finalProperties), getDate(dateTime));
        }

        private static void userAdd(Dictionary<string, object> properties, string appId)
        {
            getInstance(appId).Call("user_add", getJSONObject(properties));
        }

        private static void userAdd(Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
            getInstance(appId).Call("user_add", getJSONObject(properties), getDate(dateTime));
        }

        private static void userAppend(Dictionary<string, object> properties, string appId)
        {
            getInstance(appId).Call("user_append", getJSONObject(properties));
        }

        private static void userAppend(Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
            getInstance(appId).Call("user_append", getJSONObject(properties), getDate(dateTime));
        }

        private static void userUniqAppend(Dictionary<string, object> properties, string appId)
        {
            getInstance(appId).Call("user_uniqAppend", getJSONObject(properties));
        }

        private static void userUniqAppend(Dictionary<string, object> properties, DateTime dateTime, string appId)
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

        private static void setDynamicSuperProperties(TDDynamicSuperPropertiesHandler dynamicSuperProperties, string appId)
        {
            DynamicListenerAdapter listenerAdapter = new DynamicListenerAdapter();
            if (string.IsNullOrEmpty(appId))
            {
                appId = default_appId;
            }
            unityAPIInstance.Call("setDynamicSuperPropertiesTrackerListener", appId, listenerAdapter);
        }

        private static void setNetworkType(TDNetworkType networkType) {
            Dictionary<string, object> properties = new Dictionary<string, object>() { };
            switch (networkType)
            {
                case TDNetworkType.Wifi:
                    properties["network_type"] = 1;
                    break;
                case TDNetworkType.All:
                    properties["network_type"] = 2;
                    break;
                default:
                    properties["network_type"] = 2;
                    break;

            }
            unityAPIInstance.Call("setNetworkType", TDMiniJson.Serialize(properties));
        }

        private static void enableAutoTrack(TDAutoTrackEventType events, Dictionary<string, object> properties, string appId)
        {
            if (string.IsNullOrEmpty(appId))
            {
                appId = default_appId;
            }
            Dictionary<string, object> propertiesNew = new Dictionary<string, object>() {
                { "appId", appId},
                { "autoTrackType", (int)events}
            };
            unityAPIInstance.Call("enableAutoTrack", TDMiniJson.Serialize(propertiesNew));
            propertiesNew["properties"] = properties;
            unityAPIInstance.Call("setAutoTrackProperties", TDMiniJson.Serialize(propertiesNew));
        }

        private static void enableAutoTrack(TDAutoTrackEventType events, TDAutoTrackEventHandler eventCallback, string appId)
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
            unityAPIInstance.Call("enableAutoTrack", TDMiniJson.Serialize(properties), listenerAdapter);
        }

        private static void setAutoTrackProperties(TDAutoTrackEventType events, Dictionary<string, object> properties, string appId)
        {
            if (string.IsNullOrEmpty(appId))
            {
                appId = default_appId;
            }
            Dictionary<string, object> propertiesNew = new Dictionary<string, object>() {
                { "appId", appId},
                { "autoTrackType", (int)events}
            };
            propertiesNew["properties"] = properties;
            unityAPIInstance.Call("setAutoTrackProperties", TDMiniJson.Serialize(propertiesNew));
        }

        private static void setTrackStatus(TDTrackStatus status, string appId)
        {
            AndroidJavaClass javaClass = new AndroidJavaClass("cn.thinkingdata.analytics.ThinkingAnalyticsSDK$TATrackStatus");
            AndroidJavaObject trackStatus;
            switch (status)
            {
                case TDTrackStatus.Pause:
                    trackStatus = javaClass.GetStatic<AndroidJavaObject>("PAUSE");
                    break;
                case TDTrackStatus.Stop:
                    trackStatus = javaClass.GetStatic<AndroidJavaObject>("STOP");
                    break;
                case TDTrackStatus.SaveOnly:
                    trackStatus = javaClass.GetStatic<AndroidJavaObject>("SAVE_ONLY");
                    break;
                case TDTrackStatus.Normal:
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

        private static void enableThirdPartySharing(TDThirdPartyType shareType, Dictionary<string, object> properties, string appId)
        {
            Dictionary<string, object> obj = new Dictionary<string, object>() {
                { "appId", appId },
                { "type", (int)shareType }
            };
            obj["properties"] = properties;
            unityAPIInstance.Call("enableThirdPartySharing", TDMiniJson.Serialize(obj));
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
                if (TDWrapper.mDynamicSuperProperties != null) {
                    ret = TDWrapper.mDynamicSuperProperties.GetDynamicSuperProperties();
                } 
                else {
                    ret = new Dictionary<string, object>();
                }
                //return TDMiniJson.Serialize(ret);
                return serilize(ret);
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
                if (TDWrapper.mAutoTrackEventCallbacks.ContainsKey(appId))
                {
                    Dictionary<string, object> propertiesDic = TDMiniJson.Deserialize(properties);
                    ret = TDWrapper.mAutoTrackEventCallbacks[appId].GetAutoTrackEventProperties(type, propertiesDic);
                } 
                else {
                    ret = new Dictionary<string, object>();
                }
                return serilize(ret);
            }
        }
    }
}
#endif