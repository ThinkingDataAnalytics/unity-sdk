#if __has_include(<ThinkingSDK/ThinkingAnalyticsSDK.h>)
#import <ThinkingSDK/ThinkingAnalyticsSDK.h>
#import <ThinkingSDK/TDDeviceInfo.h>
#else
#import "ThinkingAnalyticsSDK.h"
#import "TDDeviceInfo.h"
#endif
#import <pthread.h>

#define NETWORK_TYPE_DEFAULT 1
#define NETWORK_TYPE_WIFI 2
#define NETWORK_TYPE_ALL 3

//定义一个名字参数和C#类一样的方法
typedef const char * (*ResultHandler) (const char *type, const char *jsonData);
//生命一个静态变量存储回调unity的函数指针
static ResultHandler resultHandler;
//设置回调游戏的托管函数
void RegisterRecieveGameCallback(ResultHandler handlerPointer) 
{
    resultHandler = handlerPointer;
}

static NSMutableDictionary *light_instances;
static pthread_rwlock_t rwlock = PTHREAD_RWLOCK_INITIALIZER;

ThinkingAnalyticsSDK* ta_getInstance(NSString *app_id) {
    ThinkingAnalyticsSDK *result = nil;
    
    if (app_id == nil || [app_id isEqualToString:@""]) {
        return [ThinkingAnalyticsSDK sharedInstance];
    }

    pthread_rwlock_rdlock(&rwlock);
    if (light_instances[app_id] != nil) {
        result = light_instances[app_id];
    }
    pthread_rwlock_unlock(&rwlock);
    
    if (result != nil) return result;
    
    return [ThinkingAnalyticsSDK sharedInstanceWithAppid: app_id];
}

void ta_convertToDictionary(const char *json, NSDictionary **properties_dict) {
    NSString *json_string = json != NULL ? [NSString stringWithUTF8String:json] : nil;
    if (json_string) {
        *properties_dict = [NSJSONSerialization JSONObjectWithData:[json_string dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    }
}

char* ta_strdup(const char* string) {
    if (string == NULL)
        return NULL;
    char* res = (char*)malloc(strlen(string) + 1);
    strcpy(res, string);
    return res;
}


void ta_start(const char *app_id, const char *url, int mode, const char *timezone_id, bool enable_encrypt, int encrypt_version, const char *encrypt_public_key, int pinning_mode, bool allow_invalid_certificates, bool validates_domain_name, const char *instance_name) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSString *url_string = url != NULL ? [NSString stringWithUTF8String:url] : nil;
    NSString *instance_name_string = instance_name != NULL ? [NSString stringWithUTF8String:instance_name] : nil;
    TDConfig *config = [[TDConfig alloc] init];
    config.appid = app_id_string;
    config.configureURL = url_string;
    if (instance_name) {
        [config setName:instance_name_string];
    }
    if (mode == 1) {
        // DEBUG
        config.debugMode = ThinkingAnalyticsDebug;
    } else if (mode == 2) {
        // DEBUG_ONLY
        config.debugMode = ThinkingAnalyticsDebugOnly;
    }
    NSString *timezone_id_string = timezone_id != NULL ? [NSString stringWithUTF8String:timezone_id] : nil;
    NSTimeZone *timezone = [NSTimeZone timeZoneWithName:timezone_id_string];
    if (timezone) {
        config.defaultTimeZone = timezone;
    }
    if (enable_encrypt == YES) {
        NSString *encrypt_public_key_string = encrypt_public_key != NULL ? [NSString stringWithUTF8String:encrypt_public_key] : nil;
        // 开启加密功能
        config.enableEncrypt = YES; 
        // 配置版本号、公钥等密钥信息
        config.secretKey = [[TDSecretKey alloc] initWithVersion:encrypt_version publicKey:encrypt_public_key_string];
    }

    [ThinkingAnalyticsSDK startWithConfig:config];
}

void ta_enable_log(BOOL enable_log) {
    if (enable_log) {
        [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    } else {
        [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelNone];
    }
}

void ta_set_network_type(int type) {
    switch (type) {
        case NETWORK_TYPE_DEFAULT:
            [ta_getInstance(nil) setNetworkType:TDNetworkTypeDefault];
            break;
        case NETWORK_TYPE_WIFI:
            [ta_getInstance(nil) setNetworkType:TDNetworkTypeOnlyWIFI];
            break;
        case NETWORK_TYPE_ALL:
            [ta_getInstance(nil) setNetworkType:TDNetworkTypeALL];
            break;
    }
}

void ta_identify(const char *app_id, const char *unique_id) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSString *id_string = unique_id != NULL ? [NSString stringWithUTF8String:unique_id] : nil;
    [ta_getInstance(app_id_string) identify:id_string];
}

const char *ta_get_distinct_id(const char *app_id) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSString *distinct_id =[ta_getInstance(app_id_string) getDistinctId];
    return ta_strdup([distinct_id UTF8String]);
}

