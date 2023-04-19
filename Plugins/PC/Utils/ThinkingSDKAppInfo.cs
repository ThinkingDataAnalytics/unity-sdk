using System;
using ThinkingSDK.PC.Config;
using ThinkingSDK.PC.Constant;
using UnityEngine;

namespace ThinkingSDK.PC.Utils
{
    public class ThinkingSDKAppInfo
    {
        // sdk version
        public static string LibVersion()
        {
            if (ThinkingSDKUtil.DisPresetProperties.Contains(ThinkingSDKConstant.LIB_VERSION))
            {
                return "";
            }
            return ThinkingSDKPublicConfig.Version() ;
        }
        // sdk name
        public static string LibName()
        {
            if (ThinkingSDKUtil.DisPresetProperties.Contains(ThinkingSDKConstant.LIB))
            {
                return "";
            }
            return ThinkingSDKPublicConfig.Name();
        }
        // app version
        public static string AppVersion()
        {
            if (ThinkingSDKUtil.DisPresetProperties.Contains(ThinkingSDKConstant.APP_VERSION))
            {
                return "";
            }
            return Application.version;
        }
        // app identifier, bundle ID
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