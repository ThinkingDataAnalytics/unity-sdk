using System;
using System.Collections;
using System.Collections.Generic;
using ThinkingSDK.PC.Config;
using ThinkingSDK.PC.Constant;
using ThinkingSDK.PC.DataModel;
using ThinkingSDK.PC.Storage;
using ThinkingSDK.PC.Time;
using ThinkingSDK.PC.Utils;
using UnityEngine;
namespace ThinkingSDK.PC.Main
{
    public class ThinkingPCSDK
    {
        private ThinkingPCSDK()
        {

        }
        private static readonly Dictionary<string, ThinkingSDKInstance> Instances = new Dictionary<string, ThinkingSDKInstance>();
        private static readonly Dictionary<string, ThinkingSDKInstance> LightInstances = new Dictionary<string, ThinkingSDKInstance>();
        private static string CurrentAppid;

        private static ThinkingSDKInstance GetInstance(string appId)
        {
            ThinkingSDKInstance instance = null;
            if (!string.IsNullOrEmpty(appId))
            {
                appId = appId.Replace(" ", "");
                if (LightInstances.ContainsKey(appId))
                {
                    instance = LightInstances[appId];
                }
                else if (Instances.ContainsKey(appId))
                {
                    instance = Instances[appId];
                }
            }
            if (instance == null)
            {
                instance = Instances[CurrentAppid];
            }
            return instance;
        }

        public static ThinkingSDKInstance CurrentInstance()
        {
            ThinkingSDKInstance instance = Instances[CurrentAppid];
            return instance;
        }

        public static ThinkingSDKInstance Init(string appId, string server, string instanceName, ThinkingSDKConfig config = null, MonoBehaviour mono = null)
        {
            if (ThinkingSDKUtil.IsEmptyString(appId))
            {
                ThinkingSDKLogger.Print("appId is empty");
                return null;
            }
            ThinkingSDKInstance instance = null;
            if (!string.IsNullOrEmpty(instanceName))
            {
                if (Instances.ContainsKey(instanceName))
                {
                    instance = Instances[instanceName];
                }
                else
                {
                    instance = new ThinkingSDKInstance(appId, server, instanceName, config, mono);
                    if (string.IsNullOrEmpty(CurrentAppid))
                    {
                        CurrentAppid = instanceName;
                    }
                    Instances[instanceName] = instance;
                }
            }
            else
            {
                if (Instances.ContainsKey(appId))
                {
                    instance = Instances[appId];
                }
                else
                {
                    instance = new ThinkingSDKInstance(appId, server, null, config, mono);
                    if (string.IsNullOrEmpty(CurrentAppid))
                    {
                        CurrentAppid = appId;
                    }
                    Instances[appId] = instance;
                }
            }
            return instance;
        }
        /// <summary>
        /// 设置访客ID
        /// </summary>
        /// <param name="distinctID"></param>
        /// <param name="appId"></param>
        public static void Identifiy(string distinctID, string appId = "")
        {
            GetInstance(appId).Identifiy(distinctID);
        }

        /// <summary>
        /// 获取访客ID
        /// </summary>
        /// <param name="appId"></param>
        /// <returns></returns>
        public static string DistinctId(string appId = "")
        {
            return GetInstance(appId).DistinctId();
        }
        /// <summary>
        /// 设置账号ID
        /// </summary>
        /// <param name="accountID"></param>
        /// <param name="appId"></param>
        public static void Login(string accountID,string appId = "")
        {
            GetInstance(appId).Login(accountID);
        }
        /// <summary>
        /// 获取账号ID
        /// </summary>
        /// <param name="appId"></param>
        /// <returns></returns>
        public static string AccountID(string appId = "")
        {
            return GetInstance(appId).AccountID();
        }
        /// <summary>
        ///清空账号ID
        /// </summary>
        public static void Logout(string appId = "")
        {
            GetInstance(appId).Logout();
        }

        /// <summary>
        /// 设置自动采集事件
        /// </summary>
        /// <param name="events"></param>
        /// <param name="appId"></param>
        public static void EnableAutoTrack(AUTO_TRACK_EVENTS events, Dictionary<string, object> properties, string appId = "")
        {
            GetInstance(appId).EnableAutoTrack(events, properties);
        }

        public static void EnableAutoTrack(AUTO_TRACK_EVENTS events, IAutoTrackEventCallback_PC eventCallback, string appId = "")
        {
            GetInstance(appId).EnableAutoTrack(events, eventCallback);
        }

