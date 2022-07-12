using System;
using System.Collections.Generic;
using ThinkingAnalytics.Utils;
using UnityEngine;

namespace ThinkingAnalytics.Wrapper
{
    public partial class ThinkingAnalyticsWrapper
    {
        public MonoBehaviour taMono;
        public readonly ThinkingAnalyticsAPI.Token token;
        private IDynamicSuperProperties dynamicSuperProperties;
        private IAutoTrackEventCallback autoTrackEventCallback;

        private static System.Random rnd = new System.Random();

        private string serilize<T>(Dictionary<string, T> data) {
            return TD_MiniJSON.Serialize(data, getTimeString);
        }

        public ThinkingAnalyticsWrapper(ThinkingAnalyticsAPI.Token token, MonoBehaviour mono, bool initRequired = true)
        {
            this.taMono = mono;
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

        public void EnableAutoTrack(AUTO_TRACK_EVENTS events, Dictionary<string, object> properties)
        {
            enableAutoTrack(events, serilize(properties));
        }

        public void EnableAutoTrack(AUTO_TRACK_EVENTS events, IAutoTrackEventCallback eventCallback)
        {
            this.autoTrackEventCallback = eventCallback;
            enableAutoTrack(events, eventCallback);
        }

        public void SetAutoTrackProperties(AUTO_TRACK_EVENTS events, Dictionary<string, object> properties)
        {
            setAutoTrackProperties(events, serilize(properties));
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

        public Dictionary<string, object> GetPresetProperties()
        {
            return getPresetProperties();
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
            TD_PropertiesChecker.CheckProperties(properties);
            userUnset(properties);
        }

        public void UserUnset(List<string> properties, DateTime dateTime)
        {
            TD_PropertiesChecker.CheckProperties(properties);
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

        public void UserUniqAppend(Dictionary<string, object> properties) 
        {
            TD_PropertiesChecker.CheckProperties(properties);
            userUniqAppend(serilize(properties));
        }

        public void UserUniqAppend(Dictionary<string, object> properties, DateTime dateTime) 
        {
            TD_PropertiesChecker.CheckProperties(properties);
            userUniqAppend(serilize(properties), dateTime);
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
            setDynamicSuperProperties(dynamicSuperProperties);
        }

        public void SetTrackStatus(TA_TRACK_STATUS status)
        {
            setTrackStatus(status);
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

        public void EnableThirdPartySharing(TAThirdPartyShareType shareType)
        {
            enableThirdPartySharing(shareType);
        }
    }
}

