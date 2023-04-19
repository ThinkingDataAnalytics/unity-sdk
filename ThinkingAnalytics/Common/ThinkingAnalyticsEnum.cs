using System;

namespace ThinkingAnalytics
{
    [Flags]
    // Auto-tracking Events Type
    public enum AUTO_TRACK_EVENTS
    {
        NONE = 0,
        APP_START = 1 << 0, // reporting when the app enters the foreground （ta_app_start）
        APP_END = 1 << 1, // reporting when the app enters the background （ta_app_end）
        APP_CRASH = 1 << 4, // reporting when an uncaught exception occurs （ta_app_crash）
        APP_INSTALL = 1 << 5, // reporting when the app is opened for the first time after installation （ta_app_install）
        APP_SCENE_LOAD = 1 << 6, // reporting when the scene is loaded in the app （ta_scene_loaded）
        APP_SCENE_UNLOAD = 1 << 7, // reporting when the scene is unloaded in the app （ta_scene_loaded）
        ALL = APP_START | APP_END | APP_INSTALL | APP_CRASH | APP_SCENE_LOAD | APP_SCENE_UNLOAD
    }

    // Data Reporting Status
    public enum TA_TRACK_STATUS
    {
        PAUSE = 1, // pause data reporting
        STOP = 2, // stop data reporting, and clear caches
        SAVE_ONLY = 3, // data stores in the cache, but not be reported
        NORMAL = 4 // resume data reporting
    }
}