using System.Collections.Generic;

namespace ThinkingData.Analytics
{
    /// <summary>
    /// Dynamic super properties interfaces.
    /// </summary>
    public interface TDDynamicSuperPropertiesHandler
    {
        /// <summary>
        /// Dynamically gets event properties
        /// </summary>
        /// <returns>event properties</returns>
        Dictionary<string, object> GetDynamicSuperProperties();
    }

    /// <summary>
    /// Auto track event callback interfaces.
    /// </summary>
    public interface TDAutoTrackEventHandler
    {
        /// <summary>
        /// Get Auto track event properties
        /// </summary>
        /// <param name="type">auto track event type</param>
        /// <param name="properties">event properties</param>
        /// <returns>event properties</returns>
        Dictionary<string, object> GetAutoTrackEventProperties(int type, Dictionary<string, object> properties);
    }
}