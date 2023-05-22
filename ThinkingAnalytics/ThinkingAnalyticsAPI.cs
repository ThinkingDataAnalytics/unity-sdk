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
    SDK VERSION:2.6.0-beta.2
 */
#if !(UNITY_5_4_OR_NEWER)
#define DISABLE_TA
#warning "Your Unity version is not supported by us - ThinkingAnalyticsSDK disabled"
#endif

using System;
using System.Collections.Generic;
using ThinkingAnalytics.Utils;
using ThinkingAnalytics.Wrapper;
using UnityEngine;
using ThinkingAnalytics.TAException;
using UnityEngine.SceneManagement;

namespace ThinkingAnalytics
{
    [DisallowMultipleComponent]
    public class ThinkingAnalyticsAPI : MonoBehaviour
    {
        #region settings
        [System.Serializable]
        public struct Token
        {
            public string appid;
            public string serverUrl;
            public TAMode mode;
            public TATimeZone timeZone;
            public string timeZoneId;
            public bool enableEncrypt; // enable data encryption, default is false (iOS/Android only)
            public int encryptVersion; // secret key version (iOS/Android only)
            public string encryptPublicKey; // public secret key (iOS/Android only)
            public SSLPinningMode pinningMode; // SSL Pinning mode, default is NONE (iOS/Android only)
            public bool allowInvalidCertificates; // allow invalid certificates, default is false (iOS/Android only)
            public bool validatesDomainName; // enable to verify domain name, default is true (iOS/Android only)
            private string instanceName; // instances name

            public Token(string appId, string serverUrl, TAMode mode = TAMode.NORMAL, TATimeZone timeZone = TATimeZone.Local, string timeZoneId = null, string instanceName = null)
            {
                this.appid = appId.Replace(" ", "");
                this.serverUrl = serverUrl;
                this.mode = mode;
                this.timeZone = timeZone;
                this.timeZoneId = timeZoneId;
                this.enableEncrypt = false;
                this.encryptVersion = 0;
                this.encryptPublicKey = null;
                this.pinningMode = SSLPinningMode.NONE;
                this.allowInvalidCertificates = false;
                this.validatesDomainName = true;
                if (!string.IsNullOrEmpty(instanceName))
                {
                    instanceName = instanceName.Replace(" ", "");
                }
                this.instanceName = instanceName;
            }

            public string GetInstanceName()
            {
                return this.instanceName;
            }

            public string getTimeZoneId()
            {
                switch (timeZone)
                {
                    case TATimeZone.UTC:
                        return "UTC";
                    case TATimeZone.Asia_Shanghai:
                        return "Asia/Shanghai";
                    case TATimeZone.Asia_Tokyo:
                        return "Asia/Tokyo";
                    case TATimeZone.America_Los_Angeles:
                        return "America/Los_Angeles";
                    case TATimeZone.America_New_York:
                        return "America/New_York";
                    case TATimeZone.Other:
                        return timeZoneId;
                    default:
                        break;
                }
                return null;
            }
        }

        public enum TATimeZone
        {
            Local,
            UTC,
            Asia_Shanghai,
            Asia_Tokyo,
            America_Los_Angeles,
            America_New_York,
            Other = 100
        }

        public enum TAMode
        {
            NORMAL = 0,
            DEBUG = 1,
            DEBUG_ONLY = 2
        }

        public enum NetworkType
        {
            DEFAULT = 1,
            WIFI = 2,
            ALL = 3
        }

        [Header("Configuration")]
        [Tooltip("Enable Start SDK Manually")]
        public bool startManually = true;

        [Tooltip("Enable Log")]
        public bool enableLog = true;
        [Tooltip("Sets the Network Type")]
        public NetworkType networkType = NetworkType.DEFAULT;

        [Header("Project")]
        [Tooltip("Project Setting, APP ID is given when the project is created")]
        [HideInInspector]
        public Token[] tokens = new Token[1];

        #endregion

