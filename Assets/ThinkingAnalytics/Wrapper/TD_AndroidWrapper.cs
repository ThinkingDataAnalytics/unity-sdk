using System;
using System.Collections;
using System.Collections.Generic;
using ThinkingAnalytics.Utils;
using UnityEngine;

namespace ThinkingAnalytics.Wrapper
{
    public partial class ThinkingAnalyticsWrapper
    {
#if UNITY_ANDROID && !(UNITY_EDITOR)
        private static AndroidJavaClass agent;
        private static readonly string SDK_CLASS = "cn.thinkingdata.android.ThinkingAnalyticsSDK";
        private static readonly string JSON_CLASS = "org.json.JSONObject";
        private AndroidJavaObject instance;
        /// <summary>
        /// Convert Dictionary object to JSONObject in Java.
        /// </summary>
        /// <returns>The JSONObject instance.</returns>
        /// <param name="data">The Dictionary containing some data </param>
        private static AndroidJavaObject GetJSONObject<T>(Dictionary<string, T> data)
        {
            if (null == data || data.Count == 0)
            {
                return null;
            }
            else
            {
                string dataString = TD_MiniJSON.Serialize(data);
                return new AndroidJavaObject(JSON_CLASS, dataString);
            }
        }

        private void enable_log(bool enableLog) { 
        }

        private void init(string token, string serverUrl, bool enableLog)
        {
            agent = new AndroidJavaClass(SDK_CLASS);
            agent.CallStatic("enableTrackLog", enableLog);
            AndroidJavaObject context = new AndroidJavaClass("com.unity3d.player.UnityPlayer").GetStatic<AndroidJavaObject>("currentActivity"); //获得Context
            instance = agent.CallStatic<AndroidJavaObject>("sharedInstance", context, token, serverUrl);
        }

        private void flush()
        {
            instance.Call("flush");
        }

        private void track(string eventName, Dictionary<string, object> properties, DateTime dateTime)
        {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;

            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;

            AndroidJavaObject date = new AndroidJavaObject("java.util.Date", currentMillis);
            instance.Call("track", eventName, GetJSONObject(properties), date);
        }
        private void track(string eventName, Dictionary<string, object> properties)
        {
            instance.Call("track", eventName, GetJSONObject(properties));
        }

        private void setSuperProperties(Dictionary<string, object> superProperties)
        {
            instance.Call("setSuperProperties", GetJSONObject(superProperties));
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

        private void userSetOnce(Dictionary<string, object> properties)
        {
            instance.Call("user_setOnce", GetJSONObject(properties));
        }
        private void userSet(Dictionary<string, object> properties)
        {
            instance.Call("user_set", GetJSONObject(properties));

        }
        private void userAdd(Dictionary<string, object> properties)
        {
            instance.Call("user_add", GetJSONObject(properties));
        }
        private void userDelete()
        {
            instance.Call("user_delete");
        }

        private void logout() {
            instance.Call("logout");
        }

        private string getDeviceId()
        {
            return instance.Call<string>("getDeviceId");
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

        private void trackAppInstall()
        {
            instance.Call("trackAppInstall");
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
            ThinkingAnalyticsWrapper result = new ThinkingAnalyticsWrapper(delegateToken);
            AndroidJavaObject lightInstance = instance.Call<AndroidJavaObject>("createLightInstance");
            result.setInstance(lightInstance);
            return result;
        }
#endif
    }
}