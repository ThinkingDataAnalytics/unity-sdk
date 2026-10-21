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

    /// <summary>
    /// SDK error callback interface.
    /// </summary>
    public interface TDErrorCallbackHandler
    {
        /// <summary>
        /// Called when SDK data send or related operations fail.
        /// Error codes are platform-native values (not unified): Android 1001/1002/1003/1004/1006; iOS network errors use 10001.
        /// </summary>
        /// <param name="code">error code from native SDK</param>
        /// <param name="errorMsg">error description or server response</param>
        /// <param name="ext">extra context, typically the request payload</param>
        void OnSDKErrorCallback(int code, string errorMsg, string ext);
    }
}