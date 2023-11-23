using System.Collections.Generic;
using UnityEngine;
using ThinkingSDK.PC.Main;
using ThinkingSDK.PC.Storage;
using ThinkingSDK.PC.Utils;
using ThinkingSDK.PC.Constant;
public class ThinkingSDKAutoTrack : MonoBehaviour
{
    private string mAppId;
    private TDAutoTrackEventType mAutoTrackEvents = TDAutoTrackEventType.None;
    private Dictionary<string, Dictionary<string, object>> mAutoTrackProperties = new Dictionary<string, Dictionary<string, object>>();
    private bool mStarted = false;
    private TDAutoTrackEventHandler_PC mEventCallback_PC;

    private static string TDAutoTrackEventType_APP_START = "AppStart";
    private static string TDAutoTrackEventType_APP_END = "AppEnd";
    private static string TDAutoTrackEventType_APP_CRASH = "AppCrash";
    private static string TDAutoTrackEventType_APP_INSTALL = "AppInstall";

    // Start is called before the first frame update
    void Start()
    {
    }
    void OnApplicationFocus(bool hasFocus)
    {
        if (hasFocus)
        {
            if ((mAutoTrackEvents & TDAutoTrackEventType.AppStart) != 0)
            {
                Dictionary<string, object> properties = new Dictionary<string, object>();
                if (mAutoTrackProperties.ContainsKey(TDAutoTrackEventType_APP_START))
                {
                    ThinkingSDKUtil.AddDictionary(properties, mAutoTrackProperties[TDAutoTrackEventType_APP_START]);
                }
                if (mEventCallback_PC != null)
                {
                    ThinkingSDKUtil.AddDictionary(properties, mEventCallback_PC.AutoTrackEventCallback_PC((int) TDAutoTrackEventType.AppStart, properties));
                }
                ThinkingPCSDK.Track(ThinkingSDKConstant.START_EVENT, properties, this.mAppId);
            }
            if ((mAutoTrackEvents & TDAutoTrackEventType.AppEnd) != 0)
            {
                ThinkingPCSDK.TimeEvent(ThinkingSDKConstant.END_EVENT, this.mAppId);
            }

            ThinkingPCSDK.PauseTimeEvent(false, appId: this.mAppId);
        }
        else 
        {
            if ((mAutoTrackEvents & TDAutoTrackEventType.AppEnd) != 0)
            {
                Dictionary<string, object> properties = new Dictionary<string, object>();
                if (mAutoTrackProperties.ContainsKey(TDAutoTrackEventType_APP_END))
                {
                    ThinkingSDKUtil.AddDictionary(properties, mAutoTrackProperties[TDAutoTrackEventType_APP_END]);
                }
                if (mEventCallback_PC != null)
                {
                    ThinkingSDKUtil.AddDictionary(properties, mEventCallback_PC.AutoTrackEventCallback_PC((int) TDAutoTrackEventType.AppEnd, properties));
                }
                ThinkingPCSDK.Track(ThinkingSDKConstant.END_EVENT, properties, this.mAppId);
            }
            ThinkingPCSDK.Flush(this.mAppId);

            ThinkingPCSDK.PauseTimeEvent(true, appId: this.mAppId);
        }
    }

    void OnApplicationQuit()
    {
        if (Application.isFocused == true)
        {
            OnApplicationFocus(false);
        }
        //ThinkingPCSDK.FlushImmediately(this.mAppId);
    }

    public void SetAppId(string appId)
    {
        this.mAppId = appId;
    }

    public void EnableAutoTrack(TDAutoTrackEventType events, Dictionary<string, object> properties, string appId)
    {
        SetAutoTrackProperties(events, properties);
        if ((events & TDAutoTrackEventType.AppInstall) != 0)
        {
            object result = ThinkingSDKFile.GetData(appId, ThinkingSDKConstant.IS_INSTALL, typeof(int));
            if (result == null)
            {
                Dictionary<string, object> mProperties = new Dictionary<string, object>(properties);
                ThinkingSDKFile.SaveData(appId, ThinkingSDKConstant.IS_INSTALL, 1);
                if (mAutoTrackProperties.ContainsKey(TDAutoTrackEventType_APP_INSTALL))
                {
                    ThinkingSDKUtil.AddDictionary(mProperties, mAutoTrackProperties[TDAutoTrackEventType_APP_INSTALL]);
                }
                ThinkingPCSDK.Track(ThinkingSDKConstant.INSTALL_EVENT, mProperties, this.mAppId);
                ThinkingPCSDK.Flush(this.mAppId);
            } 
        }
        if ((events & TDAutoTrackEventType.AppStart) != 0 && mStarted == false)
        {
            Dictionary<string, object> mProperties = new Dictionary<string, object>(properties);
            if (mAutoTrackProperties.ContainsKey(TDAutoTrackEventType_APP_START))
            {
                ThinkingSDKUtil.AddDictionary(mProperties, mAutoTrackProperties[TDAutoTrackEventType_APP_START]);
            }
            ThinkingPCSDK.Track(ThinkingSDKConstant.START_EVENT, mProperties, this.mAppId);
            ThinkingPCSDK.Flush(this.mAppId);
        }
        if ((events & TDAutoTrackEventType.AppEnd) != 0 && mStarted == false)
        {
            ThinkingPCSDK.TimeEvent(ThinkingSDKConstant.END_EVENT, this.mAppId);
        }

        mStarted = true;
    }

