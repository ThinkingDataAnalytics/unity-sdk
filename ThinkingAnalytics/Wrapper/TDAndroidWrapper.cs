#if UNITY_ANDROID && !(UNITY_EDITOR) && !TE_DISABLE_ANDROID_JAVA
using System;
using System.Collections.Generic;
using ThinkingData.Analytics.Utils;
using UnityEngine;

namespace ThinkingData.Analytics.Wrapper
{
    public partial class TDWrapper
    {
        private static readonly AndroidJavaClass sdkClass = new AndroidJavaClass("cn.thinkingdata.analytics.ThinkingAnalyticsProxy");

        private static TimeZoneInfo defaultTimeZone = null;
        private static TDTimeZone defaultTDTimeZone = TDTimeZone.Local;

        private static string getJsonStr(Dictionary<string, object> data) {
            if (data == null)
            {
                return "";
            }

            return serilize(data);
        }

        private static string getTimeString(DateTime dateTime) {
            if (defaultTimeZone == null)
            {
                return TDCommonUtils.FormatDate(dateTime, defaultTDTimeZone);
            }
            else {
                return TDCommonUtils.FormatDate(dateTime, defaultTimeZone);
            }
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
            string timeZoneId = token.getTimeZoneId();
            defaultTDTimeZone = token.timeZone;
            if (null != timeZoneId && timeZoneId.Length > 0)
            {
                if (defaultTimeZone == null)
                {
                    try
                    {
                        defaultTimeZone = TimeZoneInfo.FindSystemTimeZoneById(timeZoneId);
                    }
                    catch (Exception)
                    {
                    }
                }
            }
            else {
                if (defaultTimeZone == null) {
                    defaultTimeZone = TimeZoneInfo.Local;
                }
            }
            sdkClass.CallStatic("init",context,token.appId,token.serverUrl, (int)token.mode,token.name, timeZoneId, token.encryptVersion,token.encryptPublicKey);
        }

        private static void flush(string appId)
        {
            sdkClass.CallStatic("flush", appId);
        }

        private static long getDateTimeStamp(DateTime dateTime)
        {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;

            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            return currentMillis;
        }

        private static void track(string eventName, Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
            try
            {
                sdkClass.CallStatic("track", eventName, getJsonStr(properties), getDateTimeStamp(dateTime), "Local", appId);
            }
            catch (Exception e)
            {
                if (TDLog.GetEnable()) TDLog.w("ThinkingAnalytics: unexpected exception: " + e);
            }
        }

        private static void track(string eventName, Dictionary<string, object> properties, DateTime dateTime, TimeZoneInfo timeZone, string appId)
        {
            try
            {
                if (timeZone == null)
                {
                    sdkClass.CallStatic("track", eventName, getJsonStr(properties), getDateTimeStamp(dateTime), "", appId);
                }
                else {
                    sdkClass.CallStatic("track", eventName, getJsonStr(properties), getDateTimeStamp(dateTime), timeZone.Id, appId);
                }
            }
            catch (Exception e)
            {
                if (TDLog.GetEnable()) TDLog.w("ThinkingAnalytics: unexpected exception: " + e);
            }    
        }

        private static void trackForAll(string eventName, Dictionary<string, object> properties)
        {
            string appId = "";
            track(eventName, properties, appId);
        }

        private static void track(TDEventModel taEvent, string appId)
        {
            int eventType = -1;
            if (taEvent.EventType == TDEventModel.TDEventType.First)
            {
                eventType = 0;
            }
            else if (taEvent.EventType == TDEventModel.TDEventType.Updatable)
            {
                eventType = 1;
            }
            else if (taEvent.EventType == TDEventModel.TDEventType.Overwritable)
            {
                eventType = 2;
            }
            if (eventType < 0) return;
            string jsonStr;
            if (taEvent.Properties == null)
            {
                jsonStr = taEvent.StrProperties;
            }
            else {
                jsonStr = getJsonStr(getFinalEventProperties(taEvent.Properties));
            }
            if (taEvent.GetEventTimeZone() == null)
            {
                sdkClass.CallStatic("trackEvent", eventType, taEvent.EventName, jsonStr, taEvent.GetEventId(), getDateTimeStamp(taEvent.GetEventTime()), "", appId);
            }
            else
            {
                sdkClass.CallStatic("trackEvent", eventType, taEvent.EventName, jsonStr, taEvent.GetEventId(), getDateTimeStamp(taEvent.GetEventTime()), taEvent.GetEventTimeZone().Id, appId);
            }
        }

