#if UNITY_ANDROID && !(UNITY_EDITOR)
using System;
using System.Collections;
using System.Collections.Generic;
using ThinkingAnalytics.Utils;
using UnityEngine;

namespace ThinkingAnalytics.Wrapper
{
    public partial class ThinkingAnalyticsWrapper
    {
        private static ThinkingAnalyticsWrapper wrapper;
        private static readonly string JSON_CLASS = "org.json.JSONObject";
        private static readonly AndroidJavaClass sdkClass = new AndroidJavaClass("cn.thinkingdata.android.ThinkingAnalyticsSDK");
        private static readonly AndroidJavaClass configClass = new AndroidJavaClass("cn.thinkingdata.android.TDConfig");
        private AndroidJavaObject instance;
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

        private string getTimeString(DateTime dateTime) {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;

            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;

            AndroidJavaObject date = new AndroidJavaObject("java.util.Date", currentMillis);
            return instance.Call<string>("getTimeString", date);
        }

        private static void enable_log(bool enableLog) {
            sdkClass.CallStatic("enableTrackLog", enableLog);
        }
        private static void setVersionInfo(string libName, string version) {
            sdkClass.CallStatic("setCustomerLibInfo", libName, version);
        }

        private void init()
        {
            wrapper = this;
            AndroidJavaObject context = new AndroidJavaClass("com.unity3d.player.UnityPlayer").GetStatic<AndroidJavaObject>("currentActivity"); //获得Context
            AndroidJavaObject config = configClass.CallStatic<AndroidJavaObject>("getInstance", context, token.appid, token.serverUrl);
            config.Call("setModeInt", (int) token.mode);

            string timeZoneId = token.getTimeZoneId();
            if (null != timeZoneId && timeZoneId.Length > 0)
            {
                AndroidJavaObject timeZone = new AndroidJavaClass("java.util.TimeZone").CallStatic<AndroidJavaObject>("getTimeZone", timeZoneId);
                if (null != timeZone)
                {
                    config.Call("setDefaultTimeZone", timeZone);
                }
            }

            if (token.enableEncrypt == true)
            {
                config.Call("enableEncrypt", true);
                AndroidJavaObject secreteKey = new AndroidJavaObject("cn.thinkingdata.android.encrypt.TDSecreteKey", token.encryptPublicKey, token.encryptVersion, "AES", "RSA");
                config.Call("setSecretKey", secreteKey);
            }

            instance = sdkClass.CallStatic<AndroidJavaObject>("sharedInstance", config);
        }

        private void flush()
        {
            instance.Call("flush");
        }

        private AndroidJavaObject getDate(DateTime dateTime)
        {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;

            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            return new AndroidJavaObject("java.util.Date", currentMillis);
        }

        private void track(string eventName, string properties, DateTime dateTime)
        {
            AndroidJavaObject date = getDate(dateTime);
            AndroidJavaClass tzClass = new AndroidJavaClass("java.util.TimeZone");
            AndroidJavaObject tz = null;

            if (token.timeZone == ThinkingAnalyticsAPI.TATimeZone.Local)
            {
                switch (dateTime.Kind)
                {
                    case DateTimeKind.Local:
                        tz = tzClass.CallStatic<AndroidJavaObject>("getDefault");
                        break;
                    case DateTimeKind.Utc:
                        tz = tzClass.CallStatic<AndroidJavaObject>("getTimeZone", "UTC");
                        break;
                    case DateTimeKind.Unspecified:
                        break;
                }
            }
            else
            {
                tz = tzClass.CallStatic<AndroidJavaObject>("getTimeZone", token.getTimeZoneId());
            }

            instance.Call("track", eventName, getJSONObject(properties), date, tz);
        }

        private void track(ThinkingAnalyticsEvent taEvent)
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

            if (taEvent.EventTime != DateTime.MinValue) {
                AndroidJavaObject date = getDate(taEvent.EventTime);
                AndroidJavaClass tzClass = new AndroidJavaClass("java.util.TimeZone");
                AndroidJavaObject tz = null;

                if (token.timeZone == ThinkingAnalyticsAPI.TATimeZone.Local)
                {
                    switch (taEvent.EventTime.Kind)
                    {
                        case DateTimeKind.Local:
                            tz = tzClass.CallStatic<AndroidJavaObject>("getDefault");
                            break;
                        case DateTimeKind.Utc:
                            tz = tzClass.CallStatic<AndroidJavaObject>("getTimeZone", "UTC");
                            break;
                        case DateTimeKind.Unspecified:
                            break;
                    }
                }
                else
                {
                    tz = tzClass.CallStatic<AndroidJavaObject>("getTimeZone", token.getTimeZoneId());
                }
                javaEvent.Call("setEventTime", date, tz);
            }
            instance.Call("track", javaEvent);
        }

