#import <Foundation/Foundation.h>

@interface TDSqliteDataQueue : NSObject

+ (TDSqliteDataQueue *)sharedInstanceWithAppid:(NSString *)appid;
- (NSInteger)addObject:(id)obj withAppid:(NSString *)appid;
- (NSArray *)getFirstRecords:(NSUInteger)recordSize withAppid:(NSString *)appid;
- (BOOL)removeFirstRecords:(NSUInteger)recordSize withAppid:(NSString *)appid;
- (void)deleteAll:(NSString *)appid;
- (NSInteger)sqliteCountForAppid:(NSString *)appid;

@end

