using System;
using System.Collections.Generic;
using ThinkingSDK.PC.Utils;
using ThinkingSDK.PC.Request;
using ThinkingSDK.PC.Constant;
using UnityEngine;
using System.Collections;

namespace ThinkingSDK.PC.Config
{
    public enum Mode
    {
        /* normal mode, the data will be stored in the cache and reported in batches */
        NORMAL,
        /* debug mode, the data will be reported one by one */
        DEBUG,
        /* debug only mode, only verify the data, and will not store it */
        DEBUG_ONLY
    }
    public class ThinkingSDKConfig
    {
        private string mToken;
        private string mServerUrl;
        private string mNormalUrl;
        private string mDebugUrl;
        private string mConfigUrl;
        private string mInstanceName;
        private Mode mMode = Mode.NORMAL;
        private TimeZoneInfo mTimeZone;
        public int mUploadInterval = 30;
        public int mUploadSize = 30;
        private List<string> mDisableEvents = new List<string>();
        private static Dictionary<string, ThinkingSDKConfig> sInstances = new Dictionary<string, ThinkingSDKConfig>();
        private ResponseHandle mCallback;
        private ThinkingSDKConfig(string token,string serverUrl, string instanceName)
        {
            //verify server url
            serverUrl = this.VerifyUrl(serverUrl);
            this.mServerUrl = serverUrl;
            this.mNormalUrl = serverUrl + "/sync";
            this.mDebugUrl = serverUrl + "/data_debug";
            this.mConfigUrl = serverUrl + "/config";
            this.mToken = token;
            this.mInstanceName = instanceName;
            try
            {
                this.mTimeZone = TimeZoneInfo.Local;
            }
            catch (Exception)
            {
                //if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("TimeZoneInfo initial failed :" + e.Message);
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
        public string InstanceName()
        {
            return this.mInstanceName;
        }
        public static ThinkingSDKConfig GetInstance(string token, string server, string instanceName)
        {
            ThinkingSDKConfig config = null;
            if (!string.IsNullOrEmpty(instanceName))
            {
                if (sInstances.ContainsKey(instanceName))
                {
                    config = sInstances[instanceName];
                }
                else
                {
                    config = new ThinkingSDKConfig(token, server, instanceName);
                    sInstances.Add(instanceName, config);
                }
            }
            else
            {
                if (sInstances.ContainsKey(token))
                {
                    config = sInstances[token];
                }
                else
                {
                    config = new ThinkingSDKConfig(token, server, null);
                    sInstances.Add(token, config);
                }
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
        public void UpdateConfig(MonoBehaviour mono, ResponseHandle callback = null)
        {
            mCallback = callback;
            mono.StartCoroutine(this.GetWithFORM(this.mConfigUrl,this.mToken,null, ConfigResponseHandle));
        }

        private void ConfigResponseHandle(Dictionary<string, object> result)
        {
            try
            {
                int code = int.Parse(result["code"].ToString());
                if (result != null && code == 0)
                {
                    Dictionary<string, object> data = (Dictionary<string, object>)result["data"];
                    if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("Get remote config success: " + ThinkingSDKJSON.Serialize(data));
                    foreach (KeyValuePair<string, object> kv in data)
                    {
                        if (kv.Key == "sync_interval")
                        {
                            this.mUploadInterval = int.Parse(kv.Value.ToString());
                        }
                        else if (kv.Key == "sync_batch_size")
                        {
                            this.mUploadSize = int.Parse(kv.Value.ToString());
                        }
                        else if (kv.Key == "disable_event_list")
                        {
                            foreach (var item in (List<object>)kv.Value)
                            {
                                this.mDisableEvents.Add((string)item);
                            }
                        }
                    }
                }
                else
                {
                    if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("Get remote config failed: " + ThinkingSDKJSON.Serialize(result));
                }
            }
            catch (Exception ex)
            {
                if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("Get remote config failed: " + ex.Message);
            }
            if (mCallback != null)
            {
                mCallback();
            }
        }

        private IEnumerator GetWithFORM (string url, string appId, Dictionary<string, object> param, ResponseHandle responseHandle) {
            yield return ThinkingSDKBaseRequest.GetWithFORM_2(this.mConfigUrl,this.mToken,param,responseHandle);
        }
    }
}
