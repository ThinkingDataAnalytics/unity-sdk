using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Text;
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
        public ThinkingSDKDebugRequest(string appid, string url, IList<Dictionary<string, object>> data):base(appid,url,data)
        {
            
        }
        public ThinkingSDKDebugRequest(string appid, string url) : base(appid, url)
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
        //     request.ContentType = "application/x-www-form-urlencoded";
        //     request.ReadWriteTimeout = 30 * 1000;
        //     request.Timeout = 30 * 1000;
            
        //     string content = ThinkingSDKJSON.Serialize(this.Data()[0]);
        //     var postData = "appid=" + this.APPID() + "&source=client&dryRun=" + mDryRun + "&deviceId="+ mDeviceID + "&data=" + content;
        //     ThinkingSDKLogger.Print(postData);
        //     byte[] data = Encoding.UTF8.GetBytes(postData);
        //     request.ContentLength = data.Length;
        //     Stream requestStream = null;
        //     HttpWebResponse response = null;
        //     Stream responseStream = null;
        //     try
        //     {
        //         requestStream = request.GetRequestStream();
        //         using (requestStream = request.GetRequestStream())
        //         {
        //             requestStream.Write(data, 0, data.Length);
        //             response = (HttpWebResponse)request.GetResponse();
        //             responseStream = response.GetResponseStream();
        //             var responseResult = new StreamReader(responseStream).ReadToEnd();
        //             if (responseResult != null)
        //             {
        //                 ThinkingSDKLogger.Print("Request URL=" + this.URL());
        //                 ThinkingSDKLogger.Print("------------------SendContent------------------");
        //                 ThinkingSDKLogger.Print(content);
        //                 ThinkingSDKLogger.Print("Response:=" + responseResult);
        //                 Dictionary<string, object> result = ThinkingSDKJSON.Deserialize(responseResult);
        //                 int errorLevel = Convert.ToInt32(result["errorLevel"]);
        //                 if (errorLevel != 0)
        //                 {
        //                     if (errorLevel == -1)
        //                     {
        //                         if (mDryRun == 1)//DebugOnly
        //                         {
        //                             ThinkingSDKLogger.Print("The data will be discarded due to this device is not allowed to debug for: APPID = " + APPID());
        //                         }
        //                         else
        //                         {
        //                             ThinkingSDKConfig config = ThinkingSDKConfig.GetInstance(APPID(), this.URL());
        //                             config.SetMode(Mode.NORMAL);
        //                             ThinkingSDKLogger.Print("Fallback to normal mode due to the device is not allowed to debug for: APPID=" + APPID());
        //                         }
        //                     }
        //                     //if (result.ContainsKey("errorProperties"))
        //                     //{
        //                     //    object errorProperties = result["errorProperties"];
        //                     //    ThinkingSDKLogger.Print("Error Properties:" + ThinkingSDKJSON.Serialize(errorProperties));
        //                     //}

        //                     //if (result.ContainsKey("errorReasons"))
        //                     //{
        //                     //    object errorReasons = result["errorReasons"];
        //                     //    ThinkingSDKLogger.Print( "Error Reasons:" + ThinkingSDKJSON.Serialize(errorReasons));
        //                     //}
        //                 }
        //                 else
        //                 {
        //                     ThinkingSDKLogger.Print("Upload debug data successfully for" + APPID());
        //                 }

        //             }
        //         }
        //     }
        //     catch (WebException ex)
        //     {
        //         ThinkingSDKLogger.Print("server response :"+ ex.Message);
        //         //HttpWebResponse res = (HttpWebResponse)ex.Response;
        //         //ThinkingSDKLogger.Print("Error code: " + response.StatusCode);
        //         //if (res.StatusCode == HttpStatusCode.BadRequest)
        //         //{
        //         //    using (Stream stream = response.GetResponseStream())
        //         //    {
        //         //        using (StreamReader reader = new StreamReader(stream))
        //         //        {
        //         //            string text = reader.ReadToEnd();
        //         //            ThinkingSDKLogger.Print("Error Description: " + text);
        //         //        }
        //         //    }
        //         //}

        //     }
        //     finally {
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
            string content = ThinkingSDKJSON.Serialize(this.Data()[0]);

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
    }
}
