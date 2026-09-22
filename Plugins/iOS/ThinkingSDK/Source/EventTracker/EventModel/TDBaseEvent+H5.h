//
//  TDBaseEvent+H5.h
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/19.
//

#import "TDBaseEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface TDBaseEvent (H5)
@property (nonatomic, copy) NSString *h5TimeString;
@property (nonatomic, strong) NSNumber *h5ZoneOffSet;

@end

NS_ASSUME_NONNULL_END