        public static void SetAutoTrackProperties(AUTO_TRACK_EVENTS events, Dictionary<string, object> properties, string appId = "")
        {
            GetInstance(appId).SetAutoTrackProperties(events, properties);
        }

        public static void Track(string eventName,string appId = "")
        {
            GetInstance(appId).Track(eventName);
        }
        public static void Track(string eventName, Dictionary<string, object> properties, string appId = "")
        {
            GetInstance(appId).Track(eventName,properties);
        }
        public static void Track(string eventName, Dictionary<string, object> properties, DateTime date, string appId = "")
        {
            GetInstance(appId).Track(eventName, properties, date);
        }
        public static void Track(string eventName, Dictionary<string, object> properties, DateTime date, TimeZoneInfo timeZone, string appId = "")
        {
            GetInstance(appId).Track(eventName, properties, date, timeZone);
        }
        public static void TrackForAll(string eventName, Dictionary<string, object> properties, DateTime date, TimeZoneInfo timeZone)
        {
            foreach (string appId in Instances.Keys)
            {
                GetInstance(appId).Track(eventName, properties, date, timeZone);
            }
        }
        public static void Track(ThinkingSDKEventData analyticsEvent,string appId = "")
        {
            GetInstance(appId).Track(analyticsEvent);
        }

        public static void Flush (string appId = "")
        {
            GetInstance(appId).Flush();
        }
        public static void FlushImmediately (string appId = "")
        {
            GetInstance(appId).FlushImmediately();
        }
        public static void SetSuperProperties(Dictionary<string, object> superProperties,string appId = "")
        {
            GetInstance(appId).SetSuperProperties(superProperties);
        }
        public static void UnsetSuperProperty(string propertyKey, string appId = "")
        {
            GetInstance(appId).UnsetSuperProperty(propertyKey);
        }
        public static Dictionary<string, object> SuperProperties(string appId="")
        {
           return GetInstance(appId).SuperProperties();
        }
        
        public static Dictionary<string, object> PresetProperties(string appId="")
        {
            return GetInstance(appId).PresetProperties();
        }

        public static void ClearSuperProperties(string appId= "")
        {
            GetInstance(appId).ClearSuperProperties();
        }

