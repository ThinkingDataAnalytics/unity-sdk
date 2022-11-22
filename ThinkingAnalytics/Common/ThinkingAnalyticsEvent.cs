using System;
using System.Collections.Generic;

namespace ThinkingAnalytics
{
    /// <summary>
    /// 内部使用的特殊事件类， 不要直接使用此类。
    /// </summary>
    public class ThinkingAnalyticsEvent
    {
        public enum Type
        {
            FIRST,
            UPDATABLE,
            OVERWRITABLE
        }

        public ThinkingAnalyticsEvent(string eventName, Dictionary<string, object> properties)
        {
            EventName = eventName;
            Properties = properties;
        }

        public Type? EventType { get; set; }
        public string EventName { get; }
        public Dictionary<string, object> Properties { get; }

        public DateTime EventTime { get; set; }
        public TimeZoneInfo EventTimeZone { get; set; }
        public string ExtraId { get; set; }
    }

    /// <summary>
    /// 首次（唯一）事件。默认情况下采集设备首次事件。请咨询数数客户成功获取支持。
    /// </summary>
    public class TDFirstEvent : ThinkingAnalyticsEvent
    {
        public TDFirstEvent(string eventName, Dictionary<string, object> properties) : base(eventName, properties)
        {
            EventType = Type.FIRST;
        }

        // 设置用于检测是否首次的 ID，默认情况下会使用设备 ID
        public void SetFirstCheckId(string firstCheckId)
        {
            ExtraId = firstCheckId;
        }
    }

    /// <summary>
    /// 可被更新的事件。请咨询数数客户成功获取支持。
    /// </summary>
    public class TDUpdatableEvent : ThinkingAnalyticsEvent
    {
        public TDUpdatableEvent(string eventName, Dictionary<string, object> properties, string eventId) : base(eventName, properties)
        {
            EventType = Type.UPDATABLE;
            ExtraId = eventId;
        }
    }

    /// <summary>
    /// 可被重写的事件。请咨询数数客户成功获取支持。
    /// </summary>
    public class TDOverWritableEvent : ThinkingAnalyticsEvent
    {
        public TDOverWritableEvent(string eventName, Dictionary<string, object> properties, string eventId) : base(eventName, properties)
        {
            EventType = Type.OVERWRITABLE;
            ExtraId = eventId;
        }
    }

}