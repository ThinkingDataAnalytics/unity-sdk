using System;
using System.Collections.Generic;
using UnityEngine;

namespace ThinkingData.Analytics.TDException
{
    public class TDExceptionHandler
    {

        //Whether to exit the program when an exception occurs
        public static bool IsQuitWhenException = false;

        //Whether the exception catch has been registered
        public static bool IsRegistered = false;
        private static TDAutoTrackEventHandler mEventCallback;
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

        public static void RegisterTAExceptionHandler(TDAutoTrackEventHandler eventCallback)
        {
            mEventCallback = eventCallback;
            //Register exception handling delegate
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
            //Register exception handling delegate
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
            //Clear exception handling delegate
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
                //Report exception event
                string reasonStr = "exception_type: " + type.ToString() + " <br> " + "exception_message: " + logString + " <br> " + "stack_trace: " + stackTrace + " <br> " ; 
                Dictionary<string, object> properties = new Dictionary<string, object>(){
                    {"#app_crashed_reason", reasonStr}
                };
                properties = MergeProperties(properties);
                TDAnalytics.Track("ta_app_crash", properties);

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

            //Report exception event
            string reasonStr = "exception_type: " + e.GetType().Name + " <br> " + "exception_message: " + e.Message + " <br> " + "stack_trace: " + e.StackTrace + " <br> " ; 
            Dictionary<string, object> properties = new Dictionary<string, object>(){
                {"#app_crashed_reason", reasonStr}
            };
            properties = MergeProperties(properties);
            TDAnalytics.Track("ta_app_crash", properties);

            if ( IsQuitWhenException )
            {
                Application.Quit();
            }
        }

        private static Dictionary<string, object> MergeProperties(Dictionary<string, object> properties)
        {

            if (mEventCallback is TDAutoTrackEventHandler)
            {
                Dictionary<string, object> callbackProperties = mEventCallback.GetAutoTrackEventProperties((int)TDAutoTrackEventType.AppCrash, properties);
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
