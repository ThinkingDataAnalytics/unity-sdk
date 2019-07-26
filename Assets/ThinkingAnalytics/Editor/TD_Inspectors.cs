using UnityEngine;
using UnityEditor;
using UnityEditorInternal;

namespace ThinkingAnalytics.Editors
{
    [CustomEditor(typeof(ThinkingAnalyticsAPI))]
    [CanEditMultipleObjects]
    public class TD_Inspectors : Editor
    {
        private ReorderableList _stringArray;
           
        public void OnEnable()
        {
          
            var appId = this.serializedObject.FindProperty("tokens");

            _stringArray = new ReorderableList(appId.serializedObject, appId, true, true, true, true)
            {
                drawHeaderCallback = DrawListHeader,
                drawElementCallback = DrawListElement,
                onRemoveCallback = RemoveListElement,
                onAddCallback = AddListElement
            };

            _stringArray.serializedProperty.isExpanded = true;
        }

        void DrawListHeader(Rect rect)
        {
            var spacing = 20f;
            var arect = rect;
            arect.height = EditorGUIUtility.singleLineHeight;
            arect.x += 14;
            arect.width = 60;
            GUI.Label(arect, "Token ID");

            arect.x += arect.width + spacing; ;
            arect.width = 200;
            EditorGUI.LabelField(arect, "APP ID");
            arect.x += arect.width + spacing;
            arect.width = 100;
            EditorGUI.LabelField(arect, "Auto Track");
        }

        void DrawListElement(Rect rect, int index, bool isActive, bool isFocused)
        {
            var spacing = 20f;
            var arect = rect;
            SerializedProperty item = _stringArray.serializedProperty.GetArrayElementAtIndex(index);
            var serElem = this._stringArray.serializedProperty.GetArrayElementAtIndex(index);
            arect.height = EditorGUIUtility.singleLineHeight;
            arect.width = 60;
            if (index == 0)
            {
                EditorGUI.PropertyField(arect, item, new GUIContent((index + 1) + " (default)"));
            }
            else
            {
                EditorGUI.PropertyField(arect, item, new GUIContent("" + (index + 1)));

            }
            arect.x += arect.width + spacing;
            arect.width = 200;
            EditorGUI.PropertyField(arect, serElem.FindPropertyRelative("appid"), GUIContent.none);
            arect.x += arect.width + spacing;
            arect.width = 50;
            EditorGUI.PropertyField(arect, serElem.FindPropertyRelative("autoTrack"),GUIContent.none);
        }

        void AddListElement(ReorderableList list)
        {
            if (list.serializedProperty != null)
            {
                list.serializedProperty.arraySize++;
                list.index = list.serializedProperty.arraySize - 1;
                SerializedProperty item = list.serializedProperty.GetArrayElementAtIndex(list.index);
                item.FindPropertyRelative("appid").stringValue = "";
                item.FindPropertyRelative("autoTrack").boolValue = false;
            }
            else
            {
                ReorderableList.defaultBehaviours.DoAddButton(list);
            }
        }

        void RemoveListElement(ReorderableList list)
        {
            if (EditorUtility.DisplayDialog("Warnning", "Do you want to remove this element?", "Remove", "Cancel"))
            {
                ReorderableList.defaultBehaviours.DoRemoveButton(list);
            }
        }

        public override void OnInspectorGUI()
        {
            DrawDefaultInspector();
            this.serializedObject.Update();
            var property = _stringArray.serializedProperty;
            property.isExpanded = EditorGUILayout.Foldout(property.isExpanded, property.displayName);
            if (property.isExpanded)
            {
  
                _stringArray.DoLayoutList();
            }
            serializedObject.ApplyModifiedProperties();
        }
    }
}
