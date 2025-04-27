/*
 * Copyright (C) 2024 ThinkingData
 */
package cn.thinkingdata.analytics;

import android.content.Context;
import android.text.TextUtils;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;

import cn.thinkingdata.analytics.TDAnalytics;
import cn.thinkingdata.analytics.TDAnalyticsAPI;
import cn.thinkingdata.analytics.TDConfig;
import cn.thinkingdata.analytics.TDFirstEvent;
import cn.thinkingdata.analytics.TDOverWritableEvent;
import cn.thinkingdata.analytics.TDUpdatableEvent;
import cn.thinkingdata.analytics.ThinkingAnalyticsSDK;

public class ThinkingAnalyticsProxy {
    public static void setCustomerLibInfo(String libName, String libVersion) {
        TDAnalytics.setCustomerLibInfo(libName, libVersion);
    }

    public static void enableTrackLog(boolean enableLog) {
        TDAnalytics.enableLog(enableLog);
    }

    public static void calibrateTime(long timeStampMillis) {
        TDAnalytics.calibrateTime(timeStampMillis);
    }

    public static void calibrateTimeWithNtp(String ntpServer) {
        TDAnalytics.calibrateTimeWithNtp(ntpServer);
    }

    public static void init(Context context, String appId, String serverUrl, int mode, String name, String timeZone, int version, String publicKey) {
        try {
            if (context == null || TextUtils.isEmpty(appId) || TextUtils.isEmpty(serverUrl)) {
                return;
            }
            String instanceName = "";
            if (TextUtils.isEmpty(name)) {
                instanceName = appId;
            } else {
                instanceName = name;
            }
            TDConfig tdConfig = TDConfig.getInstance(context, appId, serverUrl, instanceName);
            if (!TextUtils.isEmpty(timeZone)) {
                tdConfig.setDefaultTimeZone(TimeZone.getTimeZone(timeZone));
            }
            if (mode == 1 || mode == 2) {
                tdConfig.setMode(TDConfig.TDMode.values()[mode]);
            }
            if (version > 0 && !TextUtils.isEmpty(publicKey)) {
                tdConfig.enableEncrypt(version, publicKey);
            }
            TDAnalytics.init(tdConfig);
        } catch (Exception ignore) {

        }
    }

    public static void track(String eventName, String properties, long time, String timeZoneId, String appId) {
        try {
            ThinkingAnalyticsSDK instance = TDAnalyticsAPI.getInstance(appId);
            if (null != instance) {
                JSONObject pJson = null;
                try {
                    pJson = new JSONObject(properties);
                } catch (JSONException ignore) {
                }
                if (time < 0 || TextUtils.isEmpty(timeZoneId)) {
                    instance.track(eventName, pJson);
                } else {
                    TimeZone timeZone = null;
                    if (TextUtils.equals(timeZoneId, "Local")) {
                        timeZone = TimeZone.getDefault();
                    } else {
                        timeZone = TimeZone.getTimeZone(timeZoneId);
                    }
                    instance.track(eventName, pJson, new Date(time), timeZone);
                }
            }
        } catch (Exception ignore) {
        }
    }

    public static void trackEvent(int type, String eventName, String properties, String eventId, long time, String timeZoneId, String appId) {
        try {
            Date date = null;
            if (time > 0) {
                date = new Date(time);
            }
            TimeZone timeZone = null;
            if (TextUtils.equals(timeZoneId, "Local")) {
                timeZone = TimeZone.getDefault();
            } else {
                timeZone = TimeZone.getTimeZone(timeZoneId);
            }
            JSONObject pJson = null;
            try {
                pJson = new JSONObject(properties);
            } catch (JSONException ignore) {
            }
            if (type == 0) {
                TDFirstEvent firstEvent = new TDFirstEvent(eventName, pJson);
                firstEvent.setFirstCheckId(eventId);
                firstEvent.setEventTime(date, timeZone);
                TDAnalyticsAPI.track(firstEvent, appId);
            } else if (type == 1) {
                TDUpdatableEvent updatableEvent = new TDUpdatableEvent(eventName, pJson, eventId);
                updatableEvent.setEventTime(date, timeZone);
                TDAnalyticsAPI.track(updatableEvent, appId);
            } else if (type == 2) {
                TDOverWritableEvent overWritableEvent = new TDOverWritableEvent(eventName, pJson, eventId);
                overWritableEvent.setEventTime(date, timeZone);
                TDAnalyticsAPI.track(overWritableEvent, appId);
            }
        } catch (Exception ignore) {
        }
    }


