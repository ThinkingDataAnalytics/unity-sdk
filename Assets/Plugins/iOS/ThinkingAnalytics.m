#import "ThinkingAnalyticsSDK.h"

#define NETWORK_TYPE_DEFAULT 1
#define NETWORK_TYPE_WIFI 2
#define NETWORK_TYPE_ALL 3
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


void start(const char *app_id, const char *url) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSString *url_string = url != NULL ? [NSString stringWithUTF8String:url] : nil;
    [ThinkingAnalyticsSDK startWithAppId:app_id_string withUrl: url_string];
}

void enable_log(BOOL enable_log) {
    if (enable_log) {
        [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    }
}

void set_network_type(int type) {
    switch (type) {
        case NETWORK_TYPE_DEFAULT:
            [[ThinkingAnalyticsSDK sharedInstance]setNetworkType:TDNetworkTypeDefault];
            break;
        case NETWORK_TYPE_WIFI:
            [[ThinkingAnalyticsSDK sharedInstance]setNetworkType:TDNetworkTypeOnlyWIFI];
            break;
        case NETWORK_TYPE_ALL:
            [[ThinkingAnalyticsSDK sharedInstance]setNetworkType:TDNetworkTypeALL];
            break;
    }
}

void identify(const char *app_id, const char *unique_id) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSString *id_string = unique_id != NULL ? [NSString stringWithUTF8String:unique_id] : nil;
    [[ThinkingAnalyticsSDK sharedInstanceWithAppid:app_id_string] identify:id_string];
}

const char *get_distinct_id(const char *app_id) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSString *distinct_id =[[ThinkingAnalyticsSDK sharedInstanceWithAppid:app_id_string] getDistinctId];
    return strdup([distinct_id UTF8String]);
}

void login(const char *app_id, const char *account_id) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSString *id_string = account_id != NULL ? [NSString stringWithUTF8String:account_id] : nil;
    [[ThinkingAnalyticsSDK sharedInstanceWithAppid:app_id_string] login:id_string];
}

void logout(const char *app_id) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    [[ThinkingAnalyticsSDK sharedInstanceWithAppid:app_id_string] logout];
}

void track(const char *app_id, const char *event_name, const char *properties, long time_stamp_millis) {
    NSString *event_name_string = event_name != NULL ? [NSString stringWithUTF8String:event_name] : nil;
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;

    NSDictionary *properties_dict = nil;
    convertToDictionary(properties, &properties_dict);

    if (time_stamp_millis > 0) {
        NSDate *time = [NSDate dateWithTimeIntervalSince1970:time_stamp_millis / 1000.0];
        [[ThinkingAnalyticsSDK sharedInstanceWithAppid:app_id_string] track:event_name_string  properties:properties_dict time:time];
    } else {
        [[ThinkingAnalyticsSDK sharedInstanceWithAppid:app_id_string] track:event_name_string  properties:properties_dict];
    }
}

void flush(const char *app_id) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    if (app_id_string) {
        [[ThinkingAnalyticsSDK sharedInstanceWithAppid:app_id_string] flush];
    }
}

void set_super_properties(const char *app_id, const char *properties) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSDictionary *properties_dict = nil;
    convertToDictionary(properties, &properties_dict);
    if (properties_dict) {
        [[ThinkingAnalyticsSDK sharedInstanceWithAppid:app_id_string] setSuperProperties:properties_dict];
    }
}

void unset_super_property(const char *app_id, const char *property_name) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSString *property_name_string = property_name != NULL ? [NSString stringWithUTF8String:property_name] : nil;
    [[ThinkingAnalyticsSDK sharedInstanceWithAppid:app_id_string] unsetSuperProperty:property_name_string];
}

void clear_super_properties(const char *app_id) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    [[ThinkingAnalyticsSDK sharedInstanceWithAppid:app_id_string] clearSuperProperties];
}

const char *get_super_properties(const char *app_id) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSDictionary *property_dict = [[ThinkingAnalyticsSDK sharedInstanceWithAppid:app_id_string] currentSuperProperties];
    // nsdictionary --> nsdata
    NSData *data = [NSJSONSerialization dataWithJSONObject:property_dict options:kNilOptions error:nil];
    // nsdata -> nsstring
    NSString *jsonString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    return strdup([jsonString UTF8String]);
}

void time_event(const char *app_id, const char *event_name) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSString *event_name_string = event_name != NULL ? [NSString stringWithUTF8String:event_name] : nil;
    [[ThinkingAnalyticsSDK sharedInstanceWithAppid:app_id_string] timeEvent:event_name_string];
}

void user_set(const char *app_id, const char *properties) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSDictionary *properties_dict = nil;
    convertToDictionary(properties, &properties_dict);
    if (properties_dict) {
        [[ThinkingAnalyticsSDK sharedInstanceWithAppid:app_id_string] user_set:properties_dict];
    }
}

void user_set_once(const char *app_id, const char *properties) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSDictionary *properties_dict = nil;
    convertToDictionary(properties, &properties_dict);
    if (properties_dict) {
        [[ThinkingAnalyticsSDK sharedInstanceWithAppid:app_id_string] user_setOnce:properties_dict];
    }
}

void user_add(const char *app_id, const char *properties) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    NSDictionary *properties_dict = nil;
    convertToDictionary(properties, &properties_dict);
    if (properties_dict) {
        [[ThinkingAnalyticsSDK sharedInstanceWithAppid:app_id_string] user_add:properties_dict];
    }
}

void user_delete(const char *app_id) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    [[ThinkingAnalyticsSDK sharedInstanceWithAppid:app_id_string] user_delete];
}

const char *get_device_id() {
    NSString *distinct_id =[[ThinkingAnalyticsSDK sharedInstance] getDeviceId];
    return strdup([distinct_id UTF8String]);
}

void track_app_install(const char *app_id) {
    NSString *app_id_string = app_id != NULL ? [NSString stringWithUTF8String:app_id] : nil;
    [[ThinkingAnalyticsSDK sharedInstanceWithAppid:app_id_string] enableAutoTrack: ThinkingAnalyticsEventTypeAppInstall];
}
