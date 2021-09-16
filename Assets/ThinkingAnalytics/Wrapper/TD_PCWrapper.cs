
using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using ThinkingAnalytics.Utils;
using UnityEngine;
using ThinkingSDK.PC.Main;
using ThinkingSDK.PC.Utils;
using ThinkingSDK.PC.DataModel;
using ThinkingSDK.PC.Config;

namespace ThinkingAnalytics.Wrapper
{
    public partial class ThinkingAnalyticsWrapper
    {
#if  (UNITY_STANDALONE || UNITY_EDITOR)
        private void init()
        {

        //     public enum TATimeZone
        //{
        //    Local,
        //    UTC,
        //    Asia_Shanghai,
        //    Asia_Tokyo,
        //    America_Los_Angeles,
        //    America_New_York,
        //    Other = 100
        //}
            //switch (token.timeZone)
            //{
            //    case ThinkingAnalyticsAPI.TATimeZone.Local:
            //        break;
            //    case ThinkingAnalyticsAPI.TATimeZone.UTC:
            //        break;
            //    case ThinkingAnalyticsAPI.TATimeZone.Asia_Shanghai:
            //        break;
            //    case ThinkingAnalyticsAPI.TATimeZone.Asia_Tokyo:
            //        break;
            //    case ThinkingAnalyticsAPI.TATimeZone.America_Los_Angeles:
            //        break;
            //    case ThinkingAnalyticsAPI.TATimeZone.America_New_York:
            //        break;
            //    case ThinkingAnalyticsAPI.TATimeZone.Other:
            //        break;

            //}
            ThinkingSDKConfig config = ThinkingSDKConfig.GetInstance(token.appid,token.serverUrl);
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
            ThinkingPCSDK.Init(token.appid,token.serverUrl,config);
        }

        private void identify(string uniqueId)
        {
            ThinkingPCSDK.Identifiy(uniqueId,token.appid);
        }

        private string getDistinctId()
        {
            return ThinkingPCSDK.DistinctId(token.appid);
        }

        private void login(string accountId)
        {
            ThinkingPCSDK.Login(accountId,token.appid);
        }

        private void logout()
        {
            ThinkingPCSDK.Logout(token.appid);
        }

        private void flush()
        {
           
        }

        private static void setVersionInfo(string lib_name, string lib_version) {
            ThinkingPCSDK.SetLibName(lib_name);
            ThinkingPCSDK.SetLibVersion(lib_version);
        }

        private void track(ThinkingAnalyticsEvent taEvent)
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
            if (dynamicSuperProperties != null)
            {
                eventData.SetProperties(dynamicSuperProperties.GetDynamicSuperProperties());
            }
            if (taEvent.Properties != null)
            {
                eventData.SetProperties(taEvent.Properties);
            }
            if (taEvent.EventTime != null)
            {
                eventData.SetEventTime(taEvent.EventTime);
            }
            ThinkingPCSDK.Track(eventData, token.appid);
        }

        private void track(string eventName, string properties)
        {  
            Dictionary<string,object> propertiesDic = TD_MiniJSON.Deserialize(properties);
            ThinkingPCSDK.Track(eventName,propertiesDic,token.appid);
        }

        private void track(string eventName, string properties, DateTime dateTime)
        {
            Dictionary<string,object> propertiesDic = TD_MiniJSON.Deserialize(properties);
            ThinkingPCSDK.Track(eventName,propertiesDic,dateTime,token.appid);
        }

        private void setSuperProperties(string superProperties)
        {
            Dictionary<string, object> superPropertiesDic = TD_MiniJSON.Deserialize(superProperties);
            ThinkingPCSDK.SetSuperProperties(superPropertiesDic,token.appid);
        }

        private void unsetSuperProperty(string superPropertyName)
        {
            ThinkingPCSDK.UnsetSuperProperty(superPropertyName,token.appid);
        }

        private void clearSuperProperty()
        {
            ThinkingPCSDK.ClearSuperProperties(token.appid);
        }

        private Dictionary<string, object> getSuperProperties()
        {
            return ThinkingPCSDK.SuperProperties(token.appid);
        }

        private Dictionary<string, object> getPresetProperties()
        {
            return ThinkingPCSDK.PresetProperties(token.appid);
        }
        private void timeEvent(string eventName)
        {
            ThinkingPCSDK.TimeEvent(eventName,token.appid);
        }

        private void userSet(string properties)
        {
            Dictionary<string, object> propertiesDic = TD_MiniJSON.Deserialize(properties);
            ThinkingPCSDK.UserSet(propertiesDic,token.appid);
        }

