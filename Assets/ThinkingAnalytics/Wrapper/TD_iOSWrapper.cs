
using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using ThinkingAnalytics.Utils;
using UnityEngine;

namespace ThinkingAnalytics.Wrapper
{
    public partial class ThinkingAnalyticsWrapper
    {
#if UNITY_IOS && !(UNITY_EDITOR)
        [DllImport("__Internal")]
        private static extern void start(string app_id, string server_url, int mode, string timeZoneId);
        [DllImport("__Internal")]
        private static extern void identify(string app_id, string unique_id);
        [DllImport("__Internal")]
        private static extern string get_distinct_id(string app_id);
        [DllImport("__Internal")]
        private static extern void login(string app_id, string account_id);
        [DllImport("__Internal")]
        private static extern void logout(string app_id);
        [DllImport("__Internal")]
        private static extern void track(string app_id, string event_name, string properties, long time_stamp_millis, string timezone);
        [DllImport("__Internal")]
        private static extern void track_event(string app_id, string event_string);
        [DllImport("__Internal")]
        private static extern void set_super_properties(string app_id, string properties);
        [DllImport("__Internal")]
        private static extern void unset_super_property(string app_id, string property_name);
        [DllImport("__Internal")]
        private static extern void clear_super_properties(string app_id);
        [DllImport("__Internal")]
        private static extern string get_super_properties(string app_id);
        [DllImport("__Internal")]
        private static extern void time_event(string app_id, string event_name);
        [DllImport("__Internal")]
        private static extern void user_set(string app_id, string properties);
        [DllImport("__Internal")]
        private static extern void user_set_with_time(string app_id, string properties, long timestamp);
        [DllImport("__Internal")]
        private static extern void user_unset(string app_id, string properties);
        [DllImport("__Internal")]
        private static extern void user_unset_with_time(string app_id, string properties, long timestamp);
        [DllImport("__Internal")]
        private static extern void user_set_once(string app_id, string properties);
        [DllImport("__Internal")]
        private static extern void user_set_once_with_time(string app_id, string properties, long timestamp);
        [DllImport("__Internal")]
        private static extern void user_add(string app_id, string properties);
        [DllImport("__Internal")]
        private static extern void user_add_with_time(string app_id, string properties, long timestamp);
        [DllImport("__Internal")]
        private static extern void user_delete(string app_id);
        [DllImport("__Internal")]
        private static extern void user_delete_with_time(string app_id, long timestamp);
        [DllImport("__Internal")]
        private static extern void user_append(string app_id, string properties);
        [DllImport("__Internal")]
        private static extern void user_append_with_time(string app_id, string properties, long timestamp);
        [DllImport("__Internal")]
        private static extern void flush(string app_id);
        [DllImport("__Internal")]
        private static extern void set_network_type(int type);
        [DllImport("__Internal")]
        private static extern void enable_log(bool is_enable);
        [DllImport("__Internal")]
        private static extern string get_device_id();
        [DllImport("__Internal")]
        private static extern void enable_tracking(string app_id, bool enabled);
        [DllImport("__Internal")]
        private static extern void opt_out_tracking(string app_id);
        [DllImport("__Internal")]
        private static extern void opt_out_tracking_and_delete_user(string app_id);
        [DllImport("__Internal")]
        private static extern void opt_in_tracking(string app_id);
        [DllImport("__Internal")]
        private static extern void create_light_instance(string app_id, string delegate_token);
        [DllImport("__Internal")]
        private static extern void enable_autoTrack(string app_id, int events);
        [DllImport("__Internal")]
        private static extern string get_time_string(string app_id, long events);
        [DllImport("__Internal")]
        private static extern void calibrate_time(long timestamp);
        [DllImport("__Internal")]
        private static extern void calibrate_time_with_ntp(string ntpServer);
        [DllImport("__Internal")]
        private static extern void config_custom_lib_info(string lib_name, string lib_version);

        private void init()
        {
            start(token.appid, token.serverUrl, (int)token.mode, token.getTimeZoneId());
        }

        private void identify(string uniqueId)
        {
            identify(token.appid, uniqueId);
        }

        private string getDistinctId()
        {
            return get_distinct_id(token.appid);
        }

        private void login(string accountId)
        {
            login(token.appid, accountId);
        }

        private void logout()
        {
            logout(token.appid);
        }

        private void flush()
        {
            flush(token.appid);
        }

        private static void setVersionInfo(string lib_name, string lib_version) {
            config_custom_lib_info(lib_name, lib_version);
        }

