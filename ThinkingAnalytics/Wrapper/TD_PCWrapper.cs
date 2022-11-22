#if  (!(UNITY_IOS) || UNITY_EDITOR) && (!(UNITY_ANDROID) || UNITY_EDITOR)
using System;
using System.Collections.Generic;
using ThinkingAnalytics.Utils;
using ThinkingSDK.PC.Main;
using ThinkingSDK.PC.Utils;
using ThinkingSDK.PC.DataModel;
using ThinkingSDK.PC.Config;

namespace ThinkingAnalytics.Wrapper
{
    public partial class ThinkingAnalyticsWrapper: IDynamicSuperProperties_PC, IAutoTrackEventCallback_PC
    {
        static IAutoTrackEventCallback mEventCallback;
        public Dictionary<string, object> GetDynamicSuperProperties_PC()
        {
            if (mDynamicSuperProperties != null)
            {
                return mDynamicSuperProperties.GetDynamicSuperProperties();
            }
            else
            {
                return new Dictionary<string, object>();
            }
        }

        public Dictionary<string, object> AutoTrackEventCallback_PC(int type, Dictionary<string, object>properties)
        {
            if (mEventCallback != null)
            {
                return mEventCallback.AutoTrackEventCallback(type, properties);
            }
            else
            {
                return new Dictionary<string, object>();
            }
        }

        private static void init(ThinkingAnalyticsAPI.Token token)
        {
            ThinkingSDKConfig config = ThinkingSDKConfig.GetInstance(token.appid, token.serverUrl, token.GetInstanceName());
            if (!string.IsNullOrEmpty(token.getTimeZoneId()))
            {
                try
                {
                    config.SetTimeZone(TimeZoneInfo.FindSystemTimeZoneById(token.getTimeZoneId()));
                }
                catch (Exception e)
                {
                    //ThinkingSDKLogger.Print("TimeZoneInfo set failed : " + e.Message);
                }
            }
            if (token.mode == ThinkingAnalyticsAPI.TAMode.DEBUG)
            {
                config.SetMode(Mode.DEBUG);
            }
            else if(token.mode == ThinkingAnalyticsAPI.TAMode.DEBUG_ONLY)
            {
                config.SetMode(Mode.DEBUG_ONLY);
            }
            ThinkingPCSDK.Init(token.appid, token.serverUrl, token.GetInstanceName(), config, sMono);
        }

        private static void identify(string uniqueId, string appId)
        {
            ThinkingPCSDK.Identifiy(uniqueId, appId);
        }

        private static string getDistinctId(string appId)
        {
            return ThinkingPCSDK.DistinctId(appId);
        }

        private static void login(string accountId, string appId)
        {
            ThinkingPCSDK.Login(accountId, appId);
        }

        private static void logout(string appId)
        {
            ThinkingPCSDK.Logout(appId);
        }

        private static void flush(string appId)
        {
           ThinkingPCSDK.Flush(appId);
        }

        private static void setVersionInfo(string lib_name, string lib_version) {
            ThinkingPCSDK.SetLibName(lib_name);
            ThinkingPCSDK.SetLibVersion(lib_version);
        }

        private static void track(ThinkingAnalyticsEvent taEvent, string appId)
        {
            ThinkingSDKEventData eventData = null ;
            switch (taEvent.EventType)
            {
                case ThinkingAnalyticsEvent.Type.FIRST:
                    {
                        eventData = new ThinkingSDKFirstEvent(taEvent.EventName);
                        if (!string.IsNullOrEmpty(taEvent.ExtraId))
                        {
                            ((ThinkingSDKFirstEvent)eventData).SetFirstCheckId(taEvent.ExtraId);
                        }
                    }
                    break;
                case ThinkingAnalyticsEvent.Type.UPDATABLE:
                    eventData = new ThinkingSDKUpdateEvent(taEvent.EventName,taEvent.ExtraId);
                    break;
                case ThinkingAnalyticsEvent.Type.OVERWRITABLE:
                    eventData = new ThinkingSDKOverWritableEvent(taEvent.EventName, taEvent.ExtraId);
                    break;
            }
            if (mDynamicSuperProperties != null)
            {
                eventData.SetProperties(mDynamicSuperProperties.GetDynamicSuperProperties());
            }
            if (taEvent.Properties != null)
            {
                eventData.SetProperties(taEvent.Properties);
            }
            if (taEvent.EventTime != null)
            {
                eventData.SetEventTime(taEvent.EventTime);
            }
            if (taEvent.EventTimeZone != null)
            {
                eventData.SetTimeZone(taEvent.EventTimeZone);
            }
            ThinkingPCSDK.Track(eventData, appId);
        }

