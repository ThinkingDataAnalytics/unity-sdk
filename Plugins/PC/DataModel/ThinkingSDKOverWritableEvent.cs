using System;
using System.Collections.Generic;
using ThinkingSDK.PC.Constant;
using ThinkingSDK.PC.Time;
using ThinkingSDK.PC.Utils;

namespace ThinkingSDK.PC.DataModel
{
    public class ThinkingSDKOverWritableEvent:ThinkingSDKEventData
    {
        private string mEventID;
        public ThinkingSDKOverWritableEvent(string eventName,string eventID) : base(eventName)
        {
            this.mEventID = eventID;
        }
        public override string GetDataType()
        {
            return "track_overwrite";
        }
        override public Dictionary<string, object> ToDictionary()
        {
            Dictionary<string, object> dictionary = base.ToDictionary();
            dictionary[ThinkingSDKConstant.EVENT_ID] = mEventID;
            return dictionary;
        }
    }
}