    public static void timeEvent(String eventName, String appId) {
        TDAnalyticsAPI.timeEvent(eventName, appId);
    }

    public static void login(String accountId, String appId) {
        TDAnalyticsAPI.login(accountId, appId);
    }

    public static void logout(String appId) {
        TDAnalyticsAPI.logout(appId);
    }

    public static void identify(String distinctId, String appId) {
        TDAnalyticsAPI.setDistinctId(distinctId, appId);
    }

    public static String getDistinctId(String appId) {
        return TDAnalyticsAPI.getDistinctId(appId);
    }

    public static void userSet(String properties, long time, String appId) {
        try {
            ThinkingAnalyticsSDK instance = TDAnalyticsAPI.getInstance(appId);
            if (null != instance) {
                Date date = null;
                if (time > 0) {
                    date = new Date(time);
                }
                instance.user_set(new JSONObject(properties), date);
            }
        } catch (Exception ignore) {
        }
    }

    public static void userUnset(String properties, long time, String appId) {
        try {
            ThinkingAnalyticsSDK instance = TDAnalyticsAPI.getInstance(appId);
            if (null != instance) {
                Date date = null;
                if (time > 0) {
                    date = new Date(time);
                }
                instance.user_unset(new JSONObject(properties), date);
            }
        } catch (Exception ignore) {
        }
    }

    public static void userSetOnce(String properties, long time, String appId) {
        try {
            ThinkingAnalyticsSDK instance = TDAnalyticsAPI.getInstance(appId);
            if (null != instance) {
                Date date = null;
                if (time > 0) {
                    date = new Date(time);
                }
                instance.user_setOnce(new JSONObject(properties), date);
            }
        } catch (Exception ignore) {

        }
    }

    public static void userAdd(String properties, long time, String appId) {
        try {
            ThinkingAnalyticsSDK instance = TDAnalyticsAPI.getInstance(appId);
            if (null != instance) {
                Date date = null;
                if (time > 0) {
                    date = new Date(time);
                }
                instance.user_add(new JSONObject(properties), date);
            }
        } catch (Exception ignore) {

        }
    }

    public static void userDel(long time, String appId) {
        try {
            ThinkingAnalyticsSDK instance = TDAnalyticsAPI.getInstance(appId);
            if (null != instance) {
                Date date = null;
                if (time > 0) {
                    date = new Date(time);
                }
                instance.user_delete(date);
            }
        } catch (Exception ignore) {
        }
    }

    public static void userAppend(String properties, long time, String appId) {
        try {
            ThinkingAnalyticsSDK instance = TDAnalyticsAPI.getInstance(appId);
            if (null != instance) {
                Date date = null;
                if (time > 0) {
                    date = new Date(time);
                }
                instance.user_append(new JSONObject(properties), date);
            }
        } catch (Exception ignore) {
        }
    }

    public static void userUniqAppend(String properties, long time, String appId) {
        try {
            ThinkingAnalyticsSDK instance = TDAnalyticsAPI.getInstance(appId);
            if (null != instance) {
                Date date = null;
                if (time > 0) {
                    date = new Date(time);
                }
                instance.user_uniqAppend(new JSONObject(properties), date);
            }
        } catch (Exception ignore) {
        }
    }

    public static void setSuperProperties(String properties, String appId) {
        try {
            TDAnalyticsAPI.setSuperProperties(new JSONObject(properties), appId);
        } catch (Exception ignore) {
        }
    }

    public static void unsetSuperProperty(String property, String appId) {
        TDAnalyticsAPI.unsetSuperProperty(property, appId);
    }

    public static void clearSuperProperties(String appId) {
        TDAnalyticsAPI.clearSuperProperties(appId);
    }

    public static String getSuperProperties(String appId) {
        return TDAnalyticsAPI.getSuperProperties(appId).toString();
    }

    public static String getPresetProperties(String appId) {
        return TDAnalyticsAPI.getPresetProperties(appId).toEventPresetProperties().toString();
    }

    public static void flush(String appId) {
        TDAnalyticsAPI.flush(appId);
    }

    public static String getDeviceId() {
        return TDAnalytics.getDeviceId();
    }

    public static void setTrackStatus(int status, String appId) {
        TDAnalytics.TDTrackStatus trackStatus = TDAnalytics.TDTrackStatus.NORMAL;
        if (status == 1) {
            trackStatus = TDAnalytics.TDTrackStatus.PAUSE;
        } else if (status == 2) {
            trackStatus = TDAnalytics.TDTrackStatus.STOP;
        } else if (status == 3) {
            trackStatus = TDAnalytics.TDTrackStatus.SAVE_ONLY;
        }
        TDAnalyticsAPI.setTrackStatus(trackStatus, appId);
    }

