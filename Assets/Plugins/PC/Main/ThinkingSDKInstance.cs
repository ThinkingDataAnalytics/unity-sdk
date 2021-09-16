using System;
using System.Collections.Generic;
using ThinkingSDK.PC.Config;
using ThinkingSDK.PC.Constant;
using ThinkingSDK.PC.DataModel;
using ThinkingSDK.PC.Request;
using ThinkingSDK.PC.Storage;
using ThinkingSDK.PC.TaskManager;
using ThinkingSDK.PC.Time;
using ThinkingSDK.PC.Utils;
using UnityEngine;

namespace ThinkingSDK.PC.Main
{
    [Flags]
    public enum AUTO_TRACK_EVENTS
    {
        NONE = 0,
        APP_START = 1 << 0, // 当应用进入前台的时候触发上报，对应 ta_app_start
        APP_END = 1 << 1, // 当应用进入后台的时候触发上报，对应 ta_app_end
        APP_CRASH = 1 << 4, // 当出现未捕获异常的时候触发上报，对应 ta_app_crash
        APP_INSTALL = 1 << 5, // 应用安装后首次打开的时候触发上报，对应 ta_app_install
        ALL = APP_START | APP_END | APP_INSTALL | APP_CRASH
    }

    public interface IDynamicSuperProperties
    {
         Dictionary<string, object> GetDynamicSuperProperties();
    }
    public class ThinkingSDKInstance
    {
        private string mAppid;
        private string mServer;
        protected string mDistinctID;
        protected string mAccountID;
        private bool mOptTracking = true;
        private Dictionary<string, object> mTimeEvents = new Dictionary<string, object>();
        private bool mEnableTracking = true;
        protected Dictionary<string, object> mSupperProperties = new Dictionary<string, object>();
        private ThinkingSDKConfig mConfig;
        private ThinkingSDKBaseRequest mRequest;
        private ThinkingSDKTimeCalibration mTimeCalibration;
        private IDynamicSuperProperties mDynamicProperties;
        private ThinkingSDKTask mTask = ThinkingSDKTask.SingleTask();
        private static ThinkingSDKInstance mCurrentInstance;

        ResponseHandle mResponseHandle;
        public void SetTimeCalibratieton(ThinkingSDKTimeCalibration timeCalibration)
        {
            this.mTimeCalibration = timeCalibration;
        }
        private ThinkingSDKInstance()
        {

        }
        private void DefaultData()
        {
            DistinctId();
            AccountID();
            SuperProperties();
            DefaultTrackState();
        }
        public ThinkingSDKInstance(string appid,string server):this(appid,server,null)
        {
         
            
        }
        public ThinkingSDKInstance(string appid, string server, ThinkingSDKConfig config)
        {
            mResponseHandle = delegate (Dictionary<string, object> result) {
                mTask.Release();
            };
            if (config == null)
            {
                this.mConfig = ThinkingSDKConfig.GetInstance(appid, server);
            }
            else
            {
                this.mConfig = config;
            }
            this.mConfig.UpdateConfig();
            this.mAppid = appid;
            this.mServer = server;
            if (this.mConfig.GetMode() == Mode.NORMAL)
            {
                this.mRequest = new ThinkingSDKNormalRequest(appid, this.mConfig.NormalURL());
            }
            else
            {
                this.mRequest = new ThinkingSDKDebugRequest(appid,this.mConfig.DebugURL());
                if (this.mConfig.GetMode() == Mode.DEBUG_ONLY)
                {
                    ((ThinkingSDKDebugRequest)this.mRequest).SetDryRun(1);
                }
            }
            DefaultData();
            mCurrentInstance = this;
        }
        public static ThinkingSDKInstance CreateLightInstance()
        {
            ThinkingSDKInstance lightInstance = new LightThinkingSDKInstance(mCurrentInstance.mAppid, mCurrentInstance.mServer, mCurrentInstance.mConfig);
            return lightInstance;
        }
        public ThinkingSDKTimeInter GetTime(DateTime dateTime)
        {
            ThinkingSDKTimeInter time = null;
            
            if ( dateTime == DateTime.MinValue || dateTime == null)
            {
                if (mTimeCalibration == null)//判断是否有时间校准
                {
                    time = new ThinkingSDKTime(mConfig.TimeZone(), DateTime.Now);
                }
                else
                {
                    time = new ThinkingSDKCalibratedTime(mTimeCalibration, mConfig.TimeZone());
                }
            }
            else
            {
                time = new ThinkingSDKTime(mConfig.TimeZone(), dateTime);
            }
           
            return time;
        }
        //设置访客ID
        public virtual void Identifiy(string distinctID)
        {
            if (IsPaused())
            {
                return;
            }
            if (!string.IsNullOrEmpty(distinctID))
            {
                this.mDistinctID = distinctID;
                ThinkingSDKFile.SaveData(mAppid, ThinkingSDKConstant.DISTINCT_ID,distinctID);
            }
        }
        public virtual string DistinctId()
        {
          
            this.mDistinctID = (string)ThinkingSDKFile.GetData(this.mAppid,ThinkingSDKConstant.DISTINCT_ID, typeof(string));
            if (string.IsNullOrEmpty(this.mDistinctID))
            {
                this.mDistinctID = ThinkingSDKUtil.RandomID();
                ThinkingSDKFile.SaveData(this.mAppid, ThinkingSDKConstant.DISTINCT_ID, this.mDistinctID);
            }
            
            return this.mDistinctID;
        }

