using System;
using System.Net;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;
using System.Collections.Generic;
using ThinkingSDK.PC.Constant;
using ThinkingSDK.PC.Utils;
using System.IO;
using UnityEngine.Networking;
using System.Collections;
using ThinkingSDK.PC.Config;

namespace ThinkingSDK.PC.Request
{
    /*
     * Enumerate the form of data reported by post, and the enumeration value represents json and form forms
     */
    enum POST_TYPE { JSON, FORM };
    public abstract class ThinkingSDKBaseRequest
    {
        private string mAppid;
        private string mURL;
        private string mData;
        public ThinkingSDKBaseRequest(string appId, string url, string data)
        {
            mAppid = appId;
            mURL = url;
            mData = data;
        }
        public ThinkingSDKBaseRequest(string appId, string url)
        {
            mAppid = appId;
            mURL = url;
        }
        public void SetData(string data)
        {
            this.mData = data;
        }
        public string APPID() {
            return mAppid;
        }
        public string URL()
        {
            return mURL;
        }
        public string Data()
        {
            return mData;
        }
        /** 
         * initialization interface
         */
        public static void GetConfig(string url,ResponseHandle responseHandle)
        {
            if (!ThinkingSDKUtil.IsValiadURL(url))
            {
                if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("Invalid Url:\n" + url);
            }
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);
            request.Method = "GET";
            HttpWebResponse response = (HttpWebResponse)request.GetResponse();
            var responseResult = new StreamReader(response.GetResponseStream()).ReadToEnd();
            if (responseResult != null)
            {
                if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("Request URL:\n"+url);
                if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("Response:\n"+responseResult);
            }
        }

        public bool MyRemoteCertificateValidationCallback(System.Object sender, X509Certificate certificate, X509Chain chain, SslPolicyErrors sslPolicyErrors)
        {
            bool isOk = true;
            // If there are errors in the certificate chain,
            // look at each error to determine the cause.
            if (sslPolicyErrors != SslPolicyErrors.None) {
                for (int i=0; i<chain.ChainStatus.Length; i++) {
                    if (chain.ChainStatus[i].Status == X509ChainStatusFlags.RevocationStatusUnknown) {
                        continue;
                    }
                    chain.ChainPolicy.RevocationFlag = X509RevocationFlag.EntireChain;
                    chain.ChainPolicy.RevocationMode = X509RevocationMode.Online;
                    chain.ChainPolicy.UrlRetrievalTimeout = new TimeSpan (0, 1, 0);
                    chain.ChainPolicy.VerificationFlags = X509VerificationFlags.AllFlags;
                    bool chainIsValid = chain.Build ((X509Certificate2)certificate);
                    if (!chainIsValid) {
                        isOk = false;
                        break;
                    }
                }
            }
            return isOk;
        }

        abstract public IEnumerator SendData_2(ResponseHandle responseHandle, string data, int eventCount);

        public static IEnumerator GetWithFORM_2(string url, string appId, Dictionary<string, object> param, ResponseHandle responseHandle)
        {
            string uri = url + "?appid=" + appId;
            if (param != null)
            {
                uri = uri + "&data=" + ThinkingSDKJSON.Serialize(param);
            }

            using (UnityWebRequest webRequest = UnityWebRequest.Get(uri))
            {
                webRequest.timeout = 30;
                webRequest.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded");

                //if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("Request URL: \n" + uri);

                // Request and wait for the desired page.
                yield return webRequest.SendWebRequest();

                Dictionary<string,object> resultDict = null;
#if UNITY_2020_1_OR_NEWER
                switch (webRequest.result)
                {
                    case UnityWebRequest.Result.ConnectionError:
                    case UnityWebRequest.Result.DataProcessingError:
                    case UnityWebRequest.Result.ProtocolError:
                        //if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("Error response: \n" + webRequest.error);
                        break;
                    case UnityWebRequest.Result.Success:
                        string resultText = webRequest.downloadHandler.text;
                        //if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("Response: \n" + resultText);
                        if (!string.IsNullOrEmpty(resultText))
                        {
                            resultDict = ThinkingSDKJSON.Deserialize(resultText);
                        }
                        break;
                }
#else
                if (webRequest.isHttpError || webRequest.isNetworkError)
                {
                    //if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("Error response: \n" + webRequest.error);
                }
                else
                {
                    string resultText = webRequest.downloadHandler.text;
                    //if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("Response: \n" + resultText);
                    if (!string.IsNullOrEmpty(resultText)) 
                    {
                        resultDict = ThinkingSDKJSON.Deserialize(resultText);
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

