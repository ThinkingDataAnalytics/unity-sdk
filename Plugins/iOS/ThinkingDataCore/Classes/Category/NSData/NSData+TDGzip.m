#import "NSData+TDGzip.h"
#import <zlib.h>
#import "TDCoreLog.h"

@implementation NSData (TDGzip)

+ (NSData *)td_gzipData:(NSData *)dataa {
    if (!dataa || [dataa length] == 0) {
        TDCORELOG(@"gzip error, return nil ");
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

+ (NSData *)td_gunzipData:(NSData *)compressedData {
    if ([compressedData length] == 0) {
        return compressedData;
    }
    NSUInteger full_length = [compressedData length];
    NSUInteger half_length = [compressedData length] / 2;
    NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
    BOOL done = NO;
    int status;
    z_stream strm;
    strm.next_in = (Bytef *)[compressedData bytes];
    strm.avail_in = (uint)[compressedData length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    if (inflateInit2(&strm, (15+32)) != Z_OK) return nil;
    while (!done) {
        // Make sure we have enough room and reset the lengths.
        if (strm.total_out >= [decompressed length]) {
            [decompressed increaseLengthBy: half_length];
        }
        // chadeltu 加了(Bytef *)
        strm.next_out = (Bytef *)[decompressed mutableBytes] + strm.total_out;
        strm.avail_out = (uint)[decompressed length] - (uint)(strm.total_out);
        // Inflate another chunk.
        status = inflate (&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END) {
            done = YES;
        } else if (status != Z_OK) {
            break;
        }
    }
    if (inflateEnd (&strm) != Z_OK) return nil;
    // Set real length.
    if (done) {
        [decompressed setLength: strm.total_out];
        return [NSData dataWithData: decompressed];
    } else {
        return nil;
    }
}

@end
