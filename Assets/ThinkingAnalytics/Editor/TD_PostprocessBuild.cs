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

            string mainTargetGuid;
            string unityFrameworkTargetGuid;
                    
            var unityMainTargetGuidMethod = proj.GetType().GetMethod("GetUnityMainTargetGuid");
            var unityFrameworkTargetGuidMethod = proj.GetType().GetMethod("GetUnityFrameworkTargetGuid");
                            
            if (unityMainTargetGuidMethod != null && unityFrameworkTargetGuidMethod != null)
            {
                mainTargetGuid = (string)unityMainTargetGuidMethod.Invoke(proj, null);
                unityFrameworkTargetGuid = (string)unityFrameworkTargetGuidMethod.Invoke(proj, null);
            }
            else
            {
                mainTargetGuid = proj.TargetGuidByName ("Unity-iPhone");
                unityFrameworkTargetGuid = mainTargetGuid;
            }

            proj.AddBuildProperty(unityFrameworkTargetGuid, "OTHER_LDFLAGS", "-ObjC");

            File.WriteAllText(projPath, proj.WriteToString());
        }
    }
 }

 #endif