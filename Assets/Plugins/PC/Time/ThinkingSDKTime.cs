using System;
using ThinkingSDK.PC.Time;
using ThinkingSDK.PC.Utils;

namespace ThinkingSDK.PC.Time
{
    public class ThinkingSDKTime : ThinkingSDKTimeInter
    {
        private TimeZoneInfo mTimeZone;
        private DateTime mDate;

        public ThinkingSDKTime(TimeZoneInfo timezone, DateTime date)
        {
            this.mTimeZone = timezone;
            this.mDate = date;
        }

        public string GetTime()
        {
            return ThinkingSDKUtil.FormatDate(mDate,mTimeZone);
        }
      
        public double GetZoneOffset()
        {
            return ThinkingSDKUtil.ZoneOffset(mDate, mTimeZone);
        }
    }

}