        private static void track(string eventName, string properties, string appId)
        {  
            Dictionary<string,object> propertiesDic = TD_MiniJSON.Deserialize(properties);
            ThinkingPCSDK.Track(eventName,propertiesDic,appId);
        }

        private static void track(string eventName, string properties, DateTime dateTime, string appId)
        {
            Dictionary<string,object> propertiesDic = TD_MiniJSON.Deserialize(properties);
            ThinkingPCSDK.Track(eventName,propertiesDic,dateTime,appId);
        }

        private static void track(string eventName, string properties, DateTime dateTime, TimeZoneInfo timeZone, string appId)
        {
            Dictionary<string, object> propertiesDic = TD_MiniJSON.Deserialize(properties);
            ThinkingPCSDK.Track(eventName, propertiesDic, dateTime, timeZone, appId);
        }

        private static void trackForAll(string eventName, string properties, DateTime dateTime, TimeZoneInfo timeZone)
        {
            Dictionary<string, object> propertiesDic = TD_MiniJSON.Deserialize(properties);
            ThinkingPCSDK.TrackForAll(eventName, propertiesDic, dateTime, timeZone);
        }

        private static void setSuperProperties(string superProperties, string appId)
        {
            Dictionary<string, object> superPropertiesDic = TD_MiniJSON.Deserialize(superProperties);
            ThinkingPCSDK.SetSuperProperties(superPropertiesDic,appId);
        }

        private static void unsetSuperProperty(string superPropertyName, string appId)
        {
            ThinkingPCSDK.UnsetSuperProperty(superPropertyName,appId);
        }

        private static void clearSuperProperty(string appId)
        {
            ThinkingPCSDK.ClearSuperProperties(appId);
        }

        private static Dictionary<string, object> getSuperProperties(string appId)
        {
            return ThinkingPCSDK.SuperProperties(appId);
        }

        private static Dictionary<string, object> getPresetProperties(string appId)
        {
            return ThinkingPCSDK.PresetProperties(appId);
        }
        private static void timeEvent(string eventName, string appId)
        {
            ThinkingPCSDK.TimeEvent(eventName,appId);
        }
        private static void timeEventForAll(string eventName)
        {
            ThinkingPCSDK.TimeEventForAll(eventName);
        }

        private static void userSet(string properties, string appId)
        {
            Dictionary<string, object> propertiesDic = TD_MiniJSON.Deserialize(properties);
            ThinkingPCSDK.UserSet(propertiesDic,appId);
        }

        private static void userSet(string properties, DateTime dateTime, string appId)
        {
            Dictionary<string, object> propertiesDic = TD_MiniJSON.Deserialize(properties);
            ThinkingPCSDK.UserSet(propertiesDic,dateTime,appId);
        }

        private static void userUnset(List<string> properties, string appId)
        {
            ThinkingPCSDK.UserUnset(properties,appId);
        }

        private static void userUnset(List<string> properties, DateTime dateTime, string appId)
        {
            ThinkingPCSDK.UserUnset(properties,dateTime,appId);
        }

        private static void userSetOnce(string properties, string appId)
        {
            Dictionary<string, object> propertiesDic = TD_MiniJSON.Deserialize(properties);
            ThinkingPCSDK.UserSetOnce(propertiesDic, appId);
        }

        private static void userSetOnce(string properties, DateTime dateTime, string appId)
        {
            Dictionary<string, object> propertiesDic = TD_MiniJSON.Deserialize(properties);
            ThinkingPCSDK.UserSetOnce(propertiesDic,dateTime,appId);
        }

        private static void userAdd(string properties, string appId)
        {
            Dictionary<string, object> propertiesDic = TD_MiniJSON.Deserialize(properties);
            ThinkingPCSDK.UserAdd(propertiesDic,appId);
        }

