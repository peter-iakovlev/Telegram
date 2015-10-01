#import "NSData+GZip.h"

#import <zlib.h>

#import "NSData+GZip.h"

#import "lz4.h"

#define kMemoryChunkSize 1024

@implementation NSData (GZip)

- (NSData *)compressGZip
{
    NSUInteger length = [self length];
    int windowBits = 15 + 16; //Default + gzip header instead of zlib header
    int memLevel = 8; //Default
    int retCode;
    NSMutableData *result;
    z_stream stream;
    unsigned char output[kMemoryChunkSize];
    uInt gotBack;
    
    if ((length == 0) || (length > UINT_MAX)) //FIXME: Support 64 bit inputs
        return nil;
    
    bzero(&stream, sizeof(z_stream));
    stream.avail_in = (uInt)length;
    stream.next_in = (unsigned char*)[self bytes];
    
    retCode = deflateInit2(&stream, Z_BEST_COMPRESSION, Z_DEFLATED, windowBits, memLevel, Z_DEFAULT_STRATEGY);
    if(retCode != Z_OK)
    {
        NSLog(@"%s: deflateInit2() failed with error %i", __PRETTY_FUNCTION__, retCode);
        return nil;
    }
    
    result = [[NSMutableData alloc] initWithCapacity:(length / 4)];
    do
    {
        stream.avail_out = kMemoryChunkSize;
        stream.next_out = output;
        retCode = deflate(&stream, Z_FINISH);
        if((retCode != Z_OK) && (retCode != Z_STREAM_END))
        {
            NSLog(@"%s: deflate() failed with error %i", __PRETTY_FUNCTION__, retCode);
            deflateEnd(&stream);
            return nil;
        }
        gotBack = kMemoryChunkSize - stream.avail_out;
        if (gotBack > 0)
            [result appendBytes:output length:gotBack];
    } while (retCode == Z_OK);
    
    deflateEnd(&stream);
    
    return (retCode == Z_STREAM_END ? result : nil);
}

- (NSData *)decompressGZip
{
    NSUInteger length = [self length];
    int windowBits = 15 + 32; //Default + gzip header instead of zlib header
    int retCode;
    unsigned char output[kMemoryChunkSize];
    uInt gotBack;
    NSMutableData *result;
    z_stream stream;
    
    if ((length == 0) || (length > UINT_MAX)) //FIXME: Support 64 bit inputs
        return nil;
    
    bzero(&stream, sizeof(z_stream));
    stream.avail_in = (uInt)length;
    stream.next_in = (unsigned char*)[self bytes];
    
    retCode = inflateInit2(&stream, windowBits);
    if(retCode != Z_OK)
    {
        NSLog(@"%s: inflateInit2() failed with error %i", __PRETTY_FUNCTION__, retCode);
        return nil;
    }
    
    result = [NSMutableData dataWithCapacity:(length * 4)];
    do
    {
        stream.avail_out = kMemoryChunkSize;
        stream.next_out = output;
        retCode = inflate(&stream, Z_NO_FLUSH);
        if ((retCode != Z_OK) && (retCode != Z_STREAM_END))
        {
            NSLog(@"%s: inflate() failed with error %i", __PRETTY_FUNCTION__, retCode);
            inflateEnd(&stream);
            return nil;
        }
        gotBack = kMemoryChunkSize - stream.avail_out;
        if (gotBack > 0)
            [result appendBytes:output length:gotBack];
    } while( retCode == Z_OK);
    inflateEnd(&stream);
    
    return (retCode == Z_STREAM_END ? result : nil);
}

- (NSData *)compressLZ4
{
    uint8_t *bytes = malloc(4 + LZ4_compressBound((int)self.length));
    int32_t length = LZ4_compress(self.bytes, (char *)bytes + 4, (int)self.length);
    bytes = realloc(bytes, 4 + length);
    int32_t originalLength = (int32_t)self.length;
    memcpy(bytes, &originalLength, 4);
    return [[NSData alloc] initWithBytesNoCopy:bytes length:4 + length freeWhenDone:true];
}

- (NSData *)decompressLZ4
{
    int32_t length = 0;
    memcpy(&length, self.bytes, 4);
    uint8_t *bytes = malloc(length);
    if (LZ4_decompress_safe(((char *)self.bytes) + 4, (char *)bytes, (int)(self.length - 4), length) != length)
    {
        free(bytes);
        return nil;
    }
    
    return [[NSData alloc] initWithBytesNoCopy:bytes length:length freeWhenDone:true];
}

@end