void ta_login(const char *app_id, const char *account_id) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSString *id_string = account_id != NULL ? [NSString stringWithUTF8String:account_id] : nil;
    [ta_getInstance(app_id_string) login:id_string];
}

void ta_logout(const char *app_id) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    [ta_getInstance(app_id_string) logout];
}

void ta_config_custom_lib_info(const char *lib_name, const char *lib_version) {
    NSString *lib_name_string = lib_name != NULL ? [NSString stringWithUTF8String:lib_name] : nil;
    NSString *lib_version_string = lib_version != NULL ? [NSString stringWithUTF8String:lib_version] : nil;
    [ThinkingAnalyticsSDK setCustomerLibInfoWithLibName:lib_name_string libVersion:lib_version_string];
}

void ta_track_event(const char *app_id, const char *event_model_json) {
    NSDictionary *event_model_dic = nil;
    ta_convertToDictionary(event_model_json, &event_model_dic);
    TDEventModel *eventModel;
    NSString *eventType = event_model_dic[@"event_type"];
    if ([eventType isEqualToString:@"track_first"]) {
        eventModel = [[TDFirstEventModel alloc] initWithEventName:event_model_dic[@"event_name"] firstCheckID:event_model_dic[@"extra_id"]];
    } else if ([eventType isEqualToString:@"track_update"]) {
        eventModel = [[TDUpdateEventModel alloc] initWithEventName:event_model_dic[@"event_name"] eventID:event_model_dic[@"extra_id"]];
    } else if ([eventType isEqualToString:@"track_overwrite"]) {
        eventModel = [[TDOverwriteEventModel alloc] initWithEventName:event_model_dic[@"event_name"] eventID:event_model_dic[@"extra_id"]];
    }
    
    eventModel.properties = event_model_dic[@"event_properties"];
    
    NSString *timeString = event_model_dic[@"event_time"];
    NSString *timezoneString = event_model_dic[@"event_timezone"];
    NSTimeZone *tz;
    if ([@"Local" isEqualToString:timezoneString]) {
        tz = [NSTimeZone localTimeZone];
    } else {
        tz = [NSTimeZone timeZoneWithName:timezoneString];
    }
    
    if (timeString) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
        NSDate *date = [formatter dateFromString:timeString];
        [eventModel configTime:date timeZone:tz];
    }
    
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    [ta_getInstance(app_id_string) trackWithEventModel:eventModel];
}

