#if UNITY_OPENHARMONY && !(UNITY_EDITOR)
using System;
using System.Collections.Generic;
using ThinkingAnalytics;
using ThinkingData.Analytics.Utils;
using UnityEngine;
namespace ThinkingData.Analytics.Wrapper
{
    public partial class TDWrapper
    {
        private static readonly OpenHarmonyJSClass openHarmonyJsClass = new OpenHarmonyJSClass("TDOpenHarmonyProxy");

        private static TimeZoneInfo defaultTimeZone = null;
        private static TDTimeZone defaultTDTimeZone = TDTimeZone.Local;

        private static void init(TDConfig token)
        {
            string timeZoneId = token.getTimeZoneId();
            defaultTDTimeZone = token.timeZone;
            string timeZone ="";
            if (null != timeZoneId && timeZoneId.Length > 0)
            {
                timeZone = timeZoneId;
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
            else
            {
                if (defaultTimeZone == null)
                {
                    defaultTimeZone = TimeZoneInfo.Local;
                }
            }
            openHarmonyJsClass.CallStatic("init", token.appId,token.serverUrl,(int)token.mode,timeZone,token.encryptVersion,token.encryptPublicKey);
        }

        private static string getTimeString(DateTime dateTime)
        {
            if (defaultTimeZone == null)
            {
                return TDCommonUtils.FormatDate(dateTime, defaultTDTimeZone);
            }
            else
            {
                return TDCommonUtils.FormatDate(dateTime, defaultTimeZone);
            }
        }
        private static void enableLog(bool enable) {
            openHarmonyJsClass.CallStatic("enableLog",enable);
        }
        private static void setVersionInfo(string libName, string version)
        {
            openHarmonyJsClass.CallStatic("setLibraryInfo", libName, version);
        }

        private static void identify(string uniqueId, string appId)
        {
            openHarmonyJsClass.CallStatic("setDistinctId", uniqueId, appId);
        }
        private static string getDistinctId(string appId)
        {
            return openHarmonyJsClass.CallStatic<string>("getDistinctId",appId);
        }

        private static void login(string uniqueId, string appId)
        {
            openHarmonyJsClass.CallStatic("login", uniqueId, appId);
        }
        private static void logout(string appId)
        {
            openHarmonyJsClass.CallStatic("logout", appId);
        }

        private static void enableAutoTrack(TDAutoTrackEventType events, Dictionary<string, object> properties, string appId)
        {
            openHarmonyJsClass.CallStatic("enableAutoTrack", (int)events, appId);
        }

        private static void enableAutoTrack(TDAutoTrackEventType events, TDAutoTrackEventHandler eventCallback, string appId)
        {
            
        }

        private static void setAutoTrackProperties(TDAutoTrackEventType events, Dictionary<string, object> properties, string appId)
        {
            
        }

        private static void track(string eventName, Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
            track(eventName, properties, dateTime, null, appId);
        }

        private static void track(string eventName, Dictionary<string, object> properties, DateTime dateTime, TimeZoneInfo timeZone, string appId)
        {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;
            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            string timeZoneId = "";
            if (timeZone != null)
            {
                timeZoneId = timeZone.Id;
            }
            openHarmonyJsClass.CallStatic("track", eventName,serilize(properties),currentMillis,timeZoneId, appId);
        }

        private static void track(string eventName, Dictionary<string, object> properties, string appId)
        {
            openHarmonyJsClass.CallStatic("track", eventName,serilize(properties), 0,"",appId);
        }

        private static void trackForAll(string eventName, Dictionary<string, object> properties)
        {
            track(eventName, properties, "");
        }

        private static void track(TDEventModel taEvent, string appId)
        {
            int eventType = -1;;
            switch (taEvent.EventType)
            {
                case TDEventModel.TDEventType.First:
                    eventType = 1;
                    break;
                case TDEventModel.TDEventType.Updatable:
                    eventType = 2;
                    break;
                case TDEventModel.TDEventType.Overwritable:
                    eventType = 3;
                    break;
            }
            if (eventType < 0) return;
            string jsonStr;
            if (taEvent.Properties == null)
            {
                jsonStr = taEvent.StrProperties;
            }
            else {
                jsonStr = serilize(taEvent.Properties);
            }
            long eventTime = 0;
            if (taEvent.GetEventTime() != null && taEvent.GetEventTime() != DateTime.MinValue)
            {
                long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(taEvent.GetEventTime()).Ticks;
                DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
                eventTime = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            }
            string timeZoneId = "";
            if (taEvent.GetEventTimeZone() != null)
            {
                timeZoneId = taEvent.GetEventTimeZone().Id;
            }
            openHarmonyJsClass.CallStatic("trackEvent", eventType,taEvent.EventName,jsonStr,taEvent.GetEventId(),eventTime,timeZoneId,appId);
        }

        private static void trackStr(string eventName, string properties, string appId)
        {
            openHarmonyJsClass.CallStatic("track", eventName,properties, 0,"",appId);
        }

        private static void setSuperProperties(Dictionary<string, object> superProperties, string appId)
        {
            openHarmonyJsClass.CallStatic("setSuperProperties", serilize(superProperties), appId);
        }

        private static void setSuperProperties(string superProperties, string appId)
        {
            openHarmonyJsClass.CallStatic("setSuperProperties", superProperties, appId);
        }

        private static void unsetSuperProperty(string superPropertyName, string appId)
        {
            openHarmonyJsClass.CallStatic("unsetSuperProperty", superPropertyName, appId);
        }

        private static void clearSuperProperty(string appId)
        {
            openHarmonyJsClass.CallStatic("clearSuperProperties", appId);
        }

        private static Dictionary<string, object> getSuperProperties(string appId)
        {
            string superPropertiesString = openHarmonyJsClass.CallStatic<string>("getSuperProperties", appId);
            return TDMiniJson.Deserialize(superPropertiesString);
        }

        private static Dictionary<string, object> getPresetProperties(string appId)
        {
            string presetPropertiesString = openHarmonyJsClass.CallStatic<string>("getPresetProperties",appId);
            return TDMiniJson.Deserialize(presetPropertiesString);
        }

        private static void timeEvent(string eventName, string appId)
        {
            openHarmonyJsClass.CallStatic("timeEvent", eventName, appId);
        }

        private static void timeEventForAll(string eventName)
        {
            openHarmonyJsClass.CallStatic("timeEvent", eventName, "");
        }

        private static void userSet(Dictionary<string, object> properties, string appId)
        {
            userSet(properties, new DateTime(), appId);
        }

        private static void userSet(Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;
            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            openHarmonyJsClass.CallStatic("userSet", serilize(properties),currentMillis,appId);
        }

        private static void userSet(string properties, string appId)
        {
            openHarmonyJsClass.CallStatic("userSet", properties,0,appId);
        }

        private static void userSetOnce(Dictionary<string, object> properties, string appId)
        {
            userSetOnce(properties, new DateTime(), appId);
        }

        private static void userSetOnce(Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
           long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;
            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            openHarmonyJsClass.CallStatic("userSetOnce", serilize(properties),currentMillis, appId);
        }

        private static void userSetOnce(string properties, string appId)
        {
            openHarmonyJsClass.CallStatic("userSetOnce", properties,0, appId);
        }

        private static void userUnset(List<string> properties, string appId)
        {
            userUnset(properties, new DateTime(), appId);
        }

        private static void userUnset(List<string> properties, DateTime dateTime, string appId)
        {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;
            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            foreach (string property in properties)
            {
                openHarmonyJsClass.CallStatic("userUnset", property, currentMillis, appId);
            }
        }

        private static void userAdd(Dictionary<string, object> properties, string appId)
        {
            userAdd(properties, new DateTime(), appId);
        }

        private static void userAdd(Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;
            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            openHarmonyJsClass.CallStatic("userAdd", serilize(properties),currentMillis, appId);
        }

        private static void userAddStr(string properties, string appId)
        {
            openHarmonyJsClass.CallStatic("userAdd", properties,0, appId);
        }

        private static void userAppend(Dictionary<string, object> properties, string appId)
        {
            userAppend(properties, new DateTime(), appId);
        }

        private static void userAppend(Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;
            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            openHarmonyJsClass.CallStatic("userAppend", serilize(properties),currentMillis, appId);
        }


        private static void userAppend(string properties, string appId)
        {
            openHarmonyJsClass.CallStatic("userAppend", properties,0, appId);
        }

        private static void userUniqAppend(Dictionary<string, object> properties, string appId)
        {
            userUniqAppend(properties, new DateTime(), appId);
        }

        private static void userUniqAppend(Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;
            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            openHarmonyJsClass.CallStatic("userUniqAppend", serilize(properties),currentMillis, appId);
        }

        private static void userUniqAppend(string properties, string appId)
        {
            openHarmonyJsClass.CallStatic("userUniqAppend",properties,0, appId);
        }

        private static void userDelete(string appId)
        {
            userDelete(new DateTime(), appId);
        }

        private static void userDelete(DateTime dateTime, string appId)
        {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;
            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            openHarmonyJsClass.CallStatic("userDelete", currentMillis,appId);
        }

        private static void flush(string appId)
        {
            openHarmonyJsClass.CallStatic("flush", appId);
        }

        private static string getDeviceId()
        {
            return openHarmonyJsClass.CallStatic<string>("getDeviceId");
        }

        private static void setNetworkType(TDNetworkType networkType)
        {
            openHarmonyJsClass.CallStatic("setNetWorkType", (int)networkType);
        }

        private static void setDynamicSuperProperties(TDDynamicSuperPropertiesHandler dynamicSuperProperties, string appId)
        {

        }

        private static void setTrackStatus(TDTrackStatus status, string appId)
        {

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
           
            return "";
        }

        private static void calibrateTime(long timestamp)
        {
            openHarmonyJsClass.CallStatic("calibrateTime", timestamp);
        }

        private static void calibrateTimeWithNtp(string ntpServer)
        {
            
        }

        private static void enableThirdPartySharing(TDThirdPartyType shareType, Dictionary<string, object> properties, string appId)
        {
            
        }

    }
}

#endif