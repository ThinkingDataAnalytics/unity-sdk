using System;
using ThinkingSDK.PC.Utils;

namespace ThinkingSDK.PC.Time
{
    public class ThinkingSDKCalibratedTime : ThinkingSDKTimeInter
    {
        private ThinkingSDKTimeCalibration mCalibratedTime;
        private long mSystemElapsedRealtime;
        private TimeZoneInfo mTimeZone;
        private DateTime mDate;
        public ThinkingSDKCalibratedTime(ThinkingSDKTimeCalibration calibrateTimeInter,TimeZoneInfo timeZoneInfo)
        {
            this.mCalibratedTime = calibrateTimeInter;
            this.mTimeZone = timeZoneInfo;
            this.mDate = mCalibratedTime.NowDate();
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