        private static void track(string eventName, Dictionary<string, object> properties, string appId)
        {
            try
            {
                sdkClass.CallStatic("track", eventName, getJsonStr(properties), 0L, "", appId);
            }
            catch (Exception e)
            {
                if (TDLog.GetEnable()) TDLog.w("ThinkingAnalytics: unexpected exception: " + e);
            }
        }

        private static void trackStr(string eventName, string properties, string appId)
        {
            try
            {
                sdkClass.CallStatic("track", eventName, properties, 0L, "", appId);
            }
            catch (Exception e)
            {
                if (TDLog.GetEnable()) TDLog.w("ThinkingAnalytics: unexpected exception: " + e);
            }
        }

        private static void setSuperProperties(Dictionary<string, object> superProperties, string appId)
        {
            try
            {
                sdkClass.CallStatic("setSuperProperties", getJsonStr(superProperties), appId);
            }
            catch (Exception e)
            {
                if (TDLog.GetEnable()) TDLog.w("ThinkingAnalytics: unexpected exception: " + e);
            }
        }

        private static void setSuperProperties(string superProperties, string appId)
        {
            try
            {
                sdkClass.CallStatic("setSuperProperties", superProperties, appId);
            }
            catch (Exception e)
            {
                if (TDLog.GetEnable()) TDLog.w("ThinkingAnalytics: unexpected exception: " + e);
            }
        }

        private static void unsetSuperProperty(string superPropertyName, string appId)
        {
            sdkClass.CallStatic("unsetSuperProperty", superPropertyName, appId);
        }

        private static void clearSuperProperty(string appId)
        {
            sdkClass.CallStatic("clearSuperProperties", appId);
        }

        private static Dictionary<string, object> getSuperProperties(string appId)
        {
            Dictionary<string, object> result = null;
            try
            {
                result = TDMiniJson.Deserialize(sdkClass.CallStatic<string>("getSuperProperties", appId));
            }
            catch (Exception e)
            {
                if (TDLog.GetEnable()) TDLog.w("ThinkingAnalytics: unexpected exception: " + e);
            }
            return result;
        }

        private static Dictionary<string, object> getPresetProperties(string appId)
        {
            Dictionary<string, object> result = null;
            try
            {
                 result = TDMiniJson.Deserialize(sdkClass.CallStatic<string>("getPresetProperties",appId));
            }
            catch (Exception e)
            {
                if (TDLog.GetEnable()) TDLog.w("ThinkingAnalytics: unexpected exception: " + e);
            }
            return result;
        }

        private static void timeEvent(string eventName, string appId)
        {
            sdkClass.CallStatic("timeEvent", eventName, appId);
        }

        private static void timeEventForAll(string eventName)
        {
            sdkClass.CallStatic("timeEvent", eventName, "");
        }

        private static void identify(string uniqueId, string appId)
        {
            sdkClass.CallStatic("identify", uniqueId, appId);
        }

        private static string getDistinctId(string appId)
        {
            return sdkClass.CallStatic<string>("getDistinctId", appId);
        }

        private static void login(string uniqueId, string appId)
        {
            sdkClass.CallStatic("login", uniqueId, appId);
        }

        private static void userSetOnce(Dictionary<string, object> properties, string appId)
        {
            try
            {
                sdkClass.CallStatic("userSetOnce", getJsonStr(properties), 0L,appId);
            }
            catch (Exception e)
            {
                if (TDLog.GetEnable()) TDLog.w("ThinkingAnalytics: unexpected exception: " + e);
            }
        }

        private static void userSetOnce(string properties, string appId)
        {
            try
            {
                sdkClass.CallStatic("userSetOnce", properties, 0L, appId);
            }
            catch (Exception e)
            {
                if (TDLog.GetEnable()) TDLog.w("ThinkingAnalytics: unexpected exception: " + e);
            }
        }

        private static void userSetOnce(Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
            try
            {
                sdkClass.CallStatic("userSetOnce", getJsonStr(properties), getDateTimeStamp(dateTime), appId);
            }
            catch (Exception e)
            {
                if (TDLog.GetEnable()) TDLog.w("ThinkingAnalytics: unexpected exception: " + e);
            }
        }

