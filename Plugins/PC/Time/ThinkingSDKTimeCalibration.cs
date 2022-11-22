using System;
using System.Collections;
using System.Collections.Generic;
using ThinkingSDK.PC.Utils;
using UnityEngine;

namespace ThinkingSDK.PC.Time
{
    public class ThinkingSDKTimeCalibration
    {
        /// <summary>
        ///校准时间时的时间戳
        /// </summary>
        public long mStartTime;
        /// <summary>
        /// 校准时间时的系统开机时间
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

    }
}