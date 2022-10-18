#if UNITY_IOS && !(UNITY_EDITOR)
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
        [DllImport("__Internal")]
        private static extern void ta_start(string app_id, string url, int mode, string timezone_id, bool enable_encrypt, int encrypt_version, string encrypt_public_key, int pinning_mode, bool allow_invalid_certificates, bool validates_domain_name);
        [DllImport("__Internal")]
        private static extern void ta_identify(string app_id, string unique_id);
        [DllImport("__Internal")]
        private static extern string ta_get_distinct_id(string app_id);
        [DllImport("__Internal")]
        private static extern void ta_login(string app_id, string account_id);
        [DllImport("__Internal")]
        private static extern void ta_logout(string app_id);
        [DllImport("__Internal")]
        private static extern void ta_track(string app_id, string event_name, string properties, long time_stamp_millis, string timezone);
        [DllImport("__Internal")]
        private static extern void ta_track_event(string app_id, string event_string);
        [DllImport("__Internal")]
        private static extern void ta_set_super_properties(string app_id, string properties);
        [DllImport("__Internal")]
        private static extern void ta_unset_super_property(string app_id, string property_name);
        [DllImport("__Internal")]
        private static extern void ta_clear_super_properties(string app_id);
        [DllImport("__Internal")]
        private static extern string ta_get_super_properties(string app_id);
        [DllImport("__Internal")]
        private static extern string ta_get_preset_properties(string app_id);
        [DllImport("__Internal")]
        private static extern void ta_time_event(string app_id, string event_name);
        [DllImport("__Internal")]
        private static extern void ta_user_set(string app_id, string properties);
        [DllImport("__Internal")]
        private static extern void ta_user_set_with_time(string app_id, string properties, long timestamp);
        [DllImport("__Internal")]
        private static extern void ta_user_unset(string app_id, string properties);
        [DllImport("__Internal")]
        private static extern void ta_user_unset_with_time(string app_id, string properties, long timestamp);
        [DllImport("__Internal")]
        private static extern void ta_user_set_once(string app_id, string properties);
        [DllImport("__Internal")]
        private static extern void ta_user_set_once_with_time(string app_id, string properties, long timestamp);
        [DllImport("__Internal")]
        private static extern void ta_user_add(string app_id, string properties);
        [DllImport("__Internal")]
        private static extern void ta_user_add_with_time(string app_id, string properties, long timestamp);
        [DllImport("__Internal")]
        private static extern void ta_user_delete(string app_id);
        [DllImport("__Internal")]
        private static extern void ta_user_delete_with_time(string app_id, long timestamp);
        [DllImport("__Internal")]
        private static extern void ta_user_append(string app_id, string properties);
        [DllImport("__Internal")]
        private static extern void ta_user_append_with_time(string app_id, string properties, long timestamp);
        [DllImport("__Internal")]
        private static extern void ta_user_uniq_append(string app_id, string properties);
        [DllImport("__Internal")]
        private static extern void ta_user_uniq_append_with_time(string app_id, string properties, long timestamp);
        [DllImport("__Internal")]
        private static extern void ta_flush(string app_id);
        [DllImport("__Internal")]
        private static extern void ta_set_network_type(int type);
        [DllImport("__Internal")]
        private static extern void ta_enable_log(bool is_enable);
        [DllImport("__Internal")]
        private static extern string ta_get_device_id();
        [DllImport("__Internal")]
        private static extern void ta_set_dynamic_super_properties(string app_id);
        [DllImport("__Internal")]
        private static extern void ta_enable_tracking(string app_id, bool enabled);
        [DllImport("__Internal")]
        private static extern void ta_set_track_status(string app_id, int status);
        [DllImport("__Internal")]
        private static extern void ta_opt_out_tracking(string app_id);
        [DllImport("__Internal")]
        private static extern void ta_opt_out_tracking_and_delete_user(string app_id);
        [DllImport("__Internal")]
        private static extern void ta_opt_in_tracking(string app_id);
        [DllImport("__Internal")]
        private static extern void ta_create_light_instance(string app_id, string delegate_token);
        [DllImport("__Internal")]
        private static extern void ta_enable_autoTrack(string app_id, int events, string properties);
        [DllImport("__Internal")]
        private static extern void ta_enable_autoTrack_with_callback(string app_id, int events);
        [DllImport("__Internal")]
        private static extern void ta_set_autoTrack_properties(string app_id, int events, string properties);
        [DllImport("__Internal")]
        private static extern string ta_get_time_string(string app_id, long events);
        [DllImport("__Internal")]
        private static extern void ta_calibrate_time(long timestamp);
        [DllImport("__Internal")]
        private static extern void ta_calibrate_time_with_ntp(string ntpServer);
        [DllImport("__Internal")]
        private static extern void ta_config_custom_lib_info(string lib_name, string lib_version);
        [DllImport("__Internal")]
        private static extern void ta_enable_third_party_sharing(int share_type);

        private void init()
        {
            ta_start(token.appid, token.serverUrl, (int)token.mode, token.getTimeZoneId(), token.enableEncrypt, token.encryptVersion, token.encryptPublicKey, (int) token.pinningMode, token.allowInvalidCertificates, token.validatesDomainName);
        }

        private void identify(string uniqueId)
        {
            ta_identify(token.appid, uniqueId);
        }

        private string getDistinctId()
        {
            return ta_get_distinct_id(token.appid);
        }

        private void login(string accountId)
        {
            ta_login(token.appid, accountId);
        }

        private void logout()
        {
            ta_logout(token.appid);
        }

        private void flush()
        {
            ta_flush(token.appid);
        }

        private static void enableLog(bool enable)
        {
            ta_enable_log(enable);
        }

        private static void setVersionInfo(string lib_name, string lib_version) {
            ta_config_custom_lib_info(lib_name, lib_version);
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
            ta_track_event(token.appid, serilize(finalEvent));
        }

        private void track(string eventName, string properties)
        {  
            ta_track(token.appid, eventName, properties, 0, "");
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
           
            ta_track(token.appid, eventName, properties, currentMillis, tz);
        }

        private void setSuperProperties(string superProperties)
        {
            ta_set_super_properties(token.appid, superProperties);
        }

        private void unsetSuperProperty(string superPropertyName)
        {
            ta_unset_super_property(token.appid, superPropertyName);
        }

        private void clearSuperProperty()
        {
            ta_clear_super_properties(token.appid);
        }

        private Dictionary<string, object> getSuperProperties()
        {
            string superPropertiesString = ta_get_super_properties(token.appid);
            return TD_MiniJSON.Deserialize(superPropertiesString);
        }

        private Dictionary<string, object> getPresetProperties()
        {
            string presetPropertiesString = ta_get_preset_properties(token.appid);
            return TD_MiniJSON.Deserialize(presetPropertiesString);
        }

        private void timeEvent(string eventName)
        {
            ta_time_event(token.appid, eventName);
        }

        private void userSet(string properties)
        {
            ta_user_set(token.appid, properties);
        }

        private void userSet(string properties, DateTime dateTime)
        {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;
            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            ta_user_set_with_time(token.appid, properties, currentMillis);
        }

        private void userUnset(List<string> properties)
        {
            foreach (string property in properties)
            {
                ta_user_unset(token.appid, property);
            }
        }

        private void userUnset(List<string> properties, DateTime dateTime)
        {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;
            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            foreach (string property in properties)
            {
                ta_user_unset_with_time(token.appid, property, currentMillis);
            }
        }

        private void userSetOnce(string properties)
        {
            ta_user_set_once(token.appid, properties);
        }

        private void userSetOnce(string properties, DateTime dateTime)
        {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;
            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            ta_user_set_once_with_time(token.appid, properties, currentMillis);
        }

        private void userAdd(string properties)
        {
            ta_user_add(token.appid, properties);
        }

        private void userAdd(string properties, DateTime dateTime)
        {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;
            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            ta_user_add_with_time(token.appid, properties, currentMillis);
        }

        private void userDelete()
        {
            ta_user_delete(token.appid);
        }

        private void userDelete(DateTime dateTime)
        {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;
            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            ta_user_delete_with_time(token.appid, currentMillis);
        }

        private void userAppend(string properties)
        {
            ta_user_append(token.appid, properties);
        }

        private void userAppend(string properties, DateTime dateTime)
        {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;
            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            ta_user_append_with_time(token.appid, properties, currentMillis);
        }

        private void userUniqAppend(string properties)
        {
            ta_user_uniq_append(token.appid, properties);
        }

        private void userUniqAppend(string properties, DateTime dateTime)
        {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;
            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            ta_user_uniq_append_with_time(token.appid, properties, currentMillis);
        }

        private void setNetworkType(ThinkingAnalyticsAPI.NetworkType networkType)
        {
            ta_set_network_type((int)networkType);
        }

        private string getDeviceId() 
        {
            return ta_get_device_id();
        }

        public void setDynamicSuperProperties(IDynamicSuperProperties dynamicSuperProperties)
        {
            ta_set_dynamic_super_properties(token.appid);
        }

        private void setTrackStatus(TA_TRACK_STATUS status)
        {
            ta_set_track_status(token.appid, (int)status);
        }

        private void optOutTracking()
        {
            ta_opt_out_tracking(token.appid);
        }

        private void optOutTrackingAndDeleteUser()
        {
            ta_opt_out_tracking_and_delete_user(token.appid);
        }

        private void optInTracking()
        {
            ta_opt_in_tracking(token.appid);
        }

        private void enableTracking(bool enabled)
        {
            ta_enable_tracking(token.appid, enabled);
        }

        private ThinkingAnalyticsWrapper createLightInstance(ThinkingAnalyticsAPI.Token delegateToken)
        {
            ta_create_light_instance(token.appid, delegateToken.appid);
            return new ThinkingAnalyticsWrapper(delegateToken, this.taMono, false);
        }

        private string getTimeString(DateTime dateTime)
        {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;
            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            return ta_get_time_string(token.appid, currentMillis);
        }

        private void enableAutoTrack(AUTO_TRACK_EVENTS autoTrackEvents, string properties)
        {
            ta_enable_autoTrack(token.appid, (int)autoTrackEvents, properties);
        }

        private void enableAutoTrack(AUTO_TRACK_EVENTS autoTrackEvents, IAutoTrackEventCallback eventCallback)
        {
            ta_enable_autoTrack_with_callback(token.appid, (int)autoTrackEvents);
        }

        private void setAutoTrackProperties(AUTO_TRACK_EVENTS autoTrackEvents, string properties)
        {
            ta_set_autoTrack_properties(token.appid, (int)autoTrackEvents, properties);
        }

        private static void calibrateTime(long timestamp)
        {
            ta_calibrate_time(timestamp);
        }

        private static void calibrateTimeWithNtp(string ntpServer)
        {
            ta_calibrate_time_with_ntp(ntpServer);
        }

        private void enableThirdPartySharing(TAThirdPartyShareType shareType)
        {
            ta_enable_third_party_sharing((int) shareType);
        }
    }
}
#endif