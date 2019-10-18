using System;
using System.Collections.Generic;
using ThinkingAnalytics.Utils;
using UnityEngine;

namespace ThinkingAnalytics.Wrapper
{
    public partial class ThinkingAnalyticsWrapper
    {
#if (UNITY_EDITOR || (!UNITY_IOS && !UNITY_ANDROID))
        private string uniqueId;
        private void init(string appid, string serverUrl, bool enableLog)
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - Thinking for using ThinkingAnalytics SDK for tracking data.");
            enable_log(enableLog);
        }
        private void enable_log(bool enableLog)
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling enable_log with enableLog: " + enableLog);
        }

        private void identify(string uniqueId)
        {
            this.uniqueId = uniqueId;
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling Identify with uniqueId: " + uniqueId);
        }
        private string getDistinctId()
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling GetDistinctId with return value: " + this.uniqueId);
            return this.uniqueId;
        }

        private void login(string accountId)
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling Login with accountId: " + accountId);
        }

        private void logout()
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling Logout");
        }
        private void track(string eventName, Dictionary<string, object> properties)
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling track with eventName: " + eventName + ", " +
                "properties: " + TD_MiniJSON.Serialize(properties));
        }

        private void track(string eventName, Dictionary<string, object> properties, DateTime datetime)
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling track with eventName: " + eventName + ", " +
                "properties: " + TD_MiniJSON.Serialize(properties) + ", " +
                "dateTime: " + datetime.ToString());
        }

        private void setSuperProperties(Dictionary<string, object> superProperties)
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling setSuperProperties with superProperties: " + TD_MiniJSON.Serialize(superProperties));
        }

        private void unsetSuperProperty(string superPropertyName)
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling unsetSuperProperties with superPropertyName: " + superPropertyName);

        }
        private void clearSuperProperty()
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling clearSuperProperties");
        }

        private Dictionary<string, object> getSuperProperties()
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling getSuperProperties");
            return null;
        }
        private void timeEvent(string eventName)
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling timeEvent with eventName: " + eventName);
        }

        private void userSet(Dictionary<string, object> properties)
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling userSet with properties: " + TD_MiniJSON.Serialize(properties));
        }
        private void userSetOnce(Dictionary<string, object> properties)
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling userSetOnce with properties: " + TD_MiniJSON.Serialize(properties));
        }

        private void userUnset(List<string> properties)
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling userUnset with properties: " + string.Join(", ", properties.ToArray()));
        }

        private void userAdd(Dictionary<string, object> properties)
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling userAdd with properties: " + TD_MiniJSON.Serialize(properties));
        }

        private void userDelete()
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling userDelete");
        }

        private void flush()
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling flush.");
        }
        private void setNetworkType(ThinkingAnalyticsAPI.NetworkType networkType)
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling setNetworkType with networkType: " + (int)networkType);
        }

        private string getDeviceId() {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling getDeviceId()");
            return "editor device id";
        }

        private void trackAppInstall()
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling trackAppInstall()");
        }

        private void optOutTracking()
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling optOutTracking()");
        }

        private void optOutTrackingAndDeleteUser()
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling optOutTrackingAndDeleteUser()");
        }

        private void optInTracking()
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling optInTracking()");
        }

        private void enableTracking(bool enabled)
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling enableTracking() with enabled: " + enabled);
        }

        private ThinkingAnalyticsWrapper createLightInstance(ThinkingAnalyticsAPI.Token delegateToken)
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling createLightInstance()");
            return new ThinkingAnalyticsWrapper(delegateToken);
        }

