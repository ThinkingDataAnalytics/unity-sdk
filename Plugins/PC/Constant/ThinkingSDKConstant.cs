using System.Collections.Generic;

namespace ThinkingSDK.PC.Constant
{
    public delegate void ResponseHandle(Dictionary<string,object> result = null);
    public class ThinkingSDKConstant
    {
       
        // current platform
        public static readonly string PLATFORM = "PC";
        // date format style
        public static readonly string TIME_PATTERN = "{0:yyyy-MM-dd HH:mm:ss.fff}";

        // event type
        public static readonly string TYPE = "#type";
        // event time
        public static readonly string TIME = "#time";
        // distinct ID
        public static readonly string DISTINCT_ID = "#distinct_id";
        // event name
        public static readonly string EVENT_NAME = "#event_name";
        // account ID
        public static readonly string ACCOUNT_ID = "#account_id";
        // event properties
        public static readonly string PROPERTIES = "properties";
        // network type
        public static readonly string NETWORK_TYPE = "#network_type";
        // sdk version
        public static readonly string LIB_VERSION = "#lib_version";
        // carrier name
        public static readonly string CARRIER = "#carrier";
        // sdk name
        public static readonly string LIB = "#lib";
        // os name
        public static readonly string OS = "#os";
        // device ID
        public static readonly string DEVICE_ID = "#device_id";
        // device screen height
        public static readonly string SCREEN_HEIGHT = "#screen_height";
        //device screen width
        public static readonly string SCREEN_WIDTH = "#screen_width";
        // device manufacturer
        public static readonly string MANUFACTURE = "#manufacturer";
        // device model
        public static readonly string DEVICE_MODEL = "#device_model";
        // device system language
        public static readonly string SYSTEM_LANGUAGE = "#system_language";
        // os version
        public static readonly string OS_VERSION = "#os_version";
        // app version
        public static readonly string APP_VERSION = "#app_version";
        // app bundle ID
        public static readonly string APP_BUNDLEID = "#bundle_id";
        // zone offset
        public static readonly string ZONE_OFFSET = "#zone_offset";
        // project ID
        public static readonly string APPID = "#app_id";
        // unique ID for the event
        public static readonly string UUID = "#uuid";
        // first event ID
        public static readonly string FIRST_CHECK_ID = "#first_check_id";
        // special event ID
        public static readonly string EVENT_ID = "#event_id";
        // random ID
        public static readonly string RANDOM_ID = "RANDDOM_ID";
        // random ID(WebGL)
        public static readonly string RANDOM_DEVICE_ID = "RANDOM_DEVICE_ID";
        // event duration
        public static readonly string DURATION = "#duration";
        // flush time
        public static readonly string FLUSH_TIME = "#flush_time";
        // request data
        public static readonly string REQUEST_DATA = "data";

        // super properties
        public static readonly string SUPER_PROPERTY = "super_properties";

        // user properties action
        public static readonly string USER_ADD = "user_add";
        public static readonly string USER_SET = "user_set";
        public static readonly string USER_SETONCE = "user_setOnce";
        public static readonly string USER_UNSET = "user_unset";
        public static readonly string USER_DEL = "user_del";
        public static readonly string USER_APPEND = "user_append";
        public static readonly string USER_UNIQ_APPEND = "user_uniq_append";

        // Whether to pause data reporting
        public static readonly string ENABLE_TRACK = "enable_track";
        // Whether to stop data reporting
        public static readonly string OPT_TRACK = "opt_track";
        // Whether the installation is recorded
        public static readonly string IS_INSTALL = "is_install";

        // app install event
        public static readonly string INSTALL_EVENT = "ta_app_install";
        // app start event
        public static readonly string START_EVENT = "ta_app_start";
        // app end event
        public static readonly string END_EVENT = "ta_app_end";
        // app crash event
        public static readonly string CRASH_EVENT = "ta_app_crash";
        // app crash reason
        public static readonly string CRASH_REASON = "#app_crashed_reason";
        // scene load
        public static readonly string APP_SCENE_LOAD = "ta_scene_loaded";
        // scene unload
        public static readonly string APP_SCENE_UNLOAD = "ta_scene_unloaded";







    }
}