        private static void userSet(Dictionary<string, object> properties, string appId)
        {
            try
            {
                sdkClass.CallStatic("userSet", getJsonStr(properties), 0L, appId);
            }
            catch (Exception e)
            {
                if (TDLog.GetEnable()) TDLog.w("ThinkingAnalytics: unexpected exception: " + e);
            }
        }

        private static void userSet(Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
            try
            {
                sdkClass.CallStatic("userSet", getJsonStr(properties), getDateTimeStamp(dateTime), appId);
            }
            catch (Exception e)
            {
                if (TDLog.GetEnable()) TDLog.w("ThinkingAnalytics: unexpected exception: " + e);
            }
        }

        private static void userSet(string properties, string appId)
        {
            try
            {
                sdkClass.CallStatic("userSet", properties, 0L, appId);
            }
            catch (Exception e)
            {
                if (TDLog.GetEnable()) TDLog.w("ThinkingAnalytics: unexpected exception: " + e);
            }
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
            try
            {
                sdkClass.CallStatic("userUnset", getJsonStr(finalProperties), getDateTimeStamp(dateTime), appId);
            }
            catch (Exception e)
            {
                if (TDLog.GetEnable()) TDLog.w("ThinkingAnalytics: unexpected exception: " + e);
            }
        }

        private static void userAdd(Dictionary<string, object> properties, string appId)
        {
            try
            {
                sdkClass.CallStatic("userAdd", getJsonStr(properties), 0L, appId);
            }
            catch (Exception e)
            {
                if (TDLog.GetEnable()) TDLog.w("ThinkingAnalytics: unexpected exception: " + e);
            }
        }

        private static void userAddStr(string properties, string appId)
        {
            try
            {
                sdkClass.CallStatic("userAdd", properties, 0L, appId);
            }
            catch (Exception e)
            {
                if (TDLog.GetEnable()) TDLog.w("ThinkingAnalytics: unexpected exception: " + e);
            }
        }

        private static void userAdd(Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
            try
            {
                sdkClass.CallStatic("userAdd", getJsonStr(properties), getDateTimeStamp(dateTime), appId);
            }
            catch (Exception e)
            {
                if (TDLog.GetEnable()) TDLog.w("ThinkingAnalytics: unexpected exception: " + e);
            }
        }

        private static void userAppend(Dictionary<string, object> properties, string appId)
        {
            try
            {
                sdkClass.CallStatic("userAppend", getJsonStr(properties), 0L, appId);
            }
            catch (Exception e)
            {
                if (TDLog.GetEnable()) TDLog.w("ThinkingAnalytics: unexpected exception: " + e);
            }
        }

        private static void userAppend(string properties, string appId)
        {
            try
            {
                sdkClass.CallStatic("userAppend", properties, 0L, appId);
            }
            catch (Exception e)
            {
                if (TDLog.GetEnable()) TDLog.w("ThinkingAnalytics: unexpected exception: " + e);
            }
        }

        private static void userAppend(Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
            try
            {
                sdkClass.CallStatic("userAppend", getJsonStr(properties), getDateTimeStamp(dateTime), appId);
            }
            catch (Exception e)
            {
                if (TDLog.GetEnable()) TDLog.w("ThinkingAnalytics: unexpected exception: " + e);
            }
        }

        private static void userUniqAppend(Dictionary<string, object> properties, string appId)
        {
            try
            {
                sdkClass.CallStatic("userUniqAppend", getJsonStr(properties), 0L, appId);
            }
            catch (Exception e)
            {
                if (TDLog.GetEnable()) TDLog.w("ThinkingAnalytics: unexpected exception: " + e);
            }
        }

        private static void userUniqAppend(string properties, string appId)
        {
            try
            {
                sdkClass.CallStatic("userUniqAppend", properties, 0L, appId);
            }
            catch (Exception e)
            {
                if (TDLog.GetEnable()) TDLog.w("ThinkingAnalytics: unexpected exception: " + e);
            }
        }

        private static void userUniqAppend(Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
            try
            {
                sdkClass.CallStatic("userUniqAppend", getJsonStr(properties), getDateTimeStamp(dateTime), appId);
            }
            catch (Exception e)
            {
                if (TDLog.GetEnable()) TDLog.w("ThinkingAnalytics: unexpected exception: " + e);
            }
        }