#endif
        public readonly ThinkingAnalyticsAPI.Token token;
        private IDynamicSuperProperties dynamicSuperProperties;

        private static System.Random rnd = new System.Random();

        public ThinkingAnalyticsWrapper(ThinkingAnalyticsAPI.Token token, String serverUrl, bool enableLog)
        {
            this.token = token;
            init(token.appid, serverUrl, enableLog);
        }

        private ThinkingAnalyticsWrapper(ThinkingAnalyticsAPI.Token token)
        {
            this.token = token;
        }

        public void EnableLog(bool enableLog)
        {
            enable_log(enableLog);
        }

        public void Identify(string uniqueId)
        {
            identify(uniqueId);
        }

        public string GetDistinctId()
        {
            return getDistinctId();
        }

        public void Login(string accountId)
        {
            login(accountId);
        }

        public void Logout()
        {
            logout();
        }

        public void Track(string eventName, Dictionary<string, object> properties)
        {
            if (TD_PropertiesChecker.CheckString(eventName) && TD_PropertiesChecker.CheckProperties(properties))
            {
                if (null != dynamicSuperProperties)
                {
                    Dictionary<string, object> finalProperties = new Dictionary<string, object>();
                    TD_PropertiesChecker.MergeProperties(dynamicSuperProperties.GetDynamicSuperProperties(), finalProperties);
                    TD_PropertiesChecker.MergeProperties(properties, finalProperties);
                    track(eventName, finalProperties);
                } else
                {
                    track(eventName, properties);
                }
            }
        }

        public void Track(string eventName, Dictionary<string, object> properties, DateTime datetime)
        {
            if (TD_PropertiesChecker.CheckString(eventName) && TD_PropertiesChecker.CheckProperties(properties))
            {
                if (null != dynamicSuperProperties)
                {
                    Dictionary<string, object> finalProperties = new Dictionary<string, object>();
                    TD_PropertiesChecker.MergeProperties(dynamicSuperProperties.GetDynamicSuperProperties(), finalProperties);
                    TD_PropertiesChecker.MergeProperties(properties, finalProperties);
                    track(eventName, finalProperties, datetime);
                }
                else
                {
                    track(eventName, properties, datetime);
                }
            }
        }

        public void SetSuperProperties(Dictionary<string, object> superProperties)
        {
            if (TD_PropertiesChecker.CheckProperties(superProperties))
            {
                setSuperProperties(superProperties);
            }
        }

        public void UnsetSuperProperty(string superPropertyName)
        {
            if (TD_PropertiesChecker.CheckString(superPropertyName))
            {
                unsetSuperProperty(superPropertyName);
            }
        }

        public void ClearSuperProperty()
        {
            clearSuperProperty();
        }


        public void TimeEvent(string eventName)
        {
            if (TD_PropertiesChecker.CheckString(eventName))
            {
                timeEvent(eventName);
            }
        }

        public Dictionary<string, object> GetSuperProperties()
        {
            return getSuperProperties();
        }

        public void UserSet(Dictionary<string, object> properties)
        {
            if (TD_PropertiesChecker.CheckProperties(properties))
            {
                userSet(properties);

            }
        }

        public void UserSetOnce(Dictionary<string, object> properties)
        {
            if (TD_PropertiesChecker.CheckProperties(properties))
            {
                userSetOnce(properties);
            }

        }

        public void UserUnset(List<string> properties)
        {
            if (TD_PropertiesChecker.CheckProperteis(properties))
            {
                userUnset(properties);
            }
        }

        public void UserAdd(Dictionary<string, object> properties)
        {
            if (TD_PropertiesChecker.CheckProperties(properties))
            {
                userAdd(properties);
            }
        }

        public void UserDelete()
        {
            userDelete();
        }

        public void Flush()
        {
            flush();
        }

        public void SetNetworkType(ThinkingAnalyticsAPI.NetworkType networkType)
        {
            setNetworkType(networkType);
        }

        public string GetDeviceId()
        {
            return getDeviceId();
        }

        public void SetDynamicSuperProperties(IDynamicSuperProperties dynamicSuperProperties)
        {
            if (TD_PropertiesChecker.CheckProperties(dynamicSuperProperties.GetDynamicSuperProperties()))
            {
                this.dynamicSuperProperties = dynamicSuperProperties;
            } else
            {
                TD_Log.d("TA.Wrapper(" + token.appid + ") - Cannot set dynamic super properties due to invalid properties.");
            }
        }

        public void TrackAppInstall()
        {
            trackAppInstall();
        }

        public void OptOutTracking()
        {
            optOutTracking();
        }

        public void OptOutTrackingAndDeleteUser()
        {
            optOutTrackingAndDeleteUser();
        }

        public void OptInTracking()
        {
            optInTracking();
        }

        public void EnableTracking(bool enabled)
        {
            enableTracking(enabled);
        }

        public ThinkingAnalyticsWrapper CreateLightInstance()
        {
            return createLightInstance(new ThinkingAnalyticsAPI.Token(rnd.Next().ToString(), false));
        }

        internal string GetAppId()
        {
            return token.appid;
        }
    }
}

