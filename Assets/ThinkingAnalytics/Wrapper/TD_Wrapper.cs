using System;
using System.Collections.Generic;
using ThinkingAnalytics.Utils;
using UnityEngine;

namespace ThinkingAnalytics.Wrapper
{
    public partial class ThinkingAnalyticsWrapper
    {
#if (!(UNITY_EDITOR || UNITY_IOS || UNITY_ANDROID|| UNITY_STANDALONE))
        private string uniqueId;
        private void init()
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - Thanks for using ThinkingAnalytics SDK for tracking data.");
        }
        private static void enable_log(bool enableLog)
        {
            TD_Log.d("TA.Wrapper - calling enable_log with enableLog: " + enableLog);
        }
        private static void setVersionInfo(string libName, string version) {

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
        private void track(string eventName, string properties)
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling track with eventName: " + eventName + ", " +
                "properties: " + properties);
        }

        private void track(string eventName, string properties, DateTime datetime)
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling track with eventName: " + eventName + ", " +
                "properties: " + properties + ", " +
                "dateTime: " + datetime.ToString());
        }

        private void track(ThinkingAnalyticsEvent analyticsEvent)
        {
                TD_Log.d("TA.Wrapper(" + token.appid + ") - calling track with eventName: " + analyticsEvent.EventName + ", " +
                "properties: " + getFinalEventProperties(analyticsEvent.Properties));

        }

        private void setSuperProperties(string superProperties)
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

        private void userSet(string properties)
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling userSet with properties: " + TD_MiniJSON.Serialize(properties));
        }

        private void userSet(string properties, DateTime dateTime)
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling userSet with properties: " + TD_MiniJSON.Serialize(properties)
                + ", dateTime: " + dateTime.ToString("yyyy-MM-dd HH:mm:ss.fff"));
        }
        private void userSetOnce(string properties)
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling userSetOnce with properties: " + TD_MiniJSON.Serialize(properties));
        }

        private void userSetOnce(string properties, DateTime dateTime)
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling userSetOnce with properties: " + TD_MiniJSON.Serialize(properties)
                + ", dateTime: " + dateTime.ToString("yyyy-MM-dd HH:mm:ss.fff"));
        }

        private void userUnset(List<string> properties)
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling userUnset with properties: " + string.Join(", ", properties.ToArray()));
        }

        private void userUnset(List<string> properties, DateTime dateTime)
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling userUnset with properties: " + string.Join(", ", properties.ToArray())
                + ", dateTime: " + dateTime.ToString("yyyy-MM-dd HH:mm:ss.fff"));
        }

        private void userAdd(string properties)
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling userAdd with properties: " + TD_MiniJSON.Serialize(properties));
        }

        private void userAdd(string properties, DateTime dateTime)
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling userAdd with properties: " + TD_MiniJSON.Serialize(properties)
                 + ", dateTime: " + dateTime.ToString("yyyy-MM-dd HH:mm:ss.fff"));
        }

        private void userAppend(string properties)
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling userAppend with properties: " + TD_MiniJSON.Serialize(properties));
        }

        private void userAppend(string properties, DateTime dateTime)
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling userAppend with properties: " + TD_MiniJSON.Serialize(properties)
                + ", dateTime: " + dateTime.ToString("yyyy-MM-dd HH:mm:ss.fff"));
        }

        private void userDelete()
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling userDelete");
        }

        private void userDelete(DateTime dateTime)
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling userDelete"  + ", dateTime: " + dateTime.ToString("yyyy-MM-dd HH:mm:ss.fff"));
        }

        private void flush()
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling flush.");
        }

        private void enableAutoTrack(AUTO_TRACK_EVENTS events)
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling enableAutoTrack: " + events.ToString());
        }
        private void setNetworkType(ThinkingAnalyticsAPI.NetworkType networkType)
        {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling setNetworkType with networkType: " + (int)networkType);
        }

        private string getDeviceId() {
            TD_Log.d("TA.Wrapper(" + token.appid + ") - calling getDeviceId()");
            return "editor device id";
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
            return new ThinkingAnalyticsWrapper(delegateToken, false);
        }

        private string getTimeString(DateTime dateTime) {
            return dateTime.ToString("yyyy-MM-dd HH:mm:ss.fff");
        }

        private static void calibrateTime(long timestamp)
        {
            TD_Log.d("TA.Wrapper: - calling calibrateTime() with: " + timestamp);
        }

        private static void calibrateTimeWithNtp(string ntpServer)
        {
            TD_Log.d("TA.Wrapper: - calling calibrateTimeWithNtp() with: " + ntpServer);
        }

