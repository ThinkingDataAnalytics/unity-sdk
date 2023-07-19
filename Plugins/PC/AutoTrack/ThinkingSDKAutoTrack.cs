using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using ThinkingSDK.PC.Main;
using ThinkingSDK.PC.Storage;
using ThinkingSDK.PC.Utils;
using ThinkingSDK.PC.Constant;
public class ThinkingSDKAutoTrack : MonoBehaviour
{
    private string mAppId;
    private AUTO_TRACK_EVENTS mAutoTrackEvents = AUTO_TRACK_EVENTS.NONE;
    private Dictionary<string, Dictionary<string, object>> mAutoTrackProperties = new Dictionary<string, Dictionary<string, object>>();
    private bool mStarted = false;
    private IAutoTrackEventCallback_PC mEventCallback_PC;

    private static string AUTO_TRACK_EVENTS_APP_START = "APP_START";
    private static string AUTO_TRACK_EVENTS_APP_END = "APP_END";
    private static string AUTO_TRACK_EVENTS_APP_CRASH = "APP_CRASH";
    private static string AUTO_TRACK_EVENTS_APP_INSTALL = "APP_INSTALL";

    // Start is called before the first frame update
    void Start()
    {
    }
    void OnApplicationFocus(bool hasFocus)
    {
        if (hasFocus)
        {
            if ((mAutoTrackEvents & AUTO_TRACK_EVENTS.APP_START) != 0)
            {
                Dictionary<string, object> properties = new Dictionary<string, object>();
                if (mAutoTrackProperties.ContainsKey(AUTO_TRACK_EVENTS_APP_START))
                {
                    ThinkingSDKUtil.AddDictionary(properties, mAutoTrackProperties[AUTO_TRACK_EVENTS_APP_START]);
                }
                if (mEventCallback_PC != null)
                {
                    ThinkingSDKUtil.AddDictionary(properties, mEventCallback_PC.AutoTrackEventCallback_PC((int) AUTO_TRACK_EVENTS.APP_START, properties));
                }
                ThinkingPCSDK.Track(ThinkingSDKConstant.START_EVENT, properties, this.mAppId);
            }
            if ((mAutoTrackEvents & AUTO_TRACK_EVENTS.APP_END) != 0)
            {
                ThinkingPCSDK.TimeEvent(ThinkingSDKConstant.END_EVENT, this.mAppId);
            }

            ThinkingPCSDK.PauseTimeEvent(false, appId: this.mAppId);
        }
        else 
        {
            if ((mAutoTrackEvents & AUTO_TRACK_EVENTS.APP_END) != 0)
            {
                Dictionary<string, object> properties = new Dictionary<string, object>();
                if (mAutoTrackProperties.ContainsKey(AUTO_TRACK_EVENTS_APP_END))
                {
                    ThinkingSDKUtil.AddDictionary(properties, mAutoTrackProperties[AUTO_TRACK_EVENTS_APP_END]);
                }
                if (mEventCallback_PC != null)
                {
                    ThinkingSDKUtil.AddDictionary(properties, mEventCallback_PC.AutoTrackEventCallback_PC((int) AUTO_TRACK_EVENTS.APP_END, properties));
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

    public void EnableAutoTrack(AUTO_TRACK_EVENTS events, Dictionary<string, object> properties, string appId)
    {
        SetAutoTrackProperties(events, properties);
        if ((events & AUTO_TRACK_EVENTS.APP_INSTALL) != 0)
        {
            object result = ThinkingSDKFile.GetData(appId, ThinkingSDKConstant.IS_INSTALL, typeof(int));
            if (result == null)
            {
                Dictionary<string, object> mProperties = new Dictionary<string, object>(properties);
                ThinkingSDKFile.SaveData(appId, ThinkingSDKConstant.IS_INSTALL, 1);
                if (mAutoTrackProperties.ContainsKey(AUTO_TRACK_EVENTS_APP_INSTALL))
                {
                    ThinkingSDKUtil.AddDictionary(mProperties, mAutoTrackProperties[AUTO_TRACK_EVENTS_APP_INSTALL]);
                }
                ThinkingPCSDK.Track(ThinkingSDKConstant.INSTALL_EVENT, mProperties, this.mAppId);
                ThinkingPCSDK.Flush(this.mAppId);
            } 
        }
        if ((events & AUTO_TRACK_EVENTS.APP_START) != 0 && mStarted == false)
        {
            Dictionary<string, object> mProperties = new Dictionary<string, object>(properties);
            if (mAutoTrackProperties.ContainsKey(AUTO_TRACK_EVENTS_APP_START))
            {
                ThinkingSDKUtil.AddDictionary(mProperties, mAutoTrackProperties[AUTO_TRACK_EVENTS_APP_START]);
            }
            ThinkingPCSDK.Track(ThinkingSDKConstant.START_EVENT, mProperties, this.mAppId);
            ThinkingPCSDK.Flush(this.mAppId);
        }
        if ((events & AUTO_TRACK_EVENTS.APP_END) != 0 && mStarted == false)
        {
            ThinkingPCSDK.TimeEvent(ThinkingSDKConstant.END_EVENT, this.mAppId);
        }

        mStarted = true;
    }

    public void EnableAutoTrack(AUTO_TRACK_EVENTS events, IAutoTrackEventCallback_PC eventCallback, string appId)
    {
        mAutoTrackEvents = events;
        mEventCallback_PC = eventCallback;
        if ((events & AUTO_TRACK_EVENTS.APP_INSTALL) != 0)
        {
            object result = ThinkingSDKFile.GetData(appId, ThinkingSDKConstant.IS_INSTALL, typeof(int));
            if (result == null)
            {
                ThinkingSDKFile.SaveData(appId, ThinkingSDKConstant.IS_INSTALL, 1);
                Dictionary<string, object> properties = null;
                if (mAutoTrackProperties.ContainsKey(AUTO_TRACK_EVENTS_APP_INSTALL))
                {
                    properties = mAutoTrackProperties[AUTO_TRACK_EVENTS_APP_INSTALL];
                }
                else
                {
                    properties = new Dictionary<string, object>();
                }
                if (mEventCallback_PC != null)
                {
                    ThinkingSDKUtil.AddDictionary(properties, mEventCallback_PC.AutoTrackEventCallback_PC((int)AUTO_TRACK_EVENTS.APP_INSTALL, properties));
                }
                ThinkingPCSDK.Track(ThinkingSDKConstant.INSTALL_EVENT, properties, this.mAppId);
                ThinkingPCSDK.Flush(this.mAppId);
            } 
        }
        if ((events & AUTO_TRACK_EVENTS.APP_START) != 0 && mStarted == false)
        {
            Dictionary<string, object> properties = null;
            if (mAutoTrackProperties.ContainsKey(AUTO_TRACK_EVENTS_APP_START))
            {
                properties = mAutoTrackProperties[AUTO_TRACK_EVENTS_APP_START];
            }
            else
            {
                properties = new Dictionary<string, object>();
            }
            if (mEventCallback_PC != null)
            {
                ThinkingSDKUtil.AddDictionary(properties, mEventCallback_PC.AutoTrackEventCallback_PC((int) AUTO_TRACK_EVENTS.APP_START, properties));
            }
            ThinkingPCSDK.Track(ThinkingSDKConstant.START_EVENT, properties, this.mAppId);
            ThinkingPCSDK.Flush(this.mAppId);
        }
        if ((events & AUTO_TRACK_EVENTS.APP_END) != 0 && mStarted == false)
        {
            ThinkingPCSDK.TimeEvent(ThinkingSDKConstant.END_EVENT, this.mAppId);
        }

        mStarted = true;
    }

    public void SetAutoTrackProperties(AUTO_TRACK_EVENTS events, Dictionary<string, object> properties)
    {
        mAutoTrackEvents = events;
        if ((events & AUTO_TRACK_EVENTS.APP_INSTALL) != 0)
        {
            if (mAutoTrackProperties.ContainsKey(AUTO_TRACK_EVENTS_APP_INSTALL))
            {
                ThinkingSDKUtil.AddDictionary(mAutoTrackProperties[AUTO_TRACK_EVENTS_APP_INSTALL], properties);
            }
            else
                mAutoTrackProperties[AUTO_TRACK_EVENTS_APP_INSTALL] = properties;
        }
        if ((events & AUTO_TRACK_EVENTS.APP_START) != 0)
        {
            if (mAutoTrackProperties.ContainsKey(AUTO_TRACK_EVENTS_APP_START))
            {
                ThinkingSDKUtil.AddDictionary(mAutoTrackProperties[AUTO_TRACK_EVENTS_APP_START], properties);
            }
            else
                mAutoTrackProperties[AUTO_TRACK_EVENTS_APP_START] = properties;
        }
        if ((events & AUTO_TRACK_EVENTS.APP_END) != 0)
        {
            if (mAutoTrackProperties.ContainsKey(AUTO_TRACK_EVENTS_APP_END))
            {
                ThinkingSDKUtil.AddDictionary(mAutoTrackProperties[AUTO_TRACK_EVENTS_APP_END], properties);
            }
            else
                mAutoTrackProperties[AUTO_TRACK_EVENTS_APP_END] = properties;
        }
        if ((events & AUTO_TRACK_EVENTS.APP_CRASH) != 0)
        {
            if (mAutoTrackProperties.ContainsKey(AUTO_TRACK_EVENTS_APP_CRASH))
            {
                ThinkingSDKUtil.AddDictionary(mAutoTrackProperties[AUTO_TRACK_EVENTS_APP_CRASH], properties);
            }
            else
                mAutoTrackProperties[AUTO_TRACK_EVENTS_APP_CRASH] = properties;
        }
    }

}
