using System;

namespace ThinkingAnalytics
{
    // 自动采集事件类型
    [Flags]
    public enum AUTO_TRACK_EVENTS
    {
        NONE = 0,
        APP_START = 1 << 0, // 当应用进入前台的时候触发上报，对应 ta_app_start
        APP_END = 1 << 1, // 当应用进入后台的时候触发上报，对应 ta_app_end
        APP_CRASH = 1 << 4, // 当出现未捕获异常的时候触发上报，对应 ta_app_crash
        APP_INSTALL = 1 << 5, // 应用安装后首次打开的时候触发上报，对应 ta_app_install
        APP_SCENE_LOAD = 1 << 6, // 当应用内加载场景的时候触发上报，对应 ta_scene_loaded
        APP_SCENE_UNLOAD = 1 << 7, // 当应用内卸载场景的时候触发上报，对应 ta_scene_loaded
        ALL = APP_START | APP_END | APP_INSTALL | APP_CRASH | APP_SCENE_LOAD | APP_SCENE_UNLOAD
    }

    // 数据上报状态
    public enum TA_TRACK_STATUS
    {
        PAUSE = 1, // 暂停数据上报
        STOP = 2, // 停止数据上报，并清除缓存
        SAVE_ONLY = 3, // 数据入库，但不上报
        NORMAL = 4 // 恢复数据上报
    }
}