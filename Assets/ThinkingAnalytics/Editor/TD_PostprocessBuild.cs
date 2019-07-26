using System.IO;
using UnityEditor;
using UnityEditor.Callbacks;
using UnityEditor.iOS.Xcode;

namespace ThinkingAnalytics.Editors
{
    public class TD_PostProcessBuild
    {
        [PostProcessBuild]
        public static void OnPostProcessBuild(BuildTarget buildTarget, string path)
        {
            if (buildTarget != BuildTarget.iOS)
            {
                return;
            }

            string projPath = PBXProject.GetPBXProjectPath(path);

            PBXProject proj = new PBXProject();
            proj.ReadFromString(File.ReadAllText(projPath));

            string targetName = PBXProject.GetUnityTargetName();
            string target = proj.TargetGuidByName(targetName);

            CopyAndReplaceDirectory("Assets/Plugins/iOS/ThinkingSDK.framework", Path.Combine(path, "Frameworks/ThinkingSDK.framework"));
            proj.AddFileToBuild(target, proj.AddFile("Frameworks/ThinkingSDK.framework", "Frameworks/ThinkingSDK.framework", PBXSourceTree.Source));
            proj.AddBuildProperty(target, "HEADER_SEARCH_PATHS", "$(SRCROOT)/Frameworks/ThinkingSDK.framework/Headers");
            proj.AddBuildProperty(target, "OTHER_LDFLAGS", "-ObjC");

            File.WriteAllText(projPath, proj.WriteToString());
        }

        static internal void CopyAndReplaceDirectory(string srcPath, string dstPath)
        {
            if (dstPath.EndsWith(".meta", System.StringComparison.Ordinal))
                return;

            if (dstPath.EndsWith(".DS_Store", System.StringComparison.Ordinal))
                return;
            if (Directory.Exists(dstPath))
                Directory.Delete(dstPath, true);
            if (File.Exists(dstPath))
                File.Delete(dstPath);

            Directory.CreateDirectory(dstPath);

            foreach (var file in Directory.GetFiles(srcPath))
            {
                File.Copy(file, Path.Combine(dstPath, Path.GetFileName(file)));
            }

            foreach (var dir in Directory.GetDirectories(srcPath))
            {
                CopyAndReplaceDirectory(dir, Path.Combine(dstPath, Path.GetFileName(dir)));
            }
        }
    }
}
