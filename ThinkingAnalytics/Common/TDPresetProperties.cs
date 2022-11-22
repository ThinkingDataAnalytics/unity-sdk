using System;
using System.Collections.Generic;

namespace ThinkingAnalytics
{
    ///// <summary>
    ///// 预置属性
    ///// </summary>
    public class TDPresetProperties
    {
        public TDPresetProperties(Dictionary<string, object> properties)
    {
        properties = TDEncodeDate(properties);
        mPresetProperties = properties;
    }
    // 返回事件预置属性的Key以"#"开头，不建议直接作为用户属性使用
    public Dictionary<string, object> ToEventPresetProperties()
    {
        return mPresetProperties;
    }
    public string AppVersion
    {
        get { return (string)(mPresetProperties.ContainsKey("#app_version") ? mPresetProperties["#app_version"] : ""); }
    }
    public string BundleId
    {
        get { return (string)(mPresetProperties.ContainsKey("#bundle_id") ? mPresetProperties["#bundle_id"] : ""); }
    }
    public string Carrier
    {
        get { return (string)(mPresetProperties.ContainsKey("#carrier") ? mPresetProperties["#carrier"] : ""); }
    }
    public string DeviceId
    {
        get { return (string)(mPresetProperties.ContainsKey("#device_id") ? mPresetProperties["#device_id"] : ""); }
    }
    public string DeviceModel
    {
        get { return (string)(mPresetProperties.ContainsKey("#device_model") ? mPresetProperties["#device_model"] : ""); }
    }
    public string Manufacturer
    {
        get { return (string)(mPresetProperties.ContainsKey("#manufacturer") ? mPresetProperties["#manufacturer"] : ""); }
    }
    public string NetworkType
    {
        get { return (string)(mPresetProperties.ContainsKey("#network_type") ? mPresetProperties["#network_type"] : ""); }
    }
    public string OS
    {
        get { return (string)(mPresetProperties.ContainsKey("#os") ? mPresetProperties["#os"] : ""); }
    }
    public string OSVersion
    {
        get { return (string)(mPresetProperties.ContainsKey("#os_version") ? mPresetProperties["#os_version"] : ""); }
    }
    public double ScreenHeight
    {
        get { return Convert.ToDouble(mPresetProperties.ContainsKey("#screen_height") ? mPresetProperties["#screen_height"] : 0); }
    }
    public double ScreenWidth
    {
        get { return Convert.ToDouble(mPresetProperties.ContainsKey("#screen_width") ? mPresetProperties["#screen_width"] : 0); }
    }
    public string SystemLanguage
    {
        get { return (string)(mPresetProperties.ContainsKey("#system_language") ? mPresetProperties["#system_language"] : ""); }
    }
    public double ZoneOffset
    {
        get { return Convert.ToDouble(mPresetProperties.ContainsKey("#zone_offset") ? mPresetProperties["#zone_offset"] : 0); }
    }
    public string InstallTime
    {
        get { return (string)(mPresetProperties.ContainsKey("#install_time") ? mPresetProperties["#install_time"] : ""); }
    }
    public string Disk
    {
        get { return (string)(mPresetProperties.ContainsKey("#disk") ? mPresetProperties["#disk"] : ""); }
    }
    public string Ram
    {
        get { return (string)(mPresetProperties.ContainsKey("#ram") ? mPresetProperties["#ram"] : ""); }
    }
    public double Fps
    {
        get { return Convert.ToDouble(mPresetProperties.ContainsKey("#fps") ? mPresetProperties["#fps"] : 0); }
    }
    public bool Simulator
    {
        get { return (bool)(mPresetProperties.ContainsKey("#simulator") ? mPresetProperties["#simulator"] : false); }
    }

    private Dictionary<string, object> mPresetProperties { get; set; }
    private Dictionary<string, object> TDEncodeDate(Dictionary<string, object> properties)
    {
        Dictionary<string, object> mProperties = new Dictionary<string, object>();
        foreach (KeyValuePair<string, object> kv in properties)
        {
            if (kv.Value is DateTime)
            {
                DateTime dateTime = (DateTime)kv.Value;
                mProperties.Add(kv.Key, dateTime.ToString("yyyy-MM-dd HH:mm:ss.fff", System.Globalization.CultureInfo.InvariantCulture));
            }
            else
            {
                mProperties.Add(kv.Key, kv.Value);
            }
        }
        return mProperties;
    }
}
}