void ta_track(const char *app_id, const char *event_name, const char *properties, long long time_stamp_millis, const char *timezone) {
    NSString *event_name_string = event_name != NULL ? [NSString stringWithUTF8String:event_name] : nil;
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    
    NSDictionary *properties_dict = nil;
    ta_convertToDictionary(properties, &properties_dict);
    
    NSString *time_zone_string = timezone != NULL ? [NSString stringWithUTF8String:timezone] : nil;
    NSTimeZone *tz;
    if ([@"Local" isEqualToString:time_zone_string]) {
        tz = [NSTimeZone localTimeZone];
    } else {
        tz = [NSTimeZone timeZoneWithName:time_zone_string];
    }
    
    NSDate *time = [NSDate dateWithTimeIntervalSince1970:time_stamp_millis / 1000.0];
    
    if (tz) {
        [ta_getInstance(app_id_string) track:event_name_string properties:properties_dict time:time timeZone:tz];
    } else {
        if (time_stamp_millis > 0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [ta_getInstance(app_id_string) track:event_name_string properties:properties_dict time:time];
#pragma clang diagnostic pop
        } else {
            [ta_getInstance(app_id_string) track:event_name_string properties:properties_dict];
        }
    }
}

void ta_flush(const char *app_id) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    if (app_id_string) {
        [ta_getInstance(app_id_string) flush];
    }
}

void ta_set_super_properties(const char *app_id, const char *properties) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSDictionary *properties_dict = nil;
    ta_convertToDictionary(properties, &properties_dict);
    if (properties_dict) {
        [ta_getInstance(app_id_string) setSuperProperties:properties_dict];
    }
}

void ta_unset_super_property(const char *app_id, const char *property_name) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSString *property_name_string = property_name != NULL ? [NSString stringWithUTF8String:property_name] : nil;
    [ta_getInstance(app_id_string) unsetSuperProperty:property_name_string];
}

void ta_clear_super_properties(const char *app_id) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    [ta_getInstance(app_id_string) clearSuperProperties];
}

const char *ta_get_super_properties(const char *app_id) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSDictionary *property_dict = [ta_getInstance(app_id_string) currentSuperProperties];
    // nsdictionary --> nsdata
    NSData *data = [NSJSONSerialization dataWithJSONObject:property_dict options:kNilOptions error:nil];
    // nsdata -> nsstring
    NSString *jsonString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    return ta_strdup([jsonString UTF8String]);
}

const char *ta_get_preset_properties(const char *app_id) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSDictionary *property_dict = [[ta_getInstance(app_id_string) getPresetProperties] toEventPresetProperties];
    // nsdictionary --> nsdata
    NSData *data = [NSJSONSerialization dataWithJSONObject:property_dict options:kNilOptions error:nil];
    // nsdata -> nsstring
    NSString *jsonString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    return ta_strdup([jsonString UTF8String]);
}

void ta_time_event(const char *app_id, const char *event_name) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSString *event_name_string = event_name != NULL ? [NSString stringWithUTF8String:event_name] : nil;
    [ta_getInstance(app_id_string) timeEvent:event_name_string];
}

void ta_user_set(const char *app_id, const char *properties) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSDictionary *properties_dict = nil;
    ta_convertToDictionary(properties, &properties_dict);
    if (properties_dict) {
        [ta_getInstance(app_id_string) user_set:properties_dict];
    }
}

void ta_user_set_with_time(const char *app_id, const char *properties, long long time_stamp_millis) {
    NSDate *time = [NSDate dateWithTimeIntervalSince1970:time_stamp_millis / 1000.0];
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSDictionary *properties_dict = nil;
    ta_convertToDictionary(properties, &properties_dict);
    if (properties_dict) {
        [ta_getInstance(app_id_string) user_set:properties_dict withTime:time];
    }
}

void ta_user_unset(const char *app_id, const char *properties) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSString *properties_string = properties != NULL ? [NSString stringWithUTF8String:properties] : nil;
    [ta_getInstance(app_id_string) user_unset:properties_string];
}

void ta_user_unset_with_time(const char *app_id, const char *properties, long long time_stamp_millis) {
    NSDate *time = [NSDate dateWithTimeIntervalSince1970:time_stamp_millis / 1000.0];
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSString *properties_string = properties != NULL ? [NSString stringWithUTF8String:properties] : nil;
    [ta_getInstance(app_id_string) user_unset:properties_string withTime:time];
}

