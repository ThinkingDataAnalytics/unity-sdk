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
    SDK VERSION:2.5.1
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
            public bool enableEncrypt; // 开启加密传输，默认false（仅支持iOS/Android）
            public int encryptVersion; // 密钥版本号（仅支持iOS/Android）
            public string encryptPublicKey; // 加密公钥（仅支持iOS/Android）
            public SSLPinningMode pinningMode; // SSL证书验证模式，默认NONE（仅支持iOS/Android）
            public bool allowInvalidCertificates; // 是否允许自建证书或者过期SSL证书，默认false（仅支持iOS/Android）
            public bool validatesDomainName; // 是否验证证书域名，默认true（仅支持iOS/Android）
            private string instanceName; // 实例名

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
        [Tooltip("是否手动初始化SDK")]
        public bool startManually = true;

        [Tooltip("是否打开 Log")]
        public bool enableLog = true;
        [Tooltip("设置网络类型")]
        public NetworkType networkType = NetworkType.DEFAULT;

        [Header("Project")]
        [Tooltip("项目相关配置, APP ID 会在项目申请时给出")]
        [HideInInspector]
        public Token[] tokens = new Token[1];

        #endregion

        /// <summary>
        /// 是否打开日志log
        /// </summary>
        /// <param name="enable">允许打印日志</param>
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
        /// 设置自定义访客 ID，用于替换系统生成的访客 ID
        /// </summary>
        /// <param name="firstId">访客 ID</param>
        /// <param name="appId">项目 ID(可选)</param>
        public static void Identify(string firstId, string appId = "")
        {
            if (tracking_enabled)
            {
                ThinkingAnalyticsWrapper.Identify(firstId, appId);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { firstId, appId };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// 返回当前的访客 ID.
        /// </summary>
        /// <returns>访客 ID</returns>
        /// <param name="appId">项目 ID(可选)</param>
        public static string GetDistinctId(string appId = "")
        {
            if (tracking_enabled)
            {
                return ThinkingAnalyticsWrapper.GetDistinctId(appId);
            }
            return null;
        }

        /// <summary>
        /// 设置账号 ID. 该方法不会上传用户登录事件.
        /// </summary>
        /// <param name="account">账号 ID</param>
        /// <param name="appId">项目 ID(可选)</param>
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
        /// 清空账号 ID. 该方法不会上传用户登出事件.
        /// </summary>
        /// <param name="appId">项目 ID(可选) </param>
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
        /// 开启自动采集功能.
        /// </summary>
        /// <param name="events">自动采集事件</param>
        /// <param name="properties">自动采集事件扩展属性(可选)</param>
        /// <param name="appId">项目 ID(可选)</param>
        public static void EnableAutoTrack(AUTO_TRACK_EVENTS events, Dictionary<string, object> properties = null, string appId = "")
        {
            if (tracking_enabled)
            {
                if (properties == null)
                {
                    properties = new Dictionary<string, object>();
                }
                ThinkingAnalyticsWrapper.EnableAutoTrack(events, properties, appId);
                // C#异常捕获提前，包含所有端
                if ((events & AUTO_TRACK_EVENTS.APP_CRASH) != 0 && !TD_PublicConfig.DisableCSharpException)
                {
                    ThinkingSDKExceptionHandler.RegisterTAExceptionHandler(properties);
                }
                if ((events & AUTO_TRACK_EVENTS.APP_SCENE_LOAD) != 0)
                {
                    SceneManager.sceneLoaded += ThinkingAnalyticsAPI.OnSceneLoaded;
                }
                if ((events & AUTO_TRACK_EVENTS.APP_SCENE_UNLOAD) != 0)
                {
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
        /// 开启自动采集功能.
        /// </summary>
        /// <param name="events">自动采集事件</param>
        /// <param name="eventCallback">自动采集事件回调，可动态设置扩展属性(可选)</param>
        /// <param name="appId">项目 ID(可选)</param>
        public static void EnableAutoTrack(AUTO_TRACK_EVENTS events, IAutoTrackEventCallback eventCallback, string appId = "")
        {
            if (tracking_enabled)
            {
                ThinkingAnalyticsWrapper.EnableAutoTrack(events, eventCallback, appId);
                // C#异常捕获提前，包含所有端
                if ((events & AUTO_TRACK_EVENTS.APP_CRASH) != 0 && !TD_PublicConfig.DisableCSharpException)
                {
                    ThinkingSDKExceptionHandler.RegisterTAExceptionHandler(eventCallback);
                }
                if ((events & AUTO_TRACK_EVENTS.APP_SCENE_LOAD) != 0)
                {
                    SceneManager.sceneLoaded += ThinkingAnalyticsAPI.OnSceneLoaded;
                }
                if ((events & AUTO_TRACK_EVENTS.APP_SCENE_UNLOAD) != 0)
                {
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
        /// 设置自动采集扩展属性.
        /// </summary>
        /// <param name="events">自动采集事件</param>
        /// <param name="properties">自动采集事件扩展属性</param>
        /// <param name="appId">项目 ID(可选)</param>
        public static void SetAutoTrackProperties(AUTO_TRACK_EVENTS events, Dictionary<string, object> properties, string appId = "")
        {
            if (tracking_enabled)
            {
                ThinkingAnalyticsWrapper.SetAutoTrackProperties(events, properties, appId);
                // C#异常捕获提前，包含所有端
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
        /// track 简单事件. 该事件会先缓存在本地，达到触发上报条件或者主动调用 Flush 时会上报到服务器.
        /// </summary>
        /// <param name="eventName">事件名称</param>
        /// <param name="appId">项目 ID(可选)</param>
        public static void Track(string eventName, string appId = "")
        {
            Track(eventName, null, appId);
        }

        /// <summary>
        /// track 事件及事件属性. 该事件会先缓存在本地，达到触发上报条件或者主动调用 Flush 时会上报到服务器.
        /// </summary>
        /// <param name="eventName">事件名称</param>
        /// <param name="properties">Properties</param>
        /// <param name="appId">项目 ID(可选)</param>
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
        /// track 事件及事件属性，并指定 #event_time 属性. 该事件会先缓存在本地，达到触发上报条件或者主动调用 Flush 时会上报到服务器.
        /// 从 v1.3.0 开始，会考虑 date 的时区信息。支持 UTC 和 local 时区.
        /// </summary>
        /// <param name="eventName">事件名称</param>
        /// <param name="properties">事件属性</param>
        /// <param name="date">事件时间</param>
        /// <param name="appId">项目 ID(可选)</param>
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
        /// track 事件及事件属性，并指定 #event_time #zone_offset 属性. 该事件会先缓存在本地，达到触发上报条件或者主动调用 Flush 时会上报到服务器.
        /// </summary>
        /// <param name="eventName">事件名称</param>
        /// <param name="properties">事件属性</param>
        /// <param name="date">事件时间</param>
        /// <param name="timeZone">事件时区</param>
        /// <param name="appId">项目 ID(可选)</param>
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
        /// track 事件及事件属性，并指定 #event_time #zone_offset 属性. 该事件会先缓存在本地，达到触发上报条件或者主动调用 Flush 时会上报到服务器.
        /// </summary>
        /// <param name="eventName">事件名称</param>
        /// <param name="properties">事件属性</param>
        /// <param name="date">事件时间</param>
        /// <param name="timeZone">事件时区</param>
        private static void TrackForAll(string eventName, Dictionary<string, object> properties, DateTime date, TimeZoneInfo timeZone)
        {
            if (tracking_enabled)
            {
                ThinkingAnalyticsWrapper.TrackForAll(eventName, properties, date, timeZone);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { eventName, properties, date, timeZone };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// track 特殊事件，如首次事件、可更新事件、可重写事件
        /// </summary>
        /// <param name="analyticsEvent">特殊事件对象</param>
        /// <param name="appId">项目 ID(可选)</param>
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
        /// 主动触发上报缓存事件到服务器. 
        /// </summary>
        /// <param name="appId">项目 ID(可选)</param>
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
        /// 注册场景加载监听
        /// </summary>
        /// <param name="scene">场景对象</param>
        /// <param name="mode">场景加载模式</param>
        public static void OnSceneLoaded(Scene scene, LoadSceneMode mode)
        {
            Dictionary<string, object> properties = new Dictionary<string, object>() {
                { "#scene_name", scene.name },
                { "#scene_path", scene.path }
            };
            TrackForAll("ta_scene_loaded", properties, DateTime.Now, null);
            TimeEventForAll("ta_scene_unloaded");
        }

        /// <summary>
        /// 注册场景卸载监听
        /// </summary>
        /// <param name="scene">场景对象</param>
        public static void OnSceneUnloaded(Scene scene)
        {
            Dictionary<string, object> properties = new Dictionary<string, object>() {
                { "#scene_name", scene.name },
                { "#scene_path", scene.path }
            };
            TrackForAll("ta_scene_unloaded", properties, DateTime.Now, null);
        }

        /// <summary>
        /// 设置公共事件属性. 公共事件属性指的就是每个事件都会带有的属性.
        /// </summary>
        /// <param name="superProperties">公共事件属性</param>
        /// <param name="appId">项目 ID（可选）</param>
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
        /// 删除某个公共事件属性.
        /// </summary>
        /// <param name="property">属性名称</param>
        /// <param name="appId">项目 ID(可选)</param>
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
        /// 返回当前公共事件属性.
        /// </summary>
        /// <returns>公共事件属性</returns>
        /// <param name="appId">项目 ID(可选)</param>
        public static Dictionary<string, object> GetSuperProperties(string appId = "")
        {
            if (tracking_enabled)
            {
                return ThinkingAnalyticsWrapper.GetSuperProperties(appId);
            }
            return null;
        }

        /// <summary>
        /// 清空公共事件属性.
        /// </summary>
        /// <param name="appId">项目 ID(可选)</param>
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
        /// 返回事件预置属性
        /// </summary>
        /// <returns>事件预置属性</returns>
        /// <param name="appId">项目 ID(可选)</param>
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
        /// Sets the dynamic super properties.
        /// </summary>
        /// <param name="dynamicSuperProperties">Dynamic super properties interface.</param>
        /// <param name="appId">App ID (optional).</param>
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
        /// 记录事件时长. 调用 TimeEvent 为某事件开始计时，当 track 传该事件时，SDK 会在在事件属性中加入 #duration 这一属性来表示事件时长，单位为秒.
        /// </summary>
        /// <param name="eventName">事件名称</param>
        /// <param name="appId">项目 ID(可选)</param>
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
        /// 记录事件时长. 调用 TimeEvent 为某事件开始计时，当 track 传该事件时，SDK 会在在事件属性中加入 #duration 这一属性来表示事件时长，单位为秒.
        /// </summary>
        /// <param name="eventName">事件名称</param>
        private static void TimeEventForAll(string eventName)
        {
            if (tracking_enabled)
            {
                ThinkingAnalyticsWrapper.TimeEventForAll(eventName);
            }
            else
            {
                System.Reflection.MethodBase method = System.Reflection.MethodBase.GetCurrentMethod();
                object[] parameters = new object[] { eventName };
                eventCaches.Add(new Dictionary<string, object>() {
                    { "method", method},
                    { "parameters", parameters}
                });
            }
        }

        /// <summary>
        /// 设置用户属性. 该接口上传的属性将会覆盖原有的属性值.
        /// </summary>
        /// <param name="properties">用户属性</param>
        /// <param name="appId">项目 ID(可选)</param>
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
        /// 设置用户属性. 该接口上传的属性将会覆盖原有的属性值.
        /// </summary>
        /// <param name="properties">用户属性</param>
        /// <param name="dateTime">用户属性设置的时间</param>
        /// <param name="appId">项目 ID(可选)</param>
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
        /// 重置一个用户属性.
        /// </summary>
        /// <param name="property">用户属性名称</param>
        /// <param name="appId">项目 ID(可选)</param>
        public static void UserUnset(string property, string appId = "")
        {
            List<string> properties = new List<string>();
            properties.Add(property);
            UserUnset(properties, appId);
        }


        /// <summary>
        /// 重置一组用户属性
        /// </summary>
        /// <param name="properties">用户属性列表</param>
        /// <param name="appId">项目 ID(可选)</param>
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
        /// 重置一组用户属性, 并指定操作时间
        /// </summary>
        /// <param name="properties">用户属性列表</param>
        /// <param name="dateTime">操作时间</param>
        /// <param name="appId">项目 ID(可选)</param>
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
        /// 设置用户属性. 当该属性之前已经有值的时候，将会忽略这条信息.
        /// </summary>
        /// <param name="properties">用户属性</param>
        /// <param name="appId">项目 ID(可选)</param>
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
        /// 设置用户属性. 当该属性之前已经有值的时候，将会忽略这条信息.
        /// </summary>
        /// <param name="properties">用户属性</param>
        /// <param name="dateTime">操作时间</param>
        /// <param name="appId">项目 ID(可选)</param>
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
        /// 对数值类用户属性进行累加. 如果该属性还未被设置，则会赋值 0 后再进行计算.
        /// </summary>
        /// <param name="property">属性名称</param>
        /// <param name="value">数值</param>
        /// <param name="appId">项目 ID(可选)</param>
        public static void UserAdd(string property, object value, string appId = "")
        {
            Dictionary<string, object> properties = new Dictionary<string, object>()
            {
                { property, value }
            };
            UserAdd(properties, appId);
        }

        /// <summary>
        /// 对数值类用户属性进行累加. 如果属性还未被设置，则会赋值 0 后再进行计算.
        /// </summary>
        /// <param name="properties">用户属性</param>
        /// <param name="appId">项目 ID(可选)</param>
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
        /// 对数值类用户属性进行累加. 如果属性还未被设置，则会赋值 0 后再进行计算.
        /// </summary>
        /// <param name="properties">用户属性</param>
        /// <param name="dateTime">操作时间</param>
        /// <param name="appId">项目 ID(可选)</param>
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
        /// 对 List 类型的用户属性进行追加.
        /// </summary>
        /// <param name="properties">用户属性</param>
        /// <param name="appId">项目 ID(可选)</param>
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
        /// 对 List 类型的用户属性进行追加.
        /// </summary>
        /// <param name="properties">用户属性</param>
        /// <param name="dateTime">操作时间</param>
        /// <param name="appId">项目 ID(可选)</param>
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
        /// 对 List 类型的用户属性进行去重追加.
        /// </summary>
        /// <param name="properties">用户属性</param>
        /// <param name="appId">项目 ID(可选)</param>
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
        /// 对 List 类型的用户属性进行去重追加.
        /// </summary>
        /// <param name="properties">用户属性</param>
        /// <param name="dateTime">操作时间</param>
        /// <param name="appId">项目 ID(可选)</param>
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
        /// 删除用户数据. 之后再查询该名用户的用户属性，但该用户产生的事件仍然可以被查询到
        /// </summary>
        /// <param name="appId">项目 ID(可选)</param>
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
        /// 删除用户数据并指定操作时间.
        /// </summary>
        /// <param name="appId">项目 ID(可选)</param>
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
        /// 设置允许上报数据到服务器的网络类型.
        /// </summary>
        /// <param name="networkType">网络类型</param>
        /// <param name="appId">项目 ID(可选)</param>
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
        /// 设置数据上报状态
        /// </summary>
        /// <param name="status">上报状态，详见 TA_TRACK_STATUS 定义</param>
        /// <param name="appId">项目ID</param>
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
        /// 停止上报数据，并且清空本地缓存数据(未上报的数据、已设置的访客ID、账号ID、公共属性)
        /// </summary>
        /// <param name="appId">项目ID</param>
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
        /// 停止上报数据，清空本地缓存数据，并且发送 user_del 到服务端.
        /// </summary>
        /// <param name="appId">项目ID</param>
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
        /// 恢复上报数据
        /// </summary>
        /// <param name="appId">项目ID</param>
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
        /// 暂停/恢复上报数据，本地缓存不会被清空
        /// </summary>
        /// <param name="enabled">是否打开上报数据</param>
        /// <param name="appId">项目ID</param>
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
        /// 创建轻量级实例，轻量级实例与主实例共享项目ID. 访客ID、账号ID、公共属性不共享
        /// </summary>
        /// <param name="appId">项目ID</param>
        /// <returns>轻量级实例的 token </returns>
        public static string CreateLightInstance(string appId = "") {
            if (tracking_enabled)
            {
                return ThinkingAnalyticsWrapper.CreateLightInstance();
            }
            return null;
        }

        /// <summary>
        /// 传入时间戳校准 SDK 时间.
        /// </summary>
        /// <param name="timestamp">当前 Unix timestamp, 单位 毫秒</param>
        public static void CalibrateTime(long timestamp)
        {
            ThinkingAnalyticsWrapper.CalibrateTime(timestamp);
        }

        /// <summary>
        /// 传入 NTP Server 地址校准 SDK 时间.
        /// 您可以根据您用户所在地传入访问速度较快的 NTP Server 地址, 例如 time.asia.apple.com
        /// SDK 默认情况下会等待 3 秒，去获取时间偏移数据，并用该偏移校准之后的数据.
        /// 如果在 3 秒内未因网络原因未获得正确的时间偏移，本次应用运行期间将不会再校准时间.
        /// </summary>
        /// <param name="timestamp">可用的 NTP 服务器地址</param>
        public static void CalibrateTimeWithNtp(string ntpServer)
        {
            ThinkingAnalyticsWrapper.CalibrateTimeWithNtp(ntpServer);
        }

        /// <summary>
        /// 三方数据共享
        /// 通过与三方系统共享TA账号体系，打通三方数据
        /// </summary>
        /// <param name="shareType">三方系统类型</param>
        /// <param name="properties">三方系统自定义属性（部分系统自定义属性的设置是覆盖式更新，所以需要将自定义属性传入TA SDK，此属性将会与TA账号体系一并传入三方系统）</param>
        /// <param name="appId">项目 ID</param>
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
        /// 获取当前国家/地区代码
        /// 在 ISO 3166 中定义的由两个字母组成的国家/地区代码
        /// </summary>
        /// <returns>国家/地区代码</returns>
        public static string GetLocalRegion()
        {
            return System.Globalization.RegionInfo.CurrentRegion.TwoLetterISORegionName;
        }

        /// <summary>
        /// 初始化 Thinking Analytics SDK
        /// </summary>
        /// <param name="appId">项目ID</param>
        /// <param name="serverUrl">项目URL</param>
        public static void StartThinkingAnalytics(string appId, string serverUrl)
        {
            ThinkingAnalyticsAPI.TAMode mode = ThinkingAnalyticsAPI.TAMode.NORMAL;
            ThinkingAnalyticsAPI.TATimeZone timeZone = ThinkingAnalyticsAPI.TATimeZone.Local;
            ThinkingAnalyticsAPI.Token token = new ThinkingAnalyticsAPI.Token(appId, serverUrl, mode, timeZone);
            ThinkingAnalyticsAPI.StartThinkingAnalytics(token);
        }

        /// <summary>
        /// 初始化 Thinking Analytics SDK
        /// </summary>
        /// <param name="token">项目配置，详情参见 ThinkingAnalyticsAPI.Token</param>
        public static void StartThinkingAnalytics(ThinkingAnalyticsAPI.Token token)
        {
            ThinkingAnalyticsAPI.Token[] tokens = new ThinkingAnalyticsAPI.Token[1];
            tokens[0] = token;
            ThinkingAnalyticsAPI.StartThinkingAnalytics(tokens);
        }

        /// <summary>
        /// 初始化 Thinking Analytics SDK
        /// </summary>
        /// <param name="token">多项目配置，详情参见 ThinkingAnalyticsAPI.Token</param>
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
                catch
                {
                }
            }

            //上报缓存事件
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
            Scene scene = SceneManager.GetActiveScene();
            if (scene != null)
            {
                OnSceneUnloaded(scene);
            }
        }

        private static ThinkingAnalyticsAPI sThinkingAnalyticsAPI;
        private static bool tracking_enabled = false;
        private static List<Dictionary<string, object>> eventCaches = new List<Dictionary<string, object>>();
        #endregion
    }
}
