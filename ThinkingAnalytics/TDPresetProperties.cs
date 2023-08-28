using System;
using System.Collections.Generic;

namespace ThinkingData.Analytics
{
    /// <summary>
    /// Preset Properties
    /// </summary>
    public class TDPresetProperties
    {
        /// <summary>
        /// Construct TDPresetProperties instance
        /// </summary>
        /// <param name="properties">preset properties</param>
        public TDPresetProperties(Dictionary<string, object> properties)
        {
            properties = TDEncodeDate(properties);
            mPresetProperties = properties;
        }
        /// <summary>
        /// Returns Preset Properties
        /// The key starts with "#", it is not recommended to use it directly as a user properties
        /// </summary>
        /// <returns>preset properties</returns>
        public Dictionary<string, object> ToDictionary()
        {
            return mPresetProperties;
        }
        /// <summary>
        /// Application Version Number
        /// </summary>
        public string AppVersion
        {
            get { return (string)(mPresetProperties.ContainsKey("#app_version") ? mPresetProperties["#app_version"] : ""); }
        }
        /// <summary>
        /// Application Bundle Identify
        /// </summary>
        public string BundleId
        {
            get { return (string)(mPresetProperties.ContainsKey("#bundle_id") ? mPresetProperties["#bundle_id"] : ""); }
        }
        /// <summary>
        /// Device Network Carrier
        /// </summary>
        public string Carrier
        {
            get { return (string)(mPresetProperties.ContainsKey("#carrier") ? mPresetProperties["#carrier"] : ""); }
        }
        /// <summary>
        /// Device Identify
        /// </summary>
        public string DeviceId
        {
            get { return (string)(mPresetProperties.ContainsKey("#device_id") ? mPresetProperties["#device_id"] : ""); }
        }
        /// <summary>
        /// Device Model Name
        /// </summary>
        public string DeviceModel
        {
            get { return (string)(mPresetProperties.ContainsKey("#device_model") ? mPresetProperties["#device_model"] : ""); }
        }
        /// <summary>
        /// Device Hardware Manufacturer
        /// </summary>
        public string Manufacturer
        {
            get { return (string)(mPresetProperties.ContainsKey("#manufacturer") ? mPresetProperties["#manufacturer"] : ""); }
        }
        /// <summary>
        /// Device Network Type
        /// </summary>
        public string NetworkType
        {
            get { return (string)(mPresetProperties.ContainsKey("#network_type") ? mPresetProperties["#network_type"] : ""); }
        }
        /// <summary>
        /// Device System OS Name
        /// </summary>
        public string OS
        {
            get { return (string)(mPresetProperties.ContainsKey("#os") ? mPresetProperties["#os"] : ""); }
        }
        /// <summary>
        /// Device System OS Version Number
        /// </summary>
        public string OSVersion
        {
            get { return (string)(mPresetProperties.ContainsKey("#os_version") ? mPresetProperties["#os_version"] : ""); }
        }
        /// <summary>
        /// Screen Height
        /// </summary>
        public double ScreenHeight
        {
            get { return Convert.ToDouble(mPresetProperties.ContainsKey("#screen_height") ? mPresetProperties["#screen_height"] : 0); }
        }
        /// <summary>
        /// Screen Width
        /// </summary>
        public double ScreenWidth
        {
            get { return Convert.ToDouble(mPresetProperties.ContainsKey("#screen_width") ? mPresetProperties["#screen_width"] : 0); }
        }
        /// <summary>
        /// Device System Language Code
        /// </summary>
        public string SystemLanguage
        {
            get { return (string)(mPresetProperties.ContainsKey("#system_language") ? mPresetProperties["#system_language"] : ""); }
        }
        /// <summary>
        /// Time Zone Offset With UTC
        /// </summary>
        public double ZoneOffset
        {
            get { return Convert.ToDouble(mPresetProperties.ContainsKey("#zone_offset") ? mPresetProperties["#zone_offset"] : 0); }
        }
        /// <summary>
        /// Application Install Time
        /// </summary>
        public string InstallTime
        {
            get { return (string)(mPresetProperties.ContainsKey("#install_time") ? mPresetProperties["#install_time"] : ""); }
        }
        /// <summary>
        /// Device Disk Size
        /// </summary>
        public string Disk
        {
            get { return (string)(mPresetProperties.ContainsKey("#disk") ? mPresetProperties["#disk"] : ""); }
        }
        /// <summary>
        /// Device Ram Size
        /// </summary>
        public string Ram
        {
            get { return (string)(mPresetProperties.ContainsKey("#ram") ? mPresetProperties["#ram"] : ""); }
        }
        /// <summary>
        /// Device FPS
        /// </summary>
        public double Fps
        {
            get { return Convert.ToDouble(mPresetProperties.ContainsKey("#fps") ? mPresetProperties["#fps"] : 0); }
        }
        /// <summary>
        /// Device is an Simulator
        /// </summary>
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