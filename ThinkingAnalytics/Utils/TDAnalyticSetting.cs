using UnityEngine;
namespace ThinkingData.Analytics {
    public class TDAnalyticSetting : ScriptableObject {
        public string appId;
        public string serverUrl;
        public bool enableLog = true;
        public TDNetworkType networkType = TDNetworkType.All;
        public TDMode mode = TDMode.Normal;
        public TDTimeZone timeZone;
        public int encryptVersion = 0;
        public string encryptPublicKey;

        public static TDAnalyticSetting GetSerializedObject()
        {
            return Resources.Load("TDAnalyticSetting") as TDAnalyticSetting;
        }
    }
}

