#if UNITY_IOS && !(UNITY_EDITOR) && !TE_DISABLE_IOS_OC
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using ThinkingData.Analytics.Utils;

namespace ThinkingData.Analytics.Wrapper
{
    public partial class TDWrapper
    {
        [DllImport("__Internal")]
        private static extern void ta_start(string app_id, string url, int mode, string timezone_id, bool enable_encrypt, int encrypt_version, string encrypt_public_key, int pinning_mode, bool allow_invalid_certificates, bool validates_domain_name, string instance_name);
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
        private static extern void ta_track_event(string app_id, int type, string event_name, string properties, string event_id, long time_stamp_millis, string timezone);
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
        private static extern void ta_create_light_instance(string delegate_token);
        [DllImport("__Internal")]
        private static extern void ta_enable_autoTrack(string app_id, int events, string properties);
        [DllImport("__Internal")]
        private static extern void ta_enable_autoTrack_with_callback(string app_id, int events);
        [DllImport("__Internal")]
        private static extern void ta_set_autoTrack_properties(string app_id, int events, string properties);
        [DllImport("__Internal")]
        private static extern string ta_get_time_string(long timestamp);
        [DllImport("__Internal")]
        private static extern void ta_calibrate_time(long timestamp);
        [DllImport("__Internal")]
        private static extern void ta_calibrate_time_with_ntp(string ntpServer);
        [DllImport("__Internal")]
        private static extern void ta_config_custom_lib_info(string lib_name, string lib_version);
        [DllImport("__Internal")]
        private static extern void ta_enable_third_party_sharing(string app_id, int share_type, string properties);

        private static TimeZoneInfo defaultTimeZone = null;
        private static TDTimeZone defaultTDTimeZone = TDTimeZone.Local;

        private static void init(TDConfig token)
        {
            registerRecieveGameCallback();
            ta_start(token.appId, token.serverUrl, (int)token.mode, token.getTimeZoneId(), token.enableEncrypt, token.encryptVersion, token.encryptPublicKey, (int) token.pinningMode, token.allowInvalidCertificates, token.validatesDomainName, token.name);
            string timeZoneId = token.getTimeZoneId();
            defaultTDTimeZone = token.timeZone;
            if (null != timeZoneId && timeZoneId.Length > 0)
            {
                if (defaultTimeZone == null)
                {
                    try
                    {
                        defaultTimeZone = TimeZoneInfo.FindSystemTimeZoneById(timeZoneId);
                    }
                    catch (Exception)
                    {
                    }
                }
            }
            else
            {
                if (defaultTimeZone == null)
                {
                    defaultTimeZone = TimeZoneInfo.Local;
                }
            }
        }

        private static void identify(string uniqueId, string appId)
        {
            ta_identify(appId, uniqueId);
        }

        private static string getDistinctId(string appId)
        {
            return ta_get_distinct_id(appId);
        }

        private static void login(string accountId, string appId)
        {
            ta_login(appId, accountId);
        }

        private static void logout(string appId)
        {
            ta_logout(appId);
        }

        private static void flush(string appId)
        {
            ta_flush(appId);
        }

        private static void enableLog(bool enable)
        {
            ta_enable_log(enable);
        }

        private static void setVersionInfo(string lib_name, string lib_version) {
            ta_config_custom_lib_info(lib_name, lib_version);
        }

        private static void track(TDEventModel taEvent, string appId)
        {
            int type = -1;
            switch (taEvent.EventType)
            {
                case TDEventModel.TDEventType.First:
                    type = 0;
                    break;
                case TDEventModel.TDEventType.Updatable:
                    type = 1;
                    break;
                case TDEventModel.TDEventType.Overwritable:
                    type = 2;
                    break;
            }
            string jsonStr;
            if (taEvent.Properties == null)
            {
                jsonStr = taEvent.StrProperties;
            }
            else
            {
                jsonStr = serilize(taEvent.Properties);
            }
            long currentMillis = 0;
            if (taEvent.GetEventTime() != null && taEvent.GetEventTime() != DateTime.MinValue)
            {
                long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(taEvent.GetEventTime()).Ticks;
                DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
                currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            }
            string timeZoneId = "";
            if (taEvent.GetEventTimeZone() != null)
            {
                timeZoneId = taEvent.GetEventTimeZone().Id;
            }
            ta_track_event(appId, type, taEvent.EventName, jsonStr, taEvent.GetEventId(), currentMillis, timeZoneId);
        }

