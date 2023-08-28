using UnityEngine;
using System;
using System.Xml;
using System.Collections.Generic;
using ThinkingSDK.PC.Config;
using ThinkingSDK.PC.Constant;
using ThinkingSDK.PC.Storage;

namespace ThinkingSDK.PC.Utils
{
    public class ThinkingSDKUtil
    {
        private static Dictionary<string, object> deviceInfo = null;
        public ThinkingSDKUtil()
        {

        }
        public static List<string> DisPresetProperties = ThinkingSDKUtil.GetDisPresetProperties();
        /*
         * Check if the URL is valid
         */
        public static bool IsValiadURL(string url)
        {
            return !(url == null || url.Length == 0 || !url.Contains("http") || !url.Contains("https"));
        }
        /*
         * Check if the string is empty
         */
        public static bool IsEmptyString(string str)
        {
            return (str == null || str.Length == 0);
        }
        public static Dictionary<string, object> DeviceInfo()
        {
            if (deviceInfo == null)
            {
                deviceInfo = new Dictionary<string, object>();
                deviceInfo[ThinkingSDKConstant.DEVICE_ID] = ThinkingSDKDeviceInfo.DeviceID();
                //deviceInfo[ThinkingSDKConstant.CARRIER] = ThinkingSDKDeviceInfo.Carrier(); //PC端不采集
                deviceInfo[ThinkingSDKConstant.OS] = ThinkingSDKDeviceInfo.OS();
                deviceInfo[ThinkingSDKConstant.OS_VERSION] = ThinkingSDKDeviceInfo.OSVersion();
                deviceInfo[ThinkingSDKConstant.SCREEN_HEIGHT] = ThinkingSDKDeviceInfo.ScreenHeight();
                deviceInfo[ThinkingSDKConstant.SCREEN_WIDTH] = ThinkingSDKDeviceInfo.ScreenWidth();
                deviceInfo[ThinkingSDKConstant.MANUFACTURE] = ThinkingSDKDeviceInfo.Manufacture();
                deviceInfo[ThinkingSDKConstant.DEVICE_MODEL] = ThinkingSDKDeviceInfo.DeviceModel();
                deviceInfo[ThinkingSDKConstant.APP_VERSION] = ThinkingSDKAppInfo.AppVersion();
                deviceInfo[ThinkingSDKConstant.APP_BUNDLEID] = ThinkingSDKAppInfo.AppIdentifier();
                deviceInfo[ThinkingSDKConstant.LIB] = ThinkingSDKAppInfo.LibName();
                deviceInfo[ThinkingSDKConstant.LIB_VERSION] = ThinkingSDKAppInfo.LibVersion();
            }
            deviceInfo[ThinkingSDKConstant.SYSTEM_LANGUAGE] = ThinkingSDKDeviceInfo.MachineLanguage();
            deviceInfo[ThinkingSDKConstant.NETWORK_TYPE] = ThinkingSDKDeviceInfo.NetworkType();
            return deviceInfo;
        }
        // Get disabled preset properties
        private static List<string> GetDisPresetProperties()
        {
            List<string> properties = new List<string>();
            
            TextAsset textAsset = Resources.Load<TextAsset>("ta_public_config"); 
            if (textAsset != null && textAsset.text != null)
            {
                XmlDocument xmlDoc = new XmlDocument();
                // xmlDoc.Load(srcPath);
                xmlDoc.LoadXml(textAsset.text);
                XmlNode root = xmlDoc.SelectSingleNode("resources");
                for (int i=0; i<root.ChildNodes.Count; i++)
                {
                    XmlNode x1 = root.ChildNodes[i];
                    if (x1.NodeType == XmlNodeType.Element)
                    {
                        XmlElement e1 = x1 as XmlElement;
                        if (e1.HasAttributes) 
                        {
                            string name = e1.GetAttribute("name");
                            if (name == "TDDisPresetProperties" && e1.HasChildNodes)
                            {
                                for (int j=0; j<e1.ChildNodes.Count; j++)
                                {
                                    XmlNode x2 = e1.ChildNodes[j];
                                    if (x2.NodeType == XmlNodeType.Element)
                                    {
                                        properties.Add(x2.InnerText);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            return properties;
        }

        // A persistent random number, used as an alternative to the distinct ID
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

        // Get time zone offset
        public static double ZoneOffset(DateTime dateTime, TimeZoneInfo timeZone)
        {
            bool success = true;
            TimeSpan timeSpan = new TimeSpan();
            try
            {
                timeSpan = timeZone.BaseUtcOffset;
            }
            catch (Exception)
            {
                success = false;
                //if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("ZoneOffset: TimeSpan get failed : " + e.Message);
            }
            try
            {
                if (timeZone.IsDaylightSavingTime(dateTime))
                {
                    TimeSpan timeSpan1 = TimeSpan.FromHours(1);
                    timeSpan = timeSpan.Add(timeSpan1);
                }
            }
            catch (Exception)
            {
                success = false;
                //if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("ZoneOffset: IsDaylightSavingTime get failed : " + e.Message);
            }
            if (success == false)
            {
                timeSpan = TimeZone.CurrentTimeZone.GetUtcOffset(dateTime);
            }
            return timeSpan.TotalHours;
        }
        // time formatting
        public static string FormatDate(DateTime dateTime, TimeZoneInfo timeZone)
        {
            bool success = true;
            DateTime univDateTime = dateTime.ToUniversalTime();
            TimeSpan timeSpan = new TimeSpan();
            try
            {
                timeSpan = timeZone.BaseUtcOffset;
            }
            catch (Exception)
            {
                success = false;
                //if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("FormatDate - TimeSpan get failed : " + e.Message);
            }
            try
            {
                if (timeZone.IsDaylightSavingTime(dateTime))
                {
                    TimeSpan timeSpan1 = TimeSpan.FromHours(1);
                    timeSpan = timeSpan.Add(timeSpan1);
                }
            }
            catch (Exception)
            {
                success = false;
                //if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("FormatDate: IsDaylightSavingTime get failed : " + e.Message);
            }
            if (success == false)
            {
                timeSpan = TimeZone.CurrentTimeZone.GetUtcOffset(dateTime);
            }
            DateTime dateNew = univDateTime + timeSpan;
            return dateNew.ToString("yyyy-MM-dd HH:mm:ss.fff", System.Globalization.CultureInfo.InvariantCulture);
        }
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
        //get timestamp
        public static long GetTimeStamp()
        {
            TimeSpan ts = DateTime.UtcNow - new DateTime(1970, 1, 1, 0, 0, 0, 0);
            return Convert.ToInt64(ts.TotalMilliseconds);
        }     
    }
}
