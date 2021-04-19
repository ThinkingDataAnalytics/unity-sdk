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
            ThinkingSDKLogger.Print("nowDate=" + this.mDate);
        }
        public string GetTime()
        {
            return ThinkingSDKUtil.FormatDate(mDate, mTimeZone);
        }

        public double GetZoneOffset()
        {
            return ThinkingSDKUtil.ZoneOffset(mDate, mTimeZone);
        }
    }

}
