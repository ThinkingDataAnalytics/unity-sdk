#if UNITY_IPHONE

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

            #if UNITY_2019_3_OR_NEWER
            string target = proj.GetUnityMainTargetGuid(); 
            #else
            string targetName = PBXProject.GetUnityTargetName();
            string target = proj.TargetGuidByName(targetName); 
            #endif

            proj.AddBuildProperty(target, "OTHER_LDFLAGS", "-ObjC");

            File.WriteAllText(projPath, proj.WriteToString());
        }
    }
 }

 #endif