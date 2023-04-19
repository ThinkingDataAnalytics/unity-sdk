using System;
using System.Collections.Generic;

namespace ThinkingAnalytics
{
    /// <summary>
    /// Special event class for internal use, do not use this class directly.
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
    /// First Events
    /// </summary>
    public class TDFirstEvent : ThinkingAnalyticsEvent
    {
        public TDFirstEvent(string eventName, Dictionary<string, object> properties) : base(eventName, properties)
        {
            EventType = Type.FIRST;
        }

        // First Event Check ID. By default, first events ID are device ID.
        public void SetFirstCheckId(string firstCheckId)
        {
            ExtraId = firstCheckId;
        }
    }

    /// <summary>
    /// Updatable Events
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
    /// Overwritable Events
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