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
            return ThinkingSDKPublicConfig.Version() ;
        }
        //SDK名称
        public static string LibName()
        {
            return ThinkingSDKPublicConfig.Name();
        }
        //app版本号
        public static string AppVersion()
        {
            return Application.version;
        }
        //app唯一标识 包名
        public static string AppIdentifier()
        {
            return Application.identifier;
        }
     
    }
}