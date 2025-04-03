//
//  TASessionIdPropertyPlugin.m
//  ThinkingSDK
//
//  Created by Charles on 28.11.22.
//

#import "TDSessionIdPropertyPlugin.h"
#import "TDPresetProperties.h"
#import "TDAppLifeCycle.h"
#import "TDFile.h"
#import "TDAppState.h"

#if __has_include(<ThinkingDataCore/TDCorePresetDisableConfig.h>)
#import <ThinkingDataCore/TDCorePresetDisableConfig.h>
#else
#import "TDCorePresetDisableConfig.h"
#endif

@interface TDSessionIdPropertyPlugin ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *properties;
@property (nonatomic, strong) TDFile *file;
@property (atomic, assign) long long sessionid;
@property (atomic, copy) NSString *sessionidString;
@end


@implementation TDSessionIdPropertyPlugin

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.properties = [NSMutableDictionary dictionary];
        
    }
    return self;
}

- (void)updateSessionId {
#if TARGET_OS_IOS
    if (![TDCorePresetDisableConfig disableSessionID]) {
        @synchronized ([self class]) {
            self.sessionid ++;
            self.sessionidString = [NSString stringWithFormat:@"%@_%lld", [NSUUID UUID].UUIDString, self.sessionid];
            [self.file archiveSessionID:self.sessionid];
            self.properties[@"#session_id"] = self.sessionidString;
        }
    }
#endif
}

- (void)start {
    if (![TDCorePresetDisableConfig disableSessionID]) {
        @synchronized ([self class]) {
            if (!self.file) {
                self.file = [[TDFile alloc] initWithAppid:self.instanceToken];
            }
            self.sessionid = [self.file unarchiveSessionID];
            [self updateSessionId];
        }
        
    }
}

- (void)asyncGetPropertyCompletion:(TDPropertyPluginCompletion)completion {
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    
    if (completion) {
        completion(mutableDict);
    }
}


@end
