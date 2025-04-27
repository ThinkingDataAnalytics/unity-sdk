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
            Dictionary<string, object> configDic = new Dictionary<string, object>();
            configDic["appId"] = token.appId;
            configDic["serverUrl"] = token.serverUrl;
            configDic["mode"] = (int)token.mode;
            string timeZoneId = token.getTimeZoneId();
            defaultTDTimeZone = token.timeZone;
            if (null != timeZoneId && timeZoneId.Length > 0)
            {
                configDic["timeZone"] = timeZoneId;
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
            if (token.enableEncrypt == true)
            {
                configDic["publicKey"] = token.encryptPublicKey;
                configDic["version"] = token.encryptVersion;
            }
            openHarmonyJsClass.CallStatic("init", TDMiniJson.Serialize(configDic));
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
            Dictionary<string, object> dic = new Dictionary<string, object>();
            dic["event_name"] = eventName;
            dic["event_properties"] = properties;
            dic["event_time"] = currentMillis;
            if (timeZone != null)
            {
                dic["event_timezone"] = timeZone.Id;
            }
            openHarmonyJsClass.CallStatic("track", serilize(dic), appId);
        }

        private static void track(string eventName, Dictionary<string, object> properties, string appId)
        {
            Dictionary<string, object> dic = new Dictionary<string, object>();
            dic["event_name"] = eventName;
            dic["event_properties"] = properties;
            dic["event_time"] = 0;
            openHarmonyJsClass.CallStatic("track", serilize(dic), appId);
        }

        private static void trackForAll(string eventName, Dictionary<string, object> properties)
        {
            track(eventName, properties, "");
        }

        private static void track(TDEventModel taEvent, string appId)
        {
            Dictionary<string, object> finalEvent = new Dictionary<string, object>();
            string extraId = taEvent.GetEventId();
            switch (taEvent.EventType)
            {
                case TDEventModel.TDEventType.First:
                    finalEvent["event_type"] = 1;
                    break;
                case TDEventModel.TDEventType.Updatable:
                    finalEvent["event_type"] = 2;
                    break;
                case TDEventModel.TDEventType.Overwritable:
                    finalEvent["event_type"] = 3;
                    break;
            }

            if (!string.IsNullOrEmpty(extraId))
            {
                finalEvent["event_id"] = extraId;
            }

            finalEvent["event_name"] = taEvent.EventName;
            finalEvent["event_properties"] = taEvent.Properties;
            if (taEvent.GetEventTime() != null && taEvent.GetEventTime() != DateTime.MinValue)
            {
                long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(taEvent.GetEventTime()).Ticks;
                DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
                long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
                finalEvent["event_time"] = currentMillis;
            }
            if (taEvent.GetEventTimeZone() != null)
            {
                finalEvent["event_timezone"] = taEvent.GetEventTimeZone().Id;
            }
            openHarmonyJsClass.CallStatic("trackEvent", serilize(finalEvent), appId);
        }

        private static void setSuperProperties(Dictionary<string, object> superProperties, string appId)
        {
            openHarmonyJsClass.CallStatic("setSuperProperties", serilize(superProperties), appId);
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
            openHarmonyJsClass.CallStatic("userSet", buildUserProperties(properties,dateTime), appId);
        }

        private static void userSetOnce(Dictionary<string, object> properties, string appId)
        {
            userSetOnce(properties, new DateTime(), appId);
        }

        private static void userSetOnce(Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
           
            openHarmonyJsClass.CallStatic("userSetOnce", buildUserProperties(properties,dateTime), appId);
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
            openHarmonyJsClass.CallStatic("userAdd", buildUserProperties(properties,dateTime), appId);
        }

        private static void userAppend(Dictionary<string, object> properties, string appId)
        {
            userAppend(properties, new DateTime(), appId);
        }

        private static void userAppend(Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
            openHarmonyJsClass.CallStatic("userAppend", buildUserProperties(properties, dateTime), appId);
        }

        private static void userUniqAppend(Dictionary<string, object> properties, string appId)
        {
            userUniqAppend(properties, new DateTime(), appId);
        }

        private static void userUniqAppend(Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
            openHarmonyJsClass.CallStatic("userUniqAppend", buildUserProperties(properties, dateTime), appId);
        }

        private static void userDelete(string appId)
        {
            userDelete(new DateTime(), appId);
        }

        private static void userDelete(DateTime dateTime, string appId)
        {
            openHarmonyJsClass.CallStatic("userDelete", buildUserProperties(null, dateTime),appId);
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


        private static string buildUserProperties(Dictionary<string, object> properties, DateTime dateTime) {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;
            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            Dictionary<string, object> dic = new Dictionary<string, object>();
            dic["user_properties"] = properties;
            dic["event_time"] = currentMillis;
            return serilize(dic);
        }


    }
}

#endif