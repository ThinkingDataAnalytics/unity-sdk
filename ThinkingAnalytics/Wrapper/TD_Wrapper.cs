using System;
using System.Collections.Generic;
using ThinkingAnalytics.Utils;
using UnityEngine;

namespace ThinkingAnalytics.Wrapper
{
    public partial class ThinkingAnalyticsWrapper
    {
        public static MonoBehaviour sMono;
        private static IDynamicSuperProperties mDynamicSuperProperties;
        private static IAutoTrackEventCallback mAutoTrackEventCallback;

        private static System.Random rnd = new System.Random();

        private static string serilize<T>(Dictionary<string, T> data) {
            return TD_MiniJSON.Serialize(data, getTimeString);
        }

        public static void ShareInstance(ThinkingAnalyticsAPI.Token token, MonoBehaviour mono, bool initRequired = true)
        {
            sMono = mono;
            if (initRequired) init(token);
        }

        public static void EnableLog(bool enable)
        {
            enableLog(enable);
        }

        public static void SetVersionInfo(string version)
        {
            setVersionInfo("Unity", version);
        }

        public static void Identify(string uniqueId, string appId)
        {
            identify(uniqueId, appId);
        }

        public static string GetDistinctId(string appId)
        {
            return getDistinctId(appId);
        }

        public static void Login(string accountId, string appId)
        {
            login(accountId, appId);
        }

        public static void Logout(string appId)
        {
            logout(appId);
        }

        public static void EnableAutoTrack(AUTO_TRACK_EVENTS events, Dictionary<string, object> properties, string appId)
        {
            enableAutoTrack(events, serilize(properties), appId);
        }

        public static void EnableAutoTrack(AUTO_TRACK_EVENTS events, IAutoTrackEventCallback eventCallback, string appId)
        {
            mAutoTrackEventCallback = eventCallback;
            enableAutoTrack(events, eventCallback, appId);
        }

        public static void SetAutoTrackProperties(AUTO_TRACK_EVENTS events, Dictionary<string, object> properties, string appId)
        {
            setAutoTrackProperties(events, serilize(properties), appId);
        }

        private static string getFinalEventProperties(Dictionary<string, object> properties)
        {
            TD_PropertiesChecker.CheckProperties(properties);

            if (null != mDynamicSuperProperties)
            {
                Dictionary<string, object> finalProperties = new Dictionary<string, object>();
                TD_PropertiesChecker.MergeProperties(mDynamicSuperProperties.GetDynamicSuperProperties(), finalProperties);
                TD_PropertiesChecker.MergeProperties(properties, finalProperties);
                return serilize(finalProperties);
            }
            else
            {
                return serilize(properties);
            }

        }
        public static void Track(string eventName, Dictionary<string, object> properties, string appId)
        {
            TD_PropertiesChecker.CheckString(eventName);
            track(eventName, getFinalEventProperties(properties), appId);
        }

        public static void Track(string eventName, Dictionary<string, object> properties, DateTime datetime, string appId)
        {
            TD_PropertiesChecker.CheckString(eventName);
            track(eventName, getFinalEventProperties(properties), datetime, appId);
        }

        public static void Track(string eventName, Dictionary<string, object> properties, DateTime datetime, TimeZoneInfo timeZone, string appId)
        {
            TD_PropertiesChecker.CheckString(eventName);
            track(eventName, getFinalEventProperties(properties), datetime, timeZone, appId);
        }

        public static void TrackForAll(string eventName, Dictionary<string, object> properties, DateTime datetime, TimeZoneInfo timeZone)
        {
            TD_PropertiesChecker.CheckString(eventName);
            trackForAll(eventName, getFinalEventProperties(properties), datetime, timeZone);
        }

        public static void Track(ThinkingAnalyticsEvent taEvent, string appId)
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
            track(taEvent, appId);
        }

        public static void SetSuperProperties(Dictionary<string, object> superProperties, string appId)
        {
            TD_PropertiesChecker.CheckProperties(superProperties);
            setSuperProperties(serilize(superProperties), appId);
        }

        public static void UnsetSuperProperty(string superPropertyName, string appId)
        {
            TD_PropertiesChecker.CheckString(superPropertyName);
            unsetSuperProperty(superPropertyName, appId);
        }

        public static void ClearSuperProperty(string appId)
        {
            clearSuperProperty(appId);
        }


        public static void TimeEvent(string eventName, string appId)
        {
            TD_PropertiesChecker.CheckString(eventName);
            timeEvent(eventName, appId);
        }

        public static void TimeEventForAll(string eventName)
        {
            TD_PropertiesChecker.CheckString(eventName);
            timeEventForAll(eventName);
        }