        public virtual void Login(string accountID)
        {
            if (IsPaused())
            {
                return;
            }
            if (!string.IsNullOrEmpty(accountID))
            {
                this.mAccountID = accountID;
                ThinkingSDKFile.SaveData(mAppid, ThinkingSDKConstant.ACCOUNT_ID, accountID);
            }
        }
        public virtual string AccountID()
        {
            this.mAccountID = (string)ThinkingSDKFile.GetData(this.mAppid,ThinkingSDKConstant.ACCOUNT_ID, typeof(string));
            return this.mAccountID;
        }
        public virtual void Logout()
        {
            if (IsPaused())
            {
                return;
            }

            this.mAccountID = "";
            ThinkingSDKFile.DeleteData(this.mAppid,ThinkingSDKConstant.ACCOUNT_ID);
        }
       
        //TODO
        public virtual void EnableAutoTrack(AUTO_TRACK_EVENTS events)
        {
            if ((events & AUTO_TRACK_EVENTS.APP_INSTALL) != 0)
            {
                object result = ThinkingSDKFile.GetData(mAppid, ThinkingSDKConstant.IS_INSTALL, typeof(int));
                if (result == null)
                {
                    ThinkingSDKFile.SaveData(mAppid, ThinkingSDKConstant.IS_INSTALL, 1);
                    Track(ThinkingSDKConstant.INSTALL_EVENT);
                } 
            }

            if ((events & AUTO_TRACK_EVENTS.APP_START) != 0)
            {
                Track(ThinkingSDKConstant.START_EVENT);
            }
        }
        public void Track(string eventName)
        {
            
            Track(eventName, null, DateTime.MinValue);
            
        }
        public void Track(string eventName, Dictionary<string, object> properties)
        {
            Track(eventName, properties, DateTime.MinValue);
        }
        public void Track(string eventName, Dictionary<string, object> properties, DateTime date)
        {
            
            Track(eventName, properties, date, false);
        }
        public void Track(string eventName, Dictionary<string, object> properties, DateTime date, bool immediately)
        {
            ThinkingSDKTimeInter time = GetTime(date);
            ThinkingSDKEventData data = new ThinkingSDKEventData(time, eventName, properties);
            SendData(data, immediately);
        }
        private void SendData(ThinkingSDKEventData data)
        {
            SendData(data, false);
        }
        private void SendData(ThinkingSDKEventData data, bool immediately)
        {
            if (this.mDynamicProperties != null)
            {
                data.SetProperties(this.mDynamicProperties.GetDynamicSuperProperties(),false);
            }
            if (this.mSupperProperties != null && this.mSupperProperties.Count > 0)
            {
                data.SetProperties(this.mSupperProperties,false);
            }
            data.SetProperties(ThinkingSDKUtil.DeviceInfo(), false);

            float duration = 0;
            if (mTimeEvents.ContainsKey(data.EventName()))
            {
                int beginTime = (int)mTimeEvents[data.EventName()];
                int nowTime = Environment.TickCount;
                duration = (float)((nowTime - beginTime) / 1000.0);
                mTimeEvents.Remove(data.EventName());

            }
            if (duration != 0)
            {
                data.SetDuration(duration);
            }
          
            SendData((ThinkingSDKBaseData)data, immediately);
        }
        private void SendData(ThinkingSDKBaseData data)
        {
            SendData(data, false);
        }
        private void SendData(ThinkingSDKBaseData data, bool immediately)
        {
            if (IsPaused())
            {
                return;
            }
            if (!string.IsNullOrEmpty(this.mAccountID))
            {
                data.SetAccountID(this.mAccountID);
            }
            if (string.IsNullOrEmpty(this.mDistinctID))
            {
                DistinctId();
            }
            data.SetDistinctID(this.mDistinctID);

            if (this.mConfig.IsDisabledEvent(data.EventName()))
            {
                Debug.Log("disabled Event: " + data.EventName());
                return;
            }
            IList<Dictionary<string, object>> list = new List<Dictionary<string, object>>();
            list.Add(data.ToDictionary());
            if (this.mConfig.GetMode() == Mode.NORMAL && this.mRequest.GetType() != typeof(ThinkingSDKNormalRequest))
            {
                this.mRequest = new ThinkingSDKNormalRequest(this.mAppid, this.mConfig.NormalURL());
            }

            if (immediately)
            {
                mRequest.SendData(null, list);
            }
            else
            {
                mTask.StartRequest(mRequest, mResponseHandle, list);
            }
        }
        /// <summary>
        /// 发送数据
        /// </summary>
        public virtual void Flush()
        {
            mTask.SyncInvokeAllTask();
        }
        public void Track(ThinkingSDKEventData analyticsEvent)
        {
            ThinkingSDKTimeInter time = GetTime(analyticsEvent.Time());
            analyticsEvent.SetTime(time);
            SendData(analyticsEvent);
        }

