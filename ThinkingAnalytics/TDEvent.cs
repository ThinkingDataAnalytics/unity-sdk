using System;
using System.Collections.Generic;

namespace ThinkingData.Analytics
{
    /// <summary>
    /// Special event class for internal use, do not use this class directly.
    /// </summary>
    public abstract class TDEventModel
    {
        public enum TDEventType
        {
            First,
            Updatable,
            Overwritable
        }

        public TDEventModel(string eventName)
        {
            EventName = eventName;
        }

        public TDEventType? EventType { get; set; }
        public string EventName { get; }
        public Dictionary<string, object> Properties { get; set; }
        public string StrProperties { get; set; }

        private DateTime EventTime { get; set; }
        private TimeZoneInfo EventTimeZone { get; set; }
        protected string ExtraId { get; set; }

        /// <summary>
        /// Set date time and timezone for the event
        /// </summary>
        /// <param name="time">date time</param>
        /// <param name="timeZone">timezone</param>
        public void SetTime(DateTime time, TimeZoneInfo timeZone)
        {
            EventTime = time;
            EventTimeZone = timeZone;
        }

        /// <summary>
        /// Get date time for the event
        /// </summary>
        /// <returns></returns>
        public DateTime GetEventTime()
        {
            return EventTime;
        }

        /// <summary>
        /// Get timezone for the event
        /// </summary>
        /// <returns></returns>
        public TimeZoneInfo GetEventTimeZone()
        {
            return EventTimeZone;
        }

        /// <summary>
        /// Get identify code for the event
        /// </summary>
        /// <returns></returns>
        public string GetEventId()
        {
            return ExtraId;
        }
    }

    /// <summary>
    /// First Event Model
    /// </summary>
    public class TDFirstEventModel : TDEventModel
    {
        /// <summary>
        /// Construct TDFirstEventModel instance
        /// </summary>
        /// <param name="eventName">name for the event</param>
        public TDFirstEventModel(string eventName) : base(eventName)
        {
            EventType = TDEventType.First;
        }

        /// <summary>
        /// Construct TDFirstEventModel instance
        /// </summary>
        /// <param name="eventName">name for the event</param>
        /// <param name="firstCheckId">check ID for the first event</param>
        public TDFirstEventModel(string eventName, string firstCheckId) : base(eventName)
        {
            EventType = TDEventType.First;
            ExtraId = firstCheckId;
        }
    }

    /// <summary>
    /// Updatable Event Model
    /// </summary>
    public class TDUpdatableEventModel : TDEventModel
    {
        /// <summary>
        /// Construct TDUpdatableEventModel instance
        /// </summary>
        /// <param name="eventName">name for the event</param>
        /// <param name="eventId">ID for the event</param>
        public TDUpdatableEventModel(string eventName, string eventId) : base(eventName)
        {
            EventType = TDEventType.Updatable;
            ExtraId = eventId;
        }
    }

    /// <summary>
    /// Overwritable Event Model
    /// </summary>
    public class TDOverwritableEventModel : TDEventModel
    {
        /// <summary>
        /// Construct TDOverwritableEventModel instance
        /// </summary>
        /// <param name="eventName">name for the event</param>
        /// <param name="eventId">ID for the event</param>
        public TDOverwritableEventModel(string eventName, string eventId) : base(eventName)
        {
            EventType = TDEventType.Overwritable;
            ExtraId = eventId;
        }
    }

}