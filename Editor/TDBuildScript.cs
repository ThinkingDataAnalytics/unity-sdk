#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEngine;

namespace ThinkingData.Analytics.Editors
{
    public static class TDBuildScript
    {
        private const string DemoScene = "Assets/Sample/TDAnalyticsDemo.unity";
        private const string AndroidOutput = "AndroidPro";
        private const string iOSOutput = "iOSProj";

        public static void ExportAndroid()
        {
            ConfigureAndroidExportSettings();
            Export(BuildTarget.Android, AndroidOutput);
        }

        public static void ExportIOS()
        {
            Export(BuildTarget.iOS, iOSOutput);
        }

        private static void ConfigureAndroidExportSettings()
        {
            EditorUserBuildSettings.exportAsGoogleAndroidProject = true;
            EditorUserBuildSettings.androidBuildSystem = AndroidBuildSystem.Gradle;
            EditorUserBuildSettings.buildAppBundle = false;
        }

        private static void Export(BuildTarget target, string outputPath)
        {
            var options = new BuildPlayerOptions
            {
                scenes = new[] { DemoScene },
                locationPathName = outputPath,
                target = target,
                options = BuildOptions.None
            };

            BuildReport report = BuildPipeline.BuildPlayer(options);
            if (report.summary.result != BuildResult.Succeeded)
            {
                Debug.LogError($"[TDBuildScript] Export failed: {report.summary.result}, errors={report.summary.totalErrors}");
                EditorApplication.Exit(1);
                return;
            }

            Debug.Log($"[TDBuildScript] Export succeeded: {outputPath}");
            EditorApplication.Exit(0);
        }
    }
}
#endif