    public void EnableAutoTrack(TDAutoTrackEventType events, TDAutoTrackEventHandler_PC eventCallback, string appId)
    {
        mAutoTrackEvents = events;
        mEventCallback_PC = eventCallback;
        if ((events & TDAutoTrackEventType.AppInstall) != 0)
        {
            object result = ThinkingSDKFile.GetData(appId, ThinkingSDKConstant.IS_INSTALL, typeof(int));
            if (result == null)
            {
                ThinkingSDKFile.SaveData(appId, ThinkingSDKConstant.IS_INSTALL, 1);
                Dictionary<string, object> properties = null;
                if (mAutoTrackProperties.ContainsKey(TDAutoTrackEventType_APP_INSTALL))
                {
                    properties = mAutoTrackProperties[TDAutoTrackEventType_APP_INSTALL];
                }
                else
                {
                    properties = new Dictionary<string, object>();
                }
                if (mEventCallback_PC != null)
                {
                    ThinkingSDKUtil.AddDictionary(properties, mEventCallback_PC.AutoTrackEventCallback_PC((int)TDAutoTrackEventType.AppInstall, properties));
                }
                ThinkingPCSDK.Track(ThinkingSDKConstant.INSTALL_EVENT, properties, this.mAppId);
                ThinkingPCSDK.Flush(this.mAppId);
            } 
        }
        if ((events & TDAutoTrackEventType.AppStart) != 0 && mStarted == false)
        {
            Dictionary<string, object> properties = null;
            if (mAutoTrackProperties.ContainsKey(TDAutoTrackEventType_APP_START))
            {
                properties = mAutoTrackProperties[TDAutoTrackEventType_APP_START];
            }
            else
            {
                properties = new Dictionary<string, object>();
            }
            if (mEventCallback_PC != null)
            {
                ThinkingSDKUtil.AddDictionary(properties, mEventCallback_PC.AutoTrackEventCallback_PC((int) TDAutoTrackEventType.AppStart, properties));
            }
            ThinkingPCSDK.Track(ThinkingSDKConstant.START_EVENT, properties, this.mAppId);
            ThinkingPCSDK.Flush(this.mAppId);
        }
        if ((events & TDAutoTrackEventType.AppEnd) != 0 && mStarted == false)
        {
            ThinkingPCSDK.TimeEvent(ThinkingSDKConstant.END_EVENT, this.mAppId);
        }

        mStarted = true;
    }

    public void SetAutoTrackProperties(TDAutoTrackEventType events, Dictionary<string, object> properties)
    {
        mAutoTrackEvents = events;
        if ((events & TDAutoTrackEventType.AppInstall) != 0)
        {
            if (mAutoTrackProperties.ContainsKey(TDAutoTrackEventType_APP_INSTALL))
            {
                ThinkingSDKUtil.AddDictionary(mAutoTrackProperties[TDAutoTrackEventType_APP_INSTALL], properties);
            }
            else
                mAutoTrackProperties[TDAutoTrackEventType_APP_INSTALL] = properties;
        }
        if ((events & TDAutoTrackEventType.AppStart) != 0)
        {
            if (mAutoTrackProperties.ContainsKey(TDAutoTrackEventType_APP_START))
            {
                ThinkingSDKUtil.AddDictionary(mAutoTrackProperties[TDAutoTrackEventType_APP_START], properties);
            }
            else
                mAutoTrackProperties[TDAutoTrackEventType_APP_START] = properties;
        }
        if ((events & TDAutoTrackEventType.AppEnd) != 0)
        {
            if (mAutoTrackProperties.ContainsKey(TDAutoTrackEventType_APP_END))
            {
                ThinkingSDKUtil.AddDictionary(mAutoTrackProperties[TDAutoTrackEventType_APP_END], properties);
            }
            else
                mAutoTrackProperties[TDAutoTrackEventType_APP_END] = properties;
        }
        if ((events & TDAutoTrackEventType.AppCrash) != 0)
        {
            if (mAutoTrackProperties.ContainsKey(TDAutoTrackEventType_APP_CRASH))
            {
                ThinkingSDKUtil.AddDictionary(mAutoTrackProperties[TDAutoTrackEventType_APP_CRASH], properties);
            }
            else
                mAutoTrackProperties[TDAutoTrackEventType_APP_CRASH] = properties;
        }
    }

}
