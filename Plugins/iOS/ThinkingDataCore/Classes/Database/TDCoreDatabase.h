//
//  TDCoreDatabase.h
//  Pods-DevelopProgram
//
//  Created by 杨雄 on 2024/3/14.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDCoreDatabase : NSObject

+ (void)bindObject:(id)obj toColumn:(int)idx inStatement:(sqlite3_stmt*)pStmt;

+ (NSString *)stringForColumnIndex:(int)columnIdx inStatement:(sqlite3_stmt *)pStmt;

@end

NS_ASSUME_NONNULL_END
