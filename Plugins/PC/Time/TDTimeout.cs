using UnityEngine;
using System.Collections;
using System;
using System.Threading;

namespace ThinkingSDK.PC.Time
{
    public class TDTimeout : MonoBehaviour
    {
        // Use this for initialization
        void Start()
        {

        }

        // Update is called once per frame
        void Update()
        {

        }

        public static void SetTimeout(int timeout, Action<object> action, object obj)
        {
            GameObject gameObject = new GameObject("TDTimeout");
            var tdTimeout = gameObject.AddComponent<TDTimeout>();
            tdTimeout._setTimeout(timeout, action, obj);
        }

        private void _setTimeout(int timeout, Action<object> action, object obj)
        {
            StartCoroutine(_wait(timeout, action, obj));
        }

        private IEnumerator _wait(int timeout, Action<object> action, object obj)
        {
            yield return new WaitForSeconds(timeout);
            if (action != null)
            {
                action(obj);
            }
            Destroy(gameObject);
        }
    }
}
