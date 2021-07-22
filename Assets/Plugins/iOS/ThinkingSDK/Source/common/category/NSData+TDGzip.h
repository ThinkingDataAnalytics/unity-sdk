#import <Foundation/Foundation.h>

@interface NSData (TDGzip)

+ (NSData *)gzipData:(NSData *)pUncompressedData;

@end
