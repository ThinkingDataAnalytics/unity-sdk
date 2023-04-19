//
//  TASessionIdPropertyPlugin.m
//  ThinkingSDK
//
//  Created by Charles on 28.11.22.
//

#import "TASessionIdPropertyPlugin.h"
#import "TDPresetProperties.h"
#import "TDPresetProperties+TDDisProperties.h"
#import "TAAppLifeCycle.h"
#import "TDFile.h"
#import "TDAppState.h"

@interface TASessionIdPropertyPlugin ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *properties;
@property (nonatomic, strong) TDFile *file;
@property (atomic, assign) long long sessionid;
@property (atomic, copy) NSString *sessionidString;
@end


@implementation TASessionIdPropertyPlugin

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
    if (![TDPresetProperties disableSessionID]) {
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
    if (![TDPresetProperties disableSessionID]) {
        @synchronized ([self class]) {
            if (!self.file) {
                self.file = [[TDFile alloc] initWithAppid:self.instanceToken];
            }
            self.sessionid = [self.file unarchiveSessionID];
            [self updateSessionId];
        }
        
    }
}

- (void)asyncGetPropertyCompletion:(TAPropertyPluginCompletion)completion {

}


@end
