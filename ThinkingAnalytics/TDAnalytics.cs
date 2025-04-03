/*
 * 
    Copyright 2019, ThinkingData, Inc
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
    SDK VERSION:3.1.4
 */

/**    
\mainpage

\section main_introduction Introduction

ThinkingData Analytics SDK for Unity.

This is the [ThinkingData](https://www.thinkingdata.cn)™ Analytics SDK for Unity. Documentation is available on our help center in the following languages:

- [English](https://docs.thinkingdata.cn/ta-manual/latest/en/installation/installation_menu/client_sdk/game_engine_sdk_installation/unity_sdk_installation/unity_sdk_installation.html)
- [中文](https://docs.thinkingdata.cn/ta-manual/latest/installation/installation_menu/client_sdk/game_engine_sdk_installation/unity_sdk_installation/unity_sdk_installation.html)

 */

#if !(UNITY_5_4_OR_NEWER)
#define DISABLE_TA
#warning "Your Unity version is not supported by us - ThinkingAnalyticsSDK disabled"
#endif

using System;
using System.Collections.Generic;
using ThinkingData.Analytics.Utils;
using ThinkingData.Analytics.Wrapper;
using UnityEngine;
using ThinkingData.Analytics.TDException;
using UnityEngine.SceneManagement;

namespace ThinkingData.Analytics
{
    /// <summary>
    /// ThinkingData Analytics SDK for Unity.
    /// </summary>
    [DisallowMultipleComponent]
    public class TDAnalytics : MonoBehaviour
    {
        #region settings
        //[System.Serializable]
        //public class TDConfig
        //{
        //    public string appId;
        //    public string serverUrl;
        //    public TDMode mode;
        //    public TDTimeZone timeZone;
        //    public string timeZoneId;
        //    public bool enableEncrypt; // enable data encryption, default is false (iOS/Android only)
        //    public int encryptVersion; // secret key version (iOS/Android only)
        //    public string encryptPublicKey; // public secret key (iOS/Android only)
        //    public TDSSLPinningMode pinningMode; // SSL Pinning mode, default is NONE (iOS/Android only)
        //    public bool allowInvalidCertificates; // allow invalid certificates, default is false (iOS/Android only)
        //    public bool validatesDomainName; // enable to verify domain name, default is true (iOS/Android only)
        //    private string sName;
        //    public string name { set { if (!string.IsNullOrEmpty(value)) sName = value.Replace(" ", ""); } get { return sName; } } // instances name

        //    //public TDConfig(string appId, string serverUrl, TDMode mode = TDMode.Normal, TDTimeZone timeZone = TDTimeZone.Local, string timeZoneId = null, string instanceName = null)
        //    public TDConfig(string appId, string serverUrl)
        //    {
        //        this.appId = appId.Replace(" ", "");
        //        this.serverUrl = serverUrl;
        //        this.mode = TDMode.Normal;
        //        this.timeZone = TDTimeZone.Local;
        //        this.timeZoneId = null;
        //        this.enableEncrypt = false;
        //        this.encryptVersion = 0;
        //        this.encryptPublicKey = null;
        //        this.pinningMode = TDSSLPinningMode.NONE;
        //        this.allowInvalidCertificates = false;
        //        this.validatesDomainName = true;
        //        //if (!string.IsNullOrEmpty(instanceName))
        //        //{
        //        //    instanceName = instanceName.Replace(" ", "");
        //        //}
        //    }

        //    //public string GetInstanceName()
        //    //{
        //    //    return this.instanceName;
        //    //}

        //    public string getTimeZoneId()
        //    {
        //        switch (timeZone)
        //        {
        //            case TDTimeZone.UTC:
        //                return "UTC";
        //            case TDTimeZone.Asia_Shanghai:
        //                return "Asia/Shanghai";
        //            case TDTimeZone.Asia_Tokyo:
        //                return "Asia/Tokyo";
        //            case TDTimeZone.America_Los_Angeles:
        //                return "America/Los_Angeles";
        //            case TDTimeZone.America_New_York:
        //                return "America/New_York";
        //            case TDTimeZone.Other:
        //                return timeZoneId;
        //            default:
        //                break;
        //        }
        //        return null;
        //    }
        //}

