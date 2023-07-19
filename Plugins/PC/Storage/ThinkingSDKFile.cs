using System;
using UnityEngine;

namespace ThinkingSDK.PC.Storage
{
    public class ThinkingSDKFile
    {
        private static string connectorKey = "_";
        public static string GetKey(string prefix,string key)
        {
            return prefix + connectorKey + key;
        }
        public static void SaveData(string prefix, string key, object value)
        {
            SaveData(GetKey(prefix, key), value);
        }
        public static void SaveData(string key, object value)
        {
            if (!string.IsNullOrEmpty(key))
            {
                if (value.GetType() == typeof(int))
                {
                    PlayerPrefs.SetInt(key, (int)value);
                }
                else if (value.GetType() == typeof(float))
                {
                    PlayerPrefs.SetFloat(key, (float)value);
                }
                else if (value.GetType() == typeof(string))
                {
                    PlayerPrefs.SetString(key, (string)value);
                }
                PlayerPrefs.Save();
            }
        }
        public static object GetData(string key, Type type)
        {
            if (!string.IsNullOrEmpty(key) && PlayerPrefs.HasKey(key))
            {
                if (type == typeof(int))
                {
                    return PlayerPrefs.GetInt(key);
                }
                else if (type == typeof(float))
                {
                    return PlayerPrefs.GetFloat(key);
                }
                else if (type == typeof(string))
                {
                    return PlayerPrefs.GetString(key);
                }
                PlayerPrefs.Save();
            }
            return null;

        }
        public static object GetData(string prefix,string key, Type type)
        {
            key = GetKey(prefix, key);
            return GetData(key, type);
        }

        public static void DeleteData(string key)
        {
            if (!string.IsNullOrEmpty(key))
            {
                if (PlayerPrefs.HasKey(key))
                {
                    PlayerPrefs.DeleteKey(key);
                }
            }
        }
        public static void DeleteData(string prefix,string key)
        {
            key = GetKey(prefix, key);
            DeleteData(key);
        }
    }
}

