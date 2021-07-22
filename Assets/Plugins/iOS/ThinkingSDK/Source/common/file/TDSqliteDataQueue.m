#import "TDSqliteDataQueue.h"
#import <sqlite3.h>

#import "TDLogging.h"
#import "TDJSONUtil.h"
#import "TDConfig.h"

@implementation TDSqliteDataQueue {
    sqlite3 *_database;
    NSInteger _allmessageCount;
}

- (void) closeDatabase {
    sqlite3_close(_database);
    sqlite3_shutdown();
}

- (void) dealloc {
    [self closeDatabase];
}

+ (TDSqliteDataQueue *)sharedInstanceWithAppid:(NSString *)appid {
    static TDSqliteDataQueue *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *filepath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"TDData-data.plist"];
        sharedInstance = [[self alloc] initWithPath:filepath withAppid:appid];
    });
    return sharedInstance;
}

- (id)initWithPath:(NSString *)filePath withAppid:(NSString *)appid {
    self = [super init];
    if (sqlite3_initialize() != SQLITE_OK) {
        return nil;
    }
    if (sqlite3_open_v2([filePath UTF8String], &_database, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, NULL) == SQLITE_OK ) {
        NSString *_sql = @"create table if not exists TDData (id INTEGER PRIMARY KEY AUTOINCREMENT, content TEXT, appid TEXT, creatAt INTEGER)";
        char *errorMsg;
        if (sqlite3_exec(_database, [_sql UTF8String], NULL, NULL, &errorMsg)==SQLITE_OK) {
        } else {
            return nil;
        }
        
        _allmessageCount = [self sqliteCount];
        
        if (![self isExistColumnInTable:@"appid"] || ![self isExistColumnInTable:@"creatAt"]) {
            [self addColumn:appid];
        } else if (_allmessageCount > 0) {
            [self delExpiredData];
        }
        
    } else {
        return nil;
    }
    return self;
}

- (void)addColumn:(NSString *)appid {
    int epochInterval = [[NSDate date] timeIntervalSince1970];
    NSString *query;
    if (appid.length > 0 && [appid isKindOfClass: [NSString class]])
        query = [NSString stringWithFormat:@"alter table TDData add 'appid' TEXT default \"%@\"", appid];
    else
        query = [NSString stringWithFormat:@"alter table TDData add 'appid' TEXT"];
    NSString *query2 = [NSString stringWithFormat:@"alter table TDData add 'creatAt' INTEGER default %d ", epochInterval];
    char *errMsg;
    @try {
        sqlite3_exec(_database, [query UTF8String], NULL, NULL, &errMsg);
        sqlite3_exec(_database, [query2 UTF8String], NULL, NULL, &errMsg);
    } @catch (NSException *exception) {
        TDLogError(@"addColumn: %@", exception);
    }
}

- (BOOL)isExistColumnInTable:(NSString *)column {
    sqlite3_stmt *statement = nil;
    NSString *sql = [NSString stringWithFormat:@"PRAGMA table_info(TDData)"];
    if (sqlite3_prepare_v2(_database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK ) {
        sqlite3_finalize(statement);
        return NO;
    }
    while (sqlite3_step(statement) == SQLITE_ROW) {
        NSString *columntem = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
        
        if ([column isEqualToString:columntem]) {
            sqlite3_finalize(statement);
            return YES;
        }
    }
    sqlite3_finalize(statement);
    return NO;
}

- (void)delExpiredData {
    NSTimeInterval oneDay = 24*60*60*1;
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow: -oneDay * [TDConfig expirationDays]];
    int expirationDate = [date timeIntervalSince1970];
    [self removeOldRecords:expirationDate];
}

