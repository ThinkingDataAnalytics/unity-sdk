//
//  TDEventRecord.h
//  ThinkingSDK
//
//  Created by wwango on 2022/1/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDEventRecord : NSObject

// 由于历史原因，存入数据库时是没有存事件标识的
// 取数据的时记录index，上报数据前会更新uuid，在上报成功后，根据uuid移除数据
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, strong) NSNumber *index;

@property (nonatomic, copy, readonly) NSString *content;
@property (nonatomic, copy, readonly) NSDictionary *event;
@property (nonatomic, assign) BOOL encrypted;
@property (nonatomic, copy, readonly) NSString *ekey;


- (instancetype)initWithIndex:(NSNumber *)index content:(NSDictionary *)content;
- (instancetype)initWithContent:(NSDictionary *)content;

// 设置加密字典
- (void)setSecretObject:(NSDictionary *)obj;

- (NSString *)flushContent:(NSString *)appid;
@end

NS_ASSUME_NONNULL_END
