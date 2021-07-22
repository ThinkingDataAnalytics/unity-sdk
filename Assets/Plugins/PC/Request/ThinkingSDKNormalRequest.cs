using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Net;
using System.Text;
using ThinkingSDK.PC.Constant;
using ThinkingSDK.PC.Utils;

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

        public override void SendData(ResponseHandle responseHandle, IList<Dictionary<string, object>> data)
        {
            
            this.SetData(data);
            this.SendData(responseHandle);
        }

        public override void SendData(ResponseHandle responseHandle)
        {

            ServicePointManager.ServerCertificateValidationCallback = MyRemoteCertificateValidationCallback;

            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(this.URL());
            request.Method = "POST";
            request.ContentType = "text/plain";
            request.ReadWriteTimeout = 30 * 1000;
            request.Timeout = 30 * 1000;
            request.Headers.Set("appid", this.APPID());
            request.Headers.Set("TA-Integration-Type", "PC");
            request.Headers.Set("TA-Integration-Version", "2.6.1");
            request.Headers.Set("TA-Integration-Count", "1");
            request.Headers.Set("TA-Integration-Extra", "PC");
            Dictionary<string, object> param = new Dictionary<string, object>();
            param[ThinkingSDKConstant.APPID] = this.APPID();
            param["data"] = this.Data();
            string content = ThinkingSDKJSON.Serialize(param);
            string encodeContent = Encode(content);
            byte[] contentCompressed = Encoding.UTF8.GetBytes(encodeContent);
            request.ContentLength = contentCompressed.Length;
            Stream requestStream = null;
            HttpWebResponse response = null;
            Stream responseStream = null;
            try
            {
                using (requestStream = request.GetRequestStream())
                {
                    requestStream.Write(contentCompressed, 0, contentCompressed.Length);
                    //requestStream.Flush();
                    response = (HttpWebResponse)request.GetResponse();
                    responseStream = response.GetResponseStream();
                    var responseResult = new StreamReader(responseStream).ReadToEnd();
                    if (responseResult != null)
                    {

                        ThinkingSDKLogger.Print("Request URL=" + this.URL());
                        ThinkingSDKLogger.Print("------------------SendContent------------------");
                        ThinkingSDKLogger.Print(content);
                        ThinkingSDKLogger.Print("Response:=" + responseResult);
                    }

                }
            }
            catch (WebException ex)
            {
                ThinkingSDKLogger.Print("server response :" + ex.Message);
            }
            finally
            {
                if (requestStream != null)
                {
                    requestStream.Close();
                }
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
                    responseHandle();
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
