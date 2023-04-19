using System;
using System.Collections.Generic;
using UnityEngine;
using ThinkingSDK.PC.Utils;


namespace ThinkingSDK.PC.Storage
{
    public class ThinkingSDKFileJson
    {
        // Save the event, return the number of cached events
        internal static int EnqueueTrackingData(Dictionary<string, object> data, string prefix)
        {
            int eventId = EventAutoIncrementingID(prefix);
            String trackingKey = prefix + "Event" + eventId.ToString();
            data["id"] = trackingKey;
            PlayerPrefs.SetString(trackingKey, ThinkingSDKJSON.Serialize(data));
            IncreaseTrackingDataID(prefix);
            int eventCount = EventAutoIncrementingID(prefix) - EventIndexID(prefix);
            return eventCount;
        }

        // Get event end ID
        internal static int EventAutoIncrementingID(string prefix)
        {
            string mEventAutoIncrementingID = prefix + "EventAutoIncrementingID";
            return PlayerPrefs.HasKey(mEventAutoIncrementingID) ? PlayerPrefs.GetInt(mEventAutoIncrementingID) : 0;
        }

        // Auto increment event end ID
        private static void IncreaseTrackingDataID(string prefix)
        {
            int id = EventAutoIncrementingID(prefix);
            id += 1;
            String trackingIdKey = prefix + "EventAutoIncrementingID";
            PlayerPrefs.SetInt(trackingIdKey, id);
        }

        // Reset event end ID
        private static void ResetTrackingDataID(string prefix)
        {
            int id = 0;
            String trackingIdKey = prefix + "EventAutoIncrementingID";
            PlayerPrefs.SetInt(trackingIdKey, id);
        }

        // Get event start ID
        internal static int EventIndexID(string prefix)
        {
            string mEventIndexID = prefix + "EventIndexID";
            return PlayerPrefs.HasKey(mEventIndexID) ? PlayerPrefs.GetInt(mEventIndexID) : 0;
        }

        // Save time start ID
        private static void SaveEventIndexID(int indexID, string prefix)
        {
            String trackingIdKey = prefix + "EventIndexID";
            PlayerPrefs.SetInt(trackingIdKey, indexID);
        }

        // Fetch a specified number of events in batches
        internal static List<Dictionary<string, object>> DequeueBatchTrackingData(int batchSize, string prefix)
        {
            List<Dictionary<string, object>> batch = new List<Dictionary<string, object>>();
            int dataIndex = EventIndexID(prefix);
            int maxIndex = EventAutoIncrementingID(prefix) - 1;
            while (batch.Count < batchSize && dataIndex <= maxIndex) {
                String trackingKey = prefix + "Event" + dataIndex.ToString();
                if (PlayerPrefs.HasKey(trackingKey)) {
                    try {
                        Dictionary<string, object> data = ThinkingSDKJSON.Deserialize(PlayerPrefs.GetString(trackingKey));
                        data.Remove("id");
                        batch.Add(data);
                    }
                    catch (Exception e) {
                        ThinkingSDKLogger.Print("There was an error processing " + trackingKey + " from the internal object pool: " + e);
                        PlayerPrefs.DeleteKey(trackingKey);
                    }
                }
                dataIndex++;
            }
            
            return batch;
        }

        // Batch delete the specified number of events and return the remaining number of events
        internal static int DeleteBatchTrackingData(int batchSize, string prefix)
        {
            int deletedCount = 0;
            int dataIndex = EventIndexID(prefix);
            int maxIndex = EventAutoIncrementingID(prefix) - 1;
            while (deletedCount < batchSize && dataIndex <= maxIndex) {
                String trackingKey = prefix + "Event" + dataIndex.ToString();    
                if (PlayerPrefs.HasKey(trackingKey)) {
                    PlayerPrefs.DeleteKey(trackingKey);
                    deletedCount++;
                }
                dataIndex++;
            }
            SaveEventIndexID(dataIndex, prefix);

            int eventCount = EventAutoIncrementingID(prefix) - EventIndexID(prefix);
            return eventCount;
        }

        // Batch delete specified events
        // internal static void DeleteBatchTrackingData(List<Dictionary<string, object>> batch, string prefix) {
        //     foreach(Dictionary<string, object> data in batch) {
        //         String id = data["id"].ToString();
        //         if (id != null && PlayerPrefs.HasKey(id)) {
        //             PlayerPrefs.DeleteKey(id);
        //         }
        //     }
        // }

        // Batch delete all events
        internal static int DeleteAllTrackingData(string prefix)
        {
            DeleteBatchTrackingData(int.MaxValue, prefix);
            SaveEventIndexID(0, prefix);
            ResetTrackingDataID(prefix);
            return 0;
        }
    }
}
