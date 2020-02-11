
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
        private static extern void start(string app_id, string server_url, int mode);
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
        private static extern void user_unset(string app_id, string properties);
        [DllImport("__Internal")]
        private static extern void user_set_once(string app_id, string properties);
        [DllImport("__Internal")]
        private static extern void user_add(string app_id, string properties);
        [DllImport("__Internal")]
        private static extern void user_delete(string app_id);
        [DllImport("__Internal")]
        private static extern void user_append(string app_id, string properties);
        [DllImport("__Internal")]
        private static extern void flush(string app_id);
        [DllImport("__Internal")]
        private static extern void set_network_type(int type);
        [DllImport("__Internal")]
        private static extern void enable_log(bool is_enable);
        [DllImport("__Internal")]
        private static extern string get_device_id();
        [DllImport("__Internal")]
        private static extern void track_app_install(string app_id);
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

        private void init()
        {
            start(token.appid, token.serverUrl, (int)token.mode);
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

        private void track(string eventName, Dictionary<string, object> properties)
        {  
            track(token.appid, eventName, TD_MiniJSON.Serialize(properties), 0, "");
        }

        private void track(string eventName, Dictionary<string, object> properties, DateTime dateTime)
        {
            long dateTimeTicksUTC = TimeZoneInfo.ConvertTimeToUtc(dateTime).Ticks;

            DateTime dtFrom = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            long currentMillis = (dateTimeTicksUTC - dtFrom.Ticks) / 10000;

            string tz = "";
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
           
            track(token.appid, eventName, TD_MiniJSON.Serialize(properties), currentMillis, tz);
        }

        private void setSuperProperties(Dictionary<string, object> superProperties)
        {
            string properties = TD_MiniJSON.Serialize(superProperties);
            set_super_properties(token.appid, properties);
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

        private void userSet(Dictionary<string, object> properties)
        {
            user_set(token.appid, TD_MiniJSON.Serialize(properties));
        }


        private void userUnset(List<string> properties)
        {
            foreach (string property in properties)
            {
                user_unset(token.appid, property);
            }
        }

        private void userSetOnce(Dictionary<string, object> properties)
        {
            user_set_once(token.appid, TD_MiniJSON.Serialize(properties));
        }

        private void userAdd(Dictionary<string, object> properties)
        {
            user_add(token.appid, TD_MiniJSON.Serialize(properties));
        }

        private void userDelete()
        {
            user_delete(token.appid);
        }

        private void userAppend(Dictionary<string, object> properties)
        {
            user_append(token.appid, TD_MiniJSON.Serialize(properties));
        }

        private void setNetworkType(ThinkingAnalyticsAPI.NetworkType networkType)
        {
            set_network_type((int)networkType);
        }

        private string getDeviceId() 
        {
            return get_device_id();
        }

        private void trackAppInstall() 
        {
            track_app_install(token.appid);
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
            return new ThinkingAnalyticsWrapper(delegateToken);
        }

#endif
    }
}