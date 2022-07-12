using System;
using System.Collections;
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
    // 数据上报状态
    public enum TA_TRACK_STATUS
    {
        PAUSE = 1, // 暂停数据上报
        STOP = 2, // 停止数据上报，并清除缓存
        SAVE_ONLY = 3, // 数据入库，但不上报
        NORMAL = 4 // 恢复数据上报
    }

    public interface IDynamicSuperProperties_PC
    {
         Dictionary<string, object> GetDynamicSuperProperties_PC();
    }
    public interface IAutoTrackEventCallback_PC
    {
        Dictionary<string, object> AutoTrackEventCallback_PC(int type, Dictionary<string, object>properties);
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
        private bool mEventSaveOnly = false; //事件数据仅保存，不上报
        protected Dictionary<string, object> mSupperProperties = new Dictionary<string, object>();
        protected Dictionary<string, Dictionary<string, object>> mAutoTrackProperties = new Dictionary<string, Dictionary<string, object>>();
        private ThinkingSDKConfig mConfig;
        private ThinkingSDKBaseRequest mRequest;
        private ThinkingSDKTimeCalibration mTimeCalibration;
        private IDynamicSuperProperties_PC mDynamicProperties;
        private ThinkingSDKTask mTask {
            get {
                return ThinkingSDKTask.SingleTask();
            }
            set {
                this.mTask = value;
            }
        }
        private static ThinkingSDKInstance mCurrentInstance;
        private MonoBehaviour mMono;
        private static MonoBehaviour sMono;
        private ThinkingSDKAutoTrack mAutoTrack;

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
        public ThinkingSDKInstance(string appid, string server, ThinkingSDKConfig config, MonoBehaviour mono = null)
        {
            this.mMono = mono;
            sMono = mono;
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
            this.mConfig.UpdateConfig(mono, delegate (Dictionary<string, object> result) {
                if (this.mConfig.GetMode() == Mode.NORMAL)
                {
                    sMono.StartCoroutine(WaitAndFlush());
                }
            });
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
            // 动态加载 ThinkingSDKTask ThinkingSDKAutoTrack
            GameObject mThinkingSDKTask = new GameObject("ThinkingSDKTask", typeof(ThinkingSDKTask));
            UnityEngine.Object.DontDestroyOnLoad(mThinkingSDKTask);

            GameObject mThinkingSDKAutoTrack = new GameObject("ThinkingSDKAutoTrack", typeof(ThinkingSDKAutoTrack));
            this.mAutoTrack = (ThinkingSDKAutoTrack) mThinkingSDKAutoTrack.GetComponent(typeof(ThinkingSDKAutoTrack));
            this.mAutoTrack.SetAppId(mAppid);
            UnityEngine.Object.DontDestroyOnLoad(mThinkingSDKAutoTrack);
        }
        public static ThinkingSDKInstance CreateLightInstance()
        {
            ThinkingSDKInstance lightInstance = new LightThinkingSDKInstance(mCurrentInstance.mAppid, mCurrentInstance.mServer, mCurrentInstance.mConfig, sMono);
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
        public virtual void EnableAutoTrack(AUTO_TRACK_EVENTS events, Dictionary<string, object> properties)
        {
            this.mAutoTrack.EnableAutoTrack(events, properties, mAppid);
        }
        public virtual void EnableAutoTrack(AUTO_TRACK_EVENTS events, IAutoTrackEventCallback_PC eventCallback)
        {
            this.mAutoTrack.EnableAutoTrack(events, eventCallback, mAppid);
        }
        // 设置自动采集事件的自定义属性
        public virtual void SetAutoTrackProperties(AUTO_TRACK_EVENTS events, Dictionary<string, object> properties)
        {
            this.mAutoTrack.SetAutoTrackProperties(events, properties);
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
                data.SetProperties(this.mDynamicProperties.GetDynamicSuperProperties_PC(),false);
            }
            if (this.mSupperProperties != null && this.mSupperProperties.Count > 0)
            {
                data.SetProperties(this.mSupperProperties,false);
            }
            Dictionary<string, object> deviceInfo = ThinkingSDKUtil.DeviceInfo();
            foreach (string item in ThinkingSDKUtil.DisPresetProperties)
            {
                if (deviceInfo.ContainsKey(item))
                {
                    deviceInfo.Remove(item);
                }
            }
            data.SetProperties(deviceInfo, false);

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
                ThinkingSDKLogger.Print("disabled Event: " + data.EventName());
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
                mRequest.SendData_2(null, list);
            }
            else
            {
                Dictionary<string, object> dataDic = data.ToDictionary();
                ThinkingSDKLogger.Print("Save event: " + ThinkingSDKJSON.Serialize(dataDic) + "\n  AppID: " + mAppid);
                int count = ThinkingSDKFileJson.EnqueueTrackingData(dataDic, mAppid);
                if (this.mConfig.GetMode() != Mode.NORMAL || count >= this.mConfig.mUploadSize)
                {
                    Flush();
                }
            }
        }

        private IEnumerator WaitAndFlush() 
        {
            while (true)
            {
                yield return new WaitForSeconds(mConfig.mUploadInterval);
                Flush();
            }
        }
        
        /// <summary>
        /// 发送数据
        /// </summary>
        public virtual void Flush()
        {
            if (mEventSaveOnly == false) {
                mTask.SyncInvokeAllTask();

                int batchSize = (this.mConfig.GetMode() != Mode.NORMAL) ? 1 : mConfig.mUploadSize;
                ResponseHandle responseHandle = delegate (Dictionary<string, object> result) {
                    int eventCount = 0;
                    if (result != null)
                    {
                        eventCount = ThinkingSDKFileJson.DeleteBatchTrackingData(batchSize, mAppid);
                    }
                    mTask.Release();
                    if (eventCount>0)
                    {
                        Flush();
                    }
                };
                mTask.StartRequest(mRequest, responseHandle, batchSize, mAppid);
            }
        }
        public void FlushImmediately()
        {
            if (mEventSaveOnly == false) {
                mTask.SyncInvokeAllTask();

                int batchSize = (this.mConfig.GetMode() != Mode.NORMAL) ? 1 : mConfig.mUploadSize;
                ResponseHandle responseHandle = delegate (Dictionary<string, object> result) {
                    int eventCount = 0;
                    if (result != null)
                    {
                        eventCount = ThinkingSDKFileJson.DeleteBatchTrackingData(batchSize, mAppid);
                    }
                    mTask.Release();
                    if (eventCount>0)
                    {
                        Flush();
                    }
                };
                IList<Dictionary<string, object>> list = ThinkingSDKFileJson.DequeueBatchTrackingData(batchSize, mAppid);
                if (list.Count>0)
                {
                    this.mMono.StartCoroutine(mRequest.SendData_2(responseHandle, list));
                }
            }
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
            presetProperties[ThinkingSDKConstant.APP_VERSION] = ThinkingSDKAppInfo.AppVersion();
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
        public void UserUniqAppend(Dictionary<string, object> properties)
        {
            UserUniqAppend(properties, DateTime.MinValue);
        }
        public void UserUniqAppend(Dictionary<string, object> properties, DateTime dateTime)
        {
            ThinkingSDKTimeInter time = GetTime(dateTime);
            ThinkingSDKUserData data = new ThinkingSDKUserData(time, ThinkingSDKConstant.USER_UNIQ_APPEND, properties);
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
        public void SetDynamicSuperProperties(IDynamicSuperProperties_PC dynamicSuperProperties)
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
                ThinkingSDKLogger.Print("Track status is Pause or Stop");
            }
            return mIsPaused;
        }

        public void SetTrackStatus(TA_TRACK_STATUS status)
        {
            ThinkingSDKLogger.Print("SetTrackStatus: " + status);
            switch (status)
            {
                case TA_TRACK_STATUS.PAUSE:
                    mEventSaveOnly = false;
                    OptTracking(true);
                    EnableTracking(false);
                    break;
                case TA_TRACK_STATUS.STOP:
                    mEventSaveOnly = false;
                    EnableTracking(true);
                    OptTracking(false);
                    break;
                case TA_TRACK_STATUS.SAVE_ONLY:
                    mEventSaveOnly = true;
                    EnableTracking(true);
                    OptTracking(true);
                    break;
                case TA_TRACK_STATUS.NORMAL:
                default:
                    mEventSaveOnly = false;
                    OptTracking(true);
                    EnableTracking(true);
                    Flush();
                    break;
            }
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
                ThinkingSDKFileJson.DeleteAllTrackingData(mAppid);
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

