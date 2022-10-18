using System;
using ThinkingSDK.PC.Config;
using ThinkingSDK.PC.Constant;
using UnityEngine;

namespace ThinkingSDK.PC.Utils
{
    public class ThinkingSDKAppInfo
    {
        //SDK版本号
        public static string LibVersion()
        {
            if (ThinkingSDKUtil.DisPresetProperties.Contains(ThinkingSDKConstant.LIB_VERSION))
            {
                return "";
            }
            return ThinkingSDKPublicConfig.Version() ;
        }
        //SDK名称
        public static string LibName()
        {
            if (ThinkingSDKUtil.DisPresetProperties.Contains(ThinkingSDKConstant.LIB))
            {
                return "";
            }
            return ThinkingSDKPublicConfig.Name();
        }
        //app版本号
        public static string AppVersion()
        {
            if (ThinkingSDKUtil.DisPresetProperties.Contains(ThinkingSDKConstant.APP_VERSION))
            {
                return "";
            }
            return Application.version;
        }
        //app唯一标识 包名
        public static string AppIdentifier()
        {
            if (ThinkingSDKUtil.DisPresetProperties.Contains(ThinkingSDKConstant.APP_BUNDLEID))
            {
                return "";
            }
            return Application.identifier;
        }
     
    }
}