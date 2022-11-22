﻿using System;
using ThinkingSDK.PC.Constant;
using ThinkingSDK.PC.Storage;
using UnityEngine;

namespace ThinkingSDK.PC.Utils
{
    public class ThinkingSDKDeviceInfo
    {
        //设备ID
        public static string DeviceID()
        {
            if (ThinkingSDKUtil.DisPresetProperties.Contains(ThinkingSDKConstant.DEVICE_ID))
            {
                return "";
            }
            #if (UNITY_WEBGL)
                return RandomDeviceID();
            #else
                return SystemInfo.deviceUniqueIdentifier;
            #endif
        }
        //随机数持久化,作为设备ID的备选(WebGL获取不到设备ID)
        private static string RandomDeviceID()
        {
            string randomID = (string)ThinkingSDKFile.GetData(ThinkingSDKConstant.RANDOM_DEVICE_ID, typeof(string));
            if (string.IsNullOrEmpty(randomID))
            {
                randomID = System.Guid.NewGuid().ToString("N");
                ThinkingSDKFile.SaveData(ThinkingSDKConstant.RANDOM_DEVICE_ID, randomID);
            }
            return randomID;
        }
        //网络类型
        public static string NetworkType()
        {
            if (ThinkingSDKUtil.DisPresetProperties.Contains(ThinkingSDKConstant.NETWORK_TYPE))
            {
                return "";
            }
            string networkType = "NULL";
            if (Application.internetReachability == NetworkReachability.ReachableViaCarrierDataNetwork)
            {
                networkType = "Mobile";
            }
            else if (Application.internetReachability == NetworkReachability.ReachableViaLocalAreaNetwork)
            {
                networkType = "LAN";
            }
            return networkType;
        }
        //移动网络运营商信息
        public static string Carrier()
        {
            if (ThinkingSDKUtil.DisPresetProperties.Contains(ThinkingSDKConstant.CARRIER))
            {
                return "";
            }
            return "NULL";
        }
        //os类型
        public static string OS()
        {
            if (ThinkingSDKUtil.DisPresetProperties.Contains(ThinkingSDKConstant.OS))
            {
                return "";
            }
            string os = "other";
            if (SystemInfo.operatingSystemFamily == OperatingSystemFamily.Linux)
            {
                os = "Linux";
            }
            else if (SystemInfo.operatingSystemFamily == OperatingSystemFamily.MacOSX)
            {
                os = "MacOSX";
            }
            else if (SystemInfo.operatingSystemFamily == OperatingSystemFamily.Windows)
            {
                os = "Windows";
            }
            return os;
        }
        //OS版本信息
        public static string OSVersion()
        {
            if (ThinkingSDKUtil.DisPresetProperties.Contains(ThinkingSDKConstant.OS_VERSION))
            {
                return "";
            }
            return SystemInfo.operatingSystem;
        }
        //屏幕宽度
        public static int ScreenWidth()
        {
            if (ThinkingSDKUtil.DisPresetProperties.Contains(ThinkingSDKConstant.SCREEN_WIDTH))
            {
                return 0;
            }
            return (int)(UnityEngine.Screen.currentResolution.width);
        }
        //屏幕高度
        public static int ScreenHeight()
        {
            if (ThinkingSDKUtil.DisPresetProperties.Contains(ThinkingSDKConstant.SCREEN_HEIGHT))
            {
                return 0;
            }
            return (int)(UnityEngine.Screen.currentResolution.height);
        }
        //显卡厂商名称
        public static string Manufacture()
        {
            if (ThinkingSDKUtil.DisPresetProperties.Contains(ThinkingSDKConstant.MANUFACTURE))
            {
                return "";
            }
            return SystemInfo.graphicsDeviceVendor;
        }
        //设备型号
        public static string DeviceModel()
        {
            if (ThinkingSDKUtil.DisPresetProperties.Contains(ThinkingSDKConstant.DEVICE_MODEL))
            {
                return "";
            }
            return SystemInfo.deviceModel;
        }
        //本机语言
        public static string MachineLanguage()
        {
            if (ThinkingSDKUtil.DisPresetProperties.Contains(ThinkingSDKConstant.SYSTEM_LANGUAGE))
            {
                return "";
            }
            switch (Application.systemLanguage)
            {
                case SystemLanguage.Afrikaans:
                    return "af";
                case SystemLanguage.Arabic:
                    return "ar";
                case SystemLanguage.Basque:
                    return "eu";
                case SystemLanguage.Belarusian:
                    return "be";
                case SystemLanguage.Bulgarian:
                    return "bg";
                case SystemLanguage.Catalan:
                    return "ca";
                case SystemLanguage.Chinese:
                    return "zh";
                case SystemLanguage.Czech:
                    return "cs";
                case SystemLanguage.Danish:
                    return "da";
                case SystemLanguage.Dutch:
                    return "nl";
                case SystemLanguage.English:
                    return "en";
                case SystemLanguage.Estonian:
                    return "et";
                case SystemLanguage.Faroese:
                    return "fo";
                case SystemLanguage.Finnish:
                    return "fu";
                case SystemLanguage.French:
                    return "fr";
                case SystemLanguage.German:
                    return "de";
                case SystemLanguage.Greek:
                    return "el";
                case SystemLanguage.Hebrew:
                    return "he";
                case SystemLanguage.Icelandic:
                    return "is";
                case SystemLanguage.Indonesian:
                    return "id";
                case SystemLanguage.Italian:
                    return "it";
                case SystemLanguage.Japanese:
                    return "ja";
                case SystemLanguage.Korean:
                    return "ko";
                case SystemLanguage.Latvian:
                    return "lv";
                case SystemLanguage.Lithuanian:
                    return "lt";
                case SystemLanguage.Norwegian:
                    return "nn";
                case SystemLanguage.Polish:
                    return "pl";
                case SystemLanguage.Portuguese:
                    return "pt";
                case SystemLanguage.Romanian:
                    return "ro";
                case SystemLanguage.Russian:
                    return "ru";
                case SystemLanguage.SerboCroatian:
                    return "sr";
                case SystemLanguage.Slovak:
                    return "sk";
                case SystemLanguage.Slovenian:
                    return "sl";
                case SystemLanguage.Spanish:
                    return "es";
                case SystemLanguage.Swedish:
                    return "sv";
                case SystemLanguage.Thai:
                    return "th";
                case SystemLanguage.Turkish:
                    return "tr";
                case SystemLanguage.Ukrainian:
                    return "uk";
                case SystemLanguage.Vietnamese:
                    return "vi";
                case SystemLanguage.ChineseSimplified:
                    return "zh";
                case SystemLanguage.ChineseTraditional:
                    return "zh";
                case SystemLanguage.Hungarian:
                    return "hu";
                case SystemLanguage.Unknown:
                    return "unknown";

            };
            return "";
        }
    }
}

