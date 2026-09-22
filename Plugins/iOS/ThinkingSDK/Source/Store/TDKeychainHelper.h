#import <Foundation/Foundation.h>

@interface TDKeychainHelper : NSObject

+ (void)saveInstallTimes:(NSString *)string;
+ (NSString *)readInstallTimes;

@end
