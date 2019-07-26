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
                Debug.Log(message);
            }
        }

        public static void e(string message)
        {
            if (enableLog)
            {
                Debug.LogError(message);
            }
        }

        public static void w(string message)
        {
            if (enableLog)
            {
                Debug.LogWarning(message);
            }
        }
    }
}