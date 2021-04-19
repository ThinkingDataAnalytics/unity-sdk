using System;
using System.Collections;
using System.Collections.Generic;
using ThinkingSDK.PC.Config;
using ThinkingSDK.PC.Constant;
using ThinkingSDK.PC.DataModel;
using ThinkingSDK.PC.Storage;
using ThinkingSDK.PC.Time;
using ThinkingSDK.PC.Utils;
namespace ThinkingSDK.PC.Main
{
    public class ThinkingPCSDK
    {
        private ThinkingPCSDK()
        {

        }
        private static readonly Dictionary<string, ThinkingSDKInstance> Instances = new Dictionary<string, ThinkingSDKInstance>();
        private static string CurrentAppid;

        private static ThinkingSDKInstance GetInstance(string appid)
        {
            ThinkingSDKInstance instance;
            if (string.IsNullOrEmpty(appid))
            {
                //ThinkingSDKLogger.Print("current appid is " + CurrentAppid);
                instance = Instances[CurrentAppid];
            }
            else
            {
                instance = Instances[appid];
            }
            return instance;
        }

        public static ThinkingSDKInstance Init(string appid, string server, ThinkingSDKConfig config = null)
        {
            if (ThinkingSDKUtil.IsEmptyString(appid))
            {
                ThinkingSDKLogger.Print("appid is empty");
                return null;
            }
            ThinkingSDKInstance instance = null;
            if (Instances.ContainsKey(appid))
            {
               instance = Instances[appid];
            } 
            if (instance == null)
            {
                instance = new ThinkingSDKInstance(appid,server,config);
                if (string.IsNullOrEmpty(CurrentAppid))
                {
                    CurrentAppid = appid;
                }
                Instances[appid] = instance;
            }
            return instance;
        }
        /// <summary>
        /// 设置访客ID
        /// </summary>
        /// <param name="distinctID"></param>
        /// <param name="appid"></param>
        public static void Identifiy(string distinctID, string appid ="")
        {
            GetInstance(appid).Identifiy(distinctID);
        }

        /// <summary>
        /// 获取访客ID
        /// </summary>
        /// <param name="appid"></param>
        /// <returns></returns>
        public static string DistinctId(string appid = "")
        {
            return GetInstance(appid).DistinctId();
        }
        /// <summary>
        /// 设置账号ID
        /// </summary>
        /// <param name="accountID"></param>
        /// <param name="appid"></param>
        public static void Login(string accountID,string appid = "")
        {
            GetInstance(appid).Login(accountID);
        }
        /// <summary>
        /// 获取账号ID
        /// </summary>
        /// <param name="appid"></param>
        /// <returns></returns>
        public static string AccountID(string appid = "")
        {
            return GetInstance(appid).AccountID();
        }
        /// <summary>
        ///清空账号ID
        /// </summary>
        public static void Logout(string appid = "")
        {
            GetInstance(appid).Logout();
        }
        
        /// <summary>
        /// 设置自动采集事件
        /// </summary>
        /// <param name="events"></param>
        /// <param name="appid"></param>
        public static void EnableAutoTrack(AUTO_TRACK_EVENTS events,string appid = "")
        {
            GetInstance(appid).EnableAutoTrack(events);
        }

        public static void Track(string eventName,string appid = "")
        {
            GetInstance(appid).Track(eventName);
        }
        public static void Track(string eventName, Dictionary<string, object> properties, string appid = "")
        {
            GetInstance(appid).Track(eventName,properties);
        }
        public static void Track(string eventName, Dictionary<string, object> properties, DateTime date, string appid = "")
        {

            GetInstance(appid).Track(eventName, properties, date);
        }
        public static void Track(ThinkingSDKEventData analyticsEvent,string appid = "")
        {
            GetInstance(appid).Track(analyticsEvent);
        }

