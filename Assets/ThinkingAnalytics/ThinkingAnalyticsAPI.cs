/*
    Thinkingdata Unitiy SDK v1.2.0
    
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
 */
#if !(UNITY_5_4_OR_NEWER)
#define DISABLE_TA
#warning "Your Unity version is not supported by us - ThinkingAnalyticsSDK disabled"
#endif

#if !(UNITY_EDITOR || UNITY_IOS || UNITY_ANDROID)
#define DISABLE_TA
#warning "Your Unity Platfrom is not supported by us - ThinkingAnalyticsSDK disabled"
#endif

using System;
using System.Collections.Generic;
using System.Threading;
using ThinkingAnalytics.Utils;
using ThinkingAnalytics.Wrapper;
using UnityEngine;

namespace ThinkingAnalytics
{
    /// <summary>
    /// Dynamic super properties interfaces.
    /// </summary>
    public interface IDynamicSuperProperties
    {
        Dictionary<string, object> GetDynamicSuperProperties();
    }

    public class ThinkingAnalyticsAPI : MonoBehaviour
    {
        #region settings
        [System.Serializable]
        public struct Token
        {
            public string appid;
            public bool autoTrack;

            public Token(string appId, bool autoTrackFlag)
            {
                appid = appId;
                autoTrack = autoTrackFlag;
            }
        }

        public enum NetworkType
        {
            DEFAULT = 1,
            WIFI = 2,
            ALL = 3
        }

        [Header("Configuration")]
        [Tooltip("是否打开 Log")]
        public bool enableLog = true;
        [Tooltip("设置网络类型")]
        public NetworkType networkType = NetworkType.DEFAULT;
        [Tooltip("推迟上报(主动调用 StartTrack() 之后才会上报)")]
        public bool postponeTrack = false;


        [Header("Project")]
        [Tooltip("服务端地址")]
        public string serverUrl = "https://server_url";
        [HideInInspector]
        [Tooltip("APP ID，会在项目申请时给出")]
        public Token[] tokens = new Token[1];

        #endregion


        /// <summary>
        /// 设置自定义访客 ID，用于替换系统生成的访客 ID
        /// </summary>
        /// <param name="uniqueId">访客 ID</param>
        /// <param name="appId">项目 ID(可选)</param>
        public static void Identify(string uniqueId, string appId = "")
        {
            if (tracking_enabled)
            {
                getInstance(appId).Identify(uniqueId);
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
                return getInstance(appId).GetDistinctId();
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
                getInstance(appId).Login(account);
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
                getInstance(appId).Logout();
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
                getInstance(appId).Flush();

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
                if (initComplete) {
                    getInstance(appId).Track(eventName, properties);
                } else {
                    _queue.Add(new Event(EVENT_TYPE.TRACK, appId, eventName, properties, DateTime.Now));
                }
            }
        }

        /// <summary>
        /// track 事件及事件属性，并指定 #event_time 属性. 该事件会先缓存在本地，达到触发上报条件或者主动调用 Flush 时会上报到服务器.
        /// </summary>
        /// <param name="eventName">事件名称</param>
        /// <param name="properties">事件属性</param>
        /// <param name="date">事件时间</param>
        /// <param name="appId">项目 ID(可选)</param>
        public static void Track(string eventName, Dictionary<string, object> properties, DateTime date, string appId = "")
        {
            if (tracking_enabled)
            {
                if (initComplete)
                {
                    getInstance(appId).Track(eventName, properties, date);
                } else
                {
                    _queue.Add(new Event(EVENT_TYPE.TRACK, appId, eventName, properties, date));
                }
            }
        }

