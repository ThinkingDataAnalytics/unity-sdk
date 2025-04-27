#if ((!(UNITY_IOS) || UNITY_EDITOR) && (!(UNITY_ANDROID) || UNITY_EDITOR) && (!(UNITY_OPENHARMONY) || UNITY_EDITOR)) || TE_DISABLE_ANDROID_JAVA || TE_DISABLE_IOS_OC
using System;
using System.Collections.Generic;
using ThinkingData.Analytics.Utils;
using ThinkingSDK.PC.Main;
using ThinkingSDK.PC.Utils;
using ThinkingSDK.PC.DataModel;
using ThinkingSDK.PC.Config;

namespace ThinkingData.Analytics.Wrapper
{
    public partial class TDWrapper : TDDynamicSuperPropertiesHandler_PC, TDAutoTrackEventHandler_PC
    {
        static TDAutoTrackEventHandler mEventCallback;
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

        public Dictionary<string, object> AutoTrackEventCallback_PC(int type, Dictionary<string, object> properties)
        {
            if (mEventCallback != null)
            {
                return mEventCallback.GetAutoTrackEventProperties(type, properties);
            }
            else
            {
                return new Dictionary<string, object>();
            }
        }

        private static void init(TDConfig token)
        {
            ThinkingSDKConfig config = ThinkingSDKConfig.GetInstance(token.appId, token.serverUrl, token.name);
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
            if (token.mode == TDMode.Debug)
            {
                config.SetMode(Mode.DEBUG);
            }
            else if (token.mode == TDMode.DebugOnly)
            {
                config.SetMode(Mode.DEBUG_ONLY);
            }
            ThinkingPCSDK.Init(token.appId, token.serverUrl, token.name, config, sMono);
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

        private static void setVersionInfo(string lib_name, string lib_version)
        {
            ThinkingPCSDK.SetLibName(lib_name);
            ThinkingPCSDK.SetLibVersion(lib_version);
        }

        private static void track(TDEventModel taEvent, string appId)
        {
            ThinkingSDKEventData eventData = null;
            switch (taEvent.EventType)
            {
                case TDEventModel.TDEventType.First:
                    {
                        eventData = new ThinkingSDKFirstEvent(taEvent.EventName);
                        if (!string.IsNullOrEmpty(taEvent.GetEventId()))
                        {
                            ((ThinkingSDKFirstEvent)eventData).SetFirstCheckId(taEvent.GetEventId());
                        }
                    }
                    break;
                case TDEventModel.TDEventType.Updatable:
                    eventData = new ThinkingSDKUpdateEvent(taEvent.EventName, taEvent.GetEventId());
                    break;
                case TDEventModel.TDEventType.Overwritable:
                    eventData = new ThinkingSDKOverWritableEvent(taEvent.EventName, taEvent.GetEventId());
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
            if (taEvent.GetEventTime() != null && taEvent.GetEventTimeZone() != null)
            {
                eventData.SetEventTime(taEvent.GetEventTime());
                eventData.SetTimeZone(taEvent.GetEventTimeZone());
            }
            ThinkingPCSDK.Track(eventData, appId);
        }

        private static void track(string eventName, Dictionary<string, object> properties, string appId)
        {
            ThinkingPCSDK.Track(eventName, properties, appId);
        }

        private static void trackStr(string eventName, string properties, string appId)
        {
            try
            {
                ThinkingPCSDK.Track(eventName, TDMiniJson.Deserialize(properties), appId);
            }
            catch (Exception)
            {
            }
        }

        private static void track(string eventName, Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
            ThinkingPCSDK.Track(eventName, properties, dateTime, appId);
        }

        private static void track(string eventName, Dictionary<string, object> properties, DateTime dateTime, TimeZoneInfo timeZone, string appId)
        {
            ThinkingPCSDK.Track(eventName, properties, dateTime, timeZone, appId);
        }

        private static void trackForAll(string eventName, Dictionary<string, object> properties)
        {
            ThinkingPCSDK.TrackForAll(eventName, properties);
        }

        private static void setSuperProperties(Dictionary<string, object> superProperties, string appId)
        {
            ThinkingPCSDK.SetSuperProperties(superProperties, appId);
        }

        private static void setSuperProperties(string superProperties, string appId)
        {
            try
            {
                ThinkingPCSDK.SetSuperProperties(TDMiniJson.Deserialize(superProperties), appId);
            }
            catch (Exception)
            {
            }
        }

        private static void unsetSuperProperty(string superPropertyName, string appId)
        {
            ThinkingPCSDK.UnsetSuperProperty(superPropertyName, appId);
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
            ThinkingPCSDK.TimeEvent(eventName, appId);
        }
        private static void timeEventForAll(string eventName)
        {
            ThinkingPCSDK.TimeEventForAll(eventName);
        }

        private static void userSet(Dictionary<string, object> properties, string appId)
        {
            ThinkingPCSDK.UserSet(properties, appId);
        }

        private static void userSet(string properties, string appId)
        {
            try
            {
                ThinkingPCSDK.UserSet(TDMiniJson.Deserialize(properties), appId);
            }
            catch (Exception)
            {
            }
        }

        private static void userSet(Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
            ThinkingPCSDK.UserSet(properties, dateTime, appId);
        }

        private static void userUnset(List<string> properties, string appId)
        {
            ThinkingPCSDK.UserUnset(properties, appId);
        }

        private static void userUnset(List<string> properties, DateTime dateTime, string appId)
        {
            ThinkingPCSDK.UserUnset(properties, dateTime, appId);
        }

        private static void userSetOnce(Dictionary<string, object> properties, string appId)
        {
            ThinkingPCSDK.UserSetOnce(properties, appId);
        }

        private static void userSetOnce(string properties, string appId)
        {
            try
            {
                ThinkingPCSDK.UserSetOnce(TDMiniJson.Deserialize(properties), appId);
            }
            catch (Exception)
            {
            }
        }

        private static void userSetOnce(Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
            ThinkingPCSDK.UserSetOnce(properties, dateTime, appId);
        }

        private static void userAdd(Dictionary<string, object> properties, string appId)
        {
            ThinkingPCSDK.UserAdd(properties, appId);
        }

        private static void userAddStr(string properties, string appId)
        {
            try
            {
                ThinkingPCSDK.UserAdd(TDMiniJson.Deserialize(properties), appId);
            }
            catch (Exception)
            {
            }
        }

        private static void userAdd(Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
            ThinkingPCSDK.UserAdd(properties, dateTime, appId);
        }

        private static void userDelete(string appId)
        {
            ThinkingPCSDK.UserDelete(appId);
        }

        private static void userDelete(DateTime dateTime, string appId)
        {
            ThinkingPCSDK.UserDelete(dateTime, appId);
        }

        private static void userAppend(Dictionary<string, object> properties, string appId)
        {
            ThinkingPCSDK.UserAppend(properties, appId);
        }

        private static void userAppend(string properties, string appId)
        {
            try
            {
                ThinkingPCSDK.UserAppend(TDMiniJson.Deserialize(properties), appId);
            }
            catch (Exception)
            {
            }
        }

        private static void userAppend(Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
            ThinkingPCSDK.UserAppend(properties, dateTime, appId);
        }

        private static void userUniqAppend(Dictionary<string, object> properties, string appId)
        {
            ThinkingPCSDK.UserUniqAppend(properties, appId);
        }

        private static void userUniqAppend(string properties, string appId)
        {
            try
            {
                ThinkingPCSDK.UserUniqAppend(TDMiniJson.Deserialize(properties), appId);
            }
            catch (Exception)
            {
            }
        }

        private static void userUniqAppend(Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
            ThinkingPCSDK.UserUniqAppend(properties, dateTime, appId);
        }

        private static void setNetworkType(TDNetworkType networkType)
        {

        }

        private static string getDeviceId()
        {
            return ThinkingPCSDK.GetDeviceId();
        }

        private static void setDynamicSuperProperties(TDDynamicSuperPropertiesHandler dynamicSuperProperties, string appId)
        {
            ThinkingPCSDK.SetDynamicSuperProperties(new TDWrapper());
        }

        private static void setTrackStatus(TDTrackStatus status, string appId)
        {
            ThinkingPCSDK.SetTrackStatus((ThinkingSDK.PC.Main.TDTrackStatus)status, appId);
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

        private static void enableAutoTrack(TDAutoTrackEventType autoTrackEvents, Dictionary<string, object> properties, string appId)
        {
            ThinkingSDK.PC.Main.TDAutoTrackEventType pcAutoTrackEvents = ThinkingSDK.PC.Main.TDAutoTrackEventType.None;
            if ((autoTrackEvents & TDAutoTrackEventType.AppInstall) != 0)
            {
                pcAutoTrackEvents = pcAutoTrackEvents | ThinkingSDK.PC.Main.TDAutoTrackEventType.AppInstall;
            }
            if ((autoTrackEvents & TDAutoTrackEventType.AppStart) != 0)
            {
                pcAutoTrackEvents = pcAutoTrackEvents | ThinkingSDK.PC.Main.TDAutoTrackEventType.AppStart;
            }
            if ((autoTrackEvents & TDAutoTrackEventType.AppEnd) != 0)
            {
                pcAutoTrackEvents = pcAutoTrackEvents | ThinkingSDK.PC.Main.TDAutoTrackEventType.AppEnd;
            }
            if ((autoTrackEvents & TDAutoTrackEventType.AppCrash) != 0)
            {
                pcAutoTrackEvents = pcAutoTrackEvents | ThinkingSDK.PC.Main.TDAutoTrackEventType.AppCrash;
            }
            if ((autoTrackEvents & TDAutoTrackEventType.AppSceneLoad) != 0)
            {
                pcAutoTrackEvents = pcAutoTrackEvents | ThinkingSDK.PC.Main.TDAutoTrackEventType.AppSceneLoad;
            }
            if ((autoTrackEvents & TDAutoTrackEventType.AppSceneUnload) != 0)
            {
                pcAutoTrackEvents = pcAutoTrackEvents | ThinkingSDK.PC.Main.TDAutoTrackEventType.AppSceneUnload;
            }
            ThinkingPCSDK.EnableAutoTrack(pcAutoTrackEvents, properties, appId);
        }

        private static void enableAutoTrack(TDAutoTrackEventType autoTrackEvents, TDAutoTrackEventHandler eventCallback, string appId)
        {
            ThinkingSDK.PC.Main.TDAutoTrackEventType pcAutoTrackEvents = ThinkingSDK.PC.Main.TDAutoTrackEventType.None;
            if ((autoTrackEvents & TDAutoTrackEventType.AppInstall) != 0)
            {
                pcAutoTrackEvents = pcAutoTrackEvents | ThinkingSDK.PC.Main.TDAutoTrackEventType.AppInstall;
            }
            if ((autoTrackEvents & TDAutoTrackEventType.AppStart) != 0)
            {
                pcAutoTrackEvents = pcAutoTrackEvents | ThinkingSDK.PC.Main.TDAutoTrackEventType.AppStart;
            }
            if ((autoTrackEvents & TDAutoTrackEventType.AppEnd) != 0)
            {
                pcAutoTrackEvents = pcAutoTrackEvents | ThinkingSDK.PC.Main.TDAutoTrackEventType.AppEnd;
            }
            if ((autoTrackEvents & TDAutoTrackEventType.AppCrash) != 0)
            {
                pcAutoTrackEvents = pcAutoTrackEvents | ThinkingSDK.PC.Main.TDAutoTrackEventType.AppCrash;
            }
            if ((autoTrackEvents & TDAutoTrackEventType.AppSceneLoad) != 0)
            {
                pcAutoTrackEvents = pcAutoTrackEvents | ThinkingSDK.PC.Main.TDAutoTrackEventType.AppSceneLoad;
            }
            if ((autoTrackEvents & TDAutoTrackEventType.AppSceneUnload) != 0)
            {
                pcAutoTrackEvents = pcAutoTrackEvents | ThinkingSDK.PC.Main.TDAutoTrackEventType.AppSceneUnload;
            }
            mEventCallback = eventCallback;
            ThinkingPCSDK.EnableAutoTrack(pcAutoTrackEvents, new TDWrapper(), appId);
        }

        private static void setAutoTrackProperties(TDAutoTrackEventType autoTrackEvents, Dictionary<string, object> properties, string appId)
        {
            if ((autoTrackEvents & TDAutoTrackEventType.AppInstall) != 0)
            {
                ThinkingPCSDK.SetAutoTrackProperties(ThinkingSDK.PC.Main.TDAutoTrackEventType.AppInstall, properties, appId);
            }
            if ((autoTrackEvents & TDAutoTrackEventType.AppStart) != 0)
            {
                ThinkingPCSDK.SetAutoTrackProperties(ThinkingSDK.PC.Main.TDAutoTrackEventType.AppStart, properties, appId);
            }
            if ((autoTrackEvents & TDAutoTrackEventType.AppEnd) != 0)
            {
                ThinkingPCSDK.SetAutoTrackProperties(ThinkingSDK.PC.Main.TDAutoTrackEventType.AppEnd, properties, appId);
            }
            if ((autoTrackEvents & TDAutoTrackEventType.AppCrash) != 0)
            {
                ThinkingPCSDK.SetAutoTrackProperties(ThinkingSDK.PC.Main.TDAutoTrackEventType.AppCrash, properties, appId);
            }
            if ((autoTrackEvents & TDAutoTrackEventType.AppSceneLoad) != 0)
            {
                ThinkingPCSDK.SetAutoTrackProperties(ThinkingSDK.PC.Main.TDAutoTrackEventType.AppSceneLoad, properties, appId);
            }
            if ((autoTrackEvents & TDAutoTrackEventType.AppSceneUnload) != 0)
            {
                ThinkingPCSDK.SetAutoTrackProperties(ThinkingSDK.PC.Main.TDAutoTrackEventType.AppSceneUnload, properties, appId);
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

        private static void enableThirdPartySharing(TDThirdPartyType shareType, Dictionary<string, object> properties, string appId)
        {
            if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("Sharing data is not support on PC: " + shareType + ", " + properties + ", " + appId);
        }
    }
}
#endif