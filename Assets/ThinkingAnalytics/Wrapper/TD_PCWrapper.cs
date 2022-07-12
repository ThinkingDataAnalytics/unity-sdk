#if  (!(UNITY_IOS) || UNITY_EDITOR) && (!(UNITY_ANDROID) || UNITY_EDITOR)
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
    public partial class ThinkingAnalyticsWrapper: IDynamicSuperProperties_PC, IAutoTrackEventCallback_PC
    {
        IAutoTrackEventCallback mEventCallback;
        public Dictionary<string, object> GetDynamicSuperProperties_PC()
        {
            if (this.dynamicSuperProperties != null) {
                return this.dynamicSuperProperties.GetDynamicSuperProperties();
            } 
            else {
                return new Dictionary<string, object>();
            }
        }

        public Dictionary<string, object> AutoTrackEventCallback_PC(int type, Dictionary<string, object>properties)
        {
            if (this.mEventCallback != null) {
                return this.mEventCallback.AutoTrackEventCallback(type, properties);
            } 
            else {
                return new Dictionary<string, object>();
            }
        }

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
            ThinkingPCSDK.Init(token.appid,token.serverUrl,config, this.taMono);
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
           ThinkingPCSDK.Flush(token.appid);
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

        private void userUniqAppend(string properties)
        {
            Dictionary<string, object> propertiesDic = TD_MiniJSON.Deserialize(properties);
            ThinkingPCSDK.UserUniqAppend(propertiesDic,token.appid);
        }

        private void userUniqAppend(string properties, DateTime dateTime)
        {
            Dictionary<string, object> propertiesDic = TD_MiniJSON.Deserialize(properties);
            ThinkingPCSDK.UserUniqAppend(propertiesDic,dateTime,token.appid);
        }

        private void setNetworkType(ThinkingAnalyticsAPI.NetworkType networkType)
        {
            
        }

        private string getDeviceId() 
        {
            return ThinkingPCSDK.GetDeviceId();
        }

        private void setDynamicSuperProperties(IDynamicSuperProperties dynamicSuperProperties)
        {
            ThinkingPCSDK.SetDynamicSuperProperties(this);
        }

        private void setTrackStatus(TA_TRACK_STATUS status)
        {
            ThinkingPCSDK.SetTrackStatus((ThinkingSDK.PC.Main.TA_TRACK_STATUS)status, token.appid);
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
            ThinkingAnalyticsWrapper result = new ThinkingAnalyticsWrapper(delegateToken, this.taMono, false);
            ThinkingPCSDK.CreateLightInstance(delegateToken.appid);
            return result;
        }

        private string getTimeString(DateTime dateTime)
        {
       
            return ThinkingPCSDK.TimeString(dateTime,token.appid);
        }

        private void enableAutoTrack(AUTO_TRACK_EVENTS autoTrackEvents, string properties)
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
            ThinkingPCSDK.EnableAutoTrack(pcAutoTrackEvents, propertiesDic, token.appid);
        }

        private void enableAutoTrack(AUTO_TRACK_EVENTS autoTrackEvents, IAutoTrackEventCallback eventCallback)
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
            this.mEventCallback = eventCallback;
            ThinkingPCSDK.EnableAutoTrack(pcAutoTrackEvents, this);
        }

        private void setAutoTrackProperties(AUTO_TRACK_EVENTS autoTrackEvents, string properties)
        {
            Dictionary<string, object> propertiesDic = TD_MiniJSON.Deserialize(properties);
            if ((autoTrackEvents & AUTO_TRACK_EVENTS.APP_INSTALL) != 0)
            {
                ThinkingPCSDK.SetAutoTrackProperties(ThinkingSDK.PC.Main.AUTO_TRACK_EVENTS.APP_INSTALL, propertiesDic, token.appid);
            }
            if ((autoTrackEvents & AUTO_TRACK_EVENTS.APP_START) != 0)
            {
                ThinkingPCSDK.SetAutoTrackProperties(ThinkingSDK.PC.Main.AUTO_TRACK_EVENTS.APP_START, propertiesDic, token.appid);
            }
            if ((autoTrackEvents & AUTO_TRACK_EVENTS.APP_CRASH) != 0)
            {
                ThinkingPCSDK.SetAutoTrackProperties(ThinkingSDK.PC.Main.AUTO_TRACK_EVENTS.APP_CRASH, propertiesDic, token.appid);
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

        private void enableThirdPartySharing(TAThirdPartyShareType shareType)
        {
            ThinkingSDKLogger.Print("Third Party Sharing is not support on PC");
        }
    }
}
#endif