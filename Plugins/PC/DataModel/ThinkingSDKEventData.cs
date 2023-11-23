using System;
using System.Collections.Generic;
using ThinkingSDK.PC.Constant;
using ThinkingSDK.PC.Time;

namespace ThinkingSDK.PC.DataModel
{
    public class ThinkingSDKEventData:ThinkingSDKBaseData
    {
        private DateTime mEventTime;
        private TimeZoneInfo mTimeZone;
        private float mDuration;
        private static Dictionary<string, object> mData;
        public void SetEventTime(DateTime dateTime)
        {
            this.mEventTime = dateTime;
        }
        public void SetTimeZone(TimeZoneInfo timeZone)
        {
            this.mTimeZone = timeZone;
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
            if (mData == null)
            {
                mData = new Dictionary<string, object>();
            }
            else
            {
                mData.Clear();
            }
            mData[ThinkingSDKConstant.TYPE] = GetDataType();
            mData[ThinkingSDKConstant.TIME] = this.EventTime().GetTime(this.mTimeZone);
            mData[ThinkingSDKConstant.DISTINCT_ID] = this.DistinctID();
            if (!string.IsNullOrEmpty(this.EventName()))
            {
                mData[ThinkingSDKConstant.EVENT_NAME] = this.EventName();
            }
            if (!string.IsNullOrEmpty(this.AccountID()))
            {
                mData[ThinkingSDKConstant.ACCOUNT_ID] = this.AccountID();
            }
            mData[ThinkingSDKConstant.UUID] = this.UUID();
            Dictionary<string, object> properties = this.Properties();
            properties[ThinkingSDKConstant.ZONE_OFFSET] = this.EventTime().GetZoneOffset(this.mTimeZone);
            if (mDuration != 0)
            {
                properties[ThinkingSDKConstant.DURATION] = mDuration;
            }
            mData[ThinkingSDKConstant.PROPERTIES] = properties;
            
            return mData;
        }
    }
}
