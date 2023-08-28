using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;

namespace ThinkingData.Analytics.Utils
{
    public class TDPropertiesChecker
    {
        private static readonly Regex keyPattern = new Regex(@"^[a-zA-Z][a-zA-Z\d_#]{0,49}$");
        private static readonly List<string> propertyNameWhitelist = new List<string>() { "#scene_name", "#scene_path", "#app_crashed_reason" };

        public static bool IsNumeric(object obj)
        {
            return obj is sbyte 
                || obj is byte 
                || obj is short 
                || obj is ushort
                || obj is int 
                || obj is uint 
                || obj is long 
                || obj is ulong 
                || obj is double 
                || obj is decimal 
                || obj is float;
        }
        public static bool IsString(object obj)
        {
            if (obj == null)
                return false;
            return obj is string;
        }
        public static bool IsDictionary(object obj) 
        {
            if (obj == null)
                return false;
            return (obj.GetType().IsGenericType && obj.GetType().GetGenericTypeDefinition() == typeof(Dictionary<,>));
        }
        public static bool IsList(object obj) 
        {
            if (obj == null)
                return false;
            return (obj.GetType().IsGenericType && obj.GetType().GetGenericTypeDefinition() == typeof(List<>)) || obj is Array;
        }
        public static bool CheckProperties<V>(Dictionary<string, V> properties)
        {
            if (properties == null)
            {
                return true;
            }
            bool ret = true;
            foreach(KeyValuePair<string, V> kv in properties) 
            {
                if (!CheckString(kv.Key))
                {
                    ret = false;
                }
                if (!(kv.Value is string || kv.Value is DateTime || kv.Value is bool || IsNumeric(kv.Value) || IsList(kv.Value) || IsDictionary(kv.Value)))
                {
                    if(TDLog.GetEnable()) TDLog.w("Incorrect property - property values must be one of: String, Numberic, Boolean, DateTime, Array, Row");
                    ret = false;
                }
                if (IsString(kv.Value) && !CheckProperties(kv.Value as string)) 
                {
                    ret = false;
                }
                if (IsNumeric(kv.Value)) {
                    double number = Convert.ToDouble(kv.Value);
                    if (!CheckProperties(number))
                    {
                        ret = false;
                    }
                }
                if (IsList(kv.Value) && !CheckProperties(kv.Value as List<object>)) {
                    ret = false;
                }
                if (IsDictionary(kv.Value) && !CheckProperties(kv.Value as Dictionary<string, object>)) 
                {
                    ret = false;
                }
            }
            return ret;
        }
        public static bool CheckProperties(List<object> properties)
        {
            if (properties == null)
            {
                return true;
            }
            bool ret = true;
            foreach (object value in properties)
            {
                if (!(value is string || value is DateTime || value is bool || IsNumeric(value) || IsDictionary(value)))
                {
                    if(TDLog.GetEnable()) TDLog.w("Incorrect property - property values in list must be one of: String, Numberic, Boolean, DateTime, Row");
                    ret = false;
                }
                if (IsString(value) && !CheckProperties(value as string)) 
                {
                    ret = false;
                }
                if (IsNumeric(value)) {
                    double number = Convert.ToDouble(value);
                    if (!CheckProperties(number))
                    {
                        ret = false;
                    }
                }
                if (IsDictionary(value) && !CheckProperties(value as Dictionary<string, object>)) 
                {
                    ret = false;
                }
            }
            return ret;
        }
        public static bool CheckProperties(List<string> properties)
        {
            if (properties == null)
            {
                return true;
            }

            bool ret = true;
            foreach(string value in properties)
            {
                if (!CheckProperties(value))
                {
                    ret = false;
                }
            }
            return ret;
        }
        public static bool CheckProperties(string properties) 
        {
            if (properties is string && System.Text.Encoding.UTF8.GetBytes(Convert.ToString(properties)).Length > 2048) {
                if(TDLog.GetEnable()) TDLog.w("Incorrect properties - the string is too long: " + (string)(object)properties);
                return false;
            }
            return true;
        }
        public static bool CheckProperties(double properties) 
        {
            if (properties > 9999999999999.999 || properties < -9999999999999.999)
            {
                if(TDLog.GetEnable()) TDLog.w("Incorrect properties - number value is invalid: " + properties + ", the data range is -9E15 to 9E15, with a maximum of 3 decimal places");
                return false;
            }
            return true;
        }
        public static bool CheckString(string eventName)
        {
            if (string.IsNullOrEmpty(eventName))
            {
                if(TDLog.GetEnable()) TDLog.w("Incorrect event name - the string is null");
                return false;
            }
            if (keyPattern.IsMatch(eventName))
            {
                return true;
            } 
            else
            {
                if (propertyNameWhitelist.Contains(eventName))
                {
                    return true;
                }
                if(TDLog.GetEnable()) TDLog.w("Incorrect event name - the string is invalid for TDAnalytics: " + eventName + ", event name and properties name rules: must be character string type, starting with a character and containing figures, characters, and an underline \"_\", with a maximum length of 50 characters");
                return false;
            }
        }
        public static void MergeProperties(Dictionary<string, object> source, Dictionary<string, object> dest)
        {
            if (null == source) return;
            foreach (KeyValuePair<string, object> kv in source)
            {
                if (dest.ContainsKey(kv.Key))
                {
                    dest[kv.Key] = kv.Value;
                } else
                {
                    dest.Add(kv.Key, kv.Value);
                }
            }
        }
    }
}

