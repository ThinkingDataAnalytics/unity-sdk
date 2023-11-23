using System.Collections.Generic;
using ThinkingSDK.PC.Constant;
using ThinkingSDK.PC.Time;

namespace ThinkingSDK.PC.DataModel
{
    public class ThinkingSDKUserData:ThinkingSDKBaseData
    {
        public ThinkingSDKUserData(ThinkingSDKTimeInter time,string eventType, Dictionary<string,object> properties)
        {
            this.SetEventType(eventType);
            this.SetTime(time);
            this.SetBaseData(null);
            this.SetProperties(properties);
        }
        override public Dictionary<string, object> ToDictionary()
        {
            Dictionary<string, object> data = new Dictionary<string, object>();
            data[ThinkingSDKConstant.TYPE] = GetDataType();
            data[ThinkingSDKConstant.TIME] = EventTime().GetTime(null);
            data[ThinkingSDKConstant.DISTINCT_ID] = DistinctID();
            if (!string.IsNullOrEmpty(AccountID()))
            {
                data[ThinkingSDKConstant.ACCOUNT_ID] = AccountID();
            }
            data[ThinkingSDKConstant.UUID] = UUID();
            data[ThinkingSDKConstant.PROPERTIES] = Properties();
            return data;
        }
    }
}