        private static void track(string eventName, Dictionary<string, object> properties, string appId)
        {  
            ta_track(appId, eventName, serilize(properties), 0, "");
        }

        private static void trackStr(string eventName, string properties, string appId)
        {
            ta_track(appId, eventName, properties, 0, "");
        }

        private static void track(string eventName, Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;

            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            string tz = "";
            ta_track(appId, eventName, serilize(properties), currentMillis, tz);
        }

        private static void track(string eventName, Dictionary<string, object> properties, DateTime dateTime, TimeZoneInfo timeZone, string appId)
        {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;

            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            string tz = "";
            if (timeZone != null)
            {
                tz = timeZone.Id;
            }
            ta_track(appId, eventName, serilize(properties), currentMillis, tz);
        }

        private static void trackForAll(string eventName, Dictionary<string, object> properties)
        {
            string appId = "";
            track(eventName, properties, appId);
        }

        private static void setSuperProperties(Dictionary<string, object> superProperties, string appId)
        {
            ta_set_super_properties(appId, serilize(superProperties));
        }

        private static void setSuperProperties(string superProperties, string appId)
        {
            ta_set_super_properties(appId, superProperties);
        }

        private static void unsetSuperProperty(string superPropertyName, string appId)
        {
            ta_unset_super_property(appId, superPropertyName);
        }

        private static void clearSuperProperty(string appId)
        {
            ta_clear_super_properties(appId);
        }

        private static Dictionary<string, object> getSuperProperties(string appId)
        {
            string superPropertiesString = ta_get_super_properties(appId);
            return TDMiniJson.Deserialize(superPropertiesString);
        }

        private static Dictionary<string, object> getPresetProperties(string appId)
        {
            string presetPropertiesString = ta_get_preset_properties(appId);
            return TDMiniJson.Deserialize(presetPropertiesString);
        }

        private static void timeEvent(string eventName, string appId)
        {
            ta_time_event(appId, eventName);
        }

        private static void timeEventForAll(string eventName)
        {
            ta_time_event("", eventName);
        }

        private static void userSet(Dictionary<string, object> properties, string appId)
        {
            ta_user_set(appId, serilize(properties));
        }

        private static void userSet(string properties, string appId)
        {
            ta_user_set(appId, properties);
        }

        private static void userSet(Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;
            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            ta_user_set_with_time(appId, serilize(properties), currentMillis);
        }

        private static void userUnset(List<string> properties, string appId)
        {
            foreach (string property in properties)
            {
                ta_user_unset(appId, property);
            }
        }

        private static void userUnset(List<string> properties, DateTime dateTime, string appId)
        {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;
            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            foreach (string property in properties)
            {
                ta_user_unset_with_time(appId, property, currentMillis);
            }
        }

        private static void userSetOnce(Dictionary<string, object> properties, string appId)
        {
            ta_user_set_once(appId, serilize(properties));
        }

        private static void userSetOnce(string properties, string appId)
        {
            ta_user_set_once(appId, properties);
        }

        private static void userSetOnce(Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;
            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            ta_user_set_once_with_time(appId, serilize(properties), currentMillis);
        }

        private static void userAdd(Dictionary<string, object> properties, string appId)
        {
            ta_user_add(appId, serilize(properties));
        }

        private static void userAddStr(string properties, string appId)
        {
            ta_user_add(appId, properties);
        }

        private static void userAdd(Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;
            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            ta_user_add_with_time(appId, serilize(properties), currentMillis);
        }

        private static void userDelete(string appId)
        {
            ta_user_delete(appId);
        }

        private static void userDelete(DateTime dateTime, string appId)
        {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;
            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            ta_user_delete_with_time(appId, currentMillis);
        }

        private static void userAppend(Dictionary<string, object> properties, string appId)
        {
            ta_user_append(appId, serilize(properties));
        }

        private static void userAppend(string properties, string appId)
        {
            ta_user_append(appId, properties);
        }

        private static void userAppend(Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;
            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            ta_user_append_with_time(appId, serilize(properties), currentMillis);
        }

        private static void userUniqAppend(Dictionary<string, object> properties, string appId)
        {
            ta_user_uniq_append(appId, serilize(properties));
        }

        private static void userUniqAppend(string properties, string appId)
        {
            ta_user_uniq_append(appId, properties);
        }

        private static void userUniqAppend(Dictionary<string, object> properties, DateTime dateTime, string appId)
        {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;
            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            ta_user_uniq_append_with_time(appId, serilize(properties), currentMillis);
        }

