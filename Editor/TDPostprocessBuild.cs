#if UNITY_EDITOR && UNITY_IOS
using System.IO;
using ThinkingData.Analytics.Utils;
using UnityEditor;
using UnityEditor.Callbacks;
using UnityEditor.iOS.Xcode;
using UnityEngine;

namespace ThinkingData.Analytics.Editors
{
    public class TD_PostProcessBuild
    {
        //Xcode Build Settings
        //[PostProcessBuild]
        [PostProcessBuildAttribute(88)]
        public static void OnPostProcessBuild(BuildTarget target, string targetPath)
        {
            if (target != BuildTarget.iOS)
            {
                Debug.LogWarning("[ThinkingData] Warning: Target is not iOS. XCodePostProcess will not run");
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

            //Build Property
            proj.SetBuildProperty(targetGuid, "ENABLE_BITCODE", "NO");//BitCode  NO
            proj.SetBuildProperty(targetGuid, "GCC_ENABLE_OBJC_EXCEPTIONS", "YES");//Enable Objective-C Exceptions
            proj.AddBuildProperty(targetGuid, "OTHER_LDFLAGS", "-ObjC");

            string[] headerSearchPathsToAdd = { "$(SRCROOT)/Libraries/Plugins/iOS/ThinkingSDK/Source/main", "$(SRCROOT)/Libraries/Plugins/iOS/ThinkingSDK/Source/common" };
            proj.UpdateBuildProperty(targetGuid, "HEADER_SEARCH_PATHS", headerSearchPathsToAdd, null);// Header Search Paths

            //Add Frameworks
            proj.AddFrameworkToProject(targetGuid, "WebKit.framework", true);
            proj.AddFrameworkToProject(targetGuid, "CoreTelephony.framework", true);
            proj.AddFrameworkToProject(targetGuid, "SystemConfiguration.framework", true);
            proj.AddFrameworkToProject(targetGuid, "Security.framework", true);
            proj.AddFrameworkToProject(targetGuid, "UserNotifications.framework", true);

            //Add Lib
            proj.AddFileToBuild(targetGuid, proj.AddFile("usr/lib/libsqlite3.tbd", "libsqlite3.tbd", PBXSourceTree.Sdk));
            proj.AddFileToBuild(targetGuid, proj.AddFile("usr/lib/libz.tbd", "libz.tbd", PBXSourceTree.Sdk));

            proj.WriteToFile(projPath);

            //Info.plist
            //Disable preset properties
            string plistPath = Path.Combine(targetPath, "Info.plist");
            PlistDocument plist = new PlistDocument();
            plist.ReadFromFile(plistPath);
            plist.root.CreateArray("TDDisPresetProperties");
            TDPublicConfig.GetPublicConfig();
            foreach (string item in TDPublicConfig.DisPresetProperties)
            {
                plist.root["TDDisPresetProperties"].AsArray().AddString(item);
            }
            plist.WriteToFile(plistPath);
        }
    }
}
#endif

#if UNITY_OPENHARMONY
using System.IO;
using UnityEditor;
using UnityEditor.Callbacks;

namespace ThinkingData.Analytics.Editors
{
    public class TD_PostProcessBuild
    {
        private static void changeContent(string path, string srcStr, string destStr)
        {
            string jsonContent = File.ReadAllText(path);
            int index = jsonContent.IndexOf(srcStr);
            if (index == -1) return;
            File.WriteAllText(path, jsonContent.Substring(0, index) + destStr + jsonContent.Substring(index + srcStr.Length));
        }
        private static void ChangeFirstLineContent(string path, string srcStr, string destStr)
        {
            string tempPath = path + ".tmp";
            try
            {
                using (var reader = new StreamReader(path))
                using (var writer = new StreamWriter(tempPath))
                {
                    string firstLine = reader.ReadLine();
                    if (firstLine != null)
                    {
                        int index = firstLine.IndexOf(srcStr);
                        if (index != -1)
                        {
                            firstLine = firstLine.Substring(0, index) + destStr + firstLine.Substring(index + srcStr.Length);
                        }
                        writer.WriteLine(firstLine);
                    }
                    char[] buffer = new char[4096];
                    int bytesRead;
                    while ((bytesRead = reader.Read(buffer, 0, buffer.Length)) > 0)
                    {
                        writer.Write(buffer, 0, bytesRead);
                    }
                }
                File.Delete(path);
                File.Move(tempPath, path);
            }
            finally {
                if (File.Exists(tempPath))
                    File.Delete(tempPath);
            }
        }
        [PostProcessBuildAttribute(88)]
        public static void OnPostProcessBuild(BuildTarget target, string targetPath)
        {
            string entryPath = Path.Combine(targetPath, "entry/oh-package.json5");
            string entryBuildPath = Path.Combine(targetPath, "entry/build-profile.json5");
            string entryRegisterPath = Path.Combine(targetPath, "entry/src/main/ets/gen/TuanjieJSScriptRegister.ets");
            string entryProxyPath = Path.Combine(targetPath, "entry/src/main/ets/TDOpenHarmonyProxy.ts");
            if (File.Exists(entryPath) && File.Exists(entryProxyPath) && File.Exists(entryBuildPath) && File.Exists(entryRegisterPath))
            {
                changeContent(entryPath, "\"TDAnalytics\"", "\"@thinkingdata/analytics\"");
                changeContent(entryBuildPath, "\"TDAnalytics\"", "\"@thinkingdata/analytics\"");
                changeContent(entryRegisterPath, "'TDAnalytics'", "'@thinkingdata/analytics'");
                ChangeFirstLineContent(entryProxyPath, "} from 'TDAnalytics'", "} from '@thinkingdata/analytics'");
                return;
            }
            string tuanjieLibPath = Path.Combine(targetPath, "tuanjieLib/oh-package.json5");
            string tuanjieLibBuildPath = Path.Combine(targetPath, "tuanjieLib/build-profile.json5");
            string tuanjieRegisterPath = Path.Combine(targetPath, "tuanjieLib/src/main/ets/gen/TuanjieJSScriptRegister.ets");
            string tuanjieLibProxyPath = Path.Combine(targetPath, "tuanjieLib/src/main/ets/TDOpenHarmonyProxy.ts");
            if (File.Exists(tuanjieLibPath) && File.Exists(tuanjieLibProxyPath) && File.Exists(tuanjieLibBuildPath) && File.Exists(tuanjieRegisterPath))
            {
                changeContent(tuanjieLibPath, "\"TDAnalytics\"", "\"@thinkingdata/analytics\"");
                changeContent(tuanjieLibBuildPath, "\"TDAnalytics\"", "\"@thinkingdata/analytics\"");
                changeContent(tuanjieRegisterPath,  "'TDAnalytics'", "'@thinkingdata/analytics'");
                ChangeFirstLineContent(tuanjieLibProxyPath, "} from 'TDAnalytics'", "} from '@thinkingdata/analytics'");
                return;
            }
        }
    }
}
#endif

#if UNITY_EDITOR && UNITY_ANDROID && UNITY_2019_1_OR_NEWER
using UnityEditor;
using UnityEditor.Android;
using UnityEngine;
using System.IO;
using System.Xml;
using System.Collections.Generic;

namespace ThinkingData.Analytics.Editors
{

    class TD_PostProcessBuild : IPostGenerateGradleAndroidProject
    {
        // Copy configuration file ta_public_config.xml
        public int callbackOrder { get { return 0; } }
        public void OnPostGenerateGradleAndroidProject(string path)
        {
            // Copy configuration file ta_public_config.xml
            string desPath = path + "/../launcher/src/main/res/values/ta_public_config.xml";        
            if (File.Exists(desPath))
            {
                File.Delete(desPath);
            }
            TextAsset textAsset = Resources.Load<TextAsset>("ta_public_config"); 
            if (textAsset != null && textAsset.bytes != null)
            {
                File.WriteAllBytes(desPath, textAsset.bytes);
            }
        }
    }
}
#endif
