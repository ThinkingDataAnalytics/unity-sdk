using System;
using System.Net;
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



    }
}