        /// <summary>
        /// 设置公共事件属性. 公共事件属性指的就是每个事件都会带有的属性.
        /// </summary>
        /// <param name="superProperties">公共事件属性</param>
        /// <param name="appId">项目 ID(可选)</param>
        public static void SetSuperProperties(Dictionary<string, object> superProperties, string appId = "")
        {
            if (tracking_enabled)
            {
                getInstance(appId).SetSuperProperties(superProperties);
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
                getInstance(appId).UnsetSuperProperty(property);
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
                return getInstance(appId).GetSuperProperties();
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
                getInstance(appId).ClearSuperProperty();
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
                getInstance(appId).TimeEvent(eventName);
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
                if (initComplete)
                {
                    getInstance(appId).UserSet(properties);
                }
                else
                {
                    _queue.Add(new Event(EVENT_TYPE.USER_SET, appId, null, properties));
                }
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
                if (initComplete)
                {
                    getInstance(appId).UserSetOnce(properties);
                }
                else
                {
                    _queue.Add(new Event(EVENT_TYPE.USER_SET_ONCE, appId, null, properties));
                }
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
                foreach(KeyValuePair<string, object> kv in properties)
                {
                    if (!TD_PropertiesChecker.IsNumeric(kv.Value)) {
                        TD_Log.w("TA.API - userAdd allowed only numeric values. value invalid for: " + kv.Key);
                        return;
                    }
                }
                if (initComplete)
                {
                    getInstance(appId).UserAdd(properties);
                }
                else
                {
                    _queue.Add(new Event(EVENT_TYPE.USER_ADD, appId, null, properties));
                }
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
                if (initComplete)
                {
                    getInstance(appId).UserDelete();
                }
                else
                {
                    _queue.Add(new Event(EVENT_TYPE.USER_DEL, appId, null, null));
                }
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
                getInstance(appId).SetNetworkType(networkType);
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
                return getInstance("").GetDeviceId();
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
                getInstance(appId).SetDynamicSuperProperties(dynamicSuperProperties);
            }
        }

        /// <summary>
        /// Tracks the app install event.
        /// </summary>
        /// <param name="appId"> Optional APP ID.</param>
        public static void TrackAppInstall(string appId = "")
        {
            if (tracking_enabled)
            {
                getInstance(appId).TrackAppInstall();
            }
        }

        /// <summary>
        /// Make ThinkingAnalytics functional. If Post To Server Immediately is not checked, 
        /// All track and user set/add/delete operations will be cached until this function is called.
        /// </summary>
        public static void StartTrack()
        {
            if (initComplete) return;
            initComplete = true;
            foreach(Event eventData in _queue)
            {
                switch(eventData.type)
                {
                    case EVENT_TYPE.TRACK:
                        Track(eventData.eventName, eventData.properties, eventData.dateTime.Value, eventData.appId);
                        break;
                    case EVENT_TYPE.USER_SET:
                        UserSet(eventData.properties, eventData.appId);
                        break;
                    case EVENT_TYPE.USER_SET_ONCE:
                        UserSetOnce(eventData.properties, eventData.appId);
                        break;
                    case EVENT_TYPE.USER_ADD:
                        UserAdd(eventData.properties, eventData.appId);
                        break;
                    case EVENT_TYPE.USER_DEL:
                        UserDelete(eventData.appId);
                        break;
                }
            }
            _queue.Clear();
        }

        /// <summary>
        /// 停止上报数据，并且清空本地缓存数据(未上报的数据、已设置的访客ID、账号ID、公共属性)
        /// </summary>
        /// <param name="appId">项目ID</param>
        public static void OptOutTracking(string appId = "")
        {
            if (tracking_enabled)
            {
                getInstance(appId).OptOutTracking();
            }
        }

        /// <summary>
        /// 停止上报数据，清空本地缓存数据，并且发送 user_del 到服务端.
        /// </summary>
        /// <param name="appId">项目ID</param>
        public static void OptOutTrackingAndDeleteUser(string appId = "")
        {
            if (tracking_enabled)
            {
                getInstance(appId).OptOutTrackingAndDeleteUser();
            }
        }

        /// <summary>
        /// 恢复上报数据
        /// </summary>
        /// <param name="appId">项目ID</param>
        public static void OptInTracking(string appId = "")
        {
            if (tracking_enabled)
            {
                getInstance(appId).OptInTracking();
            }
        }

        /// <summary>
        /// 暂停/恢复上报数据，本地缓存不会被清空
        /// </summary>
        /// <param name="enabled">是否打开上报数据</param>
        /// <param name="appId">项目ID</param>
        public static void EnableTracking(bool enabled, string appId = "")
        {
            if (tracking_enabled)
            {
                getInstance(appId).EnableTracking(enabled);
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
                ThinkingAnalyticsWrapper lightInstance = getInstance(appId).CreateLightInstance();
                instance_lock.EnterWriteLock();
                try
                {
                    sInstances.Add(lightInstance.GetAppId(), lightInstance);
                } finally
                {
                    instance_lock.ExitWriteLock();
                }
                return lightInstance.GetAppId();
            }
            else
            {
                return null;
            }
        }