        private static void userDelete(string appId)
        {
            sdkClass.CallStatic("userDel", 0L, appId);
        }

        private static void userDelete(DateTime dateTime, string appId)
        {
            try
            {
                sdkClass.CallStatic("userDel", getDateTimeStamp(dateTime), appId);
            }
            catch (Exception e)
            {
                if (TDLog.GetEnable()) TDLog.w("ThinkingAnalytics: unexpected exception: " + e);
            }
        }

        private static void logout(string appId)
        {
            sdkClass.CallStatic("logout", appId);
        }

        private static string getDeviceId()
        {
            return sdkClass.CallStatic<string>("getDeviceId");
        }

        private static void setDynamicSuperProperties(TDDynamicSuperPropertiesHandler dynamicSuperProperties, string appId)
        {
            DynamicListenerAdapter listenerAdapter = new DynamicListenerAdapter();
            sdkClass.CallStatic("setDynamicSuperPropertiesTrackerListener", appId, listenerAdapter);
        }

        private static void setNetworkType(TDNetworkType networkType) {
            int type;
            switch (networkType)
            {
                case TDNetworkType.Wifi:
                    type = 1;
                    break;
                case TDNetworkType.All:
                    type = 0;
                    break;
                default:
                    type = 0;
                    break;

            }
            sdkClass.CallStatic("setNetworkType", type,"");
        }

        private static void enableAutoTrack(TDAutoTrackEventType events, Dictionary<string, object> properties, string appId)
        {
            sdkClass.CallStatic("enableAutoTrack", (int)events, TDMiniJson.Serialize(properties), appId);
        }

        private static void enableAutoTrack(TDAutoTrackEventType events, TDAutoTrackEventHandler eventCallback, string appId)
        {
            AutoTrackListenerAdapter listenerAdapter = new AutoTrackListenerAdapter();
            sdkClass.CallStatic("enableAutoTrack", (int)events, listenerAdapter, appId);
        }

        private static void setAutoTrackProperties(TDAutoTrackEventType events, Dictionary<string, object> properties, string appId)
        {
            sdkClass.CallStatic("setAutoTrackProperties", (int)events, TDMiniJson.Serialize(properties), appId);
        }

        private static void setTrackStatus(TDTrackStatus status, string appId)
        {
            int type;
            switch (status)
            {
                case TDTrackStatus.Pause:
                    type = 1;
                    break;
                case TDTrackStatus.Stop:
                    type = 2;
                    break;
                case TDTrackStatus.SaveOnly:
                    type = 3;
                    break;
                case TDTrackStatus.Normal:
                default:
                    type = 0;
                    break;
            }
            sdkClass.CallStatic("setTrackStatus", type, appId);
        }

        private static void optOutTracking(string appId)
        {
        }

        private static void optOutTrackingAndDeleteUser(string appId)
        {
        }

        private static void optInTracking(string appId)
        {
        }

        private static void enableTracking(bool enabled, string appId)
        {
        }

        private static string createLightInstance()
        {
            return sdkClass.CallStatic<string>("createLightInstance","");
        }

        private static void calibrateTime(long timestamp)
        {
            sdkClass.CallStatic("calibrateTime", timestamp);
        }

        private static void calibrateTimeWithNtp(string ntpServer)
        {
            sdkClass.CallStatic("calibrateTimeWithNtp", ntpServer);
        }

        private static void enableThirdPartySharing(TDThirdPartyType shareType, Dictionary<string, object> properties, string appId)
        {
            sdkClass.CallStatic("enableThirdPartySharing", (int)shareType, TDMiniJson.Serialize(properties), appId);
        }

        //dynamic super properties
        public interface IDynamicSuperPropertiesTrackerListener
        {
            string getDynamicSuperPropertiesString();
        }

        private class DynamicListenerAdapter : AndroidJavaProxy {
            public DynamicListenerAdapter() : base("cn.thinkingdata.analytics.ThinkingAnalyticsProxy$DynamicSuperPropertiesTrackerListener") {}
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
            public AutoTrackListenerAdapter() : base("cn.thinkingdata.analytics.ThinkingAnalyticsProxy$AutoTrackEventTrackerListener") {}
            string eventCallback(int type, string appId, string properties)
            {
                Dictionary<string, object> ret;
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