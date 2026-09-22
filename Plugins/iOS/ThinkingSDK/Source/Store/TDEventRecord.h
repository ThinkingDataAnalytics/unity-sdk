//
//  TDEventRecord.h
//  ThinkingSDK
//
//  Created by wwango on 2022/1/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDEventRecord : NSObject

// Due to historical reasons, there is no event identifier stored in the database
// Record index when fetching data, update uuid before reporting data, remove data according to uuid after successful reporting
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, strong) NSNumber *index;

@property (nonatomic, copy, readonly) NSString *content;
@property (nonatomic, copy, readonly) NSDictionary *event;
@property (nonatomic, assign) BOOL encrypted;
@property (nonatomic, copy, readonly) NSString *ekey;


- (instancetype)initWithIndex:(NSNumber *)index content:(NSDictionary *)content;
- (instancetype)initWithContent:(NSDictionary *)content;

- (void)setSecretObject:(NSDictionary *)obj;

- (NSString *)flushContent:(NSString *)appid;
@end

NS_ASSUME_NONNULL_END
