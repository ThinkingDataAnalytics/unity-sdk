using System;
using System.Net;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;
using System.Collections.Generic;
using ThinkingSDK.PC.Constant;
using ThinkingSDK.PC.Utils;
using System.IO;
using System.Text;
using System.IO.Compression;
using System.Runtime.Serialization;

namespace ThinkingSDK.PC.Request
{
    /*
     * 枚举post上报数据的形式,枚举值表示json和form表单
     */
    enum POST_TYPE { JSON, FORM };
    public abstract class ThinkingSDKBaseRequest
    {
        private string mAppid;
        private string mURL;
        private IList<Dictionary<string, object>> mData;
        
        public ThinkingSDKBaseRequest(string appid, string url, IList<Dictionary<string, object>> data)
        {
            mAppid = appid;
            mURL = url;
            mData = data;
        }
        public ThinkingSDKBaseRequest(string appid, string url)
        {
            mAppid = appid;
            mURL = url;
        }
        public void SetData(IList<Dictionary<string, object>> data)
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
        public IList<Dictionary<string, object>> Data()
        {
            return mData;
        }
        /** 
         * 初始化接口
         */
        public static void GetConfig(string url,ResponseHandle responseHandle)
        {
            if (!ThinkingSDKUtil.IsValiadURL(url))
            {
                ThinkingSDKLogger.Print("invalid url");
            }
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);
            request.Method = "GET";
            HttpWebResponse response = (HttpWebResponse)request.GetResponse();
            var responseResult = new StreamReader(response.GetResponseStream()).ReadToEnd();
            if (responseResult != null)
            {
                ThinkingSDKLogger.Print("Request URL="+url);
                ThinkingSDKLogger.Print("Response:="+responseResult);
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

        abstract public void SendData(ResponseHandle responseHandle);
        abstract public void SendData(ResponseHandle responseHandle, IList<Dictionary<string, object>> data);
        //public static void PostWithJSON(string url,string appid,Dictionary<string,object> param,ResponseHandle responseHandle)
        //{
        //    HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);
        //    request.Method = "POST";
        //    request.ContentType = "text/plain";
        //    request.ReadWriteTimeout = 30 * 1000;
        //    request.Timeout = 30 * 1000;
        //    request.Headers.Set("appid", appid);
        //    request.Headers.Set("TA-Integration-Type", "PC");
        //    request.Headers.Set("TA-Integration-Version","2.6.1");
        //    request.Headers.Set("TA-Integration-Count", "1");
        //    request.Headers.Set("TA-Integration-Extra", "PC");
        //    string content = ThinkingSDKJSON.Serialize(param);
        //    string encodeContent = Encode(content); 
        //    byte[] contentCompressed = Encoding.UTF8.GetBytes(encodeContent);
        //    using (Stream stream = request.GetRequestStream())
        //    {
        //        stream.Write(contentCompressed, 0, contentCompressed.Length);
        //        stream.Flush();
        //    }
        //    HttpWebResponse response = (HttpWebResponse)request.GetResponse();
        //    var responseResult = new StreamReader(response.GetResponseStream()).ReadToEnd();
        //    if (responseResult != null)
        //    {
        //        ThinkingSDKLogger.Print("Request URL=" + url);
        //        ThinkingSDKLogger.Print("Response:=" + responseResult);
        //    }

        //}


        //public static void postWithFORM(string url, string appid, Dictionary<string, object> param, ResponseHandle responseHandle)
        //{
        //    HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);
        //    request.Method = "POST";
        //    request.ContentType = "application/x-www-form-urlencoded";
        //    request.ReadWriteTimeout = 30 * 1000;
        //    request.Timeout = 30 * 1000;
        //    var postData = "appid=" + appid + "&source=server&dryRun=" + 0 + "&data=" + ThinkingSDKJSON.Serialize(param);
        //    ThinkingSDKLogger.Print(postData);
        //    byte[] data = Encoding.UTF8.GetBytes(postData);
        //    request.ContentLength = data.Length;
        //    using (Stream stream = request.GetRequestStream())
        //    {
        //        stream.Write(data, 0, data.Length);
        //        stream.Close();
        //    }
        //    HttpWebResponse response = (HttpWebResponse)request.GetResponse();
        //    var responseResult = new StreamReader(response.GetResponseStream()).ReadToEnd();
        //    if (responseResult != null)
        //    {
        //        ThinkingSDKLogger.Print("Request URL=" + url);
        //        ThinkingSDKLogger.Print("Response:=" + responseResult);
        //    }
        //}

        public static void GetWithFORM(string url, string appid, Dictionary<string, object> param, ResponseHandle responseHandle)
        {
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url + "?appid=" + appid + "&data=" + ThinkingSDKJSON.Serialize(param));
            request.Method = "GET";
            request.ContentType = "application/x-www-form-urlencoded";
            request.ReadWriteTimeout = 30 * 1000;
            request.Timeout = 30 * 1000;

            HttpWebResponse response = null;
            Stream responseStream = null;
            Dictionary<string,object> resultDict = new Dictionary<string, object>();
            try
            {
                response = (HttpWebResponse)request.GetResponse();
                responseStream = response.GetResponseStream();
                var responseResult = new StreamReader(responseStream).ReadToEnd();
                if (responseResult != null)
                {
                    ThinkingSDKLogger.Print("Request URL=" + url);
                    ThinkingSDKLogger.Print("Response:=" + responseResult);

                    resultDict = ThinkingSDKJSON.Deserialize(responseResult);
                }
            }
            catch (WebException ex)
            {
                ThinkingSDKLogger.Print("server response :" + ex.Message);
            }
            finally
            {
                if (responseStream != null)
                {
                    responseStream.Close();
                }
                if (response != null)
                {
                    response.Close();
                }
                if (request != null)
                {
                    request.Abort();
                }
                if (responseHandle != null) 
                {
                    responseHandle(resultDict);
                }
            }  
        }
    }
}