        public static void TimeEvent(string eventName,string appId="")
        {
            GetInstance(appId).TimeEvent(eventName);
        }
        public static void TimeEventForAll(string eventName)
        {
            foreach (string appId in Instances.Keys)
            {
                GetInstance(appId).TimeEvent(eventName);
            }
        }
        /// <summary>
        /// 暂停事件的计时
        /// </summary>
        /// <param name="status">暂停状态，ture：暂停计时，false：取消暂停计时</param>
        /// <param name="eventName">事件名称，有值：暂停指定事件计时，无值：暂停全部事件计时</param>
        public static void PauseTimeEvent(bool status, string eventName = "", string appId = "")
        {
            GetInstance(appId).PauseTimeEvent(status, eventName);
        }
        public static void UserSet(Dictionary<string, object> properties, string appId = "")
        {
            GetInstance(appId).UserSet(properties);
        }
        public static void UserSet(Dictionary<string, object> properties, DateTime dateTime,string appId = "")
        {
            GetInstance(appId).UserSet(properties, dateTime);
        }
        public static void UserUnset(string propertyKey,string appId = "")
        {
            GetInstance(appId).UserUnset(propertyKey);
        }
        public static void UserUnset(string propertyKey, DateTime dateTime,string appId = "")
        {
            GetInstance(appId).UserUnset(propertyKey,dateTime);
        }
        public static void UserUnset(List<string> propertyKeys, string appId = "")
        {
            GetInstance(appId).UserUnset(propertyKeys);
        }
        public static void UserUnset(List<string> propertyKeys, DateTime dateTime, string appId = "")
        {
            GetInstance(appId).UserUnset(propertyKeys,dateTime);
        }
        public static void UserSetOnce(Dictionary<string, object> properties,string appId = "")
        {
            GetInstance(appId).UserSetOnce(properties);
        }
        public static void UserSetOnce(Dictionary<string, object> properties, DateTime dateTime, string appId = "")
        {
            GetInstance(appId).UserSetOnce(properties,dateTime);
        }
        public static void UserAdd(Dictionary<string, object> properties, string appId = "")
        {
            GetInstance(appId).UserAdd(properties);
        }
        public static void UserAdd(Dictionary<string, object> properties, DateTime dateTime, string appId = "")
        {
            GetInstance(appId).UserAdd(properties,dateTime);
        }
        public static void UserAppend(Dictionary<string, object> properties, string appId = "")
        {
            GetInstance(appId).UserAppend(properties);
        }
        public static void UserAppend(Dictionary<string, object> properties, DateTime dateTime, string appId = "")
        {
            GetInstance(appId).UserAppend(properties,dateTime);
        }
        public static void UserUniqAppend(Dictionary<string, object> properties, string appId = "")
        {
            GetInstance(appId).UserUniqAppend(properties);
        }
        public static void UserUniqAppend(Dictionary<string, object> properties, DateTime dateTime, string appId = "")
        {
            GetInstance(appId).UserUniqAppend(properties,dateTime);
        }
        public static void UserDelete(string appId="")
        {
            GetInstance(appId).UserDelete();
        }
        public static void UserDelete(DateTime dateTime,string appId = "")
        {
            GetInstance(appId).UserDelete(dateTime);
        }
        public static void SetDynamicSuperProperties(IDynamicSuperProperties_PC dynamicSuperProperties, string appId = "")
        {
            GetInstance(appId).SetDynamicSuperProperties(dynamicSuperProperties);
        }
        public static void SetTrackStatus(TA_TRACK_STATUS status, string appId = "")
        {
            GetInstance(appId).SetTrackStatus(status);
        }
        /*
        停止或开启数据上报,默认是开启状态,设置为停止时还会清空本地的访客ID,账号ID,静态公共属性
        其中true表示可以上报数据,false表示停止数据上报
        **/
        public static void OptTracking(bool optTracking,string appId = "")
        {
            GetInstance(appId).OptTracking(optTracking);
        }
        //是否暂停数据上报,默认是正常上报状态,其中true表示可以上报数据,false表示暂停数据上报
        public static void EnableTracking(bool isEnable, string appId = "")
        {
            GetInstance(appId).EnableTracking(isEnable);
        }
        //停止数据上报
        public static void OptTrackingAndDeleteUser(string appId = "")
        {
            GetInstance(appId).OptTrackingAndDeleteUser();
        }
        /// <summary>
        /// 创建轻实例
        /// </summary>
        /// <returns></returns>
        public static string CreateLightInstance()
        {
            string randomID = System.Guid.NewGuid().ToString("N");
            ThinkingSDKInstance lightInstance = ThinkingSDKInstance.CreateLightInstance();
            LightInstances[randomID] = lightInstance;
            return randomID;
        }
        /// <summary>
        /// 通过时间戳校准时间
        /// </summary>
        /// <param name="timestamp"></param>
        public static void CalibrateTime(long timestamp)
        {
            ThinkingSDKTimestampCalibration timestampCalibration = new ThinkingSDKTimestampCalibration(timestamp);
            foreach (KeyValuePair<string, ThinkingSDKInstance> kv in Instances)
            {
                kv.Value.SetTimeCalibratieton(timestampCalibration);
            }
        }
        /// <summary>
        /// 通过NTP服务器校准时间
        /// </summary>
        /// <param name="ntpServer"></param>
        public static void CalibrateTimeWithNtp(string ntpServer)
        {
            ThinkingSDKNTPCalibration ntpCalibration = new ThinkingSDKNTPCalibration(ntpServer);
            foreach (KeyValuePair<string, ThinkingSDKInstance> kv in Instances)
            {
                kv.Value.SetTimeCalibratieton(ntpCalibration);
            }
        }

        /// <summary>
        /// 获取设备ID
        /// </summary>
        /// <returns></returns>
        public static string GetDeviceId()
        {
            return ThinkingSDKDeviceInfo.DeviceID();
        }
        /// <summary>
        ///
        /// 是否打开客户端日志
        /// </summary>
        /// <param name="isEnable"></param>
        public static void EnableLog(bool isEnable)
        {
            ThinkingSDKPublicConfig.SetIsPrintLog(isEnable);
        }
        public static void SetLibName(string name)
        {
            ThinkingSDKPublicConfig.SetName(name);
        }
        public static void SetLibVersion(string versionCode)
        {
            ThinkingSDKPublicConfig.SetVersion(versionCode);
        }
        public static string TimeString(DateTime dateTime, string appId = "")
        {
            return GetInstance(appId).TimeString(dateTime);
        }
    }
}
