#if ((!(UNITY_IOS) || UNITY_EDITOR) && (!(UNITY_ANDROID) || UNITY_EDITOR) && (!(UNITY_OPENHARMONY) || UNITY_EDITOR)) || TE_DISABLE_ANDROID_JAVA || TE_DISABLE_IOS_OC
using System.Runtime.InteropServices;
namespace ThinkingData.Analytics.Wrapper
{
    public  class TDWxMiniGameWrapper
    {

        [DllImport("__Internal")]
        public static extern void SetOpenId(string openid);

        [DllImport("__Internal")]
        public static extern void SetUnionId(string unionid);

        [DllImport("__Internal")]
        public static extern void OnTrack(string type,string p);

        
        [DllImport("__Internal")]
        public static extern bool IsWxPlatform();


    }
}
#endif