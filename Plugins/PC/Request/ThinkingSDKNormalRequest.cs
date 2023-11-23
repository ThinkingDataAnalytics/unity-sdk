using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Text;
using ThinkingSDK.PC.Constant;
using ThinkingSDK.PC.Utils;
using UnityEngine.Networking;
using System.Collections;
using ThinkingSDK.PC.Config;

namespace ThinkingSDK.PC.Request
{
    public class ThinkingSDKNormalRequest:ThinkingSDKBaseRequest
    {
        public ThinkingSDKNormalRequest(string appId, string url, string data) :base(appId, url, data)
        {
        }
        public ThinkingSDKNormalRequest(string appId, string url) : base(appId, url)
        {
        }

        public override IEnumerator SendData_2(ResponseHandle responseHandle, string data, int eventCount)
        {
            this.SetData(data);
            string uri = this.URL();
            var flush_time = ThinkingSDKUtil.GetTimeStamp();

            string content = "{\"#app_id\":\"" + this.APPID() + "\",\"data\":" + data + ",\"#flush_time\":" + flush_time + "}";
            string encodeContent = Encode(content);
            byte[] contentCompressed = Encoding.UTF8.GetBytes(encodeContent);

            using (UnityWebRequest webRequest = new UnityWebRequest(uri, "POST"))
            {
                webRequest.timeout = 30;
                webRequest.SetRequestHeader("Content-Type", "text/plain");
                webRequest.SetRequestHeader("appid", this.APPID());
                webRequest.SetRequestHeader("TA-Integration-Type", "PC");
                webRequest.SetRequestHeader("TA-Integration-Version", ThinkingSDKPublicConfig.Version());
                webRequest.SetRequestHeader("TA-Integration-Count", "1");
                webRequest.SetRequestHeader("TA-Integration-Extra", "PC");
                webRequest.uploadHandler = (UploadHandler)new UploadHandlerRaw(contentCompressed);
                webRequest.downloadHandler = (DownloadHandler)new DownloadHandlerBuffer();

                if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("Send event Request:\n " + content + "\n URL = " + uri);

                // Request and wait for the desired page.
                yield return webRequest.SendWebRequest();

                Dictionary<string, object> resultDict = null;
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
        private static string Encode(string inputStr)
        {
            byte[] inputBytes = Encoding.UTF8.GetBytes(inputStr);
            using (var outputStream = new MemoryStream())
            {
                using (var gzipStream = new GZipStream(outputStream, CompressionMode.Compress))
                    gzipStream.Write(inputBytes, 0, inputBytes.Length);
                byte[] output = outputStream.ToArray();
                return Convert.ToBase64String(output);
            }
        }

    }
}
