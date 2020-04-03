#import <ThinkingSDK/ThinkingAnalyticsSDK.h>
#import <pthread.h>

#define NETWORK_TYPE_DEFAULT 1
#define NETWORK_TYPE_WIFI 2
#define NETWORK_TYPE_ALL 3

static NSMutableDictionary *light_instances;
static pthread_rwlock_t rwlock = PTHREAD_RWLOCK_INITIALIZER;

ThinkingAnalyticsSDK* getInstance(NSString *app_id) {
    ThinkingAnalyticsSDK *result = nil;

    pthread_rwlock_rdlock(&rwlock);
    if (light_instances[app_id] != nil) {
        result = light_instances[app_id];
    }
    pthread_rwlock_unlock(&rwlock);

    if (result != nil) return result;

    return [ThinkingAnalyticsSDK sharedInstanceWithAppid: app_id];
}

void convertToDictionary(const char *json, NSDictionary **properties_dict) {
    NSString *json_string = json != NULL ? [NSString stringWithUTF8String:json] : nil;
    if (json_string) {
        *properties_dict = [NSJSONSerialization JSONObjectWithData:[json_string dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    }
}

char* strdup(const char* string) {
    if (string == NULL)
        return NULL;
    char* res = (char*)malloc(strlen(string) + 1);
    strcpy(res, string);
    return res;
}


void start(const char *app_id, const char *url, int mode, const char *timezone_id) { 
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSString *url_string = url != NULL ? [NSString stringWithUTF8String:url] : nil;
    TDConfig *config = [[TDConfig alloc] init];
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
    [ThinkingAnalyticsSDK startWithAppId:app_id_string withUrl: url_string withConfig:config];
}

void enable_log(BOOL enable_log) {
    if (enable_log) {
        [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    }
}

void set_network_type(int type) {
    switch (type) {
        case NETWORK_TYPE_DEFAULT:
            [[ThinkingAnalyticsSDK sharedInstance] setNetworkType:TDNetworkTypeDefault];
            break;
        case NETWORK_TYPE_WIFI:
            [[ThinkingAnalyticsSDK sharedInstance] setNetworkType:TDNetworkTypeOnlyWIFI];
            break;
        case NETWORK_TYPE_ALL:
            [[ThinkingAnalyticsSDK sharedInstance] setNetworkType:TDNetworkTypeALL];
            break;
    }
}

void identify(const char *app_id, const char *unique_id) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSString *id_string = unique_id != NULL ? [NSString stringWithUTF8String:unique_id] : nil;
    [getInstance(app_id_string) identify:id_string];
}

const char *get_distinct_id(const char *app_id) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSString *distinct_id =[getInstance(app_id_string) getDistinctId];
    return strdup([distinct_id UTF8String]);
}

void login(const char *app_id, const char *account_id) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSString *id_string = account_id != NULL ? [NSString stringWithUTF8String:account_id] : nil;
    [getInstance(app_id_string) login:id_string];
}

void logout(const char *app_id) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    [getInstance(app_id_string) logout];
}

void track(const char *app_id, const char *event_name, const char *properties, long time_stamp_millis, const char *timezone) {
    NSString *event_name_string = event_name != NULL ? [NSString stringWithUTF8String:event_name] : nil;
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    
    NSDictionary *properties_dict = nil;
    convertToDictionary(properties, &properties_dict);
    
    NSString *time_zone_string = timezone != NULL ? [NSString stringWithUTF8String:timezone] : nil;
    NSTimeZone *tz;
    if ([time_zone_string isEqualToString:@"UTC"]) {
        tz = [NSTimeZone timeZoneWithName:@"UTC"];
    } else if ([time_zone_string isEqualToString:@"Local"]) {
        tz = [NSTimeZone localTimeZone];
    } else {
        tz = [NSTimeZone timeZoneWithName:time_zone_string];
    }
    
    NSDate *time = [NSDate dateWithTimeIntervalSince1970:time_stamp_millis / 1000.0];
    
    if (tz) {
        [getInstance(app_id_string) track:event_name_string properties:properties_dict time:time timeZone:tz];
    } else {
        if (time_stamp_millis > 0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [getInstance(app_id_string) track:event_name_string properties:properties_dict time:time];
#pragma clang diagnostic pop
        } else {
            [getInstance(app_id_string) track:event_name_string properties:properties_dict];
        }
    }
}

void flush(const char *app_id) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    if (app_id_string) {
        [getInstance(app_id_string) flush];
    }
}

void set_super_properties(const char *app_id, const char *properties) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSDictionary *properties_dict = nil;
    convertToDictionary(properties, &properties_dict);
    if (properties_dict) {
        [getInstance(app_id_string) setSuperProperties:properties_dict];
    }
}

void unset_super_property(const char *app_id, const char *property_name) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSString *property_name_string = property_name != NULL ? [NSString stringWithUTF8String:property_name] : nil;
    [getInstance(app_id_string) unsetSuperProperty:property_name_string];
}

void clear_super_properties(const char *app_id) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    [getInstance(app_id_string) clearSuperProperties];
}

const char *get_super_properties(const char *app_id) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSDictionary *property_dict = [getInstance(app_id_string) currentSuperProperties];
    // nsdictionary --> nsdata
    NSData *data = [NSJSONSerialization dataWithJSONObject:property_dict options:kNilOptions error:nil];
    // nsdata -> nsstring
    NSString *jsonString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    return strdup([jsonString UTF8String]);
}

void time_event(const char *app_id, const char *event_name) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSString *event_name_string = event_name != NULL ? [NSString stringWithUTF8String:event_name] : nil;
    [getInstance(app_id_string) timeEvent:event_name_string];
}

