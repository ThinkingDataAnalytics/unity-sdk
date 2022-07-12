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

    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void OnApplicationFocus(bool hasFocus)
    {
        if (hasFocus)
        {
            if ((mAutoTrackEvents & AUTO_TRACK_EVENTS.APP_START) != 0)
            {
                Dictionary<string, object> properties = new Dictionary<string, object>();
                if (mAutoTrackProperties.ContainsKey(AUTO_TRACK_EVENTS.APP_START.ToString()))
                {
                    ThinkingSDKUtil.AddDictionary(properties, mAutoTrackProperties[AUTO_TRACK_EVENTS.APP_START.ToString()]);
                }
                if (mEventCallback_PC != null)
                {
                    ThinkingSDKUtil.AddDictionary(properties, mEventCallback_PC.AutoTrackEventCallback_PC((int) AUTO_TRACK_EVENTS.APP_START, properties));
                }
                ThinkingPCSDK.Track(ThinkingSDKConstant.START_EVENT, properties);
            }
            if ((mAutoTrackEvents & AUTO_TRACK_EVENTS.APP_END) != 0)
            {
                ThinkingPCSDK.TimeEvent(ThinkingSDKConstant.END_EVENT);
            }
        }
        else 
        {
            if ((mAutoTrackEvents & AUTO_TRACK_EVENTS.APP_END) != 0)
            {
                Dictionary<string, object> properties = new Dictionary<string, object>();
                if (mAutoTrackProperties.ContainsKey(AUTO_TRACK_EVENTS.APP_END.ToString()))
                {
                    ThinkingSDKUtil.AddDictionary(properties, mAutoTrackProperties[AUTO_TRACK_EVENTS.APP_END.ToString()]);
                }
                if (mEventCallback_PC != null)
                {
                    ThinkingSDKUtil.AddDictionary(properties, mEventCallback_PC.AutoTrackEventCallback_PC((int) AUTO_TRACK_EVENTS.APP_END, properties));
                }
                ThinkingPCSDK.Track(ThinkingSDKConstant.END_EVENT, properties);
            }
            ThinkingPCSDK.Flush(this.mAppId);
        }
        mStarted = true;
    }

    void OnApplicationQuit()
    {
        ThinkingPCSDK.FlushImmediately(this.mAppId);
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
                if (mAutoTrackProperties.ContainsKey(AUTO_TRACK_EVENTS.APP_INSTALL.ToString()))
                {
                    ThinkingSDKUtil.AddDictionary(mProperties, mAutoTrackProperties[AUTO_TRACK_EVENTS.APP_INSTALL.ToString()]);
                }
                ThinkingPCSDK.Track(ThinkingSDKConstant.INSTALL_EVENT, mProperties);
                ThinkingPCSDK.Flush();
            } 
        }
        if ((events & AUTO_TRACK_EVENTS.APP_START) != 0 && mStarted == false)
        {
            Dictionary<string, object> mProperties = new Dictionary<string, object>(properties);
            if (mAutoTrackProperties.ContainsKey(AUTO_TRACK_EVENTS.APP_START.ToString()))
            {
                ThinkingSDKUtil.AddDictionary(mProperties, mAutoTrackProperties[AUTO_TRACK_EVENTS.APP_START.ToString()]);
            }
            ThinkingPCSDK.Track(ThinkingSDKConstant.START_EVENT, mProperties);
            ThinkingPCSDK.Flush();
        }
        if ((events & AUTO_TRACK_EVENTS.APP_END) != 0 && mStarted == false)
        {
            ThinkingPCSDK.TimeEvent(ThinkingSDKConstant.END_EVENT);
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
                if (mAutoTrackProperties.ContainsKey(AUTO_TRACK_EVENTS.APP_INSTALL.ToString()))
                {
                    properties = mAutoTrackProperties[AUTO_TRACK_EVENTS.APP_INSTALL.ToString()];
                }
                else
                {
                    properties = new Dictionary<string, object>();
                }
                ThinkingPCSDK.Track(ThinkingSDKConstant.INSTALL_EVENT, properties);
                ThinkingPCSDK.Flush();
            } 
        }
        if ((events & AUTO_TRACK_EVENTS.APP_START) != 0 && mStarted == false)
        {
            Dictionary<string, object> properties = null;
            if (mAutoTrackProperties.ContainsKey(AUTO_TRACK_EVENTS.APP_START.ToString()))
            {
                properties = mAutoTrackProperties[AUTO_TRACK_EVENTS.APP_START.ToString()];
            }
            else
            {
                properties = new Dictionary<string, object>();
            }
            if (mEventCallback_PC != null)
            {
                ThinkingSDKUtil.AddDictionary(properties, mEventCallback_PC.AutoTrackEventCallback_PC((int) AUTO_TRACK_EVENTS.APP_START, properties));
            }
            ThinkingPCSDK.Track(ThinkingSDKConstant.START_EVENT, properties);
            ThinkingPCSDK.Flush();
        }
        if ((events & AUTO_TRACK_EVENTS.APP_END) != 0 && mStarted == false)
        {
            ThinkingPCSDK.TimeEvent(ThinkingSDKConstant.END_EVENT);
        }
    }

    public void SetAutoTrackProperties(AUTO_TRACK_EVENTS events, Dictionary<string, object> properties)
    {
        mAutoTrackEvents = events;
        if ((events & AUTO_TRACK_EVENTS.APP_INSTALL) != 0)
        {
            if (mAutoTrackProperties.ContainsKey(AUTO_TRACK_EVENTS.APP_INSTALL.ToString()))
            {
                ThinkingSDKUtil.AddDictionary(mAutoTrackProperties[AUTO_TRACK_EVENTS.APP_INSTALL.ToString()], properties);
            }
            mAutoTrackProperties[AUTO_TRACK_EVENTS.APP_INSTALL.ToString()] = properties;
        }
        if ((events & AUTO_TRACK_EVENTS.APP_START) != 0)
        {
            if (mAutoTrackProperties.ContainsKey(AUTO_TRACK_EVENTS.APP_START.ToString()))
            {
                ThinkingSDKUtil.AddDictionary(mAutoTrackProperties[AUTO_TRACK_EVENTS.APP_START.ToString()], properties);
            }
            mAutoTrackProperties[AUTO_TRACK_EVENTS.APP_START.ToString()] = properties;
        }
        if ((events & AUTO_TRACK_EVENTS.APP_END) != 0)
        {
            if (mAutoTrackProperties.ContainsKey(AUTO_TRACK_EVENTS.APP_END.ToString()))
            {
                ThinkingSDKUtil.AddDictionary(mAutoTrackProperties[AUTO_TRACK_EVENTS.APP_END.ToString()], properties);
            }
            mAutoTrackProperties[AUTO_TRACK_EVENTS.APP_END.ToString()] = properties;
        }
        if ((events & AUTO_TRACK_EVENTS.APP_CRASH) != 0)
        {
            if (mAutoTrackProperties.ContainsKey(AUTO_TRACK_EVENTS.APP_CRASH.ToString()))
            {
                ThinkingSDKUtil.AddDictionary(mAutoTrackProperties[AUTO_TRACK_EVENTS.APP_CRASH.ToString()], properties);
            }
            mAutoTrackProperties[AUTO_TRACK_EVENTS.APP_CRASH.ToString()] = properties;
        }
    }

}
