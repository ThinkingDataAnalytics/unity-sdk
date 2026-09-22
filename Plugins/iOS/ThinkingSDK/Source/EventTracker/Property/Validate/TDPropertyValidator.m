//
//  TDPropertyValidator.m
//  Adjust
//
//  Created by Yangxiongon 2022/6/10.
//

#import "TDPropertyValidator.h"
#import "NSString+TDProperty.h"
#import "TDPropertyDefaultValidator.h"

@implementation TDPropertyValidator

/// Custom attribute name format validation
static NSString *const kTANormalTrackProperNameValidateRegularExpression = @"^([a-zA-Z][a-zA-Z\\d_]*|\\#(ops_push_status|ops_push_id|ops_task_id|client_user_id|ops_trigger_time|ops_exp_group_id|ops_actual_push_time|ops_receipt_properties|ops_risk_type|rcc_pull_result))$";
/// Custom attribute name regularization
static NSRegularExpression *_regexForNormalTrackValidateKey;

/// Automatic collection, custom attribute name format validation. All automatic collection of custom attributes needs to meet the following rules
static NSString *const kTAAutoTrackProperNameValidateRegularExpression = @"^([a-zA-Z][a-zA-Z\\d_]{0,49}|\\#(resume_from_background|app_crashed_reason|screen_name|referrer|title|url|element_id|element_type|element_content|element_position|background_duration|start_reason))$";

static NSRegularExpression *_regexForAutoTrackValidateKey;

+ (void)validateEventOrPropertyName:(NSString *)name withError:(NSError *__autoreleasing  _Nullable *)error {
    if (!name) {
        NSString *errorMsg = @"Property key or Event name is empty";
        TDLogError(errorMsg);
        *error = TAPropertyError(10003, errorMsg);
        return;
    }
    if (![name isKindOfClass:NSString.class]) {
        NSString *errorMsg = [NSString stringWithFormat:@"Property key or Event name is not NSString: [%@]", name];
        TDLogError(errorMsg);
        *error = TAPropertyError(10007, errorMsg);
        return;
    }
    
    [name ta_validatePropertyKeyWithError:error];
}

+ (void)validateBaseEventPropertyKey:(NSString *)key value:(NSString *)value error:(NSError **)error {
    
    if (![key conformsToProtocol:@protocol(TAPropertyKeyValidating)]) {
        NSString *errMsg = [NSString stringWithFormat:@"The property KEY must be NSString. got: %@ %@", [key class], key];
        TDLogError(errMsg);
        *error = TAPropertyError(10001, errMsg);
        return;
    }
    [(id <TAPropertyKeyValidating>)key ta_validatePropertyKeyWithError:error];
    if (*error) {
        return;
    }

    
    if (![value conformsToProtocol:@protocol(TDPropertyValueValidating)]) {
        NSString *errMsg = [NSString stringWithFormat:@"Property value must be type NSString, NSNumber, NSDate, NSDictionary or NSArray. got: %@ %@. ", [value class], value];
        TDLogError(errMsg);
        *error = TAPropertyError(10002, errMsg);
        return;
    }
    [(id <TDPropertyValueValidating>)value ta_validatePropertyValueWithError:error];
}

+ (void)validateNormalTrackEventPropertyKey:(NSString *)key value:(NSString *)value error:(NSError **)error {
    [self validateBaseEventPropertyKey:key value:value error:error];
    if (*error) {
        return;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _regexForNormalTrackValidateKey = [NSRegularExpression regularExpressionWithPattern:kTANormalTrackProperNameValidateRegularExpression options:NSRegularExpressionCaseInsensitive error:nil];
    });
    if (!_regexForNormalTrackValidateKey) {
        NSString *errorMsg = @"Property Key validate regular expression init failed";
        TDLogError(errorMsg);
        *error = TAPropertyError(10004, errorMsg);
        return;
    }
    NSRange range = NSMakeRange(0, key.length);
    if ([_regexForNormalTrackValidateKey numberOfMatchesInString:key options:0 range:range] < 1) {
        NSString *errorMsg = [NSString stringWithFormat:@"Property Key or Event name: [%@] is invalid.", key];
        TDLogError(errorMsg);
        *error = TAPropertyError(10005, errorMsg);
        return;
    }
}

+ (void)validateAutoTrackEventPropertyKey:(NSString *)key value:(NSString *)value error:(NSError **)error {
    [self validateBaseEventPropertyKey:key value:value error:error];
    if (*error) {
        return;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _regexForAutoTrackValidateKey = [NSRegularExpression regularExpressionWithPattern:kTAAutoTrackProperNameValidateRegularExpression options:NSRegularExpressionCaseInsensitive error:nil];
    });
    if (!_regexForAutoTrackValidateKey) {
        NSString *errorMsg = @"Property Key validate regular expression init failed";
        TDLogError(errorMsg);
        *error = TAPropertyError(10004, errorMsg);
        return;
    }
    NSRange range = NSMakeRange(0, key.length);
    if ([_regexForAutoTrackValidateKey numberOfMatchesInString:key options:0 range:range] < 1) {
        NSString *errorMsg = [NSString stringWithFormat:@"Property Key or Event name: [%@] is invalid.", key];
        TDLogError(errorMsg);
        *error = TAPropertyError(10005, errorMsg);
        return;
    }
}

+ (NSMutableDictionary *)validateProperties:(NSDictionary *)properties {
    return [self validateProperties:properties validator:[[TDPropertyDefaultValidator alloc] init]];
}

+ (NSMutableDictionary *)validateProperties:(NSDictionary *)properties validator:(id<TDEventPropertyValidating>)validator {
    if (![properties isKindOfClass:[NSDictionary class]] || ![validator conformsToProtocol:@protocol(TDEventPropertyValidating)]) {
        return nil;
    }
    
    for (id key in properties) {
        NSError *error = nil;
        id value = properties[key];
        
        
        [validator ta_validateKey:key value:value error:&error];
    }
    return [properties copy];
}

@end
