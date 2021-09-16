using System;
using System.Collections.Generic;
using ThinkingSDK.PC.Utils;
using ThinkingSDK.PC.Request;
using ThinkingSDK.PC.Constant;

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
        private int mUploadInterval = 60;
        private int mUploadSize = 100;
        private List<string> mDisableEvents = new List<string>();
        private static Dictionary<string, ThinkingSDKConfig> sInstances = new Dictionary<string, ThinkingSDKConfig>();
        private ThinkingSDKConfig(string token,string serverUrl)
        {
            //校验 server url
            serverUrl = this.VerifyUrl(serverUrl);
            this.mServerUrl = serverUrl;
            this.mNormalUrl = serverUrl + "/sync";
            this.mDebugUrl = serverUrl + "/data_debug";
            this.mConfigUrl = serverUrl + "/config";
            this.mToken = token;
            try
            {
                this.mTimeZone = TimeZoneInfo.Local;
            }
            catch (Exception e)
            {
                //ThinkingSDKLogger.Print("TimeZoneInfo initial failed :" + e.Message);
            }
        }
        private string VerifyUrl(string serverUrl)
        {
            Uri uri = new Uri(serverUrl);
            serverUrl = uri.Scheme + "://" + uri.Host + ":" + uri.Port;
            return serverUrl;
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
        public List<string> DisableEvents() {
            return this.mDisableEvents;
        }
        public bool IsDisabledEvent(string eventName) 
        {
            if (this.mDisableEvents == null)
            {
                return false;
            } 
            else 
            {
                return this.mDisableEvents.Contains(eventName);
            }
        }
        public void UpdateConfig()
        {
            Dictionary<string, object> dic = new Dictionary<string, object>();
            ResponseHandle responseHandle = delegate (Dictionary<string, object> result) {
                try
                {
                    int code = int.Parse(result["code"].ToString());
                    if (result!=null && code==0)
                    {
                        Dictionary<string, object> data = (Dictionary<string, object>)result["data"];
                        this.mUploadInterval = int.Parse(data["sync_interval"].ToString());
                        this.mUploadSize = int.Parse(data["sync_batch_size"].ToString());
                        foreach (var item in (List<object>)data["disable_event_list"])
                        {
                            this.mDisableEvents.Add((string)item);
                        }
                    }
                }
                catch (Exception ex)
                {
                    ThinkingSDKLogger.Print("Get config failed: " + ex.Message);
                }
            };
            ThinkingSDKBaseRequest.GetWithFORM(this.mConfigUrl,this.mToken,dic,responseHandle);            
        }
    }
}
