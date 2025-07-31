using System;
using ThinkingSDK.PC.Config;
using ThinkingSDK.PC.Utils;

namespace ThinkingSDK.PC.Time
{
    public class ThinkingSDKTimestampCalibration : ThinkingSDKTimeCalibration
    {

        public ThinkingSDKTimestampCalibration(long timestamp)
        {
            DateTime dateTimeUtcNow = DateTime.UtcNow;
            this.mStartTime = timestamp;
            this.mSystemElapsedRealtime = Environment.TickCount;

            double time_offset = (ConvertDateTimeInt(dateTimeUtcNow) - timestamp) / 1000;
            if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("Time Calibration with NTP (" + timestamp + "), diff = " + time_offset.ToString("0.000s"));
        }
    }
}

