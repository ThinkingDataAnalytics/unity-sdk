namespace ThinkingSDK.PC.Config
{
    public class ThinkingSDKPublicConfig
    {
        // Whether to print log
        bool isPrintLog;
        // sdk version
        string version = "1.0";
        // sdk name
        string name = "Unity";
        private  static readonly ThinkingSDKPublicConfig config = null;

        static ThinkingSDKPublicConfig()
        {
            config = new ThinkingSDKPublicConfig();
        }

        private static ThinkingSDKPublicConfig GetConfig()
        {
            return config;
        }
        public ThinkingSDKPublicConfig()
        {
            isPrintLog = false;
        }
        public static void SetIsPrintLog(bool isPrint)
        {
            GetConfig().isPrintLog = isPrint;
        }
        public static bool IsPrintLog()
        {
            return GetConfig().isPrintLog;
        }
        public static void SetVersion(string libVersion)
        {
            GetConfig().version = libVersion;
        }
        public static void SetName(string libName)
        {
            GetConfig().name = libName;
        }
        public static string Version()
        {
            return GetConfig().version;
        }
        public static string Name()
        {
            return GetConfig().name;
        }

    }
}
