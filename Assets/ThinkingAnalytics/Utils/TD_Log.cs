using UnityEngine;

namespace ThinkingAnalytics.Utils
{
    public class TD_Log
    {
        private static bool enableLog;
        public static void EnableLog(bool enabled)
        {
            enableLog = enabled;
        }

        public static void d(string message)
        {
            if (enableLog)
            {
                Debug.Log("[ThinkingSDK Unity_PC_V"+ TD_PublicConfig.LIB_VERSION + "] " + message);
            }
        }

        public static void e(string message)
        {
            if (enableLog)
            {
                Debug.LogError("[ThinkingSDK Unity_PC_V"+ TD_PublicConfig.LIB_VERSION + "] " + message);
            }
        }

        public static void w(string message)
        {
            if (enableLog)
            {
                Debug.LogWarning("[ThinkingSDK Unity_PC_V"+ TD_PublicConfig.LIB_VERSION + "] " + message);
            }
        }
    }
}