        private static void userAdd(string properties, DateTime dateTime, string appId)
        {
            Dictionary<string, object> propertiesDic = TD_MiniJSON.Deserialize(properties);
            ThinkingPCSDK.UserAdd(propertiesDic,dateTime,appId);
        }

        private static void userDelete(string appId)
        {
            ThinkingPCSDK.UserDelete(appId);
        }

        private static void userDelete(DateTime dateTime, string appId)
        {
            ThinkingPCSDK.UserDelete(dateTime,appId);
        }

        private static void userAppend(string properties, string appId)
        {
            Dictionary<string, object> propertiesDic = TD_MiniJSON.Deserialize(properties);
            ThinkingPCSDK.UserAppend(propertiesDic,appId);
        }

        private static void userAppend(string properties, DateTime dateTime, string appId)
        {
            Dictionary<string, object> propertiesDic = TD_MiniJSON.Deserialize(properties);
            ThinkingPCSDK.UserAppend(propertiesDic,dateTime,appId);
        }

        private static void userUniqAppend(string properties, string appId)
        {
            Dictionary<string, object> propertiesDic = TD_MiniJSON.Deserialize(properties);
            ThinkingPCSDK.UserUniqAppend(propertiesDic,appId);
        }

        private static void userUniqAppend(string properties, DateTime dateTime, string appId)
        {
            Dictionary<string, object> propertiesDic = TD_MiniJSON.Deserialize(properties);
            ThinkingPCSDK.UserUniqAppend(propertiesDic,dateTime,appId);
        }

        private static void setNetworkType(ThinkingAnalyticsAPI.NetworkType networkType)
        {
            
        }

        private static string getDeviceId() 
        {
            return ThinkingPCSDK.GetDeviceId();
        }

        private static void setDynamicSuperProperties(IDynamicSuperProperties dynamicSuperProperties, string appId)
        {
            ThinkingPCSDK.SetDynamicSuperProperties(new ThinkingAnalyticsWrapper());
        }

        private static void setTrackStatus(TA_TRACK_STATUS status, string appId)
        {
            ThinkingPCSDK.SetTrackStatus((ThinkingSDK.PC.Main.TA_TRACK_STATUS)status, appId);
        }

        private static void optOutTracking(string appId)
        {
            ThinkingPCSDK.OptTracking(false, appId);
        }

        private static void optOutTrackingAndDeleteUser(string appId)
        {
            ThinkingPCSDK.OptTrackingAndDeleteUser(appId);
        }

        private static void optInTracking(string appId)
        {
            ThinkingPCSDK.OptTracking(true, appId);
        }

        private static void enableTracking(bool enabled, string appId)
        {
            ThinkingPCSDK.EnableTracking(enabled);
        }

        private static string createLightInstance()
        {
            return ThinkingPCSDK.CreateLightInstance();
        }

        private static string getTimeString(DateTime dateTime)
        {
       
            return ThinkingPCSDK.TimeString(dateTime);
        }

        private static void enableAutoTrack(AUTO_TRACK_EVENTS autoTrackEvents, string properties, string appId)
        {
            Dictionary<string, object> propertiesDic = TD_MiniJSON.Deserialize(properties);
            ThinkingSDK.PC.Main.AUTO_TRACK_EVENTS pcAutoTrackEvents = ThinkingSDK.PC.Main.AUTO_TRACK_EVENTS.NONE;
            if ((autoTrackEvents & AUTO_TRACK_EVENTS.APP_INSTALL) != 0)
            {
                pcAutoTrackEvents = pcAutoTrackEvents | ThinkingSDK.PC.Main.AUTO_TRACK_EVENTS.APP_INSTALL;
            }
            if ((autoTrackEvents & AUTO_TRACK_EVENTS.APP_START) != 0)
            {
                pcAutoTrackEvents = pcAutoTrackEvents | ThinkingSDK.PC.Main.AUTO_TRACK_EVENTS.APP_START;
            }
            if ((autoTrackEvents & AUTO_TRACK_EVENTS.APP_END) != 0)
            {
                pcAutoTrackEvents = pcAutoTrackEvents | ThinkingSDK.PC.Main.AUTO_TRACK_EVENTS.APP_END;
            }
            if ((autoTrackEvents & AUTO_TRACK_EVENTS.APP_CRASH) != 0)
            {
                pcAutoTrackEvents = pcAutoTrackEvents | ThinkingSDK.PC.Main.AUTO_TRACK_EVENTS.APP_CRASH;
            }
            ThinkingPCSDK.EnableAutoTrack(pcAutoTrackEvents, propertiesDic, appId);
        }

