using System;

namespace ThinkingData.Analytics
{
    /// <summary>
    /// Time Zone in SDK options
    /// </summary>
    public enum TDTimeZone
    {
        Local,
        UTC,
        Asia_Shanghai,
        Asia_Tokyo,
        America_Los_Angeles,
        America_New_York,
        Other = 100
    }

    /// <summary>
    /// SDK running mode options
    /// </summary>
    public enum TDMode
    {
        Debug = 1,
        DebugOnly = 2,
        Normal = 0
    }

    /// <summary>
    /// Data post options
    /// </summary>
    public enum TDNetworkType
    {
        Wifi = 2,
        All = 1
    }

    /// <summary>
    /// Auto-tracking Events Type options
    /// </summary>
    [Flags]
    public enum TDAutoTrackEventType
    {
        None = 0,
        AppStart = 1 << 0, // reporting when the app enters the foreground （ta_app_start）
        AppEnd = 1 << 1, // reporting when the app enters the background （ta_app_end）
        AppCrash = 1 << 4, // reporting when an uncaught exception occurs （ta_app_crash）
        AppInstall = 1 << 5, // reporting when the app is opened for the first time after installation （ta_app_install）
        AppSceneLoad = 1 << 6, // reporting when the scene is loaded in the app （ta_scene_loaded）
        AppSceneUnload = 1 << 7, // reporting when the scene is unloaded in the app （ta_scene_loaded）
        All = AppStart | AppEnd | AppInstall | AppCrash | AppSceneLoad | AppSceneUnload
    }

    /// <summary>
    /// Data Reporting Status
    /// </summary>
    public enum TDTrackStatus
    {
        Pause = 1, // pause data reporting
        Stop = 2, // stop data reporting, and clear caches
        SaveOnly = 3, // data stores in the cache, but not be reported
        Normal = 4 // resume data reporting
    }
}