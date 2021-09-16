using System;
using System.Collections.Generic;
using System.Threading;
using ThinkingSDK.PC.Utils;
using ThinkingSDK.PC.Request;
using ThinkingSDK.PC.Constant;

namespace ThinkingSDK.PC.TaskManager
{
    public class ThinkingSDKTask
    {
        private System.Threading.Semaphore mSM = new Semaphore(1, 1);
        private readonly static object _locker = new object();

        private List<ThinkingSDKBaseRequest> requestList = new List<ThinkingSDKBaseRequest>();
        private List<ResponseHandle> responseHandleList = new List<ResponseHandle>();
        private List<IList<Dictionary<string, object>>> dataList = new List<IList<Dictionary<string, object>>>();

        static Queue<Thread> _threadQueue = new Queue<Thread>(); //队列
        static EventWaitHandle _waitHandle = new AutoResetEvent(false); //通知Work线程的信号

        private static ThinkingSDKTask mSingleTask = new ThinkingSDKTask();

        public static ThinkingSDKTask SingleTask()
        {
            return mSingleTask;
        }
        private ThinkingSDKTask() 
        {
            Thread newThread = new Thread(() => {
                while (true) 
                {
                    if (requestList.Count > 0)
                    {
                        WaitOne();
                        StartRequestSendData();
                    }
                    else
                    {
                        _waitHandle.WaitOne();
                    }
                }
                });
            newThread.Start();
        }

        /// <summary>
        /// 持有信号
        /// </summary>
        public void WaitOne()
        {
            mSM.WaitOne();
        }
        /// <summary>
        /// 释放信号
        /// </summary>
        public void Release()
        {
            mSM.Release();
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

            _waitHandle.Set();
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
                    mRequest.SendData(responseHandle, list);
                    lock(_locker)
                    {
                        requestList.RemoveAt(0);
                        responseHandleList.RemoveAt(0);
                        dataList.RemoveAt(0);
                    }
                }

            }
        }
    }
}

