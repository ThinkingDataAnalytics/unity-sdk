using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;

namespace ThinkingSDK.PC.Utils
{
    public class ThinkingSDKChecker
    {
        private static readonly Regex keyPattern = new Regex(@"^[a-zA-Z][a-zA-Z\d_#]{0,49}$");

        public static bool IsNumeric(object AObject)
        {
            return AObject is sbyte 
                || AObject is byte 
                || AObject is short 
                || AObject is ushort
                || AObject is int 
                || AObject is uint 
                || AObject is long 
                || AObject is ulong 
                || AObject is double 
                || AObject is decimal 
                || AObject is float;
        }

        public static bool IsList(object obj) {
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
            foreach(KeyValuePair<string, V> kv in properties) {
                if (!CheckString(kv.Key))
                {
                    return false;
                }

                if (!(kv.Value is string || kv.Value is DateTime || kv.Value is bool || IsNumeric(kv.Value) || IsList(kv.Value)))
                {
                    ThinkingSDKLogger.Print("TA.PropertiesChecker - property values must be one of: string, numberic, Boolean, DateTime, Array");
                    return false;
                }

                if (kv.Value is string && System.Text.Encoding.UTF8.GetBytes(Convert.ToString(kv.Value)).Length > 2048) {
                    ThinkingSDKLogger.Print("TA.PropertiesChecker - the string is too long: " + (string)(object)kv.Value);
                    return false;
                }

                if (IsNumeric(kv.Value)) {
                    double number = Convert.ToDouble(kv.Value);
                    if (number > 9999999999999.999 || number < -9999999999999.999)
                    {
                        ThinkingSDKLogger.Print("TA.PropertiesChecker - number value is invalid: " + number + ", 数据范围是-9E15至9E15，小数点最多保留3位");
                        return false;
                    }
                }
            }
            return true;
        }

        public static bool CheckProperteis(List<string> properties)
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

        public static bool CheckString(string eventName)
        {
            if (string.IsNullOrEmpty(eventName))
            {
                ThinkingSDKLogger.Print("TA.PropertiesChecker - the string is null");
                return false;
            }

            if (keyPattern.IsMatch(eventName))
            {
                return true;
            } else
            {
                ThinkingSDKLogger.Print("TA.PropertiesChecker - the string is invalid for TA: " + eventName + ", " +
                "事件名和属性名规则: 必须以字母开头，只能包含：数字，字母（忽略大小写）和下划线“_”，长度最大为50个字符。请注意配置时不要带有空格。");
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