    public static String createLightInstance(String appId) {
        return TDAnalyticsAPI.lightInstance(appId);
    }

    public static void setNetworkType(int type, String appId) {
        if (type == 0 || type == 2) {
            TDAnalyticsAPI.setNetworkType(TDAnalytics.TDNetworkType.ALL, appId);
        } else if (type == 1) {
            TDAnalyticsAPI.setNetworkType(TDAnalytics.TDNetworkType.WIFI, appId);
        }
    }

    public static void enableThirdPartySharing(int types, String params, String appId) {
        Map<String, Object> maps = new HashMap<>();
        try {
            JSONObject json = new JSONObject(params);
            for (Iterator<String> it = json.keys(); it.hasNext(); ) {
                String key = it.next();
                maps.put(key, json.opt(key));
            }
        } catch (JSONException ignore) {
        }
        if (maps.isEmpty()) {
            TDAnalyticsAPI.enableThirdPartySharing(types, appId);
        } else {
            TDAnalyticsAPI.enableThirdPartySharing(types, maps, appId);
        }
    }

    public static void setDynamicSuperPropertiesTrackerListener(String appId, DynamicSuperPropertiesTrackerListener listener) {
        ThinkingAnalyticsSDK ta = TDAnalyticsAPI.getInstance(appId);
        if (null == ta) return;
        ta.setAutoTrackDynamicProperties(new ThinkingAnalyticsSDK.AutoTrackDynamicProperties() {
            @Override
            public JSONObject getAutoTrackDynamicProperties() {
                try {
                    String pStr = listener.getDynamicSuperPropertiesString();
                    if (pStr != null) {
                        return new JSONObject(pStr);
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                return new JSONObject();
            }
        });
    }

    public static void enableAutoTrack(int types, String properties, String appId) {
        JSONObject json = null;
        try {
            json = new JSONObject(properties);
        } catch (JSONException ignore) {
        }
        TDAnalyticsAPI.enableAutoTrack(types, json, appId);
    }

    public static void setAutoTrackProperties(int types, String properties, String appId) {
        JSONObject json = null;
        try {
            json = new JSONObject(properties);
        } catch (JSONException ignore) {
        }
        if (json == null) return;
        ThinkingAnalyticsSDK instance = TDAnalyticsAPI.getInstance(appId);
        List<ThinkingAnalyticsSDK.AutoTrackEventType> eventTypeList = new ArrayList<>();
        if ((types & TDAnalytics.TDAutoTrackEventType.APP_START) > 0) {
            eventTypeList.add(ThinkingAnalyticsSDK.AutoTrackEventType.APP_START);
        }
        if ((types & TDAnalytics.TDAutoTrackEventType.APP_END) > 0) {
            eventTypeList.add(ThinkingAnalyticsSDK.AutoTrackEventType.APP_END);
        }

        if ((types & TDAnalytics.TDAutoTrackEventType.APP_INSTALL) > 0) {
            eventTypeList.add(ThinkingAnalyticsSDK.AutoTrackEventType.APP_INSTALL);
        }
        if ((types & TDAnalytics.TDAutoTrackEventType.APP_CRASH) > 0) {
            eventTypeList.add(ThinkingAnalyticsSDK.AutoTrackEventType.APP_CRASH);
        }
        instance.setAutoTrackProperties(eventTypeList, json);
    }

    public static void enableAutoTrack(int types, AutoTrackEventTrackerListener listener, String appId) {
        TDAnalyticsAPI.enableAutoTrack(types, new TDAnalytics.TDAutoTrackEventHandler() {
            @Override
            public JSONObject getAutoTrackEventProperties(int i, JSONObject jsonObject) {
                try {
                    String name = appId;
                    if (TextUtils.isEmpty(name)) {
                        name = TDAnalytics.instance.mConfig.getName();
                    }
                    String eStr = listener.eventCallback(i, name, jsonObject.toString());
                    if (eStr != null) {
                        return new JSONObject(eStr);
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                return new JSONObject();
            }
        }, appId);
    }

    public interface DynamicSuperPropertiesTrackerListener {
        String getDynamicSuperPropertiesString();
    }

    public interface AutoTrackEventTrackerListener {
        /**
         * Callback event name and current properties and get dynamic properties
         *
         * @return dynamic properties String
         */
        String eventCallback(int type, String appId, String properties);
    }
}
