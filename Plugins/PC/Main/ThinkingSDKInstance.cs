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
    // Auto-tracking Events Type
    public enum TDAutoTrackEventType
    {
        None = 0,
        AppStart = 1 << 0, // reporting when the app enters the foreground （ta_app_start）
        AppEnd = 1 << 1, // reporting when the app enters the background （ta_app_end）
        AppCrash = 1 << 4, // reporting when an uncaught exception occurs （ta_app_crash）
        AppInstall = 1 << 5, // reporting when the app is opened for the first time after installation （ta_app_install）
        AppSceneLoad = 1 << 6, // reporting when the scene is loaded in the app （ta_scene_loaded）
        AppSceneUnload = 1 << 7, // reporting when the scene is unloaded in the app （ta_scene_loaded）
        All = AppStart | AppEnd | AppInstall | AppCrash | AppSceneLoad | AppSceneUnload
    }
    // Data Reporting Status
    public enum TDTrackStatus
    {
        Pause = 1, // pause data reporting
        Stop = 2, // stop data reporting, and clear caches
        SaveOnly = 3, // data stores in the cache, but not be reported
        Normal = 4 // resume data reporting
    }

    public interface TDDynamicSuperPropertiesHandler_PC
    {
         Dictionary<string, object> GetDynamicSuperProperties_PC();
    }
    public interface TDAutoTrackEventHandler_PC
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
        private Dictionary<string, object> mTimeEventsBefore = new Dictionary<string, object>();
        private bool mEnableTracking = true;
        private bool mEventSaveOnly = false; //data stores in the cache, but not be reported
        protected Dictionary<string, object> mSupperProperties = new Dictionary<string, object>();
        protected Dictionary<string, Dictionary<string, object>> mAutoTrackProperties = new Dictionary<string, Dictionary<string, object>>();
        private ThinkingSDKConfig mConfig;
        private ThinkingSDKBaseRequest mRequest;
        private static ThinkingSDKTimeCalibration mTimeCalibration;
        private static ThinkingSDKTimeCalibration mNtpTimeCalibration;
        private TDDynamicSuperPropertiesHandler_PC mDynamicProperties;
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

        WaitForSeconds flushDelay;
        public static void SetTimeCalibratieton(ThinkingSDKTimeCalibration timeCalibration)
        {
            mTimeCalibration = timeCalibration;
        }
        public static void SetNtpTimeCalibratieton(ThinkingSDKTimeCalibration timeCalibration)
        {
            mNtpTimeCalibration = timeCalibration;
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
        public ThinkingSDKInstance(string appId,string server):this(appId,server,null,null)
        {
         
            
        }
        public ThinkingSDKInstance(string appId, string server, string instanceName, ThinkingSDKConfig config, MonoBehaviour mono = null)
        {
            this.mMono = mono;
            sMono = mono;
            if (config == null)
            {
                this.mConfig = ThinkingSDKConfig.GetInstance(appId, server, instanceName);
            }
            else
            {
                this.mConfig = config;
            }
            this.mConfig.UpdateConfig(mono, ConfigResponseHandle);
            this.mAppid = appId;
            this.mServer = server;
            if (this.mConfig.GetMode() == Mode.NORMAL)
            {
                this.mRequest = new ThinkingSDKNormalRequest(appId, this.mConfig.NormalURL());
            }
            else
            {
                this.mRequest = new ThinkingSDKDebugRequest(appId,this.mConfig.DebugURL());
                if (this.mConfig.GetMode() == Mode.DEBUG_ONLY)
                {
                    ((ThinkingSDKDebugRequest)this.mRequest).SetDryRun(1);
                }
            }
            DefaultData();
            mCurrentInstance = this;
            // dynamic loading ThinkingSDKTask ThinkingSDKAutoTrack
            GameObject mThinkingSDKTask = new GameObject("ThinkingSDKTask", typeof(ThinkingSDKTask));
            UnityEngine.Object.DontDestroyOnLoad(mThinkingSDKTask);

            GameObject mThinkingSDKAutoTrack = new GameObject("ThinkingSDKAutoTrack", typeof(ThinkingSDKAutoTrack));
            this.mAutoTrack = (ThinkingSDKAutoTrack) mThinkingSDKAutoTrack.GetComponent(typeof(ThinkingSDKAutoTrack));
            if (!string.IsNullOrEmpty(instanceName))
            {
                this.mAutoTrack.SetAppId(instanceName);
            }
            else
            {
                this.mAutoTrack.SetAppId(this.mAppid);
            }
            UnityEngine.Object.DontDestroyOnLoad(mThinkingSDKAutoTrack);
        }
        private void EventResponseHandle(Dictionary<string, object> result)
        {
            int eventCount = 0;
            if (result != null)
            {
                int flushCount = 0;
                if (result.ContainsKey("flush_count"))
                {
                    flushCount = (int)result["flush_count"];
                }
                if (!string.IsNullOrEmpty(this.mConfig.InstanceName()))
                {
                    eventCount = ThinkingSDKFileJson.DeleteBatchTrackingData(flushCount, this.mConfig.InstanceName());
                }
                else
                {
                    eventCount = ThinkingSDKFileJson.DeleteBatchTrackingData(flushCount, this.mAppid);
                }
            }
            mTask.Release();
            if (eventCount > 0)
            {
                if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("Flush automatically (" + this.mAppid + ")");
                Flush();
            }
        }
        private void ConfigResponseHandle(Dictionary<string, object> result)
        {
            if (this.mConfig.GetMode() == Mode.NORMAL)
            {
                flushDelay = new WaitForSeconds(mConfig.mUploadInterval);
                sMono.StartCoroutine(WaitAndFlush());
            }
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
                if (mNtpTimeCalibration != null)// check if time calibrated
                {
                    time = new ThinkingSDKCalibratedTime(mNtpTimeCalibration, mConfig.TimeZone());
                }
                else if (mTimeCalibration != null)// check if time calibrated
                {
                    time = new ThinkingSDKCalibratedTime(mTimeCalibration, mConfig.TimeZone());
                }
                else
                {
                    time = new ThinkingSDKTime(mConfig.TimeZone(), DateTime.Now);
                }
            }
            else
            {
                time = new ThinkingSDKTime(mConfig.TimeZone(), dateTime);
            }
           
            return time;
        }
        // sets distisct ID
        public virtual void Identifiy(string distinctID)
        {
            if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("Setting distinct ID, DistinctId = " + distinctID);
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
            if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("Login SDK, AccountId = " + accountID);
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
            if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("Logout SDK");
            this.mAccountID = "";
            ThinkingSDKFile.DeleteData(this.mAppid,ThinkingSDKConstant.ACCOUNT_ID);
        }
        //TODO
        public virtual void EnableAutoTrack(TDAutoTrackEventType events, Dictionary<string, object> properties)
        {
            this.mAutoTrack.EnableAutoTrack(events, properties, mAppid);
        }
        public virtual void EnableAutoTrack(TDAutoTrackEventType events, TDAutoTrackEventHandler_PC eventCallback)
        {
            this.mAutoTrack.EnableAutoTrack(events, eventCallback, mAppid);
        }
        // sets auto-tracking events properties
        public virtual void SetAutoTrackProperties(TDAutoTrackEventType events, Dictionary<string, object> properties)
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
            Track(eventName, properties, date, null, false);
        }
        public void Track(string eventName, Dictionary<string, object> properties, DateTime date, TimeZoneInfo timeZone)
        {
            Track(eventName, properties, date, timeZone, false);
        }
        public void Track(string eventName, Dictionary<string, object> properties, DateTime date, TimeZoneInfo timeZone, bool immediately)
        {
            ThinkingSDKTimeInter time = GetTime(date);
            ThinkingSDKEventData data = new ThinkingSDKEventData(time, eventName, properties);
            if (timeZone != null)
            {
                data.SetTimeZone(timeZone);
            }
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
                if (mTimeEventsBefore.ContainsKey(data.EventName()))
                {
                    int beforeTime = (int)mTimeEventsBefore[data.EventName()];
                    duration = duration + (float)(beforeTime / 1000.0);
                    mTimeEventsBefore.Remove(data.EventName());
                }
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
                if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("Disabled Event: " + data.EventName());
                return;
            }
            if (this.mConfig.GetMode() == Mode.NORMAL && this.mRequest.GetType() != typeof(ThinkingSDKNormalRequest))
            {
                this.mRequest = new ThinkingSDKNormalRequest(this.mAppid, this.mConfig.NormalURL());
            }

            if (immediately)
            {
                Dictionary<string, object> dataDic = data.ToDictionary();
                this.mMono.StartCoroutine(mRequest.SendData_2(null, ThinkingSDKJSON.Serialize(dataDic), 1));
            }
            else
            {
                Dictionary<string, object> dataDic = data.ToDictionary();
                int count = 0;
                if (!string.IsNullOrEmpty(this.mConfig.InstanceName()))
                {
                    if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("Enqueue data: \n" + ThinkingSDKJSON.Serialize(dataDic) + "\n  AppId: " + this.mAppid);
                    count = ThinkingSDKFileJson.EnqueueTrackingData(dataDic, this.mConfig.InstanceName());
                }
                else
                {
                    if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("Enqueue data: \n" + ThinkingSDKJSON.Serialize(dataDic) + "\n  AppId: " + this.mAppid);
                    count = ThinkingSDKFileJson.EnqueueTrackingData(dataDic, this.mAppid);
                }
                if (this.mConfig.GetMode() != Mode.NORMAL || count >= this.mConfig.mUploadSize)
                {
                    if (count >= this.mConfig.mUploadSize)
                    {
                        if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("Flush automatically (" + this.mAppid + ")");
                    }
                    Flush();
                }
            }
        }

        private IEnumerator WaitAndFlush() 
        {
            while (true)
            {
                yield return flushDelay;
                if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("Flush automatically (" + this.mAppid + ")");
                Flush();
            }
        }
        
        /// <summary>
        /// flush events data
        /// </summary>
        public virtual void Flush()
        {
            if (mEventSaveOnly == false) {
                mTask.SyncInvokeAllTask();

                int batchSize = (this.mConfig.GetMode() != Mode.NORMAL) ? 1 : mConfig.mUploadSize;
                if (!string.IsNullOrEmpty(this.mConfig.InstanceName()))
                {
                    mTask.StartRequest(mRequest, EventResponseHandle, batchSize, this.mConfig.InstanceName());
                }
                else
                {
                    mTask.StartRequest(mRequest, EventResponseHandle, batchSize, this.mAppid);
                }
            }
        }
        //public void FlushImmediately()
        //{
        //    if (mEventSaveOnly == false)
        //    {
        //        mTask.SyncInvokeAllTask();

        //        int batchSize = (this.mConfig.GetMode() != Mode.NORMAL) ? 1 : mConfig.mUploadSize;
        //        string list;
        //        int eventCount = 0;
        //        if (!string.IsNullOrEmpty(this.mConfig.InstanceName()))
        //        {
        //            list = ThinkingSDKFileJson.DequeueBatchTrackingData(batchSize, this.mConfig.InstanceName(), out eventCount);
        //        }
        //        else
        //        {
        //            list = ThinkingSDKFileJson.DequeueBatchTrackingData(batchSize, this.mAppid, out eventCount);
        //        }
        //        if (eventCount > 0)
        //        {
        //            this.mMono.StartCoroutine(mRequest.SendData_2(EventResponseHandle, list, eventCount));
        //        }
        //    }
        //}
        public void Track(ThinkingSDKEventData eventModel)
        {
            ThinkingSDKTimeInter time = GetTime(eventModel.Time());
            eventModel.SetTime(time);
            SendData(eventModel);
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
        /// <summary>
        /// Pause Event timing
        /// </summary>
        /// <param name="status">ture: puase timing, false: resume timing</param>
        /// <param name="eventName">event name (null or empty is for all event)</param>
        public void PauseTimeEvent(bool status, string eventName = "")
        {
            if (string.IsNullOrEmpty(eventName))
            {
                string[] eventNames = new string[mTimeEvents.Keys.Count];
                mTimeEvents.Keys.CopyTo(eventNames, 0);
                for (int i=0; i< eventNames.Length; i++)
                {
                    string key = eventNames[i];
                    if (status == true)
                    {
                        int startTime = int.Parse(mTimeEvents[key].ToString());
                        int pauseTime = Environment.TickCount;
                        int duration = pauseTime - startTime;
                        if (mTimeEventsBefore.ContainsKey(key))
                        {
                            duration = duration + int.Parse(mTimeEventsBefore[key].ToString());
                        }
                        mTimeEventsBefore[key] = duration;
                    }
                    else
                    {
                        mTimeEvents[key] = Environment.TickCount;
                    }
                }
            }
            else
            {
                if (status == true)
                {
                    int startTime = int.Parse(mTimeEvents[eventName].ToString());
                    int pauseTime = Environment.TickCount;
                    int duration = pauseTime - startTime;
                    mTimeEventsBefore[eventName] = duration;
                }
                else
                {
                    mTimeEvents[eventName] = Environment.TickCount;
                }
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
        public void SetDynamicSuperProperties(TDDynamicSuperPropertiesHandler_PC dynamicSuperProperties)
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
                if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("SDK Track status is Pause or Stop");
            }
            return mIsPaused;
        }

        public void SetTrackStatus(TDTrackStatus status)
        {
            if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("Change Status to " + status);
            switch (status)
            {
                case TDTrackStatus.Pause:
                    mEventSaveOnly = false;
                    OptTracking(true);
                    EnableTracking(false);
                    break;
                case TDTrackStatus.Stop:
                    mEventSaveOnly = false;
                    EnableTracking(true);
                    OptTracking(false);
                    break;
                case TDTrackStatus.SaveOnly:
                    mEventSaveOnly = true;
                    EnableTracking(true);
                    OptTracking(true);
                    break;
                case TDTrackStatus.Normal:
                default:
                    mEventSaveOnly = false;
                    OptTracking(true);
                    EnableTracking(true);
                    Flush();
                    break;
            }
        }

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