        /// <summary>
        /// Whether to enable logs
        /// </summary>
        /// <param name="enable">enable logs</param>
        public static void EnableLog(bool enable, string appId = "")
        {
            if (sThinkingAnalyticsAPI != null)
            {
                sThinkingAnalyticsAPI.enableLog = enable;
                TD_Log.EnableLog(enable);
                ThinkingAnalyticsWrapper.EnableLog(enable);
            }
        }
        /// <summary>
        /// Set custom distinct ID, to replace the distinct ID generated by the system 
        /// </summary>
        /// <param name="distinctId">distinct ID</param>
        /// <param name="appId">project ID (optional)</param>
        public static void Identify(string distinctId, string appId = "")
        {
            if (tracking_enabled)
            {
                ThinkingAnalyticsWrapper.Identify(distinctId, appId);
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
                return ThinkingAnalyticsWrapper.GetDistinctId(appId);
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
                ThinkingAnalyticsWrapper.Login(account, appId);
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
                ThinkingAnalyticsWrapper.Logout(appId);
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
        /// <param name="events">auto-tracking events</param>
        /// <param name="properties">properties for auto-tracking events (optional)</param>
        /// <param name="appId">project ID (optional)</param>
        public static void EnableAutoTrack(AUTO_TRACK_EVENTS events, Dictionary<string, object> properties = null, string appId = "")
        {
            if (tracking_enabled)
            {
                if (properties == null)
                {
                    properties = new Dictionary<string, object>();
                }
                ThinkingAnalyticsWrapper.EnableAutoTrack(events, properties, appId);
                if ((events & AUTO_TRACK_EVENTS.APP_CRASH) != 0 && !TD_PublicConfig.DisableCSharpException)
                {
                    ThinkingSDKExceptionHandler.RegisterTAExceptionHandler(properties);
                }
                if ((events & AUTO_TRACK_EVENTS.APP_SCENE_LOAD) != 0)
                {
                    SceneManager.sceneLoaded -= ThinkingAnalyticsAPI.OnSceneLoaded;
                    SceneManager.sceneLoaded += ThinkingAnalyticsAPI.OnSceneLoaded;
                }
                if ((events & AUTO_TRACK_EVENTS.APP_SCENE_UNLOAD) != 0)
                {
                    SceneManager.sceneUnloaded -= ThinkingAnalyticsAPI.OnSceneUnloaded;
                    SceneManager.sceneUnloaded += ThinkingAnalyticsAPI.OnSceneUnloaded;
                }
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { events, properties, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// Enable auto-tracking
        /// </summary>
        /// <param name="events">auto-tracking events</param>
        /// <param name="eventCallback">callback for auto-tracking events (optional)</param>
        /// <param name="appId">project ID (optional)</param>
        public static void EnableAutoTrack(AUTO_TRACK_EVENTS events, IAutoTrackEventCallback eventCallback, string appId = "")
        {
            if (tracking_enabled)
            {
                ThinkingAnalyticsWrapper.EnableAutoTrack(events, eventCallback, appId);
                if ((events & AUTO_TRACK_EVENTS.APP_CRASH) != 0 && !TD_PublicConfig.DisableCSharpException)
                {
                    ThinkingSDKExceptionHandler.RegisterTAExceptionHandler(eventCallback);
                }
                if ((events & AUTO_TRACK_EVENTS.APP_SCENE_LOAD) != 0)
                {
                    SceneManager.sceneLoaded -= ThinkingAnalyticsAPI.OnSceneLoaded;
                    SceneManager.sceneLoaded += ThinkingAnalyticsAPI.OnSceneLoaded;
                }
                if ((events & AUTO_TRACK_EVENTS.APP_SCENE_UNLOAD) != 0)
                {
                    SceneManager.sceneUnloaded -= ThinkingAnalyticsAPI.OnSceneUnloaded;
                    SceneManager.sceneUnloaded += ThinkingAnalyticsAPI.OnSceneUnloaded;
                }
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { events, eventCallback, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }

        }

        /// <summary>
        /// Set properties for auto-tracking events
        /// </summary>
        /// <param name="events">auto-tracking events</param>
        /// <param name="properties">properties for auto-tracking events</param>
        /// <param name="appId">project ID (optional)</param>
        public static void SetAutoTrackProperties(AUTO_TRACK_EVENTS events, Dictionary<string, object> properties, string appId = "")
        {
            if (tracking_enabled)
            {
                ThinkingAnalyticsWrapper.SetAutoTrackProperties(events, properties, appId);
                if ((events & AUTO_TRACK_EVENTS.APP_CRASH) != 0 && !TD_PublicConfig.DisableCSharpException)
                {
                    ThinkingSDKExceptionHandler.SetAutoTrackProperties(properties);
                }
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { events, properties, appId };
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
                ThinkingAnalyticsWrapper.Track(eventName, properties, appId);
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
        [Obsolete("Method is deprecated, please use Track(string eventName, Dictionary<string, object> properties, DateTime date, TimeZoneInfo timeZone, string appId = \"\") instead.")]
        public static void Track(string eventName, Dictionary<string, object> properties, DateTime date, string appId = "")
        {
            if (tracking_enabled)
            {
                ThinkingAnalyticsWrapper.Track(eventName, properties, date, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { eventName, properties, date, appId };
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
        /// <param name="timeZone">time zone for the event</param>
        /// <param name="appId">project ID (optional)</param>
        public static void Track(string eventName, Dictionary<string, object> properties, DateTime date, TimeZoneInfo timeZone, string appId = "")
        {
            if (tracking_enabled)
            {
                ThinkingAnalyticsWrapper.Track(eventName, properties, date, timeZone, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { eventName, properties, date, timeZone, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// Track a Special Event (First Event/Updatable Event/Overwritable Event)
        /// </summary>
        /// <param name="analyticsEvent">the special event</param>
        /// <param name="appId">project ID (optional)</param>
        public static void Track(ThinkingAnalyticsEvent analyticsEvent, string appId = "")
        {
            if (tracking_enabled)
            {
                ThinkingAnalyticsWrapper.Track(analyticsEvent, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { analyticsEvent, appId };
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
                ThinkingAnalyticsWrapper.QuickTrack(eventName, properties, appId);
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
                ThinkingAnalyticsWrapper.Flush(appId);
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
                ThinkingAnalyticsWrapper.TrackSceneLoad(scene);
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
                ThinkingAnalyticsWrapper.TrackSceneUnload(scene);
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
        public static void SetSuperProperties(Dictionary<string, object> superProperties, string appId = "")
        {
            if (tracking_enabled)
            {
                ThinkingAnalyticsWrapper.SetSuperProperties(superProperties, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { superProperties, appId };
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
                ThinkingAnalyticsWrapper.UnsetSuperProperty(property, appId);
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
                return ThinkingAnalyticsWrapper.GetSuperProperties(appId);
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
                ThinkingAnalyticsWrapper.ClearSuperProperty(appId);
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
                Dictionary<string, object> properties = ThinkingAnalyticsWrapper.GetPresetProperties(appId);
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
        public static void SetDynamicSuperProperties(IDynamicSuperProperties dynamicSuperProperties, string appId = "")
        {
            if (tracking_enabled)
            {
                ThinkingAnalyticsWrapper.SetDynamicSuperProperties(dynamicSuperProperties, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { dynamicSuperProperties, appId };
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
                ThinkingAnalyticsWrapper.TimeEvent(eventName, appId);
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
                ThinkingAnalyticsWrapper.UserSet(properties, appId);
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
                ThinkingAnalyticsWrapper.UserSet(properties, dateTime, appId);
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
                ThinkingAnalyticsWrapper.UserUnset(properties, appId);
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
                ThinkingAnalyticsWrapper.UserUnset(properties, dateTime, appId);
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
                ThinkingAnalyticsWrapper.UserSetOnce(properties, appId);
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
                ThinkingAnalyticsWrapper.UserSetOnce(properties, dateTime, appId);
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
                ThinkingAnalyticsWrapper.UserAdd(properties, appId);
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
                ThinkingAnalyticsWrapper.UserAdd(properties, dateTime, appId);
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
                ThinkingAnalyticsWrapper.UserAppend(properties, appId);
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
                ThinkingAnalyticsWrapper.UserAppend(properties, dateTime, appId);
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
                ThinkingAnalyticsWrapper.UserUniqAppend(properties, appId);
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
                ThinkingAnalyticsWrapper.UserUniqAppend(properties, dateTime, appId);
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
                ThinkingAnalyticsWrapper.UserDelete(appId);
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
        public static void UserDelete(DateTime dateTime, string appId = "")
        {
            if (tracking_enabled)
            {
                ThinkingAnalyticsWrapper.UserDelete(dateTime, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { dateTime, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// Sets Network Type for report date to TE
        /// </summary>
        /// <param name="networkType">network type, see NetworkType</param>
        /// <param name="appId">project ID (optional)</param>
        public static void SetNetworkType(NetworkType networkType, string appId =  "")
        {
            if (tracking_enabled)
            {
                ThinkingAnalyticsWrapper.SetNetworkType(networkType);
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
        /// Gets the device identifier.
        /// </summary>
        /// <returns>The device identifier.</returns>
        public static string GetDeviceId()
        {
            if (tracking_enabled)
            {
                return ThinkingAnalyticsWrapper.GetDeviceId();
            } 
            return null;
        }

        /// <summary>
        /// Sets Data Report Status
        /// </summary>
        /// <param name="status">data report status, see TA_TRACK_STATUS</param>
        /// <param name="appId">project ID (optional)</param>
        public static void SetTrackStatus(TA_TRACK_STATUS status, string appId = "")
        {
            if (tracking_enabled)
            {
                ThinkingAnalyticsWrapper.SetTrackStatus(status, appId);
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
                ThinkingAnalyticsWrapper.OptOutTracking(appId);
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
                ThinkingAnalyticsWrapper.OptOutTrackingAndDeleteUser(appId);
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
                ThinkingAnalyticsWrapper.OptInTracking(appId);
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
                ThinkingAnalyticsWrapper.EnableTracking(enabled, appId);
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
        public static string CreateLightInstance(string appId = "") {
            if (tracking_enabled)
            {
                return ThinkingAnalyticsWrapper.CreateLightInstance();
            }
            return null;
        }

        /// <summary>
        /// Calibrate Event Time, calibrated times are used for events after that
        /// </summary>
        /// <param name="timestamp">currnt Unix timestamp, units Ms </param>
        public static void CalibrateTime(long timestamp)
        {
            ThinkingAnalyticsWrapper.CalibrateTime(timestamp);
        }

        /// <summary>
        /// Calibrate Event Time, calibrated times are used for events after that
        /// If NTP server is not returns in 3s, the time will not be re-calibrated
        /// </summary>
        /// <param name="ntpServer">NTP server, e.g 'time.asia.apple.com' </param>
        public static void CalibrateTimeWithNtp(string ntpServer)
        {
            ThinkingAnalyticsWrapper.CalibrateTimeWithNtp(ntpServer);
        }

        /// <summary>
        /// Cross Platform
        /// Share TE account system info to other platforms
        /// </summary>
        /// <param name="shareType">type of platforms, see TAThirdPartyShareType</param>
        /// <param name="properties">properties of platforms</param>
        /// <param name="appId">project ID (optional)</param>
        public static void EnableThirdPartySharing(TAThirdPartyShareType shareType, Dictionary<string, object> properties = null, string appId = "")
        {
            if (tracking_enabled)
            {
                ThinkingAnalyticsWrapper.EnableThirdPartySharing(shareType, properties, appId);
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
        public static void StartThinkingAnalytics(string appId, string serverUrl)
        {
            ThinkingAnalyticsAPI.TAMode mode = ThinkingAnalyticsAPI.TAMode.NORMAL;
            ThinkingAnalyticsAPI.TATimeZone timeZone = ThinkingAnalyticsAPI.TATimeZone.Local;
            ThinkingAnalyticsAPI.Token token = new ThinkingAnalyticsAPI.Token(appId, serverUrl, mode, timeZone);
            ThinkingAnalyticsAPI.StartThinkingAnalytics(token);
        }

        /// <summary>
        /// Start Thinking Analytics SDK
        /// </summary>
        /// <param name="token">project setting, see ThinkingAnalyticsAPI.Token</param>
        public static void StartThinkingAnalytics(ThinkingAnalyticsAPI.Token token)
        {
            ThinkingAnalyticsAPI.Token[] tokens = new ThinkingAnalyticsAPI.Token[1];
            tokens[0] = token;
            ThinkingAnalyticsAPI.StartThinkingAnalytics(tokens);
        }

        /// <summary>
        /// Start Thinking Analytics SDK
        /// </summary>
        /// <param name="tokens">projects setting, see ThinkingAnalyticsAPI.Token</param>
        public static void StartThinkingAnalytics(Token[] tokens = null)
        {
            #if DISABLE_TA
            tracking_enabled = false;
            #else
            tracking_enabled = true;
            #endif

            if (tracking_enabled)
            {
                TD_PublicConfig.GetPublicConfig();
                TD_Log.EnableLog(sThinkingAnalyticsAPI.enableLog);
                ThinkingAnalyticsWrapper.EnableLog(sThinkingAnalyticsAPI.enableLog);
                ThinkingAnalyticsWrapper.SetVersionInfo(TD_PublicConfig.LIB_VERSION);
                if (tokens == null)
                {
                    tokens = sThinkingAnalyticsAPI.tokens;
                }
                try
                {
                    for (int i = 0; i < tokens.Length; i++)
                    {
                        Token token = tokens[i];
                        if (!string.IsNullOrEmpty(token.appid))
                        {
                            token.appid = token.appid.Replace(" ", "");
                            TD_Log.d("ThinkingAnalytics start with APPID: " + token.appid + ", SERVERURL: " + token.serverUrl + ", MODE: " + token.mode);
                            ThinkingAnalyticsWrapper.ShareInstance(token, sThinkingAnalyticsAPI);
                            ThinkingAnalyticsWrapper.SetNetworkType(sThinkingAnalyticsAPI.networkType);
                        }
                    }
                }
                catch (Exception ex)
                {
                    TD_Log.d("ThinkingAnalytics start Error: " + ex.Message);
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
            if (sThinkingAnalyticsAPI == null)
            {
                sThinkingAnalyticsAPI = this;
                DontDestroyOnLoad(gameObject);
            } 
            else
            {
                Destroy(gameObject);
                return;
            }

            if (this.startManually == false) 
            {
                ThinkingAnalyticsAPI.StartThinkingAnalytics();
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

        private static ThinkingAnalyticsAPI sThinkingAnalyticsAPI;
        private static bool tracking_enabled = false;
        private static List<Dictionary<string, object>> eventCaches = new List<Dictionary<string, object>>();
        #endregion
    }
}