        public virtual void SetSuperProperties(Dictionary<string, object> superProperties)
        {
            if (IsPaused())
            {
                return;
            }
            Dictionary<string, object> properties = new Dictionary<string, object>();
            string propertiesStr = (string)ThinkingSDKFile.GetData(this.mAppid, ThinkingSDKConstant.SUPER_PROPERTY, typeof(string));
            if (!string.IsNullOrEmpty(propertiesStr))
            {
                properties = ThinkingSDKJSON.Deserialize(propertiesStr);
            }
            ThinkingSDKUtil.AddDictionary(properties, superProperties);
            this.mSupperProperties = properties;
            ThinkingSDKFile.SaveData(this.mAppid, ThinkingSDKConstant.SUPER_PROPERTY, ThinkingSDKJSON.Serialize(this.mSupperProperties));
        }
        public virtual void UnsetSuperProperty(string propertyKey)
        {
            if (IsPaused())
            {
                return;
            }
            Dictionary<string, object> properties = new Dictionary<string, object>();
            string propertiesStr = (string)ThinkingSDKFile.GetData(this.mAppid, ThinkingSDKConstant.SUPER_PROPERTY, typeof(string));
            if (!string.IsNullOrEmpty(propertiesStr))
            {
                properties = ThinkingSDKJSON.Deserialize(propertiesStr);
            }
            if (properties.ContainsKey(propertyKey))
            {
                properties.Remove(propertyKey);
            }
            this.mSupperProperties = properties;
            ThinkingSDKFile.SaveData(this.mAppid, ThinkingSDKConstant.SUPER_PROPERTY, ThinkingSDKJSON.Serialize(this.mSupperProperties));
        }
        public virtual Dictionary<string, object> SuperProperties()
        {
            string propertiesStr = (string)ThinkingSDKFile.GetData(this.mAppid, ThinkingSDKConstant.SUPER_PROPERTY, typeof(string));
            if (!string.IsNullOrEmpty(propertiesStr))
            {
                this.mSupperProperties = ThinkingSDKJSON.Deserialize(propertiesStr);
            }
            return this.mSupperProperties;
        }
        public  Dictionary<string, object> PresetProperties()
        {
            Dictionary<string, object> presetProperties = new Dictionary<string, object>();
            presetProperties[ThinkingSDKConstant.DEVICE_ID] = ThinkingSDKDeviceInfo.DeviceID();
            presetProperties[ThinkingSDKConstant.CARRIER] = ThinkingSDKDeviceInfo.Carrier();
            presetProperties[ThinkingSDKConstant.OS] = ThinkingSDKDeviceInfo.OS();
            presetProperties[ThinkingSDKConstant.SCREEN_HEIGHT] = ThinkingSDKDeviceInfo.ScreenHeight();
            presetProperties[ThinkingSDKConstant.SCREEN_WIDTH] = ThinkingSDKDeviceInfo.ScreenWidth();
            presetProperties[ThinkingSDKConstant.MANUFACTURE] = ThinkingSDKDeviceInfo.Manufacture();
            presetProperties[ThinkingSDKConstant.DEVICE_MODEL] = ThinkingSDKDeviceInfo.DeviceModel();
            presetProperties[ThinkingSDKConstant.SYSTEM_LANGUAGE] = ThinkingSDKDeviceInfo.MachineLanguage();
            presetProperties[ThinkingSDKConstant.OS_VERSION] = ThinkingSDKDeviceInfo.OSVersion();
            presetProperties[ThinkingSDKConstant.NETWORK_TYPE] = ThinkingSDKDeviceInfo.NetworkType();
            presetProperties[ThinkingSDKConstant.APP_BUNDLEID] = ThinkingSDKAppInfo.AppIdentifier();
            presetProperties[ThinkingSDKConstant.ZONE_OFFSET] = ThinkingSDKUtil.ZoneOffset(DateTime.Now, this.mConfig.TimeZone());
            
            return presetProperties;
        }
        public virtual void ClearSuperProperties()
        {
            if (IsPaused())
            {
                return;
            }
            this.mSupperProperties.Clear();
            ThinkingSDKFile.DeleteData(this.mAppid,ThinkingSDKConstant.SUPER_PROPERTY);
        }

