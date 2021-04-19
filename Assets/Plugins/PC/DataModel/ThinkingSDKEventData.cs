using System;
using System.Collections.Generic;
using ThinkingSDK.PC.Constant;
using ThinkingSDK.PC.Time;
using ThinkingSDK.PC.Utils;

namespace ThinkingSDK.PC.DataModel
{
    public class ThinkingSDKEventData:ThinkingSDKBaseData
    {
        private DateTime mEventTime;
        //事件持续时长
        private float mDuration;
        public void SetEventTime(DateTime dateTime)
        {
            this.mEventTime = dateTime;
        }

        //public DateTime EventTime()
        //{
        //    return this.mEventTime;
        //}
        public DateTime Time()
        {
            return mEventTime;
        }
        public ThinkingSDKEventData(string eventName) : base(eventName)
        {
        }

        public ThinkingSDKEventData(ThinkingSDKTimeInter time, string eventName):base(time,eventName)
        {
        }
        public ThinkingSDKEventData(ThinkingSDKTimeInter time, string eventName, Dictionary<string, object> properties):base(time,eventName,properties)
        {            
        }
        public override string GetDataType()
        {
            return "track";
        }
        public void SetDuration(float duration)
        {
            this.mDuration = duration;
        }

        public override Dictionary<string, object> ToDictionary()
        {
            Dictionary<string, object> data = new Dictionary<string, object>();
            data[ThinkingSDKConstant.TYPE] = GetDataType();
            data[ThinkingSDKConstant.TIME] = this.EventTime().GetTime();
            data[ThinkingSDKConstant.DISTINCT_ID] = this.DistinctID();
            if (!string.IsNullOrEmpty(this.EventName()))
            {
                data[ThinkingSDKConstant.EVENT_NAME] = this.EventName();
            }
            if (!string.IsNullOrEmpty(this.AccountID()))
            {
                data[ThinkingSDKConstant.ACCOUNT_ID] = this.AccountID();
            }
            data[ThinkingSDKConstant.UUID] = this.UUID();
            Dictionary<string, object> properties = this.Properties();
            properties[ThinkingSDKConstant.ZONE_OFFSET] = this.EventTime().GetZoneOffset();
            if (mDuration != 0)
            {
                properties[ThinkingSDKConstant.DURATION] = mDuration;
            }
            data[ThinkingSDKConstant.PROPERTIES] = properties;
            
            return data;
        }
    }
}
