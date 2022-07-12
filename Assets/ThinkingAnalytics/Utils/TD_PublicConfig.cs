using UnityEngine;
using System;
using System.IO;
using System.Xml;
using System.Collections.Generic;

namespace ThinkingAnalytics.Utils
{
    // 三方数据共享类型
    public enum TAThirdPartyShareType
    {
        NONE = 0,
        APPSFLYER = 1 << 0, // AppsFlyer
        IRONSOURCE = 1 << 1, // IronSource
        ADJUST = 1 << 2, // Adjust
        BRANCH = 1 << 3, // Branch
        TOPON = 1 << 4, // TopOn
        TRACKING = 1 << 5, // 热云
        TRADPLUS = 1 << 6, // TradPlus
    };

    // SSL认证方式类型
    public enum SSLPinningMode
    {
        NONE = 0, // 默认认证方式，只会在系统的信任的证书列表中对服务端返回的证书进行验证
        PUBLIC_KEY = 1 << 0, // 校验证书的公钥
        CERTIFICATE = 1 << 1 // 校验证书的所有内容
    }

    public class TD_PublicConfig
    {
        public static bool DisableCSharpException = false;
        public static List<string> DisPresetProperties = new List<string>();

        public static readonly string LIB_VERSION = "2.4.0";

        public static void GetPublicConfig()
        {
            TextAsset textAsset = Resources.Load<TextAsset>("ta_public_config");
            if (textAsset != null && !string.IsNullOrEmpty(textAsset.text))
            {
                XmlDocument xmlDoc = new XmlDocument();
                xmlDoc.LoadXml(textAsset.text);
                XmlNode root = xmlDoc.SelectSingleNode("resources");
                //遍历节点
                for (int i=0; i<root.ChildNodes.Count; i++)
                {
                    XmlNode x1 = root.ChildNodes[i];
                    if (x1.NodeType == XmlNodeType.Element)
                    {
                        XmlElement e1 = x1 as XmlElement;
                        if (e1.HasAttributes) 
                        {
                            string name = e1.GetAttribute("name");
                            if (name == "TDDisPresetProperties" && e1.HasChildNodes)
                            {
                                for (int j=0; j<e1.ChildNodes.Count; j++)
                                {
                                    XmlNode x2 = e1.ChildNodes[j];
                                    if (x2.NodeType == XmlNodeType.Element)
                                    {
                                        DisPresetProperties.Add(x2.InnerText);
                                    }
                                }
                            }
                            else if (name == "DisableCSharpException")
                            {
                                DisableCSharpException = Convert.ToBoolean(e1.InnerText);
                            }
                        }
                    }
                }
            }
        }
    }
}