void ta_user_set_once(const char *app_id, const char *properties) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSDictionary *properties_dict = nil;
    ta_convertToDictionary(properties, &properties_dict);
    if (properties_dict) {
        [ta_getInstance(app_id_string) user_setOnce:properties_dict];
    }
}

void ta_user_set_once_with_time(const char *app_id, const char *properties, long long time_stamp_millis) {
    NSDate *time = [NSDate dateWithTimeIntervalSince1970:time_stamp_millis / 1000.0];
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSDictionary *properties_dict = nil;
    ta_convertToDictionary(properties, &properties_dict);
    if (properties_dict) {
        [ta_getInstance(app_id_string) user_setOnce:properties_dict withTime:time];
    }
}

void ta_user_add(const char *app_id, const char *properties) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSDictionary *properties_dict = nil;
    ta_convertToDictionary(properties, &properties_dict);
    if (properties_dict) {
        [ta_getInstance(app_id_string) user_add:properties_dict];
    }
}

void ta_user_add_with_time(const char *app_id, const char *properties, long long time_stamp_millis) {
    NSDate *time = [NSDate dateWithTimeIntervalSince1970:time_stamp_millis / 1000.0];
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSDictionary *properties_dict = nil;
    ta_convertToDictionary(properties, &properties_dict);
    if (properties_dict) {
        [ta_getInstance(app_id_string) user_add:properties_dict withTime:time];
    }
}

void ta_user_delete(const char *app_id) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    [ta_getInstance(app_id_string) user_delete];
}

void ta_user_delete_with_time(const char *app_id, long long time_stamp_millis) {
    NSDate *time = [NSDate dateWithTimeIntervalSince1970:time_stamp_millis / 1000.0];
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    [ta_getInstance(app_id_string) user_delete:time];
}

void ta_user_append(const char *app_id, const char *properties) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSDictionary *properties_dict = nil;
    ta_convertToDictionary(properties, &properties_dict);
    if (properties_dict) {
        [ta_getInstance(app_id_string) user_append:properties_dict];
    }
}

void ta_user_append_with_time(const char *app_id, const char *properties, long long time_stamp_millis) {
    NSDate *time = [NSDate dateWithTimeIntervalSince1970:time_stamp_millis / 1000.0];
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSDictionary *properties_dict = nil;
    ta_convertToDictionary(properties, &properties_dict);
    if (properties_dict) {
        [ta_getInstance(app_id_string) user_append:properties_dict withTime:time];
    }
}

void ta_user_uniq_append(const char *app_id, const char *properties) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSDictionary *properties_dict = nil;
    ta_convertToDictionary(properties, &properties_dict);
    if (properties_dict) {
        [ta_getInstance(app_id_string) user_uniqAppend:properties_dict];
    }
}

void ta_user_uniq_append_with_time(const char *app_id, const char *properties, long long time_stamp_millis) {
    NSDate *time = [NSDate dateWithTimeIntervalSince1970:time_stamp_millis / 1000.0];
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSDictionary *properties_dict = nil;
    ta_convertToDictionary(properties, &properties_dict);
    if (properties_dict) {
        [ta_getInstance(app_id_string) user_uniqAppend:properties_dict withTime:time];
    }
}

const char *ta_get_device_id() {
    NSString *distinct_id = [ta_getInstance(nil) getDeviceId];
    return ta_strdup([distinct_id UTF8String]);
}

void ta_set_dynamic_super_properties(const char *app_id) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    [ta_getInstance(app_id_string) registerDynamicSuperProperties:^NSDictionary * _Nonnull{
        const char *ret = resultHandler("DynamicSuperProperties", nil);
        NSDictionary *dynamicSuperProperties = nil;
        ta_convertToDictionary(ret, &dynamicSuperProperties);
        return dynamicSuperProperties;
    }];
}

void ta_set_track_status(const char *app_id, int status) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    ThinkingAnalyticsSDK* instance = ta_getInstance(app_id_string);
    switch (status) {
        case 1:
            [instance setTrackStatus:TATrackStatusPause];
            break;
        case 2:
            [instance setTrackStatus:TATrackStatusStop];
            break;
        case 3:
            [instance setTrackStatus:TATrackStatusSaveOnly];
            break;
        case 4:
        default:
            [instance setTrackStatus:TATrackStatusNormal];
    }
}

