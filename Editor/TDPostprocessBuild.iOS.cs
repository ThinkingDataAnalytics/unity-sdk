#if UNITY_EDITOR
using System.IO;
using System.Text.RegularExpressions;
using ThinkingData.Analytics.Utils;
using UnityEditor;
using UnityEditor.Callbacks;
using UnityEditor.iOS.Xcode;
using UnityEngine;

namespace ThinkingData.Analytics.Editors
{
    public static class TD_PostProcessBuildIOS
    {
        [PostProcessBuildAttribute(88)]
        public static void OnPostProcessBuild(BuildTarget target, string targetPath)
        {
            if (target != BuildTarget.iOS)
            {
                return;
            }

            string projPath = Path.GetFullPath(targetPath) + "/Unity-iPhone.xcodeproj/project.pbxproj";

            PBXProject proj = new PBXProject();
            proj.ReadFromFile(projPath);
#if UNITY_2019_3_OR_NEWER
            string targetGuid = proj.GetUnityFrameworkTargetGuid();
#else
            string targetGuid = proj.TargetGuidByName(PBXProject.GetUnityTargetName());
#endif

            proj.SetBuildProperty(targetGuid, "ENABLE_BITCODE", "NO");
            proj.SetBuildProperty(targetGuid, "GCC_ENABLE_OBJC_EXCEPTIONS", "YES");
            proj.AddBuildProperty(targetGuid, "OTHER_LDFLAGS", "-ObjC");

            string[] headerSearchPathsToAdd = { "$(SRCROOT)/Libraries/Plugins/iOS/ThinkingSDK/Source/main", "$(SRCROOT)/Libraries/Plugins/iOS/ThinkingSDK/Source/common" };
            proj.UpdateBuildProperty(targetGuid, "HEADER_SEARCH_PATHS", headerSearchPathsToAdd, null);

            proj.AddFrameworkToProject(targetGuid, "WebKit.framework", true);
            proj.AddFrameworkToProject(targetGuid, "CoreTelephony.framework", true);
            proj.AddFrameworkToProject(targetGuid, "SystemConfiguration.framework", true);
            proj.AddFrameworkToProject(targetGuid, "Security.framework", true);
            proj.AddFrameworkToProject(targetGuid, "UserNotifications.framework", true);

            proj.AddFileToBuild(targetGuid, proj.AddFile("usr/lib/libsqlite3.tbd", "libsqlite3.tbd", PBXSourceTree.Sdk));
            proj.AddFileToBuild(targetGuid, proj.AddFile("usr/lib/libz.tbd", "libz.tbd", PBXSourceTree.Sdk));

            proj.WriteToFile(projPath);

            string plistPath = Path.Combine(targetPath, "Info.plist");
            PlistDocument plist = new PlistDocument();
            plist.ReadFromFile(plistPath);
            plist.root.CreateArray("TDDisPresetProperties");
            TDPublicConfig.GetPublicConfig();
            foreach (string item in TDPublicConfig.DisPresetProperties)
            {
                plist.root["TDDisPresetProperties"].AsArray().AddString(item);
            }
            if (HasEnableDNSServiceCallInProject())
            {
                PlistElementDict atsDict;
                if (plist.root.values.ContainsKey("NSAppTransportSecurity"))
                {
                    atsDict = plist.root["NSAppTransportSecurity"].AsDict();
                }
                else
                {
                    atsDict = plist.root.CreateDict("NSAppTransportSecurity");
                }
                atsDict.SetBoolean("NSAllowsArbitraryLoads", true);
            }
            plist.WriteToFile(plistPath);
        }

        // ATS must be written at export time. Runtime EnableDNSService cannot change Info.plist.
        // iOS export relaxes ATS only when game scripts call EnableDNSService.
        private static bool HasEnableDNSServiceCallInProject()
        {
            string assetsRoot = Application.dataPath;
            if (!Directory.Exists(assetsRoot))
            {
                return false;
            }
            string[] files = Directory.GetFiles(assetsRoot, "*.cs", SearchOption.AllDirectories);
            for (int i = 0; i < files.Length; i++)
            {
                string normalized = files[i].Replace("\\", "/");
                if (ShouldSkipDnsScanPath(normalized))
                {
                    continue;
                }
                string content = File.ReadAllText(files[i]);
                if (content.IndexOf("EnableDNSService(") < 0)
                {
                    continue;
                }
                if (ContainsEnableDNSServiceCall(content))
                {
                    return true;
                }
            }
            return false;
        }

        private static bool ShouldSkipDnsScanPath(string normalizedPath)
        {
            return normalizedPath.Contains("/ThinkingAnalytics/")
                || normalizedPath.Contains("/Assets/Editor/")
                || normalizedPath.Contains("/Assets/Tests/");
        }

        private static bool ContainsEnableDNSServiceCall(string content)
        {
            content = Regex.Replace(content, @"/\*.*?\*/", "", RegexOptions.Singleline);
            string[] lines = content.Split('\n');
            for (int i = 0; i < lines.Length; i++)
            {
                string trimmed = lines[i].Trim();
                if (trimmed.StartsWith("//"))
                {
                    continue;
                }
                int commentIndex = trimmed.IndexOf("//");
                string code = commentIndex >= 0 ? trimmed.Substring(0, commentIndex) : trimmed;
                if (code.IndexOf("EnableDNSService(") >= 0 && code.IndexOf("void EnableDNSService") < 0)
                {
                    return true;
                }
            }
            return false;
        }
    }
}
#endif