void user_set(const char *app_id, const char *properties) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSDictionary *properties_dict = nil;
    convertToDictionary(properties, &properties_dict);
    if (properties_dict) {
        [getInstance(app_id_string) user_set:properties_dict];
    }
}

void user_set_with_time(const char *app_id, const char *properties, long time_stamp_millis) {
    NSDate *time = [NSDate dateWithTimeIntervalSince1970:time_stamp_millis / 1000.0];
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSDictionary *properties_dict = nil;
    convertToDictionary(properties, &properties_dict);
    if (properties_dict) {
        [getInstance(app_id_string) user_set:properties_dict withTime:time];
    }
}

void user_unset(const char *app_id, const char *properties) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSString *properties_string = properties != NULL ? [NSString stringWithUTF8String:properties] : nil;
    [getInstance(app_id_string) user_unset:properties_string];
}

void user_unset_with_time(const char *app_id, const char *properties, long time_stamp_millis) {
    NSDate *time = [NSDate dateWithTimeIntervalSince1970:time_stamp_millis / 1000.0];
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSString *properties_string = properties != NULL ? [NSString stringWithUTF8String:properties] : nil;
    [getInstance(app_id_string) user_unset:properties_string withTime:time];
}

void user_set_once(const char *app_id, const char *properties) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSDictionary *properties_dict = nil;
    convertToDictionary(properties, &properties_dict);
    if (properties_dict) {
        [getInstance(app_id_string) user_setOnce:properties_dict];
    }
}

void user_set_once_with_time(const char *app_id, const char *properties, long time_stamp_millis) {
    NSDate *time = [NSDate dateWithTimeIntervalSince1970:time_stamp_millis / 1000.0];
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSDictionary *properties_dict = nil;
    convertToDictionary(properties, &properties_dict);
    if (properties_dict) {
        [getInstance(app_id_string) user_setOnce:properties_dict withTime:time];
    }
}

void user_add(const char *app_id, const char *properties) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSDictionary *properties_dict = nil;
    convertToDictionary(properties, &properties_dict);
    if (properties_dict) {
        [getInstance(app_id_string) user_add:properties_dict];
    }
}

void user_add_with_time(const char *app_id, const char *properties, long time_stamp_millis) {
    NSDate *time = [NSDate dateWithTimeIntervalSince1970:time_stamp_millis / 1000.0];
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSDictionary *properties_dict = nil;
    convertToDictionary(properties, &properties_dict);
    if (properties_dict) {
        [getInstance(app_id_string) user_add:properties_dict withTime:time];
    }
}

void user_delete(const char *app_id) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    [getInstance(app_id_string) user_delete];
}

void user_delete_with_time(const char *app_id, long time_stamp_millis) {
    NSDate *time = [NSDate dateWithTimeIntervalSince1970:time_stamp_millis / 1000.0];
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    [getInstance(app_id_string) user_delete:time];
}

void user_append(const char *app_id, const char *properties) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSDictionary *properties_dict = nil;
    convertToDictionary(properties, &properties_dict);
    if (properties_dict) {
        [getInstance(app_id_string) user_append:properties_dict];
    }
}

void user_append_with_time(const char *app_id, const char *properties, long time_stamp_millis) {
    NSDate *time = [NSDate dateWithTimeIntervalSince1970:time_stamp_millis / 1000.0];
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSDictionary *properties_dict = nil;
    convertToDictionary(properties, &properties_dict);
    if (properties_dict) {
        [getInstance(app_id_string) user_append:properties_dict withTime:time];
    }
}

const char *get_device_id() {
    NSString *distinct_id = [[ThinkingAnalyticsSDK sharedInstance] getDeviceId];
    return strdup([distinct_id UTF8String]);
}

void enable_tracking(const char *app_id, BOOL enabled) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    [getInstance(app_id_string) enableTracking:enabled];
}

void opt_out_tracking(const char *app_id) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    [getInstance(app_id_string)  optOutTracking];
}

void opt_out_tracking_and_delete_user(const char *app_id) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    [getInstance(app_id_string)  optOutTrackingAndDeleteUser];
}

void opt_in_tracking(const char *app_id) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    [getInstance(app_id_string)  optInTracking];
}

void create_light_instance(const char *app_id, const char *delegate_app_id) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSString *delegate_app_id_string = delegate_app_id != NULL ? [NSString stringWithUTF8String:delegate_app_id] : nil;
    ThinkingAnalyticsSDK *light = [getInstance(app_id_string) createLightInstance];

    pthread_rwlock_wrlock(&rwlock);
    if (light_instances == nil) {
        light_instances = [NSMutableDictionary dictionary];
    }

    [light_instances setObject:light forKey:delegate_app_id_string];
    pthread_rwlock_unlock(&rwlock);
}

void enable_autoTrack(const char *app_id, int autoTrackEvents) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    [[ThinkingAnalyticsSDK sharedInstanceWithAppid:app_id_string] enableAutoTrack: autoTrackEvents];
}

const char *get_time_string(const char *app_id, long time_stamp_millis) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSDate *time = [NSDate dateWithTimeIntervalSince1970:time_stamp_millis / 1000.0];
    NSString *time_string = [[ThinkingAnalyticsSDK sharedInstanceWithAppid:app_id_string] getTimeString:time];
    return strdup([time_string UTF8String]);
}

void calibrate_time(long time_stamp_millis) {
    [ThinkingAnalyticsSDK calibrateTime:time_stamp_millis];
}

void calibrate_time_with_ntp(const char *ntp_server) {
    NSString *ntp_server_string = ntp_server != NULL ? [NSString stringWithUTF8String:ntp_server] : nil;
    [ThinkingAnalyticsSDK calibrateTimeWithNtp:ntp_server_string];
}
