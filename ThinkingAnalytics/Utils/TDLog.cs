using UnityEngine;

namespace ThinkingData.Analytics.Utils
{
    public class TDLog
    {
        private static bool enableLog;
        public static void EnableLog(bool enabled)
        {
            enableLog = enabled;
        }

        public static bool GetEnable()
        {
            return enableLog;
        }


        public static void i(string message)
        {
            if (enableLog)
            {
                Debug.Log("[ThinkingData] Info: " + message);
            }
        }

        public static void d(string message)
        {
            if (enableLog)
            {
                Debug.Log("[ThinkingData] Debug: " + message);
            }
        }

        public static void e(string message)
        {
            if (enableLog)
            {
                Debug.LogError("[ThinkingData] Error: " + message);
            }
        }

        public static void w(string message)
        {
            if (enableLog)
            {
                Debug.LogWarning("[ThinkingData] Warning: " + message);
            }
        }
    }
}