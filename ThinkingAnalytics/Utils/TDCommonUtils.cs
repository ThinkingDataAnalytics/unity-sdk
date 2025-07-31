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
            try
            {
                DateTime dateNew = univDateTime + timeSpan;
                return dateNew.ToString("yyyy-MM-dd HH:mm:ss.fff", System.Globalization.CultureInfo.InvariantCulture);
            }
            catch (Exception)
            {
            }
            return univDateTime.ToString("yyyy-MM-dd HH:mm:ss.fff", System.Globalization.CultureInfo.InvariantCulture);
        }

        public static string FormatDate(DateTime dateTime, TDTimeZone timeZone) {
            DateTime univDateTime = dateTime.ToUniversalTime();
            TimeSpan span;
            switch (timeZone)
            {
                case TDTimeZone.Local:
                    span = TimeZoneInfo.Local.BaseUtcOffset;
                    break;
                case TDTimeZone.UTC:
                    span = TimeSpan.Zero;
                    break;
                case TDTimeZone.Asia_Shanghai:
                    span = TimeSpan.FromHours(8);
                    break;
                case TDTimeZone.Asia_Tokyo:
                    span = TimeSpan.FromHours(9);
                    break;
                case TDTimeZone.America_Los_Angeles:
                    span = TimeSpan.FromHours(-7);
                    break;
                case TDTimeZone.America_New_York:
                    span = TimeSpan.FromHours(-4);
                    break;
                default:
                    span = TimeSpan.Zero;
                    break;
            }
            try
            {
                DateTime dateNew = univDateTime + span;
                return dateNew.ToString("yyyy-MM-dd HH:mm:ss.fff", System.Globalization.CultureInfo.InvariantCulture);
            }
            catch (Exception) {
            }
            return univDateTime.ToString("yyyy-MM-dd HH:mm:ss.fff", System.Globalization.CultureInfo.InvariantCulture);
        }
    }
}

