using System;
using System.Collections.Generic;
namespace ThinkingSDK.PC.Config
{
    public enum Mode
    {
        /* 正常模式，数据会存入缓存，并依据一定的缓存策略上报 */
        NORMAL,
        /* Debug 模式，数据逐条上报。当出现问题时会以日志和异常的方式提示用户 */
        DEBUG,
        /* Debug Only 模式，只对数据做校验，不会入库 */
        DEBUG_ONLY
    }
    public class ThinkingSDKConfig
    {
        private string mToken;
        private string mServerUrl;
        private string mNormalUrl;
        private string mDebugUrl;
        private string mConfigUrl;
        private Mode mMode = Mode.NORMAL;
        private TimeZoneInfo mTimeZone;
        private static Dictionary<string, ThinkingSDKConfig> sInstances = new Dictionary<string, ThinkingSDKConfig>();
        private ThinkingSDKConfig(string token,string serverUrl)
        {
            this.mServerUrl = serverUrl;
            this.mNormalUrl = serverUrl + "/sync";
            this.mDebugUrl = serverUrl + "/data_debug";
            this.mConfigUrl = serverUrl + "/config?appid=" + token;
            this.mToken = token;
            this.mTimeZone = TimeZoneInfo.Local;
           
        }
        public void SetMode(Mode mode)
        {
            this.mMode = mode;
        }
        public Mode GetMode()
        {
            return this.mMode;
        }
        public string DebugURL()
        {
            return this.mDebugUrl;
        }
        public string NormalURL()
        {
            return this.mNormalUrl;
        }
        public string ConfigURL()
        {
            return this.mConfigUrl;
        }
        public string Server()
        {
            return this.mServerUrl;
        }
        public static ThinkingSDKConfig GetInstance(string token, string server)
        {
            ThinkingSDKConfig config = null;
            if (sInstances.ContainsKey(token))
            {
                config = sInstances[token];
            }
            if (config == null)
            {
                config = new ThinkingSDKConfig(token,server);
                sInstances.Add(token, config);
            }
            return config;
        }
        public void SetTimeZone(TimeZoneInfo timeZoneInfo)
        {
            this.mTimeZone = timeZoneInfo;
        }
        public TimeZoneInfo TimeZone()
        {
            return this.mTimeZone;
        }
    }
}
