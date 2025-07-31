using System.Collections.Generic;
using ThinkingSDK.PC.Config;
using ThinkingSDK.PC.Constant;
using ThinkingSDK.PC.Utils;
using UnityEngine;
using UnityEngine.Networking;
using System.Collections;

namespace ThinkingSDK.PC.Request
{
    public class ThinkingSDKDebugRequest:ThinkingSDKBaseRequest
    {
        private int mDryRun = 0;
        private string mDeviceID = ThinkingSDKDeviceInfo.DeviceID();
        public void SetDryRun(int dryRun)
        {
            mDryRun = dryRun;
        }
        public ThinkingSDKDebugRequest(string appId, string url, string data):base(appId,url,data)
        {
            
        }
        public ThinkingSDKDebugRequest(string appId, string url) : base(appId, url)
        {
        }

        public override IEnumerator SendData_2(ResponseHandle responseHandle, string data, int eventCount)
        {
            this.SetData(data);
            string uri = this.URL();
            //string content = ThinkingSDKJSON.Serialize(this.Data()[0]);
            string content = data.Substring(1,data.Length-2);

            WWWForm form = new WWWForm();
            form.AddField("appid", this.APPID());
            form.AddField("source", "client");
            form.AddField("dryRun", mDryRun);
            form.AddField("deviceId", mDeviceID);
            form.AddField("data", content);

            using (UnityWebRequest webRequest = UnityWebRequest.Post(uri, form))
            {
                webRequest.timeout = 30;
                webRequest.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded");

                if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("Send event Request:\n " + content + "\n URL = " + uri);

                // Request and wait for the desired page.
                yield return webRequest.SendWebRequest();

                Dictionary<string,object> resultDict = null;
#if UNITY_2020_1_OR_NEWER
                switch (webRequest.result)
                {
                    case UnityWebRequest.Result.ConnectionError:
                    case UnityWebRequest.Result.DataProcessingError:
                    case UnityWebRequest.Result.ProtocolError:
                        if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("Send event Response Error:\n " + webRequest.error);
                        break;
                    case UnityWebRequest.Result.Success:
                        string resultText = webRequest.downloadHandler.text;
                        if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("Send event Response:\n " + resultText);
                        if (!string.IsNullOrEmpty(resultText))
                        {
                            resultDict = ThinkingSDKJSON.Deserialize(resultText);
                        }
                        break;
                }
#else
                if (webRequest.isHttpError || webRequest.isNetworkError)
                {
                    if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("Send event Response Error:\n " + webRequest.error);
                }
                else
                {
                    string resultText = webRequest.downloadHandler.text;
                    if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("Send event Response:\n " + resultText);
                    if (!string.IsNullOrEmpty(resultText)) 
                    {
                        resultDict = ThinkingSDKJSON.Deserialize(resultText);
                    } 
                }
#endif
                if (responseHandle != null) 
                {
                    if (resultDict != null)
                    {
                        resultDict.Add("flush_count", eventCount);
                    }
                    responseHandle(resultDict);
                }
            }
        }
    }
}
