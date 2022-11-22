using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;

namespace ThinkingAnalytics.Utils
{
    public class TD_PropertiesChecker
    {
        private static readonly Regex keyPattern = new Regex(@"^[a-zA-Z][a-zA-Z\d_#]{0,49}$");

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
        // 检测属性是否合法
        public static bool CheckProperties<V>(Dictionary<string, V> properties)
        {
            if (properties == null)
            {
                return true;
            }
            foreach(KeyValuePair<string, V> kv in properties) 
            {
                if (!CheckString(kv.Key))
                {
                    return false;
                }
                if (!(kv.Value is string || kv.Value is DateTime || kv.Value is bool || IsNumeric(kv.Value) || IsList(kv.Value) || IsDictionary(kv.Value)))
                {
                    TD_Log.w("TA.PropertiesChecker - property values must be one of: string, numberic, Boolean, DateTime, Array, Row");
                    return false;
                }
                if (IsString(kv.Value)) 
                {
                    return CheckProperties(kv.Value as string);
                }
                if (IsNumeric(kv.Value)) {
                    double number = Convert.ToDouble(kv.Value);
                    return CheckProperties(number);
                }
                if (IsList(kv.Value)) {
                    return CheckProperties(kv.Value as List<object>);
                }
                if (IsDictionary(kv.Value)) 
                {
                    return CheckProperties(kv.Value as Dictionary<string, object>);
                }
            }
            return true;
        }
        // 检测属性是否合法 - Array(Row)
        public static bool CheckProperties(List<object> properties)
        {
            if (properties == null)
            {
                return true;
            }
            foreach(object value in properties)
            {
                if (!(value is string || value is DateTime || value is bool || IsNumeric(value) || IsDictionary(value)))
                {
                    TD_Log.w("TA.PropertiesChecker - property values in list must be one of: string, numberic, Boolean, DateTime, Row");
                    return false;
                }
                if (IsString(value)) 
                {
                    return CheckProperties(value as string);
                }
                if (IsNumeric(value)) {
                    double number = Convert.ToDouble(value);
                    return CheckProperties(number);
                }
                if (IsDictionary(value)) 
                {
                    return CheckProperties(value as Dictionary<string, object>);
                }
            }
            return true;
        }
        // 检测属性是否合法 - Array
        public static bool CheckProperties(List<string> properties)
        {
            if (properties == null)
            {
                return true;
            }

            foreach(string value in properties)
            {
                if (!CheckString(value))
                {
                    return false;
                }
            }
            return true;
        }
        // 检测属性是否合法 - String
        public static bool CheckProperties(string properties) 
        {
            if (properties is string && System.Text.Encoding.UTF8.GetBytes(Convert.ToString(properties)).Length > 2048) {
                TD_Log.w("TA.PropertiesChecker - the string is too long: " + (string)(object)properties);
                return false;
            }
            return true;
        }
        // 检测属性是否合法 - Number
        public static bool CheckProperties(double properties) 
        {
            if (properties > 9999999999999.999 || properties < -9999999999999.999)
            {
                TD_Log.w("TA.PropertiesChecker - number value is invalid: " + properties + ", 数据范围是-9E15至9E15，小数点最多保留3位");
                return false;
            }
            return true;
        }
        public static bool CheckString(string eventName)
        {
            if (string.IsNullOrEmpty(eventName))
            {
                TD_Log.w("TA.PropertiesChecker - the string is null");
                return false;
            }
            if (keyPattern.IsMatch(eventName))
            {
                return true;
            } 
            else
            {
                TD_Log.w("TA.PropertiesChecker - the string is invalid for TA: " + eventName + ", " + "事件名和属性名规则: 必须以字母开头，只能包含：数字，字母（忽略大小写）和下划线“_”，长度最大为50个字符。请注意配置时不要带有空格。");
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