        public static Dictionary<string, object> GetSuperProperties(string appId)
        {
            return getSuperProperties(appId);
        }

        public static Dictionary<string, object> GetPresetProperties(string appId)
        {
            return getPresetProperties(appId);
        }

        public static void UserSet(Dictionary<string, object> properties, string appId)
        {
            TD_PropertiesChecker.CheckProperties(properties);
            userSet(serilize(properties), appId);
        }

        public static void UserSet(Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
            TD_PropertiesChecker.CheckProperties(properties);
            userSet(serilize(properties), dateTime, appId);
        }

        public static void UserSetOnce(Dictionary<string, object> properties, string appId)
        {
            TD_PropertiesChecker.CheckProperties(properties);
            userSetOnce(serilize(properties), appId);
        }

        public static void UserSetOnce(Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
            TD_PropertiesChecker.CheckProperties(properties);
            userSetOnce(serilize(properties), dateTime, appId);
        }

        public static void UserUnset(List<string> properties, string appId)
        {
            TD_PropertiesChecker.CheckProperties(properties);
            userUnset(properties, appId);
        }

        public static void UserUnset(List<string> properties, DateTime dateTime, string appId)
        {
            TD_PropertiesChecker.CheckProperties(properties);
            userUnset(properties, dateTime, appId);
        }

        public static void UserAdd(Dictionary<string, object> properties, string appId)
        {
            TD_PropertiesChecker.CheckProperties(properties);
            userAdd(serilize(properties), appId);
        }

        public static void UserAdd(Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
            TD_PropertiesChecker.CheckProperties(properties);
            userAdd(serilize(properties), dateTime, appId);
        }

        public static void UserAppend(Dictionary<string, object> properties, string appId)
        {
            TD_PropertiesChecker.CheckProperties(properties);
            userAppend(serilize(properties), appId);
        }

        public static void UserAppend(Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
            TD_PropertiesChecker.CheckProperties(properties);
            userAppend(serilize(properties), dateTime, appId);
        }

        public static void UserUniqAppend(Dictionary<string, object> properties, string appId) 
        {
            TD_PropertiesChecker.CheckProperties(properties);
            userUniqAppend(serilize(properties), appId);
        }

        public static void UserUniqAppend(Dictionary<string, object> properties, DateTime dateTime, string appId) 
        {
            TD_PropertiesChecker.CheckProperties(properties);
            userUniqAppend(serilize(properties), dateTime, appId);
        }

        public static void UserDelete(string appId)
        {
            userDelete(appId);
        }

        public static void UserDelete(DateTime dateTime, string appId)
        {
            userDelete(dateTime, appId);
        }

        public static void Flush(string appId)
        {
            flush(appId);
        }

        public static void SetNetworkType(ThinkingAnalyticsAPI.NetworkType networkType)
        {
            setNetworkType(networkType);
        }

        public static string GetDeviceId()
        {
            return getDeviceId();
        }

        public static void SetDynamicSuperProperties(IDynamicSuperProperties dynamicSuperProperties, string appId)
        {
            if (!TD_PropertiesChecker.CheckProperties(dynamicSuperProperties.GetDynamicSuperProperties()))
            {
                TD_Log.d("TA.Wrapper(" + appId + ") - Cannot set dynamic super properties due to invalid properties.");
            }
            mDynamicSuperProperties = dynamicSuperProperties;
            setDynamicSuperProperties(dynamicSuperProperties, appId);
        }

        public static void SetTrackStatus(TA_TRACK_STATUS status, string appId)
        {
            setTrackStatus(status, appId);
        }

        public static void OptOutTracking(string appId)
        {
            optOutTracking(appId);
        }

        public static void OptOutTrackingAndDeleteUser(string appId)
        {
            optOutTrackingAndDeleteUser(appId);
        }

        public static void OptInTracking(string appId)
        {
            optInTracking(appId);
        }

        public static void EnableTracking(bool enabled, string appId)
        {
            enableTracking(enabled, appId);
        }

        public static string CreateLightInstance()
        {
            return createLightInstance();
        }

        public static void CalibrateTime(long timestamp)
        {
            calibrateTime(timestamp);
        }

        public static void CalibrateTimeWithNtp(string ntpServer)
        {
            calibrateTimeWithNtp(ntpServer);
        }

        public static void EnableThirdPartySharing(TAThirdPartyShareType shareType, Dictionary<string, object> properties = null, string appId = "")
        {
            if (null == properties) properties = new Dictionary<string, object>();
            enableThirdPartySharing(shareType, serilize(properties), appId);
        }
    }
}

