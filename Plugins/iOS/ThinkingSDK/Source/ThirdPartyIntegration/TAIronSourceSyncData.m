//
//  TAIronSourceSyncData.m
//  ThinkingSDK
//
//  Created by wwango on 2022/2/16.
//

#import "TAIronSourceSyncData.h"

@implementation TAIronSourceSyncData

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

static id _td_last_IronSource_delegate;

- (void)syncThirdData:(id<TAThinkingTrackProtocol>)taInstance {
    
    [super syncThirdData:taInstance];
    
    if (self.isSwizzleMethod) return;
    
    Class class = NSClassFromString(@"IronSource");
    NSString *oriSELString = @"addImpressionDataDelegate:";
    SEL newSel = NSSelectorFromString([NSString stringWithFormat:@"td_%@", oriSELString]);
    IMP newIMP = imp_implementationWithBlock(^(id _self, id delegate) {
        if ([_self respondsToSelector:newSel]) {
            [_self performSelector:newSel withObject:delegate];
            _td_last_IronSource_delegate = delegate;
        }
        
        id class1 = delegate;
        NSString *oriSELString1 = @"impressionDataDidSucceed:";
        SEL newSel1 = NSSelectorFromString([NSString stringWithFormat:@"td_%@", oriSELString1]);
        IMP newIMP1 = imp_implementationWithBlock(^(id _self1, id impressionData) {
            if ([_self1 respondsToSelector:newSel1]) {
                [_self1 performSelector:newSel1 withObject:impressionData];
            }

            NSDictionary *all_data;
            SEL sel = NSSelectorFromString(@"all_data");
            if ([impressionData respondsToSelector:sel]) {
                all_data = [impressionData performSelector:sel];
            }
            
            if (_td_last_IronSource_delegate == _self1) {
                [self.taInstance track:@"ta_ironSource_callback" properties:all_data];
            }
        });
        __td_td_swizzleWithOriSELStr(class1, oriSELString1, newSel1, newIMP1);
    });
    
    __td_td__swizzleWithClassMethod(class, oriSELString, newSel, newIMP);
    
    self.isSwizzleMethod = YES;
}

#pragma clang diagnostic pop

@end

