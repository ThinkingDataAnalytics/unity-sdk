using System.Collections.Generic;

namespace ThinkingAnalytics
{
    /// <summary>
    /// Dynamic super properties interfaces.
    /// </summary>
    public interface IDynamicSuperProperties
    {
        Dictionary<string, object> GetDynamicSuperProperties();
    }

    /// <summary>
    /// Auto track event callback interfaces.
    /// </summary>
    public interface IAutoTrackEventCallback
    {
        Dictionary<string, object> AutoTrackEventCallback(int type, Dictionary<string, object> properties);
    }
}