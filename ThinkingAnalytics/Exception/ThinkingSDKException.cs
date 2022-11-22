using System;
using System.Collections.Generic;
using UnityEngine;

namespace ThinkingAnalytics.TAException
{
    public class ThinkingSDKExceptionHandler
    {

        //是否退出程序当异常发生时
        public static bool IsQuitWhenException = false;

        //是否已注册异常捕获
        public static bool IsRegistered = false;
        private static IAutoTrackEventCallback mEventCallback;
        private static Dictionary<string, object> mProperties;


        public static void SetAutoTrackProperties(Dictionary<string, object> properties)
        {
            if (!(mProperties is Dictionary<string, object>))
            {
                mProperties = new Dictionary<string, object>();
            }

            foreach (var item in properties)
            {
                if (!mProperties.ContainsKey(item.Key))
                {
                    mProperties.Add(item.Key, item.Value);
                }
            }
        }

        public static void RegisterTAExceptionHandler(IAutoTrackEventCallback eventCallback)
        {
            mEventCallback = eventCallback;
            //注册异常处理委托
            try
            {
                if (!IsRegistered)
                {
                    Application.logMessageReceived += _LogHandler;
                    AppDomain.CurrentDomain.UnhandledException += _UncaughtExceptionHandler;
                    IsRegistered = true;
                }
            }
            catch
            {
            }            
        }

        public static void RegisterTAExceptionHandler(Dictionary<string, object> properties)
        {
            SetAutoTrackProperties(properties);
            //注册异常处理委托
            try
            {
                if (!IsRegistered)
                {
                    Application.logMessageReceived += _LogHandler;
                    AppDomain.CurrentDomain.UnhandledException += _UncaughtExceptionHandler;
                    IsRegistered = true;
                }
            }
            catch
            {
            }
        }

        public static void UnregisterTAExceptionHandler ()
        {
            //清除异常处理委托
            try
            {
                Application.logMessageReceived -= _LogHandler;
                System.AppDomain.CurrentDomain.UnhandledException -= _UncaughtExceptionHandler;
            }
            catch
            {
            }
        }
    
    
        private static void _LogHandler( string logString, string stackTrace, LogType type )
        {
            if( type == LogType.Error || type == LogType.Exception || type == LogType.Assert )
            {
                //发送异常日志
                string reasonStr = "exception_type: " + type.ToString() + " <br> " + "exception_message: " + logString + " <br> " + "stack_trace: " + stackTrace + " <br> " ; 
                Dictionary<string, object> properties = new Dictionary<string, object>(){
                    {"#app_crashed_reason", reasonStr}
                };
                properties = MergeProperties(properties);
                ThinkingAnalyticsAPI.Track("ta_app_crash", properties);

                //退出程序，bug反馈程序重启主程序
                if ( IsQuitWhenException )
                {
                    Application.Quit();
                }
            }
        }

        private static void _UncaughtExceptionHandler (object sender, System.UnhandledExceptionEventArgs args)
        {
            if (args == null || args.ExceptionObject == null)
            {
                return;
            }
            
            try
            {
                if (args.ExceptionObject.GetType () != typeof(System.Exception))
                {
                    return;
                }
            }
            catch
            {
                return;
            }

            System.Exception e = (System.Exception)args.ExceptionObject;

            //发送异常日志
            string reasonStr = "exception_type: " + e.GetType().Name + " <br> " + "exception_message: " + e.Message + " <br> " + "stack_trace: " + e.StackTrace + " <br> " ; 
            Dictionary<string, object> properties = new Dictionary<string, object>(){
                {"#app_crashed_reason", reasonStr}
            };
            properties = MergeProperties(properties);
            ThinkingAnalyticsAPI.Track("ta_app_crash", properties);

            //退出程序，bug反馈程序重启主程序
            if ( IsQuitWhenException )
            {
                Application.Quit();
            }
        }

        private static Dictionary<string, object> MergeProperties(Dictionary<string, object> properties)
        {

            if (mEventCallback is IAutoTrackEventCallback)
            {
                Dictionary<string, object> callbackProperties = mEventCallback.AutoTrackEventCallback((int)AUTO_TRACK_EVENTS.APP_CRASH, properties);
                foreach (var item in callbackProperties)
                {
                    if (!properties.ContainsKey(item.Key))
                    {
                        properties.Add(item.Key, item.Value);
                    }
                }
            }

            if (mProperties is Dictionary<string, object>)
            {
                foreach (var item in mProperties)
                {
                    if (!properties.ContainsKey(item.Key))
                    {
                        properties.Add(item.Key, item.Value);
                    }
                }
            }

            return properties;
        }
    }
}
