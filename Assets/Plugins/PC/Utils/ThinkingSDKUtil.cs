using System;
using System.Collections.Generic;
using ThinkingSDK.PC.Config;
using ThinkingSDK.PC.Constant;
using ThinkingSDK.PC.Storage;

namespace ThinkingSDK.PC.Utils
{
    public class ThinkingSDKUtil
    {
        public ThinkingSDKUtil()
        {

        }
        /*
         *判断是否为有效URL
         */
        public static bool IsValiadURL(string url)
        {
            return !(url == null || url.Length == 0 || !url.Contains("http") || !url.Contains("https"));
        }
        /*
         * 判断字符串是否为空
         */
        public static bool IsEmptyString(string str)
        {
            return (str == null || str.Length == 0);
        }
        public static Dictionary<string, object> DeviceInfo()
        {
            Dictionary<string, object> deviceInfo = new Dictionary<string, object>();
            deviceInfo[ThinkingSDKConstant.DEVICE_ID] = ThinkingSDKDeviceInfo.DeviceID();
            deviceInfo[ThinkingSDKConstant.LIB_VERSION] = ThinkingSDKAppInfo.LibVersion();
            //deviceInfo[ThinkingSDKConstant.CARRIER] = ThinkingSDKDeviceInfo.Carrier();
            deviceInfo[ThinkingSDKConstant.LIB] = ThinkingSDKAppInfo.LibName();
            deviceInfo[ThinkingSDKConstant.OS] = ThinkingSDKDeviceInfo.OS();
            deviceInfo[ThinkingSDKConstant.SCREEN_HEIGHT] = ThinkingSDKDeviceInfo.ScreenHeight();
            deviceInfo[ThinkingSDKConstant.SCREEN_WIDTH] = ThinkingSDKDeviceInfo.ScreenWidth();
            deviceInfo[ThinkingSDKConstant.MANUFACTURE] = ThinkingSDKDeviceInfo.Manufacture();
            deviceInfo[ThinkingSDKConstant.DEVICE_MODEL] = ThinkingSDKDeviceInfo.DeviceModel();
            deviceInfo[ThinkingSDKConstant.SYSTEM_LANGUAGE] = ThinkingSDKDeviceInfo.MachineLanguage();
            deviceInfo[ThinkingSDKConstant.OS_VERSION] = ThinkingSDKDeviceInfo.OSVersion();
            deviceInfo[ThinkingSDKConstant.APP_VERSION] = ThinkingSDKAppInfo.AppVersion();
            deviceInfo[ThinkingSDKConstant.NETWORK_TYPE] = ThinkingSDKDeviceInfo.NetworkType();
            deviceInfo[ThinkingSDKConstant.APP_BUNDLEID] = ThinkingSDKAppInfo.AppIdentifier();
            return deviceInfo;
        }
        //随机数持久化,作为访客ID的备选
        public static string RandomID(bool persistent = true)
        {
            string randomID = null;
            if (persistent)
            {
                randomID = (string)ThinkingSDKFile.GetData(ThinkingSDKConstant.RANDOM_ID, typeof(string));
            }
            if (string.IsNullOrEmpty(randomID))
            {
                randomID = System.Guid.NewGuid().ToString("N");
                if (persistent)
                {
                    ThinkingSDKFile.SaveData(ThinkingSDKConstant.RANDOM_ID, randomID);
                }
            }
            return randomID;
        }
        //获取时区偏移
        public static double ZoneOffset(DateTime dateTime, TimeZoneInfo timeZone)
        {
            bool success = true;
            TimeSpan timeSpan = new TimeSpan();
            try
            {
                timeSpan = timeZone.BaseUtcOffset;
            }
            catch (Exception e)
            {
                success = false;
                //ThinkingSDKLogger.Print("ZoneOffset: TimeSpan get failed : " + e.Message);
            }
            try
            {
                if (timeZone.IsDaylightSavingTime(dateTime))
                {
                    TimeSpan timeSpan1 = TimeSpan.FromHours(1);
                    timeSpan = timeSpan.Add(timeSpan1);
                }
            }
            catch (Exception e)
            {
                success = false;
                //ThinkingSDKLogger.Print("ZoneOffset: IsDaylightSavingTime get failed : " + e.Message);
            }
            if (success == false)
            {
                timeSpan = TimeZone.CurrentTimeZone.GetUtcOffset(dateTime);
            }
            return timeSpan.TotalHours;
        }
        //时间格式化
        public static string FormatDate(DateTime dateTime, TimeZoneInfo timeZone)
        {
            bool success = true;
            DateTime univDateTime = dateTime.ToUniversalTime();
            TimeSpan timeSpan = new TimeSpan();
            try
            {
                timeSpan = timeZone.BaseUtcOffset;
            }
            catch (Exception e)
            {
                success = false;
                //ThinkingSDKLogger.Print("FormatDate - TimeSpan get failed : " + e.Message);
            }
            try
            {
                if (timeZone.IsDaylightSavingTime(dateTime))
                {
                    TimeSpan timeSpan1 = TimeSpan.FromHours(1);
                    timeSpan = timeSpan.Add(timeSpan1);
                }
            }
            catch (Exception e)
            {
                success = false;
                //ThinkingSDKLogger.Print("FormatDate: IsDaylightSavingTime get failed : " + e.Message);
            }
            if (success == false)
            {
                timeSpan = TimeZone.CurrentTimeZone.GetUtcOffset(dateTime);
            }
            DateTime dateNew = univDateTime + timeSpan;
            return string.Format(ThinkingSDKConstant.TIME_PATTERN, dateNew);
        }
        //向Dictionary添加Dictionary
        public static void AddDictionary(Dictionary<string, object> originalDic, Dictionary<string, object> subDic)
        {
            foreach (KeyValuePair<string, object> kv in subDic)
            {
                originalDic[kv.Key] = kv.Value;
            }
        }
    }
}
