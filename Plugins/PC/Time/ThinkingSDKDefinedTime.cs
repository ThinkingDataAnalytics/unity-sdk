using System;

namespace ThinkingSDK.PC.Time
{
    public class ThinkingSDKDefinedTime : ThinkingSDKTimeInter
    {
        private string mTime;
        private double mZoneOffset;
        public ThinkingSDKDefinedTime(string time,double zoneOffset)
        {
            this.mTime = time;
            this.mZoneOffset = zoneOffset;
        }
        public string GetTime(TimeZoneInfo timeZone)
        {
            return this.mTime;
        }

        public double GetZoneOffset(TimeZoneInfo timeZone)
        {
            return this.mZoneOffset;
        }
    }
}

