using System;
using System.IO;
using ThinkingSDK.PC.Constant;
using ThinkingSDK.PC.Config;
using UnityEngine;

namespace ThinkingSDK.PC.Utils
{
    public class ThinkingSDKLogger
    {
        public ThinkingSDKLogger()
        {

        }
        public static void Print(string str)
        {
            if (ThinkingSDKPublicConfig.IsPrintLog())
            {
                Debug.Log("[ThinkingSDK Unity_PC_V"+ ThinkingSDKAppInfo.LibVersion() + "]");
                Debug.Log(str);
            }   
        }
    }
}
