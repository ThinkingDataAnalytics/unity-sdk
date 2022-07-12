using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Net;
using System.Text;
using ThinkingSDK.PC.Constant;
using ThinkingSDK.PC.Utils;
using UnityEngine.Networking;
using System.Collections;

namespace ThinkingSDK.PC.Request
{
    public class ThinkingSDKNormalRequest:ThinkingSDKBaseRequest
    {
        public ThinkingSDKNormalRequest(string appid, string url, IList<Dictionary<string, object>> data) :base(appid,url,data)
        {
        }
        public ThinkingSDKNormalRequest(string appid, string url) : base(appid, url)
        {
        }

        // public override void SendData(ResponseHandle responseHandle, IList<Dictionary<string, object>> data)
        // {
            
        //     this.SetData(data);
        //     this.SendData(responseHandle);
        // }

        // public override void SendData(ResponseHandle responseHandle)
        // {

        //     ServicePointManager.ServerCertificateValidationCallback = MyRemoteCertificateValidationCallback;

        //     HttpWebRequest request = (HttpWebRequest)WebRequest.Create(this.URL());
        //     request.Method = "POST";
        //     request.ContentType = "text/plain";
        //     request.ReadWriteTimeout = 30 * 1000;
        //     request.Timeout = 30 * 1000;
        //     request.Headers.Set("appid", this.APPID());
        //     request.Headers.Set("TA-Integration-Type", "PC");
        //     request.Headers.Set("TA-Integration-Version", "2.3.0");
        //     request.Headers.Set("TA-Integration-Count", "1");
        //     request.Headers.Set("TA-Integration-Extra", "PC");
        //     Dictionary<string, object> param = new Dictionary<string, object>();
        //     param[ThinkingSDKConstant.APPID] = this.APPID();
        //     param["data"] = this.Data();
        //     string content = ThinkingSDKJSON.Serialize(param);
        //     string encodeContent = Encode(content);
        //     byte[] contentCompressed = Encoding.UTF8.GetBytes(encodeContent);
        //     request.ContentLength = contentCompressed.Length;
        //     Stream requestStream = null;
        //     HttpWebResponse response = null;
        //     Stream responseStream = null;
        //     try
        //     {
        //         using (requestStream = request.GetRequestStream())
        //         {
        //             requestStream.Write(contentCompressed, 0, contentCompressed.Length);
        //             //requestStream.Flush();
        //             response = (HttpWebResponse)request.GetResponse();
        //             responseStream = response.GetResponseStream();
        //             var responseResult = new StreamReader(responseStream).ReadToEnd();
        //             if (responseResult != null)
        //             {

        //                 ThinkingSDKLogger.Print("Request URL=" + this.URL());
        //                 ThinkingSDKLogger.Print("------------------SendContent------------------");
        //                 ThinkingSDKLogger.Print(content);
        //                 ThinkingSDKLogger.Print("Response:=" + responseResult);
        //             }

        //         }
        //     }
        //     catch (WebException ex)
        //     {
        //         ThinkingSDKLogger.Print("server response :" + ex.Message);
        //     }
        //     finally
        //     {
        //         if (requestStream != null)
        //         {
        //             requestStream.Close();
        //         }
        //         if (responseStream != null)
        //         {
        //             responseStream.Close();
        //         }
        //         if (response != null)
        //         {
        //             response.Close();
        //         }
        //         if (request != null)
        //         {
        //             request.Abort();
        //         }
        //         if (responseHandle != null) 
        //         {
        //             responseHandle();
        //         }
        //     }  
        // }

        public override IEnumerator SendData_2(ResponseHandle responseHandle, IList<Dictionary<string, object>> data)
        {
            this.SetData(data);
            string uri = this.URL();
            Dictionary<string, object> param = new Dictionary<string, object>();
            param[ThinkingSDKConstant.APPID] = this.APPID();
            param["data"] = this.Data();
            param["#flush_time"] = ThinkingSDKUtil.GetTimeStamp();
            string content = ThinkingSDKJSON.Serialize(param);
            string encodeContent = Encode(content);
            byte[] contentCompressed = Encoding.UTF8.GetBytes(encodeContent);

            using (UnityWebRequest webRequest = new UnityWebRequest(uri, "POST"))
            {
                webRequest.timeout = 30;
                webRequest.SetRequestHeader("Content-Type", "text/plain");
                webRequest.SetRequestHeader("appid", this.APPID());
                webRequest.SetRequestHeader("TA-Integration-Type", "PC");
                webRequest.SetRequestHeader("TA-Integration-Version", "2.3.0");
                webRequest.SetRequestHeader("TA-Integration-Count", "1");
                webRequest.SetRequestHeader("TA-Integration-Extra", "PC");
                webRequest.uploadHandler = (UploadHandler) new UploadHandlerRaw(contentCompressed);
                webRequest.downloadHandler = (DownloadHandler) new DownloadHandlerBuffer();

                ThinkingSDKLogger.Print("Post event: " + content + "\n  Request URL: " + uri);

                // Request and wait for the desired page.
                yield return webRequest.SendWebRequest();

                Dictionary<string,object> resultDict = null;
                #if UNITY_2020_1_OR_NEWER
                switch (webRequest.result)
                {
                    case UnityWebRequest.Result.ConnectionError:
                    case UnityWebRequest.Result.DataProcessingError:
                    case UnityWebRequest.Result.ProtocolError:
                        ThinkingSDKLogger.Print("Error response : " + webRequest.error);
                        break;
                    case UnityWebRequest.Result.Success:
                        ThinkingSDKLogger.Print("Response : " + webRequest.downloadHandler.text);
                        if (!string.IsNullOrEmpty(webRequest.downloadHandler.text)) 
                        {
                            resultDict = ThinkingSDKJSON.Deserialize(webRequest.downloadHandler.text);
                        } 
                        break;
                }
                #else
                if (webRequest.isHttpError || webRequest.isNetworkError)
                {
                    ThinkingSDKLogger.Print("Error response : " + webRequest.error);
                }
                else
                {
                    ThinkingSDKLogger.Print("Response : " + webRequest.downloadHandler.text);
                    if (!string.IsNullOrEmpty(webRequest.downloadHandler.text)) 
                    {
                        resultDict = ThinkingSDKJSON.Deserialize(webRequest.downloadHandler.text);
                    }
                }
                #endif
                if (responseHandle != null) 
                {
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
