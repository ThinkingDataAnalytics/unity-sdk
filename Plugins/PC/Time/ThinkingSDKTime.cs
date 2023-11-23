using System;
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

        public string GetTime(TimeZoneInfo timeZone)
        {
            if (timeZone == null)
            {
                return ThinkingSDKUtil.FormatDate(mDate, mTimeZone);
            }
            else
            {
                return ThinkingSDKUtil.FormatDate(mDate, timeZone);
            }
        }

        public double GetZoneOffset(TimeZoneInfo timeZone)
        {
            if (timeZone == null)
            {
                return ThinkingSDKUtil.ZoneOffset(mDate, mTimeZone);
            }
            else
            {
                return ThinkingSDKUtil.ZoneOffset(mDate, timeZone);
            }
        }
    }

}
