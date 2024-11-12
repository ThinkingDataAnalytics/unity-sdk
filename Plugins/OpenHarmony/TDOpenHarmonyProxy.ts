import { TDAnalytics, TDConfig, TDMode, TDNetworkType } from '@thinkingdata/analytics';
import I18n from '@ohos.i18n';

export class TDOpenHarmonyProxy {
    static init(appId: string, serverUrl: string, mode: number, timeZone: string, version: number, publicKey: string) {
        let config = new TDConfig()
        config.appId = appId
        config.serverUrl = serverUrl
        if (mode == 1) {
            config.mode = TDMode.DEBUG
        } else if (mode == 2) {
            config.mode = TDMode.DEBUG_ONLY
        } else {
            config.mode = TDMode.NORMAL
        }
        if (timeZone) {
            config.defaultTimeZone = I18n.getTimeZone(timeZone)
        }
        if (publicKey && version > 0) {
            config.enableEncrypt(version, publicKey)
        }
        TDAnalytics.initWithConfig(globalThis.context, config)
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

    static track(eventName: string, properties: string, timeStamp: number, timeZoneId: string, appId: string) {
        try {
            let time: Date = null;
            let timeZone: I18n.TimeZone = null;
            if (timeStamp > 0) {
                time = new Date(timeStamp)
                if (timeZoneId) {
                    if (timeZoneId === 'Local') {
                        timeZone = I18n.getTimeZone()
                    } else {
                        timeZone = I18n.getTimeZone(timeZoneId)
                    }
                }
            }
            TDAnalytics.track({
                eventName: eventName,
                properties: this.parseJsonStrict(properties),
                time: time,
                timeZone: timeZone
            }, appId)
        } catch (e) {
        }
    }

    static trackEvent(eventType: number, eventName: string, properties: string, eventId: string, timeStamp: number,
        timezoneId: string, appId: string) {
        try {
            let time: Date = null;
            let timeZone: I18n.TimeZone = null;
            if (timeStamp > 0) {
                time = new Date(timeStamp);
                if (timezoneId) {
                    if (timezoneId == 'Local') {
                        timeZone = I18n.getTimeZone()
                    } else {
                        timeZone = I18n.getTimeZone(timezoneId)
                    }
                }
            }
            if (eventType == 1) {
                TDAnalytics.trackFirst({
                    eventName: eventName,
                    properties: this.parseJsonStrict(properties),
                    firstCheckId: eventId,
                    time: time,
                    timeZone: timeZone
                }, appId)
            } else if (eventType == 2) {
                TDAnalytics.trackUpdate({
                    eventName: eventName,
                    properties: this.parseJsonStrict(properties),
                    eventId: eventId,
                    time: time,
                    timeZone: timeZone
                }, appId)
            } else if (eventType == 3) {
                TDAnalytics.trackOverwrite({
                    eventName: eventName,
                    properties: this.parseJsonStrict(properties),
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
            TDAnalytics.setSuperProperties(this.parseJsonStrict(superProperties), appId)
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

    static userSet(properties: string, timeStamp: number, appId: string) {
        try {
            let time: Date = null;
            if (timeStamp > 0) {
                time = new Date(timeStamp)
            }
            TDAnalytics.userSet({
                properties: this.parseJsonStrict(properties),
                time: time
            }, appId)
        } catch (e) {
        }
    }

    static userSetOnce(properties: string, timeStamp: number, appId: string) {
        try {
            let time: Date = null;
            if (timeStamp > 0) {
                time = new Date(timeStamp)
            }
            TDAnalytics.userSetOnce({
                properties: this.parseJsonStrict(properties),
                time: time
            }, appId)
        } catch (e) {
        }
    }

    static userUnset(property: string, timeStamp: number, appId: string) {
        let time: Date = null;
        if (timeStamp > 0) {
            time = new Date(timeStamp)
        }
        TDAnalytics.userUnset({
            property: property,
            time: time
        }, appId)
    }

    static userAdd(properties: string, timeStamp: number, appId: string) {
        try {
            let time: Date = null;
            if (timeStamp > 0) {
                time = new Date(timeStamp)
            }
            TDAnalytics.userAdd({
                properties: this.parseJsonStrict(properties),
                time: time
            }, appId)
        } catch (e) {
        }
    }

    static userAppend(properties: string, timeStamp: number, appId: string) {
        try {
            let time: Date = null;
            if (timeStamp > 0) {
                time = new Date(timeStamp)
            }
            TDAnalytics.userAppend({
                properties: this.parseJsonStrict(properties),
                time: time
            }, appId)
        } catch (e) {
        }
    }

    static userUniqAppend(properties: string, timeStamp: number, appId: string) {
        try {
            let time: Date = null;
            if (timeStamp > 0) {
                time = new Date(timeStamp)
            }
            TDAnalytics.userUniqAppend({
                properties: this.parseJsonStrict(properties),
                time: time
            }, appId)
        } catch (e) {
        }
    }

    static userDelete(timeStamp: number, appId: string) {
        let time: Date = null;
        if (timeStamp > 0) {
            time = new Date(timeStamp)
        }
        TDAnalytics.userDelete({
            time: time
        }, appId)
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
        TDAnalytics.enableAutoTrack(globalThis.context, autoTypes, null, appId)
    }

    static timeEvent(eventName: string, appId: string) {
        TDAnalytics.timeEvent(eventName, appId)
    }

    static calibrateTime(timestamp: number) {
        TDAnalytics.calibrateTime(timestamp)
    }

    private static parseJsonStrict(jsonString: string): object {
        try {
            const parsed = JSON.parse(jsonString);
            if (typeof parsed !== 'object' || parsed === null) {
                return {};
            }
            return parsed;
        } catch (error) {
            return {};
        }
    }
}