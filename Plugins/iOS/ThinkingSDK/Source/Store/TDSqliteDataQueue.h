#import <Foundation/Foundation.h>

@class TDEventRecord;

@interface TDSqliteDataQueue : NSObject

+ (TDSqliteDataQueue *)sharedInstanceWithAppid:(NSString *)appid;
- (NSInteger)addObject:(id)obj withAppid:(NSString *)appid;
- (NSArray<TDEventRecord *> *)getFirstRecords:(NSUInteger)recordSize withAppid:(NSString *)appid;
- (BOOL)removeFirstRecords:(NSUInteger)recordSize withAppid:(NSString *)appid;
- (void)deleteAll:(NSString *)appid;
- (NSInteger)sqliteCountForAppid:(NSString *)appid;
- (void)addColumnText:(NSString *)columnText;

- (NSArray *)upadteRecordIds:(NSArray<NSNumber *> *)recordIds;
- (BOOL)removeDataWithuids:(NSArray *)recordIDs;

@end