- (NSInteger)addObject:(id)obj withAppid:(NSString *)appid {
    NSUInteger maxCacheSize = [TDConfig maxNumEvents];
    if (_allmessageCount >= maxCacheSize) {
        [self removeFirstRecords:100 withAppid:nil];
    }
    
    NSString *jsonStr = [TDJSONUtil JSONStringForObject:obj];
    if (!jsonStr) {
        return [self sqliteCountForAppid:appid];
    }
    NSTimeInterval epochInterval = [[NSDate date] timeIntervalSince1970];
    NSString *query = @"INSERT INTO TDData(content, appid, creatAt) values(?, ?, ?)";
    sqlite3_stmt *insertStatement;
    int rc;
    rc = sqlite3_prepare_v2(_database, [query UTF8String],-1, &insertStatement, nil);
    if (rc == SQLITE_OK) {
        sqlite3_bind_text(insertStatement, 1, [jsonStr UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(insertStatement, 2, [appid UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(insertStatement, 3, epochInterval);
        
        rc = sqlite3_step(insertStatement);
        if (rc == SQLITE_DONE) {
            _allmessageCount ++;
        }
    }
    
    sqlite3_finalize(insertStatement);
    return [self sqliteCountForAppid:appid];
}

- (NSArray *)getFirstRecords:(NSUInteger)recordSize withAppid:(NSString *)appid {
    if (_allmessageCount == 0) {
        return @[];
    }
    
    NSMutableArray *contentArray = [[NSMutableArray alloc] init];
    NSString *query = @"SELECT content FROM TDData where appid=? ORDER BY id ASC LIMIT ?";

    sqlite3_stmt *stmt = NULL;
    int rc = sqlite3_prepare_v2(_database, [query UTF8String], -1, &stmt, NULL);
    if (rc == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, [appid UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(stmt, 2, (int)recordSize);
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            char *jsonChar = (char *)sqlite3_column_text(stmt, 0);
            if (!jsonChar) {
                continue;
            }
            
            NSData *jsonData = [[NSString stringWithUTF8String:jsonChar] dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *eventDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                      options:NSJSONReadingMutableContainers
                                                                        error:&err];
            if (!err && [eventDict isKindOfClass:[NSDictionary class]]) {
                [contentArray addObject:eventDict];
            }
        }
    }
    sqlite3_finalize(stmt);
    return [NSArray arrayWithArray:contentArray];
}

- (BOOL)removeFirstRecords:(NSUInteger)recordSize withAppid:(NSString *)appid {
    NSString *query;
    
    if (appid.length == 0) {
        query = @"DELETE FROM TDData WHERE id IN (SELECT id FROM TDData ORDER BY id ASC LIMIT ?)";
    } else {
        query = @"DELETE FROM TDData WHERE id IN (SELECT id FROM TDData where appid=? ORDER BY id ASC LIMIT ?)";
    }
    
    sqlite3_stmt *stmt = NULL;
    int rc = sqlite3_prepare_v2(_database, [query UTF8String], -1, &stmt, NULL);
    
    if (rc == SQLITE_OK) {
        if (appid.length == 0) {
            sqlite3_bind_int(stmt, 1, (int)recordSize);
        } else {
            sqlite3_bind_text(stmt, 1, [appid UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(stmt, 2, (int)recordSize);
        }
        rc = sqlite3_step(stmt);
        if (rc != SQLITE_DONE && rc != SQLITE_OK) {
            sqlite3_finalize(stmt);
            return NO;
        }
    } else {
        sqlite3_finalize(stmt);
        return NO;
    }
    sqlite3_finalize(stmt);
    _allmessageCount = [self sqliteCount];
    return YES;
}

- (BOOL)removeOldRecords:(int)timestamp {
    NSString *query = @"DELETE FROM TDData WHERE creatAt<?";
    
    sqlite3_stmt *stmt = NULL;
    int rc = sqlite3_prepare_v2(_database, [query UTF8String], -1, &stmt, NULL);
    if (rc == SQLITE_OK) {
        sqlite3_bind_int(stmt, 1, (int)timestamp);
        sqlite3_step(stmt);
    }
    sqlite3_finalize(stmt);
    _allmessageCount = [self sqliteCount];
    return YES;
}

- (NSInteger)sqliteCount {
    return [self sqliteCountForAppid:nil];
}

- (NSInteger)sqliteCountForAppid:(NSString *)appid {
    NSString *query;
    NSInteger count = 0;
    if (appid == nil) {
        query = @"select count(*) from TDData";
    } else {
        query = @"select count(*) from TDData where appid=? ";
    }
    
    sqlite3_stmt *stmt = NULL;
    int rc = sqlite3_prepare_v2(_database, [query UTF8String], -1, &stmt, NULL);
    
    if (rc == SQLITE_OK) {
        if (appid.length > 0) {
            sqlite3_bind_text(stmt, 1, [appid UTF8String], -1, SQLITE_TRANSIENT);
        }
        if (sqlite3_step(stmt) == SQLITE_ROW) {
            count = sqlite3_column_int(stmt, 0);
        }
    }
    
    sqlite3_finalize(stmt);
    return count;
}

- (void)deleteAll:(NSString *)appid {
    if ([appid isKindOfClass:[NSString class]] && appid.length > 0) {
        NSString *query = @"DELETE FROM TDData where appid=? ";
        
        sqlite3_stmt *stmt = NULL;
        int rc = sqlite3_prepare_v2(_database, [query UTF8String], -1, &stmt, NULL);
        if (rc == SQLITE_OK) {
            sqlite3_bind_text(stmt, 1, [appid UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_step(stmt);
        }
        sqlite3_finalize(stmt);
        
        _allmessageCount = [self sqliteCount];
    }
}

@end
