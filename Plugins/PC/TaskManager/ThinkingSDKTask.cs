using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using ThinkingSDK.PC.Request;
using ThinkingSDK.PC.Constant;
using ThinkingSDK.PC.Storage;
using ThinkingSDK.PC.Main;

namespace ThinkingSDK.PC.TaskManager
{
    [DisallowMultipleComponent]
    public class ThinkingSDKTask : MonoBehaviour
    {
        private readonly static object _locker = new object();

        private List<ThinkingSDKBaseRequest> requestList = new List<ThinkingSDKBaseRequest>();
        private List<ResponseHandle> responseHandleList = new List<ResponseHandle>();
        private List<int> batchSizeList = new List<int>();
        private List<string> appIdList = new List<string>();


        private static ThinkingSDKTask mSingleTask;

        private bool isWaiting = false;
        private float updateInterval = 0;

        public static ThinkingSDKTask SingleTask()
        {
            return mSingleTask;
        }

        private void Awake() {
            mSingleTask = this;
        }

        private void Start() {
        }

        private void Update() {
            updateInterval += UnityEngine.Time.deltaTime;
            if (updateInterval > 0.2)
            {
                updateInterval = 0;
                if (!isWaiting && requestList.Count > 0)
                {
                    WaitOne();
                    StartRequestSendData();
                }
            }
        }

        //private void OnDestroy()
        //{
        //    ThinkingPCSDK.OnDestory();
        //}

        /// <summary>
        /// hold signal
        /// </summary>
        public void WaitOne()
        {
            isWaiting = true;
        }
        /// <summary>
        /// release signal
        /// </summary>
        public void Release()
        {
            isWaiting = false;
        }
        public void SyncInvokeAllTask()
        {

        }

        public void StartRequest(ThinkingSDKBaseRequest mRequest, ResponseHandle responseHandle, int batchSize, string appId)
        {
            lock(_locker)
            {
                requestList.Add(mRequest);
                responseHandleList.Add(responseHandle);
                batchSizeList.Add(batchSize);
                appIdList.Add(appId);
            }
        }

        private void StartRequestSendData() 
        {
            if (requestList.Count > 0)
            {
                ThinkingSDKBaseRequest mRequest;
                ResponseHandle responseHandle;
                string list;
                int eventCount = 0;
                lock (_locker)
                {
                    mRequest = requestList[0];
                    responseHandle = responseHandleList[0];
                    list = ThinkingSDKFileJson.DequeueBatchTrackingData(batchSizeList[0], appIdList[0], out eventCount);
                }
                if (mRequest != null) 
                {
                    if (eventCount > 0 && list.Length > 0)
                    {
                        this.StartCoroutine(this.SendData(mRequest, responseHandle, list, eventCount));                        
                    }
                    else
                    {
                        if (responseHandle != null) 
                        {
                            responseHandle(null);
                        }
                    }
                    lock(_locker)
                    {
                        requestList.RemoveAt(0);
                        responseHandleList.RemoveAt(0);
                        batchSizeList.RemoveAt(0);
                        appIdList.RemoveAt(0);
                    }
                }

            }
        }
        private IEnumerator SendData(ThinkingSDKBaseRequest mRequest, ResponseHandle responseHandle, string list, int eventCount) {
            yield return mRequest.SendData_2(responseHandle, list, eventCount);
        }
    }
}

