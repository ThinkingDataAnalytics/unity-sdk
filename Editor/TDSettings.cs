using System;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;
using UnityEngine.UIElements;
using ThinkingData.Analytics.Utils;
namespace ThinkingData.Analytics.Editors {

    [CustomEditor(typeof(TDAnalyticSetting))]
    public class TDSettingsView : Editor {
        protected override void OnHeaderGUI()
        {
            GUILayout.Label("请从Project Settings配置");
        }
        public override void OnInspectorGUI() { }
    }

    public class TDAnalyticSettingUtil
    {
        private const string SettingsFile = "Assets/Resources/TDAnalyticSetting.asset";

        public static TDAnalyticSetting GetOrCreateSettings()
        {
            TDAnalyticSetting settings = AssetDatabase.LoadAssetAtPath<TDAnalyticSetting>(SettingsFile);
            if (settings == null)
            {
                settings = ScriptableObject.CreateInstance<TDAnalyticSetting>();
                if (!Directory.Exists(Path.GetDirectoryName(SettingsFile)))
                {
                    Directory.CreateDirectory(Path.GetDirectoryName(SettingsFile));
                }
                AssetDatabase.CreateAsset(settings, SettingsFile);
                AssetDatabase.SaveAssets();
            }
            return settings;
        }

        public static SerializedObject GetSerializedSettings()
        {
            return new SerializedObject(GetOrCreateSettings());
        }
    }

    public class TDAnalyticSettingsProvider : SettingsProvider
    {
        private const string ProjectSettingPtah = "Project/TDAnalytics";


        private SerializedObject settings;


        public TDAnalyticSettingsProvider(string path, SettingsScope scopes) : base(path, scopes)
        {
        }

        public override void OnActivate(string searchContext, VisualElement rootElement)
        {
            settings = TDAnalyticSettingUtil.GetSerializedSettings();
        }

        public override void OnGUI(string searchContext)
        {
            EditorGUILayout.PropertyField(settings.FindProperty("enableLog"), new GUIContent("Enable Log："));
            EditorGUILayout.PropertyField(settings.FindProperty("networkType"), new GUIContent("Network Type："));
            EditorGUILayout.PropertyField(settings.FindProperty("appId"), new GUIContent("APP ID："));
            EditorGUILayout.PropertyField(settings.FindProperty("serverUrl"), new GUIContent("SERVER URL："));
            EditorGUILayout.PropertyField(settings.FindProperty("mode"), new GUIContent("MODEL："));
            EditorGUILayout.PropertyField(settings.FindProperty("timeZone"), new GUIContent("TimeZone："));
            EditorGUILayout.PropertyField(settings.FindProperty("encryptVersion"), new GUIContent("Encrypt Version："));
            EditorGUILayout.PropertyField(settings.FindProperty("encryptPublicKey"), new GUIContent("Encrypt PublicKey："));
            settings.ApplyModifiedPropertiesWithoutUndo();
        }


        [SettingsProvider]
        public static SettingsProvider CreateTDAnalyticSettingsProvider()
        {
            var provider = new TDAnalyticSettingsProvider(ProjectSettingPtah, SettingsScope.Project);
            provider.keywords = new HashSet<string>(new[] { "TDAnalytics", "Analytic", "TA" });
            return provider;
        }
    }


}
