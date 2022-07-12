using System;
using System.Collections.Generic;
using UnityEngine;
using ThinkingSDK.PC.Utils;


namespace ThinkingSDK.PC.Storage
{
    public class ThinkingSDKFileJson
    {
        // 保存事件，返回缓存事件数量
        internal static int EnqueueTrackingData(Dictionary<string, object> data)
        {
            int eventId = EventAutoIncrementingID();
            String trackingKey = "Event" + eventId.ToString();
            data["id"] = trackingKey;
            PlayerPrefs.SetString(trackingKey, ThinkingSDKJSON.Serialize(data));
            IncreaseTrackingDataID();
            int eventCount = EventAutoIncrementingID() - EventIndexID();
            return eventCount;
        }

        // 获取事件结束ID
        internal static int EventAutoIncrementingID()
        {
            return PlayerPrefs.HasKey("EventAutoIncrementingID") ? PlayerPrefs.GetInt("EventAutoIncrementingID") : 0;
        }

        // 自动增加事件结束ID
        private static void IncreaseTrackingDataID()
        {
            int id = EventAutoIncrementingID();
            id += 1;
            String trackingIdKey = "EventAutoIncrementingID";
            PlayerPrefs.SetInt(trackingIdKey, id);
        }

        // 获取事件起始ID
        internal static int EventIndexID()
        {
            return PlayerPrefs.HasKey("EventIndexID") ? PlayerPrefs.GetInt("EventIndexID") : 0;
        }
        
        // 保存时间起始ID
        private static void SaveEventIndexID(int indexID)
        {
            String trackingIdKey = "EventIndexID";
            PlayerPrefs.SetInt(trackingIdKey, indexID);
        }

        // 批量取出指定数量的事件
        internal static List<Dictionary<string, object>> DequeueBatchTrackingData(int batchSize)
        {
            List<Dictionary<string, object>> batch = new List<Dictionary<string, object>>();
            int dataIndex = EventIndexID();
            int maxIndex = EventAutoIncrementingID() - 1;
            while (batch.Count < batchSize && dataIndex <= maxIndex) {
                String trackingKey = "Event" + dataIndex.ToString();
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

        // 批量删除指定数量的事件，返回剩余事件数量
        internal static int DeleteBatchTrackingData(int batchSize)
        {
            int deletedCount = 0;
            int dataIndex = EventIndexID();
            int maxIndex = EventAutoIncrementingID() - 1;
            while (deletedCount < batchSize && dataIndex <= maxIndex) {
                String trackingKey = "Event" + dataIndex.ToString();    
                if (PlayerPrefs.HasKey(trackingKey)) {
                    PlayerPrefs.DeleteKey(trackingKey);
                    deletedCount++;
                }
                dataIndex++;
            }
            SaveEventIndexID(dataIndex);

            int eventCount = EventAutoIncrementingID() - EventIndexID();
            return eventCount;
        }

        // 批量删除指定事件
        // internal static void DeleteBatchTrackingData(List<Dictionary<string, object>> batch) {
        //     foreach(Dictionary<string, object> data in batch) {
        //         String id = data["id"].ToString();
        //         if (id != null && PlayerPrefs.HasKey(id)) {
        //             PlayerPrefs.DeleteKey(id);
        //         }
        //     }
        // }

        // 批量删除全部事件
        internal static int DeleteAllTrackingData()
        {
            DeleteBatchTrackingData(int.MaxValue);
            SaveEventIndexID(0);
            return 0;
        }
    }
}
