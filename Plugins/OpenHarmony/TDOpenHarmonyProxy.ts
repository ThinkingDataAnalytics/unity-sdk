import { TDAnalytics, TDConfig, TDMode, TDAutoTrackEventType, TDNetworkType } from '@thinkingdata/analytics';
import I18n from '@ohos.i18n';
export class TDOpenHarmonyProxy {
    static init(configStr: string) {
        try {
            let configJson: object = JSON.parse(configStr)
            let config = new TDConfig()
            config.appId = configJson['appId']
            config.serverUrl = configJson['serverUrl']
            let mode: number = configJson['mode']
            if (mode == 1) {
                config.mode = TDMode.DEBUG
            } else if (mode == 2) {
                config.mode = TDMode.DEBUG_ONLY
            } else {
                config.mode = TDMode.NORMAL
            }
            let tienZoneStr: string = configJson['timeZone']
            if (tienZoneStr) {
                config.defaultTimeZone = I18n.getTimeZone(tienZoneStr)
            }
            let publicKey: string = configJson['publicKey']
            let version: number = configJson['version']
            if (publicKey && version > 0) {
                config.enableEncrypt(version, publicKey)
            }
            TDAnalytics.initWithConfig(globalThis.context, config)
        } catch (e) {

        }
    }

    static enableLog(enable: boolean) {
        TDAnalytics.enableLog(enable)

    }

    static setLibraryInfo(libName: string, libVersion: string) {
        TDAnalytics.setCustomerLibInfo(libName, libVersion)
    }

    static setDistinctId(distinctId: string, appId: string) {
        TDAnalytics.setDistinctId(distinctId, appId)
    }

    static getDistinctId(appId: string): string {
        return TDAnalytics.getDistinctId(appId)
    }

    static login(accountId: string, appId: string) {
        TDAnalytics.login(accountId, appId)
    }

    static logout(appId: string) {
        TDAnalytics.logout(appId)
    }

    static track(dataJson: string, appId: string) {
        try {
            let obj: object = JSON.parse(dataJson);
            let eventTimeStamp: number = obj['event_time'];
            let time: Date = null;
            let timeZone: I18n.TimeZone = null;
            if (eventTimeStamp > 0) {
                time = new Date(eventTimeStamp)
                let timeZoneStr = obj['event_timezone']
                if (timeZoneStr) {
                    if (timeZoneStr == 'Local') {
                        timeZone = I18n.getTimeZone()
                    } else {
                        timeZone = I18n.getTimeZone(timeZoneStr)
                    }
                }
            }
            TDAnalytics.track({
                eventName: obj['event_name'],
                properties: obj['event_properties'],
                time: time,
                timeZone: timeZone
            }, appId)
        } catch (e) {
        }
    }

    static trackEvent(dataJson: string, appId: string) {
        try {
            let obj: object = JSON.parse(dataJson);
            let eventTimeStamp: number = obj['event_time'];
            let time: Date = null;
            let timeZone: I18n.TimeZone = null;
            if (eventTimeStamp > 0) {
                time = new Date(eventTimeStamp);
                let timeZoneStr = obj['event_timezone']
                if (timeZoneStr) {
                    if (timeZoneStr == 'Local') {
                        timeZone = I18n.getTimeZone()
                    } else {
                        timeZone = I18n.getTimeZone(timeZoneStr)
                    }
                }
            }
            let eventId: string = obj['event_id']
            let eventName: string = obj['event_name']
            let eventProperties: object = obj['event_properties']
            let eventType: number = obj['event_type']
            if (eventType == 1) {
                TDAnalytics.trackFirst({
                    eventName: eventName,
                    properties: eventProperties,
                    firstCheckId: eventId,
                    time: time,
                    timeZone: timeZone
                }, appId)
            } else if (eventType == 2) {
                TDAnalytics.trackUpdate({
                    eventName: eventName,
                    properties: eventProperties,
                    eventId: eventId,
                    time: time,
                    timeZone: timeZone
                }, appId)
            } else if (eventType == 3) {
                TDAnalytics.trackOverwrite({
                    eventName: eventName,
                    properties: eventProperties,
                    eventId: eventId,
                    time: time,
                    timeZone: timeZone
                }, appId)
            }
        } catch (e) {
        }
    }

