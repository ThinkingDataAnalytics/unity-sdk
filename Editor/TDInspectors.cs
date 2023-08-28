using UnityEngine;
using UnityEditor;
using UnityEditorInternal;

namespace ThinkingData.Analytics.Editors
{
    [CustomEditor(typeof(TDAnalytics))]
    [CanEditMultipleObjects]
    public class TD_Inspectors : Editor
    {
        private ReorderableList _stringArray;

        public void OnEnable()
        {

            var appId = this.serializedObject.FindProperty("configs");

            _stringArray = new ReorderableList(appId.serializedObject, appId, true, true, true, true)
            {
                drawHeaderCallback = DrawListHeader,
                drawElementCallback = DrawListElement,
                onRemoveCallback = RemoveListElement,
                onAddCallback = AddListElement
            };

            _stringArray.elementHeight = 5 * (EditorGUIUtility.singleLineHeight + 10);

            _stringArray.serializedProperty.isExpanded = true;
        }

        void DrawListHeader(Rect rect)
        {
            var arect = rect;
            arect.height = EditorGUIUtility.singleLineHeight + 10;
            arect.x += 14;
            arect.width = 80;
            GUIStyle style = new GUIStyle();
            style.fontStyle = FontStyle.Bold;

            GUI.Label(arect, "Instance Configurations", style);
        }

        void DrawListElement(Rect rect, int index, bool isActive, bool isFocused)
        {
            var spacing = 5;
            var xSpacing = 85;
            var arect = rect;
            SerializedProperty item = _stringArray.serializedProperty.GetArrayElementAtIndex(index);
            var serElem = this._stringArray.serializedProperty.GetArrayElementAtIndex(index);
            arect.height = EditorGUIUtility.singleLineHeight;
            arect.width = 240;

            if (index == 0)
            {
                EditorGUI.PropertyField(arect, item, new GUIContent((index + 1) + " (default)"));
            }
            else
            {
                EditorGUI.PropertyField(arect, item, new GUIContent("" + (index + 1)));

            }
            arect.y += EditorGUIUtility.singleLineHeight + spacing;
            GUIStyle style = new GUIStyle();
            style.fontStyle = FontStyle.Bold;


            EditorGUI.LabelField(arect, "APP ID:", style);
            arect.x += xSpacing;
            EditorGUI.PropertyField(arect, serElem.FindPropertyRelative("appId"), GUIContent.none);

            arect.y += EditorGUIUtility.singleLineHeight + spacing;
            arect.x -= xSpacing;

            EditorGUI.LabelField(arect, "SERVER URL:", style);
            arect.x += xSpacing;
            EditorGUI.PropertyField(new Rect(arect.x, arect.y, arect.width, arect.height), serElem.FindPropertyRelative("serverUrl"), GUIContent.none);

            arect.y += EditorGUIUtility.singleLineHeight + spacing;
            arect.x -= xSpacing;

            EditorGUI.LabelField(arect, "MODE:", style);
            arect.x += xSpacing;
            EditorGUI.PropertyField(arect, serElem.FindPropertyRelative("mode"), GUIContent.none);

            arect.y += EditorGUIUtility.singleLineHeight + spacing;
            arect.x -= xSpacing;

            EditorGUI.LabelField(arect, "TimeZone:", style);
            arect.x += xSpacing;
            var a = serElem.FindPropertyRelative("timeZone");
            if (a.intValue == 100)
            {
                EditorGUI.PropertyField(new Rect(arect.x, arect.y, 115, arect.height), a, GUIContent.none);
                arect.x += 125;
                EditorGUI.PropertyField(new Rect(arect.x, arect.y, 115, arect.height), serElem.FindPropertyRelative("timeZoneId"), GUIContent.none);
            }
            else
            {
                EditorGUI.PropertyField(arect, a, GUIContent.none);
            }
        }

        void AddListElement(ReorderableList list)
        {
            if (list.serializedProperty != null)
            {
                list.serializedProperty.arraySize++;
                list.index = list.serializedProperty.arraySize - 1;
                SerializedProperty item = list.serializedProperty.GetArrayElementAtIndex(list.index);
                item.FindPropertyRelative("appId").stringValue = "";
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