        //public enum TDTimeZone
        //{
        //    Local,
        //    UTC,
        //    Asia_Shanghai,
        //    Asia_Tokyo,
        //    America_Los_Angeles,
        //    America_New_York,
        //    Other = 100
        //}

        //public enum TDMode
        //{
        //    Debug = 1,
        //    DebugOnly = 2,
        //    Normal = 0
        //}

        //public enum TDNetworkType
        //{
        //    Wifi = 1,
        //    All = 0
        //}

        [Header("Configuration")]
        [Tooltip("Enable Start SDK Manually")]
        public bool startManually = true;

        [Tooltip("Enable Log")]
        public bool enableLog = true;
        [Tooltip("Sets the Network Type")]
        public TDNetworkType networkType = TDNetworkType.All;

        [Header("Project")]
        [Tooltip("Project Setting, APP ID is given when the project is created")]
        [HideInInspector]
        public TDConfig[] configs = new TDConfig[1];

        #endregion

        /// <summary>
        /// Whether to enable logs
        /// </summary>
        /// <param name="enable">enable logs</param>
        public static void EnableLog(bool enable)
        {
            if (sThinkingData != null)
            {
                sThinkingData.enableLog = enable;
                TDLog.EnableLog(enable);
                TDWrapper.EnableLog(enable);
            }
        }
        /// <summary>
        /// Set custom distinct ID, to replace the distinct ID generated by the system 
        /// </summary>
        /// <param name="distinctId">distinct ID</param>
        /// <param name="appId">project ID (optional)</param>
        public static void SetDistinctId(string distinctId, string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.SetDistinctId(distinctId, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { distinctId, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// Returns the current distinct ID
        /// </summary>
        /// <returns>distinct ID</returns>
        /// <param name="appId">project ID (optional)</param>
        public static string GetDistinctId(string appId = "")
        {
            if (tracking_enabled)
            {
                return TDWrapper.GetDistinctId(appId);
            }
            return null;
        }

        /// <summary>
        /// Set account ID. This method does not upload Login events
        /// </summary>
        /// <param name="account">account ID</param>
        /// <param name="appId">project ID (optional)</param>
        public static void Login(string account, string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.Login(account, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { account, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// Clear account ID. This method does not upload Logout events
        /// </summary>
        /// <param name="appId">project ID (optional) </param>
        public static void Logout(string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.Logout(appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// Enable auto-tracking
        /// </summary>
        /// <param name="eventType">auto-tracking eventType</param>
        /// <param name="properties">properties for auto-tracking events (optional)</param>
        /// <param name="appId">project ID (optional)</param>
        public static void EnableAutoTrack(TDAutoTrackEventType eventType, Dictionary<string, object> properties = null, string appId = "")
        {
            if (tracking_enabled)
            {
                if (properties == null)
                {
                    properties = new Dictionary<string, object>();
                }
                TDWrapper.EnableAutoTrack(eventType, properties, appId);
                if ((eventType & TDAutoTrackEventType.AppCrash) != 0 && !TDPublicConfig.DisableCSharpException)
                {
                    TDExceptionHandler.RegisterTAExceptionHandler(properties);
                }
                if ((eventType & TDAutoTrackEventType.AppSceneLoad) != 0)
                {
                    SceneManager.sceneLoaded -= TDAnalytics.OnSceneLoaded;
                    SceneManager.sceneLoaded += TDAnalytics.OnSceneLoaded;
                }
                if ((eventType & TDAutoTrackEventType.AppSceneUnload) != 0)
                {
                    SceneManager.sceneUnloaded -= TDAnalytics.OnSceneUnloaded;
                    SceneManager.sceneUnloaded += TDAnalytics.OnSceneUnloaded;
                }
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { eventType, properties, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// Enable auto-tracking
        /// </summary>
        /// <param name="events">auto-tracking eventType</param>
        /// <param name="eventHandler">callback for auto-tracking events</param>
        /// <param name="appId">project ID (optional)</param>
        public static void EnableAutoTrack(TDAutoTrackEventType eventType, TDAutoTrackEventHandler eventHandler, string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.EnableAutoTrack(eventType, eventHandler, appId);
                if ((eventType & TDAutoTrackEventType.AppCrash) != 0 && !TDPublicConfig.DisableCSharpException)
                {
                    TDExceptionHandler.RegisterTAExceptionHandler(eventHandler);
                }
                if ((eventType & TDAutoTrackEventType.AppSceneLoad) != 0)
                {
                    SceneManager.sceneLoaded -= TDAnalytics.OnSceneLoaded;
                    SceneManager.sceneLoaded += TDAnalytics.OnSceneLoaded;
                }
                if ((eventType & TDAutoTrackEventType.AppSceneUnload) != 0)
                {
                    SceneManager.sceneUnloaded -= TDAnalytics.OnSceneUnloaded;
                    SceneManager.sceneUnloaded += TDAnalytics.OnSceneUnloaded;
                }
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { eventType, eventHandler, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }

        }

        /// <summary>
        /// Set properties for auto-tracking events
        /// </summary>
        /// <param name="eventType">auto-tracking eventType</param>
        /// <param name="properties">properties for auto-tracking events</param>
        /// <param name="appId">project ID (optional)</param>
        public static void SetAutoTrackProperties(TDAutoTrackEventType eventType, Dictionary<string, object> properties, string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.SetAutoTrackProperties(eventType, properties, appId);
                if ((eventType & TDAutoTrackEventType.AppCrash) != 0 && !TDPublicConfig.DisableCSharpException)
                {
                    TDExceptionHandler.SetAutoTrackProperties(properties);
                }
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { eventType, properties, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// Track a Event
        /// </summary>
        /// <param name="eventName">event name</param>
        /// <param name="appId">project ID (optional)</param>
        public static void Track(string eventName, string appId = "")
        {
            Track(eventName, null, appId);
        }

        /// <summary>
        /// Track a Event
        /// </summary>
        /// <param name="eventName">the event name</param>
        /// <param name="properties">properties for the event</param>
        /// <param name="appId">project ID (optional)</param>
        public static void Track(string eventName, Dictionary<string, object> properties, string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.Track(eventName, properties, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { eventName, properties, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        public static void TrackStr(string eventName, string properties = "", string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.TrackStr(eventName, properties, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { eventName, properties, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// Track a Event
        /// </summary>
        /// <param name="eventName">the event name</param>
        /// <param name="properties">properties for the event</param>
        /// <param name="date">date for the event</param>
        /// <param name="appId">project ID (optional)</param>
        //[Obsolete("Method is deprecated, please use Track(string eventName, Dictionary<string, object> properties, DateTime date, TimeZoneInfo timeZone, string appId = \"\") instead.")]
        //public static void Track(string eventName, Dictionary<string, object> properties, DateTime date, string appId = "")
        //{
        //    if (tracking_enabled)
        //    {
        //        TDWrapper.Track(eventName, properties, date, appId);
        //    }
        //    else
        //    {
        //        System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
        //        object[] parameters = new object[] { eventName, properties, date, appId };
        //        eventCaches.Add(new Dictionary<string, object>() {
        //            { "method", method},
        //            { "parameters", parameters}
        //        });
        //    }
        //}

        /// <summary>
        /// Track a Event
        /// </summary>
        /// <param name="eventName">the event name</param>
        /// <param name="properties">properties for the event</param>
        /// <param name="date">date for the event</param>
        /// <param name="timeZone">time zone for the event</param>
        /// <param name="appId">project ID (optional)</param>
        public static void Track(string eventName, Dictionary<string, object> properties, DateTime time, TimeZoneInfo timeZone, string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.Track(eventName, properties, time, timeZone, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { eventName, properties, time, timeZone, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// Track a Special Event (First Event/Updatable Event/Overwritable Event)
        /// </summary>
        /// <param name="eventModel">the special event</param>
        /// <param name="appId">project ID (optional)</param>
        public static void Track(TDEventModel eventModel, string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.Track(eventModel, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { eventModel, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// Quickly track a Special Event
        /// </summary>
        /// <param name="eventName">the event name, 'SceneView' for scene view event, 'AppClick' for click event</param>
        /// <param name="properties"> event properties </param>
        /// <param name="appId"></param>
        public static void QuickTrack(string eventName, Dictionary<string, object> properties = null, string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.QuickTrack(eventName, properties, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { eventName, properties, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// Report events data to TE server immediately
        /// </summary>
        /// <param name="appId">project ID (optional)</param>
        public static void Flush(string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.Flush(appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// Scenes load Delegate
        /// </summary>
        /// <param name="scene">the load scene</param>
        /// <param name="mode">the scene loading mode</param>
        public static void OnSceneLoaded(Scene scene, LoadSceneMode mode)
        {
            if (tracking_enabled)
            {
                TDWrapper.TrackSceneLoad(scene);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { scene, mode };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// Scenes unload Delegate
        /// </summary>
        /// <param name="scene">the unload scene</param>
        public static void OnSceneUnloaded(Scene scene)
        {
            if (tracking_enabled)
            {
                TDWrapper.TrackSceneUnload(scene);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { scene };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// Super Properties, refer to properties that would be uploaded by each event
        /// </summary>
        /// <param name="superProperties">super properties for events</param>
        /// <param name="appId">project ID (optional)</param>
        public static void SetSuperProperties(Dictionary<string, object> properties, string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.SetSuperProperties(properties, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { properties, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        public static void SetSuperProperties(string properties,string appId = "") {
            if (tracking_enabled)
            {
                TDWrapper.SetSuperProperties(properties, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { properties, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// Delete Property form current Super Properties
        /// </summary>
        /// <param name="property">property name</param>
        /// <param name="appId">project ID (optional)</param>
        public static void UnsetSuperProperty(string property, string appId  = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.UnsetSuperProperty(property, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { property, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// Returns current Super Properties
        /// </summary>
        /// <returns>current super properties</returns>
        /// <param name="appId">project ID (optional)</param>
        public static Dictionary<string, object> GetSuperProperties(string appId = "")
        {
            if (tracking_enabled)
            {
                return TDWrapper.GetSuperProperties(appId);
            }
            return null;
        }

        /// <summary>
        /// Clear current Super Properties
        /// </summary>
        /// <param name="appId">project ID (optional)</param>
        public static void ClearSuperProperties(string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.ClearSuperProperty(appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// Returns current Preset Properties
        /// </summary>
        /// <returns>current preset properties</returns>
        /// <param name="appId">project ID (optional)</param>
        public static TDPresetProperties GetPresetProperties(string appId = "")
        {
            if (tracking_enabled)
            {
                Dictionary<string, object> properties = TDWrapper.GetPresetProperties(appId);
                TDPresetProperties presetProperties = new TDPresetProperties(properties);
                return presetProperties;
            }
            return null;
        }

        /// <summary>
        /// Sets the Dynamic Super Properties.
        /// </summary>
        /// <param name="dynamicSuperProperties">dynamic super properties interface</param>
        /// <param name="appId">project ID (optional)</param>
        public static void SetDynamicSuperProperties(TDDynamicSuperPropertiesHandler propertiesHandler, string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.SetDynamicSuperProperties(propertiesHandler, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { propertiesHandler, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// Records Event Duration, call TimeEvent to start timing for the Event, call Track to end timing
        /// </summary>
        /// <param name="eventName">the event name</param>
        /// <param name="appId">project ID (optional)</param>
        public static void TimeEvent(string eventName, string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.TimeEvent(eventName, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { eventName, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// Sets User Properties, this will overwrite the original properties value
        /// </summary>
        /// <param name="properties">user properties</param>
        /// <param name="appId">project ID (optional)</param>
        public static void UserSet(Dictionary<string, object> properties, string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.UserSet(properties, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { properties, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        public static void UserSet(string properties, string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.UserSet(properties, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { properties, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// Sets User Properties, this will overwrite the original properties value
        /// </summary>
        /// <param name="properties">user properties</param>
        /// <param name="dateTime">date time</param>
        /// <param name="appId">project ID (optional)</param>
        public static void UserSet(Dictionary<string, object> properties, DateTime dateTime, string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.UserSet(properties, dateTime, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { properties , dateTime, appId};
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// Unsets one of User Porperties, this would not create properties that have not been created in TE
        /// </summary>
        /// <param name="property">the user property name</param>
        /// <param name="appId">project ID (optional)</param>
        public static void UserUnset(string property, string appId = "")
        {
            List<string> properties = new List<string>();
            properties.Add(property);
            UserUnset(properties, appId);
        }


        /// <summary>
        /// Unsets some of User Porperties, this would not create properties that have not been created in TE
        /// </summary>
        /// <param name="properties">the user properties name</param>
        /// <param name="appId">project ID (optional)</param>
        public static void UserUnset(List<string> properties, string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.UserUnset(properties, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { properties, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }

        }

        /// <summary>
        /// Unsets some of User Porperties, this would not create properties that have not been created in TE
        /// </summary>
        /// <param name="properties">the user properties name</param>
        /// <param name="dateTime">date time</param>
        /// <param name="appId">project ID (optional)</param>
        public static void UserUnset(List<string> properties, DateTime dateTime, string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.UserUnset(properties, dateTime, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { properties, dateTime, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// Sets User Properties for Once. This message would be neglected, if such property had been set before
        /// </summary>
        /// <param name="properties">user properties</param>
        /// <param name="appId">project ID (optional)</param>
        public static void UserSetOnce(Dictionary<string, object> properties, string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.UserSetOnce(properties, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { properties, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }

        }

        public static void UserSetOnce(string properties, string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.UserSetOnce(properties, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { properties, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }

        }

        /// <summary>
        /// Sets User Properties for Once. The property would be neglected, if such property had been set before
        /// </summary>
        /// <param name="properties">user properties</param>
        /// <param name="dateTime">date time</param>
        /// <param name="appId">project ID (optional)</param>
        public static void UserSetOnce(Dictionary<string, object> properties, DateTime dateTime, string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.UserSetOnce(properties, dateTime, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { properties, dateTime,appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }

        }

        /// <summary>
        /// Accumulates the property. If the property has not been set, it would be given a value of 0 before computing. 
        /// </summary>
        /// <param name="property">the property name</param>
        /// <param name="value">value of the property</param>
        /// <param name="appId">project ID (optional)</param>
        public static void UserAdd(string property, object value, string appId = "")
        {
            Dictionary<string, object> properties = new Dictionary<string, object>()
            {
                { property, value }
            };
            UserAdd(properties, appId);
        }

        /// <summary>
        /// Accumulates the property. If the property has not been set, it would be given a value of 0 before computing. 
        /// </summary>
        /// <param name="properties">user properties</param>
        /// <param name="appId">project ID (optional)</param>
        public static void UserAdd(Dictionary<string, object> properties, string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.UserAdd(properties, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { properties, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        public static void UserAddStr(string properties, string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.UserAddStr(properties, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { properties, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// Accumulates the property, type of Number. If the property has not been set, it would be given a value of 0 before computing. 
        /// </summary>
        /// <param name="properties">user properties</param>
        /// <param name="dateTime">date time</param>
        /// <param name="appId">project ID (optional)</param>
        public static void UserAdd(Dictionary<string, object> properties, DateTime dateTime, string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.UserAdd(properties, dateTime, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { properties, dateTime, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// Appends the property, type of List.
        /// </summary>
        /// <param name="properties">user properties</param>
        /// <param name="appId">project ID (optional)</param>
        public static void UserAppend(Dictionary<string, object> properties, string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.UserAppend(properties, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { properties, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        public static void UserAppend(string properties, string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.UserAppend(properties, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { properties, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// Appends the property, type of List.
        /// </summary>
        /// <param name="properties">user properties</param>
        /// <param name="dateTime">date time</param>
        /// <param name="appId">project ID (optional)</param>
        public static void UserAppend(Dictionary<string, object> properties, DateTime dateTime, string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.UserAppend(properties, dateTime, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { properties, dateTime, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// Appends the property Uniquely, type of List. If the property has been set, it would be neglected
        /// </summary>
        /// <param name="properties">user properties</param>
        /// <param name="appId">project ID (optional)</param>
        public static void UserUniqAppend(Dictionary<string, object> properties, string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.UserUniqAppend(properties, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { properties, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        public static void UserUniqAppend(string properties, string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.UserUniqAppend(properties, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { properties, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// Appends the property Uniquely, type of List. If the property has been set, it would be neglected
        /// </summary>
        /// <param name="properties">user prpoerties</param>
        /// <param name="dateTime">date time</param>
        /// <param name="appId">project ID (optional)</param>
        public static void UserUniqAppend(Dictionary<string, object> properties, DateTime dateTime, string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.UserUniqAppend(properties, dateTime, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { properties, dateTime, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// Deletes All Properties for a user, the events triggered by the user are still exist
        /// </summary>
        /// <param name="appId">project ID (optional)</param>
        public static void UserDelete(string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.UserDelete(appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// Deletes All Properties for a user, the events triggered by the user are still exist
        /// </summary>
        /// <param name="dateTime">date time</param>
        /// <param name="appId">project ID (optional)</param>
        //public static void UserDelete(DateTime dateTime, string appId = "")
        //{
        //    if (tracking_enabled)
        //    {
        //        TDWrapper.UserDelete(dateTime, appId);
        //    }
        //    else
        //    {
        //        System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
        //        object[] parameters = new object[] { dateTime, appId };
        //        eventCaches.Add(new Dictionary<string, object>() {
        //            { "method", method},
        //            { "parameters", parameters}
        //        });
        //    }
        //}

        /// <summary>
        /// Sets Network Type for report date to TE
        /// </summary>
        /// <param name="networkType">network type, see TDNetworkType</param>
        /// <param name="appId">project ID (optional)</param>
        public static void SetNetworkType(TDNetworkType networkType, string appId =  "")
        {
            if (tracking_enabled)
            {
                TDWrapper.SetNetworkType(networkType);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { networkType, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// Gets TDAnalytics SDK version
        /// </summary>
        /// <returns>SDK version</returns>
        public static string GetSDKVersion()
        {
            return TDPublicConfig.LIB_VERSION;
        }

        /// <summary>
        /// Gets the device identifier.
        /// </summary>
        /// <returns>The device identifier.</returns>
        public static string GetDeviceId()
        {
            if (tracking_enabled)
            {
                return TDWrapper.GetDeviceId();
            } 
            return null;
        }

        /// <summary>
        /// Sets Data Report Status
        /// </summary>
        /// <param name="status">data report status, see TDTrackStatus</param>
        /// <param name="appId">project ID (optional)</param>
        public static void SetTrackStatus(TDTrackStatus status, string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.SetTrackStatus(status, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { status, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// Stops Report Event Data, and Clear Cache Data (include unreported event data, custom distinct ID, account ID, Super Properties)
        /// </summary>
        /// <param name="appId">project ID (optional)</param>
        [Obsolete("Method is deprecated, please use SetTrackStatus() instead.")]
        public static void OptOutTracking(string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.OptOutTracking(appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// Stops Report Event Data, and Clear Cache Data (include unreported event data, custom distinct ID, account ID, super properties), and Delete User
        /// </summary>
        /// <param name="appId">project ID (optional)</param>
        [Obsolete("Method is deprecated, please use SetTrackStatus() instead.")]
        public static void OptOutTrackingAndDeleteUser(string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.OptOutTrackingAndDeleteUser(appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// Resumes Report Event Data
        /// </summary>
        /// <param name="appId">project ID (optional)</param>
        [Obsolete("Method is deprecated, please use SetTrackStatus() instead.")]
        public static void OptInTracking(string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.OptInTracking(appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// Enable Report Event Data
        /// </summary>
        /// <param name="enabled">Whether to enable reported data</param>
        /// <param name="appId">project ID (optional)</param>
        [Obsolete("Method is deprecated, please use SetTrackStatus() instead.")]
        public static void EnableTracking(bool enabled, string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.EnableTracking(enabled, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { enabled, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// Creats Light Instance, it has same project ID to main instance, diffent distinct ID, account ID, super properties
        /// </summary>
        /// <param name="appId">project ID (optional)</param>
        /// <returns>light instance token </returns>
        public static string LightInstance(string appId = "") {
            if (tracking_enabled)
            {
                return TDWrapper.CreateLightInstance();
            }
            return null;
        }

        /// <summary>
        /// Calibrate Event Time, calibrated times are used for events after that
        /// If both CalibrateTime and CalibrateTimeWithNtp are called, the event time is based on the CalibrateTimeWithNtp result.
        /// </summary>
        /// <param name="timestamp">currnt Unix timestamp, units Ms </param>
        public static void CalibrateTime(long timestamp)
        {
            TDWrapper.CalibrateTime(timestamp);
        }

        /// <summary>
        /// Calibrate Event Time, calibrated times are used for events after that
        /// If NTP server is not returns in 3s, the time will not be re-calibrated
        /// If both CalibrateTime and CalibrateTimeWithNtp are called, the event time is based on the CalibrateTimeWithNtp result.
        /// </summary>
        /// <param name="ntpServer">NTP server, e.g 'time.asia.apple.com' </param>
        public static void CalibrateTimeWithNtp(string ntpServer)
        {
            TDWrapper.CalibrateTimeWithNtp(ntpServer);
        }

        /// <summary>
        /// Cross Platform
        /// Share TE account system info to other platforms
        /// </summary>
        /// <param name="shareType">type of platforms, see TDThirdPartyType</param>
        /// <param name="properties">properties of platforms</param>
        /// <param name="appId">project ID (optional)</param>
        public static void EnableThirdPartySharing(TDThirdPartyType shareType, Dictionary<string, object> properties = null, string appId = "")
        {
            if (tracking_enabled)
            {
                TDWrapper.EnableThirdPartySharing(shareType, properties, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { shareType };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// Gets the Local Country/Region Code
        /// the two-letter code defined in ISO 3166 for the country/region
        /// </summary>
        /// <returns>country/region code</returns>
        public static string GetLocalRegion()
        {
            return System.Globalization.RegionInfo.CurrentRegion.TwoLetterISORegionName;
        }

        /// <summary>
        /// Start Thinking Analytics SDK
        /// </summary>
        /// <param name="appId">project ID</param>
        /// <param name="serverUrl">project URL</param>
        public static void Init(string appId, string serverUrl)
        {
            TDConfig tDConfig = new TDConfig(appId, serverUrl);
            Init(tDConfig);
        }

        /// <summary>
        /// Start Thinking Analytics SDK
        /// </summary>
        /// <param name="config">project setting, see TDConfig</param>
        public static void Init(TDConfig config)
        {
            new GameObject("ThinkingData", typeof(TDAnalytics));
            TDConfig[] configs = new TDConfig[1];
            configs[0] = config;
            TDAnalytics.Init(configs);
        }

        /// <summary>
        /// Start Thinking Analytics SDK
        /// </summary>
        /// <param name="configs">projects setting, see TDConfig</param>
        public static void Init(TDConfig[] configs = null)
        {
            #if DISABLE_TA
            tracking_enabled = false;
            #else
            tracking_enabled = true;
            #endif

            if (tracking_enabled)
            {
                TDPublicConfig.GetPublicConfig();
                TDLog.EnableLog(sThinkingData.enableLog);
                TDWrapper.EnableLog(sThinkingData.enableLog);
                TDWrapper.SetVersionInfo(TDPublicConfig.LIB_VERSION);
                if (configs == null)
                {
                    configs = sThinkingData.configs;
                }
                try
                {
                    for (int i = 0; i < configs.Length; i++)
                    {
                        TDConfig config = configs[i];
                        if (!string.IsNullOrEmpty(config.appId))
                        {
                            config.appId = config.appId.Replace(" ", "");
                            TDWrapper.ShareInstance(config, sThinkingData);
                            TDWrapper.SetNetworkType(sThinkingData.networkType);
                            if (TDLog.GetEnable()) TDLog.i(string.Format("TDAnalytics SDK initialize success, AppId = {0}, ServerUrl = {1}, Mode = {2}, TimeZone = {3}, DeviceId = {4}, Lib = Unity, LibVersion = {5}{6}", config.appId, config.serverUrl, config.mode, config.timeZone, GetDeviceId(), GetSDKVersion(), (config.name != null ? (", Name = " + config.name) : "")));
                        }
                    }
                }
                catch (Exception ex)
                {
                    if(TDLog.GetEnable()) TDLog.i("ThinkingAnalytics start Error: " + ex.Message);
                }
            }

            FlushEventCaches();
        }

        #region internal
        private static void FlushEventCaches()
        {
            List<Dictionary<string, object>> tmpEventCaches = new List<Dictionary<string, object>>(eventCaches);
            eventCaches.Clear();
            foreach (Dictionary<string, object> eventCache in tmpEventCaches)
            {
                if (eventCache.ContainsKey("method") && eventCache.ContainsKey("parameters"))
                {
                    System.Reflection.MethodBase method = (System.Reflection.MethodBase)eventCache["method"];
                    object[] parameters = (object[])eventCache["parameters"];
                    method.Invoke(null, parameters);
                }
            }
        }

        private void Awake()
        {
            if (sThinkingData == null)
            {
                sThinkingData = this;
                DontDestroyOnLoad(gameObject);
            } 
            else
            {
                Destroy(gameObject);
                return;
            }

            if (this.startManually == false) 
            {
                TDAnalytics.Init();
            }
        }

        private void Start()
        {
        }

        private void OnApplicationQuit()
        {
            //Scene scene = SceneManager.GetActiveScene();
            //if (scene != null)
            //{
            //    OnSceneUnloaded(scene);
            //}
        }

        private static TDAnalytics sThinkingData;
        private static bool tracking_enabled = false;
        private static List<Dictionary<string, object>> eventCaches = new List<Dictionary<string, object>>();
        #endregion
    }

    /// <summary>
    /// SDK Configuration information class
    /// </summary>
    [System.Serializable]
    public class TDConfig
    {
        /// <summary>
        /// Project ID
        /// </summary>
        public string appId;
        /// <summary>
        /// Project URL
        /// </summary>
        public string serverUrl;
        /// <summary>
        /// SDK Mode
        /// </summary>
        public TDMode mode;
        /// <summary>
        /// TIme Zone Type
        /// </summary>
        public TDTimeZone timeZone;
        /// <summary>
        /// Time Zone ID
        /// </summary>
        public string timeZoneId;
        /// <summary>
        /// enable data encryption, default is false (iOS/Android only)
        /// </summary>
        internal bool enableEncrypt;
        /// <summary>
        /// secret key version (iOS/Android only)
        /// </summary>
        internal int encryptVersion;
        /// <summary>
        /// public secret key (iOS/Android only)
        /// </summary>
        internal string encryptPublicKey;
        internal string symType;
        internal string asymType;
        /// <summary>
        /// SSL Pinning mode, default is NONE (iOS/Android only)
        /// </summary>
        public TDSSLPinningMode pinningMode;
        /// <summary>
        /// allow invalid certificates, default is false (iOS/Android only)
        /// </summary>
        public bool allowInvalidCertificates;
        /// <summary>
        /// enable to verify domain name, default is true (iOS/Android only)
        /// </summary>
        public bool validatesDomainName;
        /// <summary>
        /// SDK instance name, to call SDK quickly
        /// </summary>
        public string name { set { if (!string.IsNullOrEmpty(value)) sName = value.Replace(" ", ""); } get { return sName; } } // instances name
        private string sName;

        public int reportingToTencentSdk;

        /// <summary>
        /// Construct TDConfig instance
        /// </summary>
        /// <param name="appId"> project ID</param>
        /// <param name="serverUrl"> project URL </param>
        public TDConfig(string appId, string serverUrl)
        {
            this.appId = appId.Replace(" ", "");
            this.serverUrl = serverUrl;
            this.mode = TDMode.Normal;
            this.timeZone = TDTimeZone.Local;
            this.timeZoneId = null;
            this.enableEncrypt = false;
            this.encryptPublicKey = null;
            this.encryptVersion = 0;
            this.symType = null;
            this.asymType = null;
            this.pinningMode = TDSSLPinningMode.NONE;
            this.allowInvalidCertificates = false;
            this.validatesDomainName = true;
        }

        public void EnableEncrypt(string publicKey, int version = 0, string symType = "", string asymType = "")
        {
            this.enableEncrypt = true;
            this.encryptVersion = version;
            this.encryptPublicKey = publicKey;
            this.symType = symType;
            this.asymType = asymType;
        }

        /// <summary>
        /// Get Time Zone Identify Code in SDK
        /// </summary>
        /// <returns> Time Zone ID </returns>
        public string getTimeZoneId()
        {
            switch (timeZone)
            {
                case TDTimeZone.UTC:
                    return "UTC";
                case TDTimeZone.Asia_Shanghai:
                    return "Asia/Shanghai";
                case TDTimeZone.Asia_Tokyo:
                    return "Asia/Tokyo";
                case TDTimeZone.America_Los_Angeles:
                    return "America/Los_Angeles";
                case TDTimeZone.America_New_York:
                    return "America/New_York";
                case TDTimeZone.Other:
                    return timeZoneId;
                default:
                    break;
            }
            return null;
        }
    }

}
