using System;
namespace ThinkingSDK.PC.Time
{
    public class ThinkingSDKTimestampCalibration : ThinkingSDKTimeCalibration
    {

        public ThinkingSDKTimestampCalibration(long timestamp)
        {
            this.mStartTime = timestamp;
            this.mSystemElapsedRealtime = Environment.TickCount;
        } 
    }
}

