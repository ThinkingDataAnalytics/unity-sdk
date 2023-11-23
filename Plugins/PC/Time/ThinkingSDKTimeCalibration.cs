using System;

namespace ThinkingSDK.PC.Time
{
    public class ThinkingSDKTimeCalibration
    {
        /// <summary>
        /// Timestamp when time was calibrated
        /// </summary>
        public long mStartTime;
        /// <summary>
        /// System boot time when calibrating time
        /// </summary>
        public long mSystemElapsedRealtime;
        public DateTime NowDate()
        {
            long nowTime = Environment.TickCount;
            long timestamp = nowTime - this.mSystemElapsedRealtime + this.mStartTime;
            // DateTime dt = DateTimeOffset.FromUnixTimeMilliseconds(timestamp).LocalDateTime;
            // return dt;
            
            DateTime dt = new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc);
            return dt.AddMilliseconds(timestamp);
        }

        protected static double ConvertDateTimeInt(System.DateTime time)
        {
            DateTime startTime = new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc);
            return (double)(time - startTime).TotalMilliseconds;
        }
    }
}