        private static void setNetworkType(TDNetworkType networkType)
        {
            ta_set_network_type((int)networkType);
        }

        private static string getDeviceId() 
        {
            return ta_get_device_id();
        }

        private static void setDynamicSuperProperties(TDDynamicSuperPropertiesHandler dynamicSuperProperties, string appId)
        {
            ta_set_dynamic_super_properties(appId);
        }

        private static void setTrackStatus(TDTrackStatus status, string appId)
        {
            ta_set_track_status(appId, (int)status);
        }

        private static void optOutTracking(string appId)
        {
            ta_opt_out_tracking(appId);
        }

        private static void optOutTrackingAndDeleteUser(string appId)
        {
            ta_opt_out_tracking_and_delete_user(appId);
        }

        private static void optInTracking(string appId)
        {
            ta_opt_in_tracking(appId);
        }

        private static void enableTracking(bool enabled, string appId)
        {
            ta_enable_tracking(appId, enabled);
        }

        private static string createLightInstance()
        {
            string randomID = System.Guid.NewGuid().ToString("N");
            ta_create_light_instance(randomID);
            return randomID;
        }

        private static string getTimeString(DateTime dateTime)
        {
            //long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;
            //DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            //long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;
            //return ta_get_time_string(currentMillis);
            if (defaultTimeZone == null)
            {
                return TDCommonUtils.FormatDate(dateTime, defaultTDTimeZone);
            }
            else
            {
                return TDCommonUtils.FormatDate(dateTime, defaultTimeZone);
            }
        }

        private static void enableAutoTrack(TDAutoTrackEventType autoTrackEvents, Dictionary<string, object> properties, string appId)
        {
            ta_enable_autoTrack(appId, (int)autoTrackEvents, serilize(properties));
        }

        private static void enableAutoTrack(TDAutoTrackEventType autoTrackEvents, TDAutoTrackEventHandler eventCallback, string appId)
        {
            ta_enable_autoTrack_with_callback(appId, (int)autoTrackEvents);
        }

        private static void setAutoTrackProperties(TDAutoTrackEventType autoTrackEvents, Dictionary<string, object> properties, string appId)
        {
            ta_set_autoTrack_properties(appId, (int)autoTrackEvents, serilize(properties));
        }

        private static void calibrateTime(long timestamp)
        {
            ta_calibrate_time(timestamp);
        }

        private static void calibrateTimeWithNtp(string ntpServer)
        {
            ta_calibrate_time_with_ntp(ntpServer);
        }

        private static void enableThirdPartySharing(TDThirdPartyType shareType, Dictionary<string, object> properties, string appId)
        {
            ta_enable_third_party_sharing(appId, (int) shareType, serilize(properties));
        }

        private static void registerRecieveGameCallback()
        {
            ResultHandler handler = new ResultHandler(resultHandler);
            IntPtr handlerPointer = Marshal.GetFunctionPointerForDelegate(handler);
            RegisterRecieveGameCallback(handlerPointer);
        }

        [DllImport("__Internal")]
        public static extern void RegisterRecieveGameCallback
        (
            IntPtr handlerPointer
        );    

        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        public delegate string ResultHandler(string type, string jsonData);

        [AOT.MonoPInvokeCallback(typeof(ResultHandler))]
        static string resultHandler(string type, string jsonData) 
        {
            if (type == "AutoTrackProperties")
            {
                Dictionary<string, object>properties = TDMiniJson.Deserialize(jsonData);
                string appId = properties["AppID"].ToString();
                int eventType = Convert.ToInt32(properties["EventType"]);
                if (!string.IsNullOrEmpty(appId) && mAutoTrackEventCallbacks.ContainsKey(appId))
                {
                    properties.Remove("EventType");
                    properties.Remove("AppID");
                    Dictionary<string, object>autoTrackProperties = mAutoTrackEventCallbacks[appId].GetAutoTrackEventProperties(eventType, properties);
                    //return TDMiniJson.Serialize(autoTrackProperties);
                    return serilize(autoTrackProperties); 
                }
            } 
            else if (type == "DynamicSuperProperties")
            {
                if (mDynamicSuperProperties != null)
                {
                    Dictionary<string, object>dynamicSuperProperties = mDynamicSuperProperties.GetDynamicSuperProperties();
                    //return TDMiniJson.Serialize(dynamicSuperProperties);
                    return serilize(dynamicSuperProperties);
                }
            }
            return "{}";
        }
    }
}
#endif