        public static void SetSuperProperties(Dictionary<string, object> superProperties,string appid = "")
        {
            GetInstance(appid).SetSuperProperties(superProperties);
        }
        public static void UnsetSuperProperty(string propertyKey, string appid = "")
        {
            GetInstance(appid).UnsetSuperProperty(propertyKey);
        }
        public static Dictionary<string, object> SuperProperties(string appid="")
        {
           return GetInstance(appid).SuperProperties();
        }
        
        public static void ClearSuperProperties(string appid= "")
        {
            GetInstance(appid).ClearSuperProperties();
        }

        public static void TimeEvent(string eventName,string appid="")
        {
            GetInstance(appid).TimeEvent(eventName);
        }
        public static void UserSet(Dictionary<string, object> properties, string appid = "")
        {
            GetInstance(appid).UserSet(properties);
        }
        public static void UserSet(Dictionary<string, object> properties, DateTime dateTime,string appid = "")
        {
            GetInstance(appid).UserSet(properties, dateTime);
        }
        public static void UserUnset(string propertyKey,string appid = "")
        {
            GetInstance(appid).UserUnset(propertyKey);
        }
        public static void UserUnset(string propertyKey, DateTime dateTime,string appid = "")
        {
            GetInstance(appid).UserUnset(propertyKey,dateTime);
        }
        public static void UserUnset(List<string> propertyKeys, string appid = "")
        {
            GetInstance(appid).UserUnset(propertyKeys);
        }
        public static void UserUnset(List<string> propertyKeys, DateTime dateTime, string appid = "")
        {
            GetInstance(appid).UserUnset(propertyKeys,dateTime);
        }
        public static void UserSetOnce(Dictionary<string, object> properties,string appid = "")
        {
            GetInstance(appid).UserSetOnce(properties);
        }
        public static void UserSetOnce(Dictionary<string, object> properties, DateTime dateTime, string appid = "")
        {
            GetInstance(appid).UserSetOnce(properties,dateTime);
        }
        public static void UserAdd(Dictionary<string, object> properties, string appid = "")
        {
            GetInstance(appid).UserAdd(properties);
        }
        public static void UserAdd(Dictionary<string, object> properties, DateTime dateTime, string appid = "")
        {
            GetInstance(appid).UserAdd(properties,dateTime);
        }
        public static void UserAppend(Dictionary<string, object> properties, string appid = "")
        {
            GetInstance(appid).UserAppend(properties);
        }
        public static void UserAppend(Dictionary<string, object> properties, DateTime dateTime, string appid = "")
        {
            GetInstance(appid).UserAppend(properties,dateTime);
        }
        public static void UserDelete(string appid="")
        {
            GetInstance(appid).UserDelete();
        }
        public static void UserDelete(DateTime dateTime,string appid = "")
        {
            GetInstance(appid).UserDelete(dateTime);
        }
        public static void SetDynamicSuperProperties(IDynamicSuperProperties dynamicSuperProperties, string appid = "")
        {
            GetInstance(appid).SetDynamicSuperProperties(dynamicSuperProperties);
        }
        /*
        停止或开启数据上报,默认是开启状态,设置为停止时还会清空本地的访客ID,账号ID,静态公共属性
        其中true表示可以上报数据,false表示停止数据上报
        **/
        public static void OptTracking(bool optTracking,string appid = "")
        {
            GetInstance(appid).OptTracking(optTracking);
        }
        //是否暂停数据上报,默认是正常上报状态,其中true表示可以上报数据,false表示暂停数据上报
        public static void EnableTracking(bool isEnable, string appid = "")
        {
            GetInstance(appid).EnableTracking(isEnable);
        }
        //停止数据上报
        public static void OptTrackingAndDeleteUser(string appid = "")
        {
            GetInstance(appid).OptTrackingAndDeleteUser();
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
        public static string TimeString(DateTime dateTime, string appid = "")
        {
            return GetInstance(appid).TimeString(dateTime);
        }
    }
}