    static setSuperProperties(superProperties: string, appId: string) {
        try {
            let superObj: object = JSON.parse(superProperties)
            TDAnalytics.setSuperProperties(superObj, appId)
        } catch (e) {
        }
    }

    static unsetSuperProperty(property: string, appId: string) {
        TDAnalytics.unsetSuperProperty(property, appId)
    }

    static clearSuperProperties(appId: string) {
        TDAnalytics.clearSuperProperties(appId)
    }

    static getSuperProperties(appId: string): string {
        return TDAnalytics.getSuperProperties(appId)
    }

    static getPresetProperties(appId: string): string {
        return TDAnalytics.getPresetProperties(appId)
    }

    static flush(appId: string) {
        TDAnalytics.flush(appId)
    }

    static userSet(dataJson: string, appId: string) {
        try {
            let obj: object = JSON.parse(dataJson);
            let eventTimeStamp: number = obj['event_time'];
            let time: Date = null;
            if (eventTimeStamp > 0) {
                time = new Date(eventTimeStamp)
            }
            TDAnalytics.userSet({
                properties: obj['user_properties'],
                time: time
            }, appId)
        } catch (e) {
        }
    }

    static userSetOnce(dataJson: string, appId: string) {
        try {
            let obj: object = JSON.parse(dataJson);
            let eventTimeStamp: number = obj['event_time'];
            let time: Date = null;
            if (eventTimeStamp > 0) {
                time = new Date(eventTimeStamp)
            }
            TDAnalytics.userSetOnce({
                properties: obj['user_properties'],
                time: time
            }, appId)
        } catch (e) {
        }
    }

    static userUnset(property: string, timeStamp: number, appId: string) {
        try {
            let time: Date = null;
            if (timeStamp > 0) {
                time = new Date(timeStamp)
            }
            TDAnalytics.userUnset({
                property: property,
                time: time
            }, appId)
        } catch (e) {
        }
    }

    static userAdd(dataJson: string, appId: string) {
        try {
            let obj: object = JSON.parse(dataJson);
            let eventTimeStamp: number = obj['event_time'];
            let time: Date = null;
            if (eventTimeStamp > 0) {
                time = new Date(eventTimeStamp)
            }
            TDAnalytics.userAdd({
                properties: obj['user_properties'],
                time: time
            }, appId)
        } catch (e) {
        }
    }

    static userAppend(dataJson: string, appId: string) {
        try {
            let obj: object = JSON.parse(dataJson);
            let eventTimeStamp: number = obj['event_time'];
            let time: Date = null;
            if (eventTimeStamp > 0) {
                time = new Date(eventTimeStamp)
            }
            TDAnalytics.userAppend({
                properties: obj['user_properties'],
                time: time
            }, appId)
        } catch (e) {
        }
    }

    static userUniqAppend(dataJson: string, appId: string) {
        try {
            let obj: object = JSON.parse(dataJson);
            let eventTimeStamp: number = obj['event_time'];
            let time: Date = null;
            if (eventTimeStamp > 0) {
                time = new Date(eventTimeStamp)
            }
            TDAnalytics.userUniqAppend({
                properties: obj['user_properties'],
                time: time
            }, appId)
        } catch (e) {
        }
    }

    static userDelete(dataJson: string, appId: string) {
        try {
            let obj: object = JSON.parse(dataJson);
            let eventTimeStamp: number = obj['event_time'];
            let time: Date = null;
            if (eventTimeStamp > 0) {
                time = new Date(eventTimeStamp)
            }
            TDAnalytics.userDelete({
                time: time
            }, appId)
        } catch (e) {
        }
    }

    static getDeviceId(): string {
        return TDAnalytics.getDeviceId()
    }

    static setNetWorkType(type: number) {
        if (type == 2) {
            TDAnalytics.setNetworkType(TDNetworkType.WIFI)
        } else {
            TDAnalytics.setNetworkType(TDNetworkType.ALL)
        }
    }

    static enableAutoTrack(autoTypes: number, appId: string) {
        TDAnalytics.enableAutoTrack(autoTypes, appId)
    }

    static timeEvent(eventName: string, appId: string) {
        TDAnalytics.timeEvent(eventName, appId)
    }

    static calibrateTime(timestamp: number) {
        TDAnalytics.calibrateTime(timestamp)
    }
}