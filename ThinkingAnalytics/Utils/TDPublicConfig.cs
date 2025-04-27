using UnityEngine;
using System;
using System.Xml;
using System.Collections.Generic;

namespace ThinkingData.Analytics.Utils
{
    // Crosss Platform
    public enum TDThirdPartyType
    {
        NONE = 0,
        APPSFLYER = 1 << 0, // AppsFlyer
        IRONSOURCE = 1 << 1, // IronSource
        ADJUST = 1 << 2, // Adjust
        BRANCH = 1 << 3, // Branch
        TOPON = 1 << 4, // TopOn
        TRACKING = 1 << 5, // ReYun
        TRADPLUS = 1 << 6, // TradPlus
    };

    // SSL
    public enum TDSSLPinningMode
    {
        NONE = 0, // Only allow certificates trusted by the system
        PUBLIC_KEY = 1 << 0, // Verify public key
        CERTIFICATE = 1 << 1 // Verify all contents
    }

    public class TDPublicConfig
    {
        public static bool DisableCSharpException = false;
        public static List<string> DisPresetProperties = new List<string>();

        public static readonly string LIB_VERSION = "3.2.0";

        public static void GetPublicConfig()
        {
            TextAsset textAsset = Resources.Load<TextAsset>("ta_public_config");
            if (textAsset != null && !string.IsNullOrEmpty(textAsset.text))
            {
                XmlDocument xmlDoc = new XmlDocument();
                xmlDoc.LoadXml(textAsset.text);
                XmlNode root = xmlDoc.SelectSingleNode("resources");
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