        #region internal

        void Awake()
        {
            #if DISABLE_TA
            tracking_enabled = false;
            #endif
            TD_Log.EnableLog(enableLog);
            if (TA_instance == null)
            {
                DontDestroyOnLoad(gameObject);
                TA_instance = this;
            } else
            {
                Destroy(gameObject);
                return;
            }

            if (tracking_enabled)
            {
                default_appid = tokens[0].appid;
                instance_lock.EnterWriteLock();
                try
                {
                    foreach (Token token in tokens)
                    {
                        if (!string.IsNullOrEmpty(token.appid))
                        {
                            sInstances.Add(token.appid, new ThinkingAnalyticsWrapper(token, serverUrl, enableLog));
                        }
                    }

                    initComplete = !postponeTrack;

                    if (sInstances.Count == 0)
                    {
                        tracking_enabled = false;
                    }
                    else
                    {
                        sInstances[default_appid].SetNetworkType(networkType);
                        if (!running)
                        {
                            running = true;
                            autoTrackStart();
                        }
                    }

                } finally
                {
                    instance_lock.ExitWriteLock();
                }

            }
        }

        void OnApplicationFocus(bool focus)
        {
            if (focus && !running)
            {
                running = true;
                autoTrackStart();
            } else if(!focus)
            {
                running = false;
                autoTrackEnd();
            }
        }

        private static ThinkingAnalyticsAPI TA_instance;
        private static string default_appid; // 如果用户调用接口时不指定项目 ID，默认使用第一个项目 ID
        private static bool tracking_enabled = true;
        private static bool running = false; // 是否在游戏中（Application focused）
        private static ReaderWriterLockSlim instance_lock = new ReaderWriterLockSlim(LockRecursionPolicy.SupportsRecursion);
        private static readonly Dictionary<string, ThinkingAnalyticsWrapper> sInstances = 
            new Dictionary<string, ThinkingAnalyticsWrapper>();

        private static ThinkingAnalyticsWrapper getInstance(string appid)
        {
            instance_lock.EnterReadLock();
            try
            {
                if (sInstances.Count > 0 && sInstances.ContainsKey(appid))
                {
                    return sInstances[appid];
                }
                return sInstances[default_appid];
            } finally
            {
                instance_lock.ExitReadLock();
            }
        }

        private static void autoTrackEnd()
        {
            instance_lock.EnterReadLock();
            try
            {
                foreach (ThinkingAnalyticsWrapper instance in sInstances.Values)
                {
                    if (instance.token.autoTrack)
                    {
                        Track("ta_app_end", instance.token.appid);
                    }
                    instance.Flush();
                }
            } finally
            {
                instance_lock.ExitReadLock();
            }

        }
        private static void autoTrackStart()
        {
            instance_lock.EnterReadLock();
            try
            {
                foreach (ThinkingAnalyticsWrapper instance in sInstances.Values)
                {
                    if (instance.token.autoTrack)
                    {
                        Track("ta_app_start", instance.token.appid);
                        instance.TimeEvent("ta_app_end");
                    }
                }
            } finally
            {
                instance_lock.ExitReadLock();
            }

        }

        private static bool initComplete = false;
        private enum EVENT_TYPE 
        { 
            TRACK,
            USER_SET,
            USER_SET_ONCE,
            USER_ADD,
            USER_DEL
        }

        private struct Event 
        {
            public EVENT_TYPE type;
            public string appId;
            public string eventName;
            public Dictionary<string, object> properties;
            public DateTime? dateTime;

            public Event(EVENT_TYPE type, string appId, string eventName, Dictionary<string, object> properties, DateTime? dateTime = null)
            {
                this.type = type;
                this.appId = appId;
                this.eventName = eventName;
                this.properties = properties;
                this.dateTime = dateTime;
            }
        }

        private static List<Event> _queue = new List<Event>();

        #endregion
    }
}
