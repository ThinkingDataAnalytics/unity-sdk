#import <Foundation/Foundation.h>

@interface NSData (TDGzip)

+ (NSData *)td_gzipData:(NSData *)dataa;

+ (NSData *)td_gunzipData:(NSData *)data;

@end
