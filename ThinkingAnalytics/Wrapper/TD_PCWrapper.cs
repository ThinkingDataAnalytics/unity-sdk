#if ((!(UNITY_IOS) || UNITY_EDITOR) && (!(UNITY_ANDROID) || UNITY_EDITOR)) || TE_DISABLE_ANDROID_JAVA || TE_DISABLE_IOS_OC
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
                catch (Exception)
                {
                    //if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("TimeZoneInfo set failed : " + e.Message);
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

        private static void track(string eventName, Dictionary<string,object> properties, string appId)
        {  
            ThinkingPCSDK.Track(eventName,properties,appId);
        }

        private static void track(string eventName, Dictionary<string,object> properties, DateTime dateTime, string appId)
        {
            ThinkingPCSDK.Track(eventName,properties,dateTime,appId);
        }

        private static void track(string eventName, Dictionary<string,object> properties, DateTime dateTime, TimeZoneInfo timeZone, string appId)
        {
            ThinkingPCSDK.Track(eventName, properties, dateTime, timeZone, appId);
        }

        private static void trackForAll(string eventName, Dictionary<string,object> properties)
        {
            ThinkingPCSDK.TrackForAll(eventName, properties);
        }

        private static void setSuperProperties(Dictionary<string, object> superProperties, string appId)
        {
            ThinkingPCSDK.SetSuperProperties(superProperties, appId);
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

        private static void userSet(Dictionary<string,object> properties, string appId)
        {
            ThinkingPCSDK.UserSet(properties,appId);
        }

        private static void userSet(Dictionary<string,object> properties, DateTime dateTime, string appId)
        {
            ThinkingPCSDK.UserSet(properties,dateTime,appId);
        }

        private static void userUnset(List<string> properties, string appId)
        {
            ThinkingPCSDK.UserUnset(properties,appId);
        }

        private static void userUnset(List<string> properties, DateTime dateTime, string appId)
        {
            ThinkingPCSDK.UserUnset(properties,dateTime,appId);
        }

        private static void userSetOnce(Dictionary<string,object> properties, string appId)
        {
            ThinkingPCSDK.UserSetOnce(properties, appId);
        }

        private static void userSetOnce(Dictionary<string,object> properties, DateTime dateTime, string appId)
        {
            ThinkingPCSDK.UserSetOnce(properties,dateTime,appId);
        }

        private static void userAdd(Dictionary<string,object> properties, string appId)
        {
            ThinkingPCSDK.UserAdd(properties,appId);
        }

        private static void userAdd(Dictionary<string,object> properties, DateTime dateTime, string appId)
        {
            ThinkingPCSDK.UserAdd(properties,dateTime,appId);
        }

        private static void userDelete(string appId)
        {
            ThinkingPCSDK.UserDelete(appId);
        }

        private static void userDelete(DateTime dateTime, string appId)
        {
            ThinkingPCSDK.UserDelete(dateTime,appId);
        }

        private static void userAppend(Dictionary<string,object> properties, string appId)
        {
            ThinkingPCSDK.UserAppend(properties,appId);
        }

        private static void userAppend(Dictionary<string,object> properties, DateTime dateTime, string appId)
        {
            ThinkingPCSDK.UserAppend(properties,dateTime,appId);
        }

        private static void userUniqAppend(Dictionary<string,object> properties, string appId)
        {
            ThinkingPCSDK.UserUniqAppend(properties,appId);
        }

        private static void userUniqAppend(Dictionary<string,object> properties, DateTime dateTime, string appId)
        {
            ThinkingPCSDK.UserUniqAppend(properties,dateTime,appId);
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

        private static void enableAutoTrack(AUTO_TRACK_EVENTS autoTrackEvents, Dictionary<string,object> properties, string appId)
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
            if ((autoTrackEvents & AUTO_TRACK_EVENTS.APP_SCENE_LOAD) != 0)
            {
                pcAutoTrackEvents = pcAutoTrackEvents | ThinkingSDK.PC.Main.AUTO_TRACK_EVENTS.APP_SCENE_LOAD;
            }
            if ((autoTrackEvents & AUTO_TRACK_EVENTS.APP_SCENE_UNLOAD) != 0)
            {
                pcAutoTrackEvents = pcAutoTrackEvents | ThinkingSDK.PC.Main.AUTO_TRACK_EVENTS.APP_SCENE_UNLOAD;
            }
            ThinkingPCSDK.EnableAutoTrack(pcAutoTrackEvents, properties, appId);
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
            if ((autoTrackEvents & AUTO_TRACK_EVENTS.APP_SCENE_LOAD) != 0)
            {
                pcAutoTrackEvents = pcAutoTrackEvents | ThinkingSDK.PC.Main.AUTO_TRACK_EVENTS.APP_SCENE_LOAD;
            }
            if ((autoTrackEvents & AUTO_TRACK_EVENTS.APP_SCENE_UNLOAD) != 0)
            {
                pcAutoTrackEvents = pcAutoTrackEvents | ThinkingSDK.PC.Main.AUTO_TRACK_EVENTS.APP_SCENE_UNLOAD;
            }
            mEventCallback = eventCallback;
            ThinkingPCSDK.EnableAutoTrack(pcAutoTrackEvents, new ThinkingAnalyticsWrapper(), appId);
        }

        private static void setAutoTrackProperties(AUTO_TRACK_EVENTS autoTrackEvents, Dictionary<string,object> properties, string appId)
        {
            if ((autoTrackEvents & AUTO_TRACK_EVENTS.APP_INSTALL) != 0)
            {
                ThinkingPCSDK.SetAutoTrackProperties(ThinkingSDK.PC.Main.AUTO_TRACK_EVENTS.APP_INSTALL, properties, appId);
            }
            if ((autoTrackEvents & AUTO_TRACK_EVENTS.APP_START) != 0)
            {
                ThinkingPCSDK.SetAutoTrackProperties(ThinkingSDK.PC.Main.AUTO_TRACK_EVENTS.APP_START, properties, appId);
            }
            if ((autoTrackEvents & AUTO_TRACK_EVENTS.APP_END) != 0)
            {
                ThinkingPCSDK.SetAutoTrackProperties(ThinkingSDK.PC.Main.AUTO_TRACK_EVENTS.APP_END, properties, appId);
            }
            if ((autoTrackEvents & AUTO_TRACK_EVENTS.APP_CRASH) != 0)
            {
                ThinkingPCSDK.SetAutoTrackProperties(ThinkingSDK.PC.Main.AUTO_TRACK_EVENTS.APP_CRASH, properties, appId);
            }
            if ((autoTrackEvents & AUTO_TRACK_EVENTS.APP_SCENE_LOAD) != 0)
            {
                ThinkingPCSDK.SetAutoTrackProperties(ThinkingSDK.PC.Main.AUTO_TRACK_EVENTS.APP_SCENE_LOAD, properties, appId);
            }
            if ((autoTrackEvents & AUTO_TRACK_EVENTS.APP_SCENE_UNLOAD) != 0)
            {
                ThinkingPCSDK.SetAutoTrackProperties(ThinkingSDK.PC.Main.AUTO_TRACK_EVENTS.APP_SCENE_UNLOAD, properties, appId);
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

        private static void enableThirdPartySharing(TAThirdPartyShareType shareType, Dictionary<string,object> properties, string appId)
        {
            if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("Third Party Sharing is not support on PC: " + shareType + ", " + properties + ", "+ appId);
        }
    }
}
#endif