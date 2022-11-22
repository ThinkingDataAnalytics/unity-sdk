#import "NSData+TDGzip.h"
#import "zlib.h"
#import "TDLogging.h"

@implementation NSData (TDGzip)

+ (NSData *)td_gzipData:(NSData *)dataa {
    if (!dataa || [dataa length] == 0) {
        TDLogDebug(@"gzip error, return nil ");
        return nil;
    }
    
    z_stream zlibStreamStruct;
    zlibStreamStruct.zalloc = Z_NULL;
    zlibStreamStruct.zfree = Z_NULL;
    zlibStreamStruct.opaque = Z_NULL;
    zlibStreamStruct.total_out = 0;
    zlibStreamStruct.next_in = (Bytef *)[dataa bytes];
    zlibStreamStruct.avail_in = (uInt)[dataa length];
    
    int initError = deflateInit2(&zlibStreamStruct, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY);
    
    if (initError != Z_OK) return nil;
    
    NSMutableData *gzipData = [NSMutableData dataWithLength:[dataa length] * 1.01 + 21];
    int deflateStatus;
    
    do {
        zlibStreamStruct.next_out = [gzipData mutableBytes] + zlibStreamStruct.total_out;
        zlibStreamStruct.avail_out = (uInt)([gzipData length] - zlibStreamStruct.total_out);
        deflateStatus = deflate(&zlibStreamStruct, Z_FINISH);
    } while (deflateStatus == Z_OK);
    
    if (deflateStatus != Z_STREAM_END) return nil;
    deflateEnd(&zlibStreamStruct);
    [gzipData setLength:zlibStreamStruct.total_out];
    return gzipData;
}

@end
