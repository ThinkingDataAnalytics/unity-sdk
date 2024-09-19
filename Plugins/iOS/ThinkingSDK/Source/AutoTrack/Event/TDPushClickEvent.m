//
//  TAPushClickEvent.m
//  ThinkingSDK
//
//  Created by liulongbing on 2023/5/31.
//

#import "TDPushClickEvent.h"

@implementation TDPushClickEvent

- (NSMutableDictionary *)jsonObject {
    NSMutableDictionary *dict = [super jsonObject];
    self.properties[@"#ops_receipt_properties"] = self.ops;
    return dict;
}

@end