#endif
        public readonly ThinkingAnalyticsAPI.Token token;
        private IDynamicSuperProperties dynamicSuperProperties;

        private static System.Random rnd = new System.Random();

        private string serilize<T>(Dictionary<string, T> data) {
            return TD_MiniJSON.Serialize(data, getTimeString);
        }

        public ThinkingAnalyticsWrapper(ThinkingAnalyticsAPI.Token token, bool initRequired = true)
        {
            this.token = token;
            if (initRequired) init();
        }

        public static void EnableLog(bool enableLog)
        {
            enable_log(enableLog);
        }

        public static void SetVersionInfo(string version)
        {
            setVersionInfo("Unity", version);
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

        public void EnableAutoTrack(AUTO_TRACK_EVENTS events)
        {
            enableAutoTrack(events);
        }

        private string getFinalEventProperties(Dictionary<string, object> properties)
        {
            TD_PropertiesChecker.CheckProperties(properties);

            if (null != dynamicSuperProperties)
            {
                Dictionary<string, object> finalProperties = new Dictionary<string, object>();
                TD_PropertiesChecker.MergeProperties(dynamicSuperProperties.GetDynamicSuperProperties(), finalProperties);
                TD_PropertiesChecker.MergeProperties(properties, finalProperties);
                return serilize(finalProperties);
            }
            else
            {
                return serilize(properties);
            }

        }
        public void Track(string eventName, Dictionary<string, object> properties)
        {
            TD_PropertiesChecker.CheckString(eventName);
            track(eventName, getFinalEventProperties(properties));
        }

        public void Track(string eventName, Dictionary<string, object> properties, DateTime datetime)
        {
            TD_PropertiesChecker.CheckString(eventName);
            track(eventName, getFinalEventProperties(properties), datetime);
        }

        public void Track(ThinkingAnalyticsEvent taEvent)
        {
            if (null == taEvent || null == taEvent.EventType)
            {
                TD_Log.w("Ignoring invalid TA event");
                return;
            }

            if (taEvent.EventTime == null)
            {
                TD_Log.w("ppp null...");
            }
            TD_PropertiesChecker.CheckString(taEvent.EventName);
            TD_PropertiesChecker.CheckProperties(taEvent.Properties);
            track(taEvent);
        }

        public void SetSuperProperties(Dictionary<string, object> superProperties)
        {
            TD_PropertiesChecker.CheckProperties(superProperties);
            setSuperProperties(serilize(superProperties));
        }

        public void UnsetSuperProperty(string superPropertyName)
        {
            TD_PropertiesChecker.CheckString(superPropertyName);
            unsetSuperProperty(superPropertyName);
        }

        public void ClearSuperProperty()
        {
            clearSuperProperty();
        }


        public void TimeEvent(string eventName)
        {
            TD_PropertiesChecker.CheckString(eventName);
            timeEvent(eventName);
        }

        public Dictionary<string, object> GetSuperProperties()
        {
            return getSuperProperties();
        }

        public void UserSet(Dictionary<string, object> properties)
        {
            TD_PropertiesChecker.CheckProperties(properties);
            userSet(serilize(properties));
        }

        public void UserSet(Dictionary<string, object> properties, DateTime dateTime)
        {
            TD_PropertiesChecker.CheckProperties(properties);
            userSet(serilize(properties), dateTime);
        }

        public void UserSetOnce(Dictionary<string, object> properties)
        {
            TD_PropertiesChecker.CheckProperties(properties);
            userSetOnce(serilize(properties));
        }

        public void UserSetOnce(Dictionary<string, object> properties, DateTime dateTime)
        {
            TD_PropertiesChecker.CheckProperties(properties);
            userSetOnce(serilize(properties), dateTime);
        }

        public void UserUnset(List<string> properties)
        {
            TD_PropertiesChecker.CheckProperteis(properties);
            userUnset(properties);
        }

        public void UserUnset(List<string> properties, DateTime dateTime)
        {
            TD_PropertiesChecker.CheckProperteis(properties);
            userUnset(properties, dateTime);
        }

        public void UserAdd(Dictionary<string, object> properties)
        {
            TD_PropertiesChecker.CheckProperties(properties);
            userAdd(serilize(properties));
        }

        public void UserAdd(Dictionary<string, object> properties, DateTime dateTime)
        {
            TD_PropertiesChecker.CheckProperties(properties);
            userAdd(serilize(properties), dateTime);
        }

        public void UserAppend(Dictionary<string, object> properties)
        {
            TD_PropertiesChecker.CheckProperties(properties);
            userAppend(serilize(properties));
        }

        public void UserAppend(Dictionary<string, object> properties, DateTime dateTime)
        {
            TD_PropertiesChecker.CheckProperties(properties);
            userAppend(serilize(properties), dateTime);
        }

        public void UserDelete()
        {
            userDelete();
        }

        public void UserDelete(DateTime dateTime)
        {
            userDelete(dateTime);
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
            if (!TD_PropertiesChecker.CheckProperties(dynamicSuperProperties.GetDynamicSuperProperties()))
            {
                TD_Log.d("TA.Wrapper(" + token.appid + ") - Cannot set dynamic super properties due to invalid properties.");
            }
            this.dynamicSuperProperties = dynamicSuperProperties;
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
            return createLightInstance(new ThinkingAnalyticsAPI.Token(rnd.Next().ToString(), token.serverUrl, token.mode, token.timeZone, token.timeZoneId));
        }

        internal string GetAppId()
        {
            return token.appid;
        }

        public static void CalibrateTime(long timestamp)
        {
            calibrateTime(timestamp);
        }

        public static void CalibrateTimeWithNtp(string ntpServer)
        {
            calibrateTimeWithNtp(ntpServer);
        }
    }
}