        public void TimeEvent(string eventName)
        {
            if (!mTimeEvents.ContainsKey(eventName))
            {
                mTimeEvents.Add(eventName, Environment.TickCount);
            }
        }
        public void UserSet(Dictionary<string, object> properties)
        {
            UserSet(properties, DateTime.MinValue);
        }
        public void UserSet(Dictionary<string, object> properties,DateTime dateTime)
        {
            ThinkingSDKTimeInter time = GetTime(dateTime);
            ThinkingSDKUserData data = new ThinkingSDKUserData(time, ThinkingSDKConstant.USER_SET, properties);
            SendData(data);
        }
        public void UserUnset(string propertyKey)
        {
            UserUnset(propertyKey, DateTime.MinValue);
        }
        public void UserUnset(string propertyKey, DateTime dateTime)
        {
            ThinkingSDKTimeInter time = GetTime(dateTime);
            Dictionary<string, object> properties = new Dictionary<string, object>();
            properties[propertyKey] = 0;
            ThinkingSDKUserData data = new ThinkingSDKUserData(time, ThinkingSDKConstant.USER_UNSET, properties);
            SendData(data);
        }
        public void UserUnset(List<string> propertyKeys)
        {
            UserUnset(propertyKeys,DateTime.MinValue);
        }
        public void UserUnset(List<string> propertyKeys, DateTime dateTime)
        {
            ThinkingSDKTimeInter time = GetTime(dateTime);
            Dictionary<string, object> properties = new Dictionary<string, object>();
            foreach (string key in propertyKeys)
            {
                properties[key] = 0;
            }
            ThinkingSDKUserData data = new ThinkingSDKUserData(time, ThinkingSDKConstant.USER_UNSET, properties);
            SendData(data);
        }
        public void UserSetOnce(Dictionary<string, object> properties)
        {
            UserSetOnce(properties, DateTime.MinValue);
        }
        public void UserSetOnce(Dictionary<string, object> properties, DateTime dateTime)
        {
            ThinkingSDKTimeInter time = GetTime(dateTime);
            ThinkingSDKUserData data = new ThinkingSDKUserData(time, ThinkingSDKConstant.USER_SETONCE, properties);
            SendData(data);
        }
        public void UserAdd(Dictionary<string, object> properties)
        {
            UserAdd(properties, DateTime.MinValue);
        }
        public void UserAdd(Dictionary<string, object> properties, DateTime dateTime)
        {
            ThinkingSDKTimeInter time = GetTime(dateTime);
            ThinkingSDKUserData data = new ThinkingSDKUserData(time, ThinkingSDKConstant.USER_ADD, properties);
            SendData(data);
        }
        public void UserAppend(Dictionary<string, object> properties)
        {
            UserAppend(properties, DateTime.MinValue);
        }
        public void UserAppend(Dictionary<string, object> properties, DateTime dateTime)
        {
            ThinkingSDKTimeInter time = GetTime(dateTime);
            ThinkingSDKUserData data = new ThinkingSDKUserData(time, ThinkingSDKConstant.USER_APPEND, properties);
            SendData(data);
        }
        public  void UserDelete()
        {
            UserDelete(DateTime.MinValue);
        }
        public  void UserDelete(DateTime dateTime)
        {
            ThinkingSDKTimeInter time = GetTime(dateTime);
            Dictionary<string, object> properties = new Dictionary<string, object>();
            ThinkingSDKUserData data = new ThinkingSDKUserData(time, ThinkingSDKConstant.USER_DEL,properties);
            SendData(data);
        }
        public void SetDynamicSuperProperties(IDynamicSuperProperties dynamicSuperProperties)
        {
            if (IsPaused())
            {
                return;
            }
            this.mDynamicProperties = dynamicSuperProperties;
        }
        protected bool IsPaused()
        {
            bool mIsPaused = !mEnableTracking || !mOptTracking;
            if (mIsPaused)
            {
                ThinkingSDKLogger.Print("已暂停/已停止数据上报");
            }
            return mIsPaused;
        }
        /*
        停止或开启数据上报,默认是开启状态,设置为停止时还会清空本地的访客ID,账号ID,静态公共属性
        其中true表示可以上报数据,false表示停止数据上报
        **/
        public void OptTracking(bool optTracking)
        {
            mOptTracking = optTracking;
            int opt = optTracking ? 1 : 0;
            ThinkingSDKFile.SaveData(mAppid, ThinkingSDKConstant.OPT_TRACK, opt);
            if (!optTracking)
            {
                ThinkingSDKFile.DeleteData(mAppid, ThinkingSDKConstant.ACCOUNT_ID);
                ThinkingSDKFile.DeleteData(mAppid, ThinkingSDKConstant.DISTINCT_ID);
                ThinkingSDKFile.DeleteData(mAppid, ThinkingSDKConstant.SUPER_PROPERTY);
                this.mAccountID = null;
                this.mDistinctID = null;
                this.mSupperProperties = new Dictionary<string, object>();
            }
        }
        //是否暂停数据上报,默认是正常上报状态,其中true表示可以上报数据,false表示暂停数据上报
        public void EnableTracking(bool isEnable)
        {
            mEnableTracking = isEnable;
            int enable = isEnable ? 1 : 0;
            ThinkingSDKFile.SaveData(mAppid, ThinkingSDKConstant.ENABLE_TRACK,enable);
        }
        private void DefaultTrackState()
        {
            object enableTrack = ThinkingSDKFile.GetData(mAppid, ThinkingSDKConstant.ENABLE_TRACK, typeof(int));
            object optTrack = ThinkingSDKFile.GetData(mAppid, ThinkingSDKConstant.OPT_TRACK, typeof(int));
            if (enableTrack != null)
            {
                this.mEnableTracking = ((int)enableTrack) == 1;
            }
            else
            {
                this.mEnableTracking = true;
            }
            if (optTrack != null)
            {
                this.mOptTracking = ((int)optTrack) == 1;
            }
            else
            {
                this.mOptTracking = true;
            }
        }
        //停止数据上报
        public void OptTrackingAndDeleteUser()
        {
            UserDelete();
            OptTracking(false);
        }
        public string TimeString(DateTime dateTime)
        {
            return ThinkingSDKUtil.FormatDate(dateTime, mConfig.TimeZone());
        }
    }
}

