using System;
namespace ThinkingData.Analytics.Utils
{
    public class TDCommonUtils
    {
        public static string FormatDate(DateTime dateTime, TimeZoneInfo timeZone)
        {
            bool success = true;
            DateTime univDateTime = dateTime.ToUniversalTime();
            TimeSpan timeSpan = new TimeSpan();
            try
            {
                timeSpan = timeZone.BaseUtcOffset;
            }
            catch (Exception)
            {
                success = false;
                //if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("FormatDate - TimeSpan get failed : " + e.Message);
            }
            try
            {
                if (timeZone.IsDaylightSavingTime(dateTime))
                {
                    TimeSpan timeSpan1 = TimeSpan.FromHours(1);
                    timeSpan = timeSpan.Add(timeSpan1);
                }
            }
            catch (Exception)
            {
                success = false;
                //if (ThinkingSDKPublicConfig.IsPrintLog()) ThinkingSDKLogger.Print("FormatDate: IsDaylightSavingTime get failed : " + e.Message);
            }
            if (success == false)
            {
                timeSpan = TimeZone.CurrentTimeZone.GetUtcOffset(dateTime);
            }
            DateTime dateNew = univDateTime + timeSpan;
            return dateNew.ToString("yyyy-MM-dd HH:mm:ss.fff", System.Globalization.CultureInfo.InvariantCulture);
        }
    }
}

