using System.Collections.Generic;
using ThinkingSDK.PC.Constant;
using ThinkingSDK.PC.Utils;
namespace ThinkingSDK.PC.DataModel
{
    public class ThinkingSDKFirstEvent:ThinkingSDKEventData
    {
        private string mFirstCheckId;
        public ThinkingSDKFirstEvent(string eventName):base(eventName)
        {

        }
        public void SetFirstCheckId(string firstCheckId)
        {
            mFirstCheckId = firstCheckId;
        }
        public string FirstCheckId()
        {
            if (string.IsNullOrEmpty(mFirstCheckId))
            {
                return ThinkingSDKDeviceInfo.DeviceID();
            }
            else
            {
                return mFirstCheckId;
            }
        }
        override public Dictionary<string, object> ToDictionary()
        {
            Dictionary<string,object> dictionary = base.ToDictionary();
            dictionary[ThinkingSDKConstant.FIRST_CHECK_ID] = FirstCheckId();
            return dictionary;
        }
    }
}
