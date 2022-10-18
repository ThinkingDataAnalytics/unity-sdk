using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Text;
using System.Diagnostics;
using System.Reflection;

namespace ThinkingAnalytics.TaException
{
    public interface TaExceptionHandler
    {
        void InvokeTaExceptionHandler(string eventName, Dictionary<string, object> properties);
    }

    public class ThinkingSDKExceptionHandler
    {

        public void SetTaExceptionHandler(TaExceptionHandler handler)
        {
            this.taExceptionHandler = handler;
        }

        private TaExceptionHandler taExceptionHandler;

        //是否退出程序当异常发生时
        public bool IsQuitWhenException = false;
    
        public void RegisterTaExceptionHandler ()
        {     
            //注册异常处理委托
            try {
                #if UNITY_5
                Application.logMessageReceived += _LogHandler;
                #else
                Application.RegisterLogCallback (_LogHandler);
                #endif
                AppDomain.CurrentDomain.UnhandledException += _UncaughtExceptionHandler;                
            }
            catch {
                
            }
            
        }
    
        public void UnregisterTaExceptionHandler ()
        {
            //清除异常处理委托
            try {
                #if UNITY_5
                Application.logMessageReceived -= _LogHandler;
                #else
                Application.RegisterLogCallback (null);
                #endif
                System.AppDomain.CurrentDomain.UnhandledException -= _UncaughtExceptionHandler;
            }
            catch {
                
            }
        }
    
    
        private void _LogHandler( string logString, string stackTrace, LogType type )
        {
            if( type == LogType.Error || type == LogType.Exception || type == LogType.Assert )
            {
                //发送异常日志
                string reasonStr = "exception_type: " + type.ToString() + " <br> " + "exception_message: " + logString + " <br> " + "stack_trace: " + stackTrace + " <br> " ; 
                Dictionary<string, object> properties = new Dictionary<string, object>(){
                    // {ThinkingSDKConstant.CRASH_REASON, reasonStr}
                    {"#app_crashed_reason", reasonStr}
                };

                taExceptionHandler.InvokeTaExceptionHandler("ta_app_crash",properties);

                //退出程序，bug反馈程序重启主程序
                if( IsQuitWhenException )
                {
                    Application.Quit();
                }
            }
        }

        private void _UncaughtExceptionHandler (object sender, System.UnhandledExceptionEventArgs args)
        {
            if (args == null || args.ExceptionObject == null) {
                return;
            }
            
            try {
                if (args.ExceptionObject.GetType () != typeof(System.Exception)) {
                    return;
                }
            }
            catch {
                return;
            }

            System.Exception e = (System.Exception)args.ExceptionObject;

            //发送异常日志
            string reasonStr = "exception_type: " + e.GetType().Name + " <br> " + "exception_message: " + e.Message + " <br> " + "stack_trace: " + e.StackTrace + " <br> " ; 
            Dictionary<string, object> properties = new Dictionary<string, object>(){
                // {ThinkingSDKConstant.CRASH_REASON, reasonStr}
                {"#app_crashed_reason", reasonStr}
            };

            taExceptionHandler.InvokeTaExceptionHandler("ta_app_crash",properties);

            //退出程序，bug反馈程序重启主程序
            if( IsQuitWhenException )
            {
                Application.Quit();
            }
        }
    }
}
