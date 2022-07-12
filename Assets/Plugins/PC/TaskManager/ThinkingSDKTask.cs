using System.Collections.Generic;
using ThinkingSDK.PC.Request;
using ThinkingSDK.PC.Constant;
using UnityEngine;
using System.Collections;

namespace ThinkingSDK.PC.TaskManager
{
    [DisallowMultipleComponent]
    public class ThinkingSDKTask : MonoBehaviour
    {
        private readonly static object _locker = new object();

        private List<ThinkingSDKBaseRequest> requestList = new List<ThinkingSDKBaseRequest>();
        private List<ResponseHandle> responseHandleList = new List<ResponseHandle>();
        private List<IList<Dictionary<string, object>>> dataList = new List<IList<Dictionary<string, object>>>();


        private static ThinkingSDKTask mSingleTask;// = new ThinkingSDKTask();

        private bool isWaiting = false;

        public static ThinkingSDKTask SingleTask()
        {
            return mSingleTask;
        }

        private void Awake() {
            mSingleTask = this;
            responseHandleList = new List<ResponseHandle>();
            requestList = new List<ThinkingSDKBaseRequest>();
            dataList = new List<IList<Dictionary<string, object>>>();
        }

        private void Start() {
        }

        private void Update() {
            if (requestList.Count > 0 && !isWaiting)
            {
                WaitOne();
                StartRequestSendData();
            }
        }

        /// <summary>
        /// 持有信号
        /// </summary>
        public void WaitOne()
        {
            isWaiting = true;
        }
        /// <summary>
        /// 释放信号
        /// </summary>
        public void Release()
        {
            isWaiting = false;
        }
        public void SyncInvokeAllTask()
        {

        }

        public void StartRequest(ThinkingSDKBaseRequest mRequest, ResponseHandle responseHandle, IList<Dictionary<string, object>> list)
        {
            lock(_locker)
            {
                requestList.Add(mRequest);
                responseHandleList.Add(responseHandle);
                dataList.Add(list);
            }
        }

        private void StartRequestSendData() 
        {
            if (requestList.Count > 0)
            {
                ThinkingSDKBaseRequest mRequest;
                ResponseHandle responseHandle;
                IList<Dictionary<string, object>> list;
                lock(_locker)
                {
                    mRequest = requestList[0];
                    responseHandle = responseHandleList[0];
                    list = dataList[0];
                }
                if (mRequest != null) 
                {
                    this.StartCoroutine(this.SendData(mRequest, responseHandle, list));
                    lock(_locker)
                    {
                        requestList.RemoveAt(0);
                        responseHandleList.RemoveAt(0);
                        dataList.RemoveAt(0);
                    }
                }

            }
        }
        private IEnumerator SendData(ThinkingSDKBaseRequest mRequest, ResponseHandle responseHandle, IList<Dictionary<string, object>> list) {
            yield return mRequest.SendData_2(responseHandle, list);
        }
    }
}