        private void userSet(string properties, DateTime dateTime)
        {
            Dictionary<string, object> propertiesDic = TD_MiniJSON.Deserialize(properties);
            ThinkingPCSDK.UserSet(propertiesDic,dateTime,token.appid);
        }

        private void userUnset(List<string> properties)
        {
            ThinkingPCSDK.UserUnset(properties,token.appid);
        }

        private void userUnset(List<string> properties, DateTime dateTime)
        {
            ThinkingPCSDK.UserUnset(properties,dateTime,token.appid);
        }

        private void userSetOnce(string properties)
        {
            Dictionary<string, object> propertiesDic = TD_MiniJSON.Deserialize(properties);
            ThinkingPCSDK.UserSetOnce(propertiesDic, token.appid);
        }

        private void userSetOnce(string properties, DateTime dateTime)
        {
            Dictionary<string, object> propertiesDic = TD_MiniJSON.Deserialize(properties);
            ThinkingPCSDK.UserSetOnce(propertiesDic,dateTime,token.appid);
        }

        private void userAdd(string properties)
        {
            Dictionary<string, object> propertiesDic = TD_MiniJSON.Deserialize(properties);
            ThinkingPCSDK.UserAdd(propertiesDic,token.appid);
        }

        private void userAdd(string properties, DateTime dateTime)
        {
            Dictionary<string, object> propertiesDic = TD_MiniJSON.Deserialize(properties);
            ThinkingPCSDK.UserAdd(propertiesDic,dateTime,token.appid);
        }

        private void userDelete()
        {
            ThinkingPCSDK.UserDelete(token.appid);
        }

        private void userDelete(DateTime dateTime)
        {
            ThinkingPCSDK.UserDelete(dateTime,token.appid);
        }

        private void userAppend(string properties)
        {
            Dictionary<string, object> propertiesDic = TD_MiniJSON.Deserialize(properties);
            ThinkingPCSDK.UserAppend(propertiesDic,token.appid);
        }

        private void userAppend(string properties, DateTime dateTime)
        {
            Dictionary<string, object> propertiesDic = TD_MiniJSON.Deserialize(properties);
            ThinkingPCSDK.UserAppend(propertiesDic,dateTime,token.appid);
        }

        private void setNetworkType(ThinkingAnalyticsAPI.NetworkType networkType)
        {
            
        }

        private string getDeviceId() 
        {
            return ThinkingPCSDK.GetDeviceId();
        }

        private void optOutTracking()
        {
            ThinkingPCSDK.OptTracking(false, token.appid);
        }

        private void optOutTrackingAndDeleteUser()
        {
            ThinkingPCSDK.OptTrackingAndDeleteUser(token.appid);
        }

        private void optInTracking()
        {
            ThinkingPCSDK.OptTracking(true, token.appid);
        }

        private void enableTracking(bool enabled)
        {
            ThinkingPCSDK.EnableTracking(enabled);
        }

        private ThinkingAnalyticsWrapper createLightInstance(ThinkingAnalyticsAPI.Token delegateToken)
        {
            ThinkingAnalyticsWrapper result = new ThinkingAnalyticsWrapper(delegateToken, false);
            ThinkingPCSDK.CreateLightInstance(delegateToken.appid);
            return result;
        }

        private string getTimeString(DateTime dateTime)
        {
       
            return ThinkingPCSDK.TimeString(dateTime,token.appid);
        }

        private void enableAutoTrack(AUTO_TRACK_EVENTS autoTrackEvents)
        {
            if ((autoTrackEvents & AUTO_TRACK_EVENTS.APP_INSTALL) != 0)
            {
                ThinkingPCSDK.EnableAutoTrack(ThinkingSDK.PC.Main.AUTO_TRACK_EVENTS.APP_INSTALL, token.appid);
            }
            if ((autoTrackEvents & AUTO_TRACK_EVENTS.APP_START) != 0)
            {
                ThinkingPCSDK.EnableAutoTrack(ThinkingSDK.PC.Main.AUTO_TRACK_EVENTS.APP_START,token.appid);
            }
            if ((autoTrackEvents & AUTO_TRACK_EVENTS.APP_CRASH) != 0)
            {
                ThinkingPCSDK.EnableAutoTrack(ThinkingSDK.PC.Main.AUTO_TRACK_EVENTS.APP_CRASH,token.appid);
            }
        }
        private static void enable_log(bool enableLog)
        {
            ThinkingPCSDK.EnableLog(enableLog);
        }
        private static void calibrateTime(long timestamp)
        {
            ThinkingPCSDK.CalibrateTime(timestamp);
        }

        private static void calibrateTimeWithNtp(string ntpServer)
        {
            ThinkingPCSDK.CalibrateTimeWithNtp(ntpServer);
        }
#endif
    }
}