void ta_enable_tracking(const char *app_id, BOOL enabled) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    [ta_getInstance(app_id_string) enableTracking:enabled];
}

void ta_opt_out_tracking(const char *app_id) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    [ta_getInstance(app_id_string)  optOutTracking];
}

void ta_opt_out_tracking_and_delete_user(const char *app_id) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    [ta_getInstance(app_id_string)  optOutTrackingAndDeleteUser];
}

void ta_opt_in_tracking(const char *app_id) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    [ta_getInstance(app_id_string)  optInTracking];
}

void ta_create_light_instance(const char *delegate_app_id) {
    NSString *delegate_app_id_string = delegate_app_id != NULL ? [NSString stringWithUTF8String:delegate_app_id] : nil;
    ThinkingAnalyticsSDK *light = [ta_getInstance(nil) createLightInstance];
    
    pthread_rwlock_wrlock(&rwlock);
    if (light_instances == nil) {
        light_instances = [NSMutableDictionary dictionary];
    }
    
    [light_instances setObject:light forKey:delegate_app_id_string];
    pthread_rwlock_unlock(&rwlock);
}

void ta_enable_autoTrack(const char *app_id, int autoTrackEvents, const char *properties) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSDictionary *properties_dict = nil;
    ta_convertToDictionary(properties, &properties_dict);
    [ta_getInstance(app_id_string) enableAutoTrack: autoTrackEvents properties:properties_dict];
}

void ta_enable_autoTrack_with_callback(const char *app_id, int autoTrackEvents) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    [ta_getInstance(app_id_string) enableAutoTrack: autoTrackEvents callback:^NSDictionary * _Nonnull(ThinkingAnalyticsAutoTrackEventType eventType, NSDictionary * _Nonnull properties) {
        NSMutableDictionary *callbackProperties = [NSMutableDictionary dictionaryWithDictionary:properties];
        [callbackProperties setObject:@(eventType) forKey:@"EventType"];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:callbackProperties options:NSJSONWritingPrettyPrinted error:nil];
        const char *ret = resultHandler("AutoTrackProperties", jsonData.bytes);
        NSDictionary *autoTrackProperties = nil;
        ta_convertToDictionary(ret, &autoTrackProperties);
        return autoTrackProperties;
    }];
}

void ta_set_autoTrack_properties(const char *app_id, int autoTrackEvents, const char *properties) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSDictionary *properties_dict = nil;
    ta_convertToDictionary(properties, &properties_dict);
    [ta_getInstance(app_id_string) setAutoTrackProperties: autoTrackEvents properties:properties_dict];
}

const char *ta_get_time_string(long long time_stamp_millis) {
    NSDate *time = [NSDate dateWithTimeIntervalSince1970:time_stamp_millis / 1000.0];
    NSString *time_string = [ta_getInstance(nil) getTimeString:time];
    return ta_strdup([time_string UTF8String]);
}

void ta_calibrate_time(long long time_stamp_millis) {
    [ThinkingAnalyticsSDK calibrateTime:time_stamp_millis];
}

void ta_calibrate_time_with_ntp(const char *ntp_server) {
    NSString *ntp_server_string = ntp_server != NULL ? [NSString stringWithUTF8String:ntp_server] : nil;
    [ThinkingAnalyticsSDK calibrateTimeWithNtp:ntp_server_string];
}

void ta_enable_third_party_sharing(const char *app_id, int share_type, const char *properties) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSDictionary *properties_dict = nil;
    ta_convertToDictionary(properties, &properties_dict);
    if (properties_dict) {
        [ta_getInstance(app_id_string) enableThirdPartySharing:share_type customMap:properties_dict];
    } else {
        [ta_getInstance(app_id_string) enableThirdPartySharing:share_type];
    }
}