        private static void enableAutoTrack(AUTO_TRACK_EVENTS autoTrackEvents, IAutoTrackEventCallback eventCallback, string appId)
        {
            ThinkingSDK.PC.Main.AUTO_TRACK_EVENTS pcAutoTrackEvents = ThinkingSDK.PC.Main.AUTO_TRACK_EVENTS.NONE;
            if ((autoTrackEvents & AUTO_TRACK_EVENTS.APP_INSTALL) != 0)
            {
                pcAutoTrackEvents = pcAutoTrackEvents | ThinkingSDK.PC.Main.AUTO_TRACK_EVENTS.APP_INSTALL;
            }
            if ((autoTrackEvents & AUTO_TRACK_EVENTS.APP_START) != 0)
            {
                pcAutoTrackEvents = pcAutoTrackEvents | ThinkingSDK.PC.Main.AUTO_TRACK_EVENTS.APP_START;
            }
            if ((autoTrackEvents & AUTO_TRACK_EVENTS.APP_END) != 0)
            {
                pcAutoTrackEvents = pcAutoTrackEvents | ThinkingSDK.PC.Main.AUTO_TRACK_EVENTS.APP_END;
            }
            if ((autoTrackEvents & AUTO_TRACK_EVENTS.APP_CRASH) != 0)
            {
                pcAutoTrackEvents = pcAutoTrackEvents | ThinkingSDK.PC.Main.AUTO_TRACK_EVENTS.APP_CRASH;
            }
            mEventCallback = eventCallback;
            ThinkingPCSDK.EnableAutoTrack(pcAutoTrackEvents, new ThinkingAnalyticsWrapper());
        }

        private static void setAutoTrackProperties(AUTO_TRACK_EVENTS autoTrackEvents, string properties, string appId)
        {
            Dictionary<string, object> propertiesDic = TD_MiniJSON.Deserialize(properties);
            if ((autoTrackEvents & AUTO_TRACK_EVENTS.APP_INSTALL) != 0)
            {
                ThinkingPCSDK.SetAutoTrackProperties(ThinkingSDK.PC.Main.AUTO_TRACK_EVENTS.APP_INSTALL, propertiesDic, appId);
            }
            if ((autoTrackEvents & AUTO_TRACK_EVENTS.APP_START) != 0)
            {
                ThinkingPCSDK.SetAutoTrackProperties(ThinkingSDK.PC.Main.AUTO_TRACK_EVENTS.APP_START, propertiesDic, appId);
            }
            if ((autoTrackEvents & AUTO_TRACK_EVENTS.APP_END) != 0)
            {
                ThinkingPCSDK.SetAutoTrackProperties(ThinkingSDK.PC.Main.AUTO_TRACK_EVENTS.APP_END, propertiesDic, appId);
            }
            if ((autoTrackEvents & AUTO_TRACK_EVENTS.APP_CRASH) != 0)
            {
                ThinkingPCSDK.SetAutoTrackProperties(ThinkingSDK.PC.Main.AUTO_TRACK_EVENTS.APP_CRASH, propertiesDic, appId);
            }
        }

        private static void enableLog(bool enable)
        {
            ThinkingPCSDK.EnableLog(enable);
        }
        private static void calibrateTime(long timestamp)
        {
            ThinkingPCSDK.CalibrateTime(timestamp);
        }

        private static void calibrateTimeWithNtp(string ntpServer)
        {
            ThinkingPCSDK.CalibrateTimeWithNtp(ntpServer);
        }

        private static void enableThirdPartySharing(TAThirdPartyShareType shareType, string properties, string appId)
        {
            ThinkingSDKLogger.Print("Third Party Sharing is not support on PC: " + shareType + ", " + properties + ", "+ appId);
        }
    }
}
#endif