        private void track(string eventName, string properties)
        {
            instance.Call("track", eventName, getJSONObject(properties));
        }

        private void setSuperProperties(string superProperties)
        {
            instance.Call("setSuperProperties", getJSONObject(superProperties));
        }

        private void unsetSuperProperty(string superPropertyName)
        {
            instance.Call("unsetSuperProperty", superPropertyName);
        }

        private void clearSuperProperty()
        {
            instance.Call("clearSuperProperties");
        }

        private Dictionary<string, object> getSuperProperties()
        {
            Dictionary<string, object> result = null;
            AndroidJavaObject superPropertyObject = instance.Call<AndroidJavaObject>("getSuperProperties");
            if (null != superPropertyObject)
            {
                string superPropertiesString = superPropertyObject.Call<string>("toString");
                result = TD_MiniJSON.Deserialize(superPropertiesString);
            }
            return result;
        }

        private Dictionary<string, object> getPresetProperties()
        {
            Dictionary<string, object> result = null;
            AndroidJavaObject presetPropertyObject = instance.Call<AndroidJavaObject>("getPresetProperties").Call<AndroidJavaObject>("toEventPresetProperties");
            if (null != presetPropertyObject)
            {
                string presetPropertiesString = presetPropertyObject.Call<string>("toString");
                result = TD_MiniJSON.Deserialize(presetPropertiesString);
            }
            return result;
        }

        private void timeEvent(string eventName)
        {
            instance.Call("timeEvent", eventName);
        }

        private void identify(string uniqueId)
        {
            instance.Call("identify", uniqueId);
        }

        private string getDistinctId()
        {
            return instance.Call<string>("getDistinctId");
        }

        private void login(string uniqueId)
        {
            instance.Call("login", uniqueId);
        }

        private void userSetOnce(string properties)
        {
            instance.Call("user_setOnce", getJSONObject(properties));
        }

        private void userSetOnce(string properties, DateTime dateTime)
        {
            instance.Call("user_setOnce", getJSONObject(properties), getDate(dateTime));
        }

        private void userSet(string properties)
        {
            instance.Call("user_set", getJSONObject(properties));
        }

        private void userSet(string properties, DateTime dateTime)
        {
            instance.Call("user_set", getJSONObject(properties), getDate(dateTime));
        }

        private void userUnset(List<string> properties)
        {
            userUnset(properties, DateTime.Now);
        }

        private void userUnset(List<string> properties, DateTime dateTime)
        {
            Dictionary<string, object> finalProperties = new Dictionary<string, object>();
            foreach(string s in properties)
            {
                finalProperties.Add(s, 0);
            }

            instance.Call("user_unset", getJSONObject(TD_MiniJSON.Serialize(finalProperties)), getDate(dateTime));
        }

        private void userAdd(string properties)
        {
            instance.Call("user_add", getJSONObject(properties));
        }

        private void userAdd(string properties, DateTime dateTime)
        {
            instance.Call("user_add", getJSONObject(properties), getDate(dateTime));
        }

        private void userAppend(string properties)
        {
            instance.Call("user_append", getJSONObject(properties));
        }

        private void userAppend(string properties, DateTime dateTime)
        {
            instance.Call("user_append", getJSONObject(properties), getDate(dateTime));
        }

        private void userUniqAppend(string properties)
        {
            instance.Call("user_uniqAppend", getJSONObject(properties));
        }

        private void userUniqAppend(string properties, DateTime dateTime)
        {
            instance.Call("user_uniqAppend", getJSONObject(properties), getDate(dateTime));
        }

        private void userDelete()
        {
            instance.Call("user_delete");
        }

        private void userDelete(DateTime dateTime)
        {
            instance.Call("user_delete", getDate(dateTime));
        }

        private void logout() {
            instance.Call("logout");
        }

        private string getDeviceId()
        {
            return instance.Call<string>("getDeviceId");
        }

        public void setDynamicSuperProperties(IDynamicSuperProperties dynamicSuperProperties)
        {
            DynamicListenerAdapter listenerAdapter = new DynamicListenerAdapter();
            instance.Call("setDynamicSuperPropertiesTrackerListener", listenerAdapter);
        }

        private void setNetworkType(ThinkingAnalyticsAPI.NetworkType networkType) {
            switch (networkType)
            {
                case ThinkingAnalyticsAPI.NetworkType.DEFAULT:
                    instance.Call("setNetworkType", 0);
                    break;
                case ThinkingAnalyticsAPI.NetworkType.WIFI:
                    instance.Call("setNetworkType", 1);
                    break;
                case ThinkingAnalyticsAPI.NetworkType.ALL:
                    instance.Call("setNetworkType", 2);
                    break;
            }
        }

        private void enableAutoTrack(AUTO_TRACK_EVENTS events, string properties)
        {
            instance.Call("enableAutoTrack", (int) events, getJSONObject(properties));
        }

        private void enableAutoTrack(AUTO_TRACK_EVENTS events, IAutoTrackEventCallback eventCallback)
        {
            AutoTrackListenerAdapter listenerAdapter = new AutoTrackListenerAdapter();
            instance.Call("enableAutoTrack", (int) events, listenerAdapter);
        }

        private void setAutoTrackProperties(AUTO_TRACK_EVENTS events, string properties)
        {
            instance.Call("setAutoTrackProperties", (int) events, getJSONObject(properties));
        }

        private void setTrackStatus(TA_TRACK_STATUS status)
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
            instance.Call("setTrackStatus", trackStatus);
        }

        private void optOutTracking()
        {
            instance.Call("optOutTracking");
        }

        private void optOutTrackingAndDeleteUser()
        {
            instance.Call("optOutTrackingAndDeleteUser");
        }

        private void optInTracking()
        {
            instance.Call("optInTracking");
        }

        private void enableTracking(bool enabled)
        {
            instance.Call("enableTracking", enabled);
        }

        private void setInstance(AndroidJavaObject anotherInstance)
        {
            this.instance = anotherInstance;
        }

        private ThinkingAnalyticsWrapper createLightInstance(ThinkingAnalyticsAPI.Token delegateToken)
        {
            ThinkingAnalyticsWrapper result = new ThinkingAnalyticsWrapper(delegateToken, this.taMono, false);
            AndroidJavaObject lightInstance = instance.Call<AndroidJavaObject>("createLightInstance");
            result.setInstance(lightInstance);
            return result;
        }

        private static void calibrateTime(long timestamp)
        {
            sdkClass.CallStatic("calibrateTime", timestamp);
        }

        private static void calibrateTimeWithNtp(string ntpServer)
        {
            sdkClass.CallStatic("calibrateTimeWithNtpForUnity", ntpServer);
        }

        private void enableThirdPartySharing(TAThirdPartyShareType shareType)
        {
            instance.Call("enableThirdPartySharing", (int) shareType);
        }

        //动态公共属性
        public interface IDynamicSuperPropertiesTrackerListener
        {
            string getDynamicSuperPropertiesString();
        }
        private class DynamicListenerAdapter : AndroidJavaProxy {
            public DynamicListenerAdapter() : base("cn.thinkingdata.android.ThinkingAnalyticsSDK$DynamicSuperPropertiesTrackerListener") {}
            public string getDynamicSuperPropertiesString()
            {
                Dictionary<string, object> ret;
                if (wrapper.dynamicSuperProperties != null) {
                    ret = wrapper.dynamicSuperProperties.GetDynamicSuperProperties();
                } 
                else {
                    ret = new Dictionary<string, object>();
                }
                return TD_MiniJSON.Serialize(ret);
            }
        }
        //自动采集事件回调
        public interface IAutoTrackEventTrackerListener
        {
            string eventCallback(int type, string properties);
        }
        private class AutoTrackListenerAdapter : AndroidJavaProxy {
            public AutoTrackListenerAdapter() : base("cn.thinkingdata.android.ThinkingAnalyticsSDK$AutoTrackEventTrackerListener") {}
            string eventCallback(int type, string properties)
            {
                Dictionary<string, object> ret;
                if (wrapper.autoTrackEventCallback != null) {
                    Dictionary<string, object> propertiesDic = TD_MiniJSON.Deserialize(properties);
                    ret = wrapper.autoTrackEventCallback.AutoTrackEventCallback(type, propertiesDic);
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