        private void track(ThinkingAnalyticsEvent taEvent)
        {
            Dictionary<string, object> finalEvent = new Dictionary<string, object>();
            string extraId = taEvent.ExtraId;
            switch (taEvent.EventType)
            {
                case ThinkingAnalyticsEvent.Type.FIRST:
                    finalEvent["event_type"] = "track_first";
                    break;
                case ThinkingAnalyticsEvent.Type.UPDATABLE:
                    finalEvent["event_type"] = "track_update";
                    break;
                case ThinkingAnalyticsEvent.Type.OVERWRITABLE:
                    finalEvent["event_type"] = "track_overwrite";
                    break;
            }

            if (!string.IsNullOrEmpty(extraId))
            {
                finalEvent["extra_id"] = extraId;
            }

            finalEvent["event_name"] = taEvent.EventName;
            finalEvent["event_properties"] = taEvent.Properties;

            if (taEvent.EventTime != DateTime.MinValue) 
            {
                finalEvent["event_time"] = taEvent.EventTime;
                if (token.timeZone == ThinkingAnalyticsAPI.TATimeZone.Local)
                {
                    switch (taEvent.EventTime.Kind)
                    {
                        case DateTimeKind.Local:
                            finalEvent["event_timezone"] = "Local";
                            break;
                        case DateTimeKind.Utc:
                            finalEvent["event_timezone"] = "UTC";
                            break;
                        case DateTimeKind.Unspecified:
                            break;
                    }
                }
            }   
            track_event(token.appid, serilize(finalEvent));
        }

        private void track(string eventName, string properties)
        {  
            track(token.appid, eventName, properties, 0, "");
        }

        private void track(string eventName, string properties, DateTime dateTime)
        {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;

            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;

            string tz = "";
            if (token.timeZone == ThinkingAnalyticsAPI.TATimeZone.Local)
            {
                switch(dateTime.Kind)
                {
                    case DateTimeKind.Local:
                        tz = "Local";
                        break;
                    case DateTimeKind.Utc:
                        tz = "UTC";
                        break;
                    case DateTimeKind.Unspecified:
                        break;
                }
            }
            else 
            {
                tz = token.getTimeZoneId();
            }
           
            track(token.appid, eventName, properties, currentMillis, tz);
        }

        private void setSuperProperties(string superProperties)
        {
            set_super_properties(token.appid, superProperties);
        }

        private void unsetSuperProperty(string superPropertyName)
        {
            unset_super_property(token.appid, superPropertyName);
        }

        private void clearSuperProperty()
        {
            clear_super_properties(token.appid);
        }

        private Dictionary<string, object> getSuperProperties()
        {
            string superPropertiesString = get_super_properties(token.appid);
            return TD_MiniJSON.Deserialize(superPropertiesString);
        }

        private void timeEvent(string eventName)
        {
            time_event(token.appid, eventName);
        }

        private void userSet(string properties)
        {
            user_set(token.appid, properties);
        }

        private void userSet(string properties, DateTime dateTime)
        {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;
            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            user_set_with_time(token.appid, properties, currentMillis);
        }

        private void userUnset(List<string> properties)
        {
            foreach (string property in properties)
            {
                user_unset(token.appid, property);
            }
        }

        private void userUnset(List<string> properties, DateTime dateTime)
        {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;
            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            foreach (string property in properties)
            {
                user_unset_with_time(token.appid, property, currentMillis);
            }
        }

        private void userSetOnce(string properties)
        {
            user_set_once(token.appid, properties);
        }

        private void userSetOnce(string properties, DateTime dateTime)
        {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;
            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            user_set_once_with_time(token.appid, properties, currentMillis);
        }

        private void userAdd(string properties)
        {
            user_add(token.appid, properties);
        }

        private void userAdd(string properties, DateTime dateTime)
        {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;
            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            user_add_with_time(token.appid, properties, currentMillis);
        }

        private void userDelete()
        {
            user_delete(token.appid);
        }

        private void userDelete(DateTime dateTime)
        {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;
            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            user_delete_with_time(token.appid, currentMillis);
        }

        private void userAppend(string properties)
        {
            user_append(token.appid, properties);
        }

        private void userAppend(string properties, DateTime dateTime)
        {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;
            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            user_append_with_time(token.appid, properties, currentMillis);
        }

        private void setNetworkType(ThinkingAnalyticsAPI.NetworkType networkType)
        {
            set_network_type((int)networkType);
        }

        private string getDeviceId() 
        {
            return get_device_id();
        }

        private void optOutTracking()
        {
            opt_out_tracking(token.appid);
        }

        private void optOutTrackingAndDeleteUser()
        {
            opt_out_tracking_and_delete_user(token.appid);
        }

        private void optInTracking()
        {
            opt_in_tracking(token.appid);
        }

        private void enableTracking(bool enabled)
        {
            enable_tracking(token.appid, enabled);
        }

        private ThinkingAnalyticsWrapper createLightInstance(ThinkingAnalyticsAPI.Token delegateToken)
        {
            create_light_instance(token.appid, delegateToken.appid);
            return new ThinkingAnalyticsWrapper(delegateToken, false);
        }

        private string getTimeString(DateTime dateTime)
        {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;
            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            return get_time_string(token.appid, currentMillis);
        }

        private void enableAutoTrack(AUTO_TRACK_EVENTS autoTrackEvents)
        {
            enable_autoTrack(token.appid, (int)autoTrackEvents);
        }

        private static void calibrateTime(long timestamp)
        {
            calibrate_time(timestamp);
        }

        private static void calibrateTimeWithNtp(string ntpServer)
        {
            calibrate_time_with_ntp(ntpServer);
        }
#endif
    }
}