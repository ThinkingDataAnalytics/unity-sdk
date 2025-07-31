using System;
using System.Collections.Generic;
using ThinkingData.Analytics.Utils;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace ThinkingData.Analytics.Wrapper
{
    public partial class TDWrapper
    {
        public static MonoBehaviour sMono;
        private static TDDynamicSuperPropertiesHandler mDynamicSuperProperties;
        private static Dictionary<string, TDAutoTrackEventHandler> mAutoTrackEventCallbacks = new Dictionary<string, TDAutoTrackEventHandler>();
        private static Dictionary<string, Dictionary<string, object>> mAutoTrackProperties = new Dictionary<string, Dictionary<string, object>>();
        private static Dictionary<string, TDAutoTrackEventType> mAutoTrackEventInfos = new Dictionary<string, TDAutoTrackEventType>();
        private static System.Random rnd = new System.Random();

        private static string default_appId = null;

        // add Dictionary to Dictionary
        public static void AddDictionary(Dictionary<string, object> originalDic, Dictionary<string, object> subDic)
        {
            if (originalDic != subDic)
            {
                foreach (KeyValuePair<string, object> kv in subDic)
                {
                    originalDic[kv.Key] = kv.Value;
                }
            }
        }

        private static string serilize<T>(Dictionary<string, T> data) {
            return TDMiniJson.Serialize(data, getTimeString);
        }

        public static void ShareInstance(TDConfig token, MonoBehaviour mono, bool initRequired = true)
        {
            sMono = mono;
            if (string.IsNullOrEmpty(default_appId)) default_appId = token.appId;
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

        public static void SetDistinctId(string uniqueId, string appId)
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

        public static void EnableAutoTrack(TDAutoTrackEventType events, Dictionary<string, object> properties, string appId)
        {
            if (string.IsNullOrEmpty(appId)) appId = default_appId;
            UpdateAutoTrackSceneInfos(events, appId);
            SetAutoTrackProperties(events, properties, appId);
            enableAutoTrack(events, properties, appId);
            if ((events & TDAutoTrackEventType.AppSceneLoad) != 0)
            {
                TrackSceneLoad(SceneManager.GetActiveScene(), appId);
            }
        }

        public static void EnableAutoTrack(TDAutoTrackEventType events, TDAutoTrackEventHandler eventCallback, string appId)
        {
            if (string.IsNullOrEmpty(appId)) appId = default_appId;
            UpdateAutoTrackSceneInfos(events, appId);
            mAutoTrackEventCallbacks[appId] = eventCallback;
            //mAutoTrackEventCallback = eventCallback;
            enableAutoTrack(events, eventCallback, appId);
            if ((events & TDAutoTrackEventType.AppSceneLoad) != 0)
            {
                TrackSceneLoad(SceneManager.GetActiveScene(), appId);
            }
        }

        private static string TDAutoTrackEventType_APP_SCENE_LOAD = "AppSceneLoad";
        private static string TDAutoTrackEventType_APP_SCENE_UNLOAD = "AppSceneUnload";
        public static void SetAutoTrackProperties(TDAutoTrackEventType events, Dictionary<string, object> properties, string appId)
        {
            if ((events & TDAutoTrackEventType.AppSceneLoad) != 0)
            {
                if (mAutoTrackProperties.ContainsKey(TDAutoTrackEventType_APP_SCENE_LOAD))
                {
                    AddDictionary(mAutoTrackProperties[TDAutoTrackEventType_APP_SCENE_LOAD], properties);
                }
                else
                    mAutoTrackProperties[TDAutoTrackEventType_APP_SCENE_LOAD] = properties;
            }
            if ((events & TDAutoTrackEventType.AppSceneUnload) != 0)
            {
                if (mAutoTrackProperties.ContainsKey(TDAutoTrackEventType_APP_SCENE_UNLOAD))
                {
                    AddDictionary(mAutoTrackProperties[TDAutoTrackEventType_APP_SCENE_UNLOAD], properties);
                }
                else
                    mAutoTrackProperties[TDAutoTrackEventType_APP_SCENE_UNLOAD] = properties;
            }
            setAutoTrackProperties(events, properties, appId);
        }

        public static void TrackSceneLoad(Scene scene, string appId = "")
        {
            Dictionary<string, object> properties = new Dictionary<string, object>() {
                { "#scene_name", scene.name },
                { "#scene_path", scene.path }
            };
            if (mAutoTrackProperties.ContainsKey(TDAutoTrackEventType_APP_SCENE_LOAD))
            {
                AddDictionary(properties, mAutoTrackProperties[TDAutoTrackEventType_APP_SCENE_LOAD]);
            }
            if (string.IsNullOrEmpty(appId))
            {
                foreach (var kv in mAutoTrackEventInfos)
                {
                    Dictionary<string, object> finalProperties = new Dictionary<string, object>(properties);
                    if (mAutoTrackEventCallbacks.ContainsKey(kv.Key))
                    {
                        AddDictionary(finalProperties, mAutoTrackEventCallbacks[kv.Key].GetAutoTrackEventProperties((int)TDAutoTrackEventType.AppSceneLoad, properties));
                    }
                    if ((kv.Value & TDAutoTrackEventType.AppSceneLoad) != 0)
                    {
                        Track("ta_scene_loaded", finalProperties, kv.Key);
                    }
                    if ((kv.Value & TDAutoTrackEventType.AppSceneUnload) != 0)
                    {
                        TimeEvent("ta_scene_unloaded", kv.Key);
                    }
                }
            }
            else
            {
                Dictionary<string, object> finalProperties = new Dictionary<string, object>(properties);
                if (mAutoTrackEventCallbacks.ContainsKey(appId))
                {
                    AddDictionary(finalProperties, mAutoTrackEventCallbacks[appId].GetAutoTrackEventProperties((int)TDAutoTrackEventType.AppSceneLoad, properties));
                }
                Track("ta_scene_loaded", finalProperties, appId);
                TimeEvent("ta_scene_unloaded", appId);
            }
        }

        public static void TrackSceneUnload(Scene scene, string appId = "")
        {
            Dictionary<string, object> properties = new Dictionary<string, object>() {
                { "#scene_name", scene.name },
                { "#scene_path", scene.path }
            };
            if (mAutoTrackProperties.ContainsKey(TDAutoTrackEventType_APP_SCENE_UNLOAD))
            {
                AddDictionary(properties, mAutoTrackProperties[TDAutoTrackEventType_APP_SCENE_UNLOAD]);
            }
            foreach (var kv in mAutoTrackEventInfos)
            {
                Dictionary<string, object> finalProperties = new Dictionary<string, object>(properties);
                if (mAutoTrackEventCallbacks.ContainsKey(kv.Key))
                {
                    AddDictionary(finalProperties, mAutoTrackEventCallbacks[kv.Key].GetAutoTrackEventProperties((int)TDAutoTrackEventType.AppSceneUnload, properties));
                }
                if ((kv.Value & TDAutoTrackEventType.AppSceneUnload) != 0)
                {
                    Track("ta_scene_unloaded", finalProperties, kv.Key);
                }
            }
        }

        private static void UpdateAutoTrackSceneInfos(TDAutoTrackEventType events, string appId = "")
        {
            if (string.IsNullOrEmpty(appId)) appId = default_appId;
            mAutoTrackEventInfos[appId] = events;
        }

        private static Dictionary<string, object> getFinalEventProperties(Dictionary<string, object> properties)
        {
            TDPropertiesChecker.CheckProperties(properties);

            if (null != mDynamicSuperProperties)
            {
                Dictionary<string, object> finalProperties = new Dictionary<string, object>();
                TDPropertiesChecker.MergeProperties(mDynamicSuperProperties.GetDynamicSuperProperties(), finalProperties);
                TDPropertiesChecker.MergeProperties(properties, finalProperties);
                return finalProperties;
            }
            else
            {
                return properties;
            }

        }
        public static void Track(string eventName, Dictionary<string, object> properties, string appId)
        {
            TDPropertiesChecker.CheckString(eventName);
            track(eventName, getFinalEventProperties(properties), appId);
        }

        public static void TrackStr(string eventName, string properties, string appId)
        {
            trackStr(eventName, properties, appId);
        }

        public static void Track(string eventName, Dictionary<string, object> properties, DateTime datetime, string appId)
        {
            TDPropertiesChecker.CheckString(eventName);
            track(eventName, getFinalEventProperties(properties), datetime, appId);
        }

        public static void Track(string eventName, Dictionary<string, object> properties, DateTime datetime, TimeZoneInfo timeZone, string appId)
        {
            TDPropertiesChecker.CheckString(eventName);
            track(eventName, getFinalEventProperties(properties), datetime, timeZone, appId);
        }

        public static void TrackForAll(string eventName, Dictionary<string, object> properties)
        {
            TDPropertiesChecker.CheckString(eventName);
            trackForAll(eventName, getFinalEventProperties(properties));
        }

        public static void Track(TDEventModel taEvent, string appId)
        {
            if (null == taEvent || null == taEvent.EventType)
            {
                if(TDLog.GetEnable()) TDLog.w("Ignoring invalid TA event");
                return;
            }

            if (taEvent.GetEventTime() == null)
            {
                if(TDLog.GetEnable()) TDLog.w("ppp null...");
            }
            TDPropertiesChecker.CheckString(taEvent.EventName);
            TDPropertiesChecker.CheckProperties(taEvent.Properties);
            track(taEvent, appId);
        }

        public static void QuickTrack(string eventName, Dictionary<string, object> properties, string appId)
        {
            if ("SceneView" == eventName)
            {
                if (properties == null)
                {
                    properties = new Dictionary<string, object>() { };
                }
                Scene scene = SceneManager.GetActiveScene();
                if (scene != null)
                {
                    properties.Add("#scene_name", scene.name);
                    properties.Add("#scene_path", scene.path);
                }
                Track("ta_scene_view", properties, appId);
            }
            else if ("AppClick" == eventName)
            {
                if (properties == null)
                {
                    properties = new Dictionary<string, object>() { };
                }
                Track("ta_app_click", properties, appId);
            }
        }

        public static void SetSuperProperties(Dictionary<string, object> superProperties, string appId)
        {
            TDPropertiesChecker.CheckProperties(superProperties);
            setSuperProperties(superProperties, appId);
        }

        public static void SetSuperProperties(string superProperties, string appId)
        {
            setSuperProperties(superProperties, appId);
        }

        public static void UnsetSuperProperty(string superPropertyName, string appId)
        {
            TDPropertiesChecker.CheckString(superPropertyName);
            unsetSuperProperty(superPropertyName, appId);
        }

        public static void ClearSuperProperty(string appId)
        {
            clearSuperProperty(appId);
        }


        public static void TimeEvent(string eventName, string appId)
        {
            TDPropertiesChecker.CheckString(eventName);
            timeEvent(eventName, appId);
        }

        public static void TimeEventForAll(string eventName)
        {
            TDPropertiesChecker.CheckString(eventName);
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
            TDPropertiesChecker.CheckProperties(properties);
            userSet(properties, appId);
        }

        public static void UserSet(string properties, string appId)
        {
            userSet(properties, appId);
        }

        public static void UserSet(Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
            TDPropertiesChecker.CheckProperties(properties);
            userSet(properties, dateTime, appId);
        }

        public static void UserSetOnce(Dictionary<string, object> properties, string appId)
        {
            TDPropertiesChecker.CheckProperties(properties);
            userSetOnce(properties, appId);
        }

        public static void UserSetOnce(string properties, string appId)
        {
            userSetOnce(properties, appId);
        }

        public static void UserSetOnce(Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
            TDPropertiesChecker.CheckProperties(properties);
            userSetOnce(properties, dateTime, appId);
        }

        public static void UserUnset(List<string> properties, string appId)
        {
            TDPropertiesChecker.CheckProperties(properties);
            userUnset(properties, appId);
        }

        public static void UserUnset(List<string> properties, DateTime dateTime, string appId)
        {
            TDPropertiesChecker.CheckProperties(properties);
            userUnset(properties, dateTime, appId);
        }

        public static void UserAdd(Dictionary<string, object> properties, string appId)
        {
            TDPropertiesChecker.CheckProperties(properties);
            userAdd(properties, appId);
        }

        public static void UserAddStr(string properties, string appId)
        {
            userAddStr(properties, appId);
        }

        public static void UserAdd(Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
            TDPropertiesChecker.CheckProperties(properties);
            userAdd(properties, dateTime, appId);
        }

        public static void UserAppend(Dictionary<string, object> properties, string appId)
        {
            TDPropertiesChecker.CheckProperties(properties);
            userAppend(properties, appId);
        }

        public static void UserAppend(string properties, string appId)
        {
            userAppend(properties, appId);
        }

        public static void UserAppend(Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
            TDPropertiesChecker.CheckProperties(properties);
            userAppend(properties, dateTime, appId);
        }

        public static void UserUniqAppend(Dictionary<string, object> properties, string appId) 
        {
            TDPropertiesChecker.CheckProperties(properties);
            userUniqAppend(properties, appId);
        }

        public static void UserUniqAppend(string properties, string appId)
        {
            userUniqAppend(properties, appId);
        }

        public static void UserUniqAppend(Dictionary<string, object> properties, DateTime dateTime, string appId) 
        {
            TDPropertiesChecker.CheckProperties(properties);
            userUniqAppend(properties, dateTime, appId);
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

        public static void SetNetworkType(TDNetworkType networkType)
        {
            setNetworkType(networkType);
        }

        public static string GetDeviceId()
        {
            return getDeviceId();
        }

        public static void SetDynamicSuperProperties(TDDynamicSuperPropertiesHandler dynamicSuperProperties, string appId)
        {
            if (!TDPropertiesChecker.CheckProperties(dynamicSuperProperties.GetDynamicSuperProperties()))
            {
                if(TDLog.GetEnable()) TDLog.d("Cannot set dynamic super properties due to invalid properties.");
            }
            mDynamicSuperProperties = dynamicSuperProperties;
            setDynamicSuperProperties(dynamicSuperProperties, appId);
        }

        public static void SetTrackStatus(TDTrackStatus status, string appId)
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

        public static void EnableThirdPartySharing(TDThirdPartyType shareType, Dictionary<string, object> properties = null, string appId = "")
        {
            if (null == properties) properties = new Dictionary<string, object>();
            enableThirdPartySharing(shareType, properties, appId);
        }
    }
}

