using System;
using System.Collections.Generic;
using ThinkingSDK.PC.Time;

namespace ThinkingSDK.PC.DataModel
{
    public abstract class ThinkingSDKBaseData
    {
        // event type
        private string mType;
        // event time
        private ThinkingSDKTimeInter mTime;
        // distinct ID
        private string mDistinctID;
        // event name
        private string mEventName;
        // account ID
        private string mAccountID;

        // unique ID for the event
        private string mUUID;
        private Dictionary<string, object> mProperties = new  Dictionary<string, object>();
        public Dictionary<string, object> Properties()
        {
            return mProperties;
        }
        public void SetEventName(string eventName)
        {
            this.mEventName = eventName;
        }
        public void SetEventType(string eventType)
        {
            this.mType = eventType;
        }
        public string EventName()
        {
            return this.mEventName;
        }
        public void SetTime(ThinkingSDKTimeInter time)
        {
            this.mTime = time;
        }
        public ThinkingSDKTimeInter EventTime()
        {
            return this.mTime;
        }
        public void SetDataType(string type)
        {
            this.mType = type;
        }
        virtual public String GetDataType()
        {
            return this.mType;
        }
        public string AccountID()
        {
            return this.mAccountID;
        }
        public string DistinctID()
        {
            return this.mDistinctID;
        }
        public void SetAccountID(string accuntID)
        {
            this.mAccountID = accuntID;
        }
        public void SetDistinctID(string distinctID)
        {
            this.mDistinctID = distinctID;
        }
        public string UUID()
        {
            return this.mUUID;
        }
        public ThinkingSDKBaseData() { }
        public ThinkingSDKBaseData(ThinkingSDKTimeInter time,string eventName)
        {
            this.SetBaseData(eventName);
            this.SetTime(time);
        }
        public ThinkingSDKBaseData(string eventName)
        {
            this.SetBaseData(eventName);
        }
        public void SetBaseData(string eventName)
        {
            this.mEventName = eventName;
            this.mUUID = System.Guid.NewGuid().ToString();
        }
        
        public ThinkingSDKBaseData(ThinkingSDKTimeInter time, string eventName, Dictionary<string, object> properties):this(time,eventName)
        {
            if (properties != null)
            {
                this.SetProperties(properties);
            }
        }

        abstract public Dictionary<string, object> ToDictionary();
        public void SetProperties(Dictionary<string, object> properties,bool isOverwrite = true)
        {
            if (isOverwrite)
            {
                foreach (KeyValuePair<string, object> kv in properties)
                {
                    mProperties[kv.Key] = kv.Value;

                }
            }
            else
            {
                foreach (KeyValuePair<string, object> kv in properties)
                {
                    if (!mProperties.ContainsKey(kv.Key))
                    {
                        mProperties[kv.Key] = kv.Value;
                    } 

                }
            }
            
        }
       
    }
}
