//
//  UIImage+WebP.m
//  iOS-WebP
//
//  Created by Sean Ooi on 12/21/13.
//  Copyright (c) 2013 Sean Ooi. All rights reserved.
//

#import "UIImage+WebP.h"

#import "NSData+GZip.h"

#import <WebP/decode.h>
#import <WebP/encode.h>

@implementation UIImage (WebP)

#pragma mark - Private methods

static int32_t compressedMagic = 0x456ba41;

+ (UIImage *)convertFromWebP:(NSString *)filePath compressedData:(__autoreleasing NSData **)compressedData error:(NSError **)error
{
    // If passed `filepath` is invalid, return nil to caller and log error in console
    NSError *dataError = nil;;
    NSData *imgData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&dataError];
    if(dataError != nil) {
        NSLog(@"imageFromWebP: error: %@", dataError.localizedDescription);
        return nil;
    }
    
    // `WebPGetInfo` weill return image width and height
    int width = 0, height = 0;
    if(!WebPGetInfo([imgData bytes], [imgData length], &width, &height)) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Header formatting error." forKey:NSLocalizedDescriptionKey];
        if(error != NULL)
            *error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@.errorDomain",  [[NSBundle mainBundle] bundleIdentifier]] code:-101 userInfo:errorDetail];
        return nil;
    }
    
    const struct { int width, height; } targetContextSize = { width, height};
    
    size_t targetBytesPerRow = ((4 * (int)targetContextSize.width) + 15) & (~15);
    
    void *targetMemory = malloc((int)(targetBytesPerRow * targetContextSize.height));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
    
    CGContextRef targetContext = CGBitmapContextCreate(targetMemory, (int)targetContextSize.width, (int)targetContextSize.height, 8, targetBytesPerRow, colorSpace, bitmapInfo);
    
    UIGraphicsPushContext(targetContext);
    
    CGColorSpaceRelease(colorSpace);
    
    //TG_TIMESTAMP_DEFINE(webp)
    if (WebPDecodeBGRAInto(imgData.bytes, imgData.length, targetMemory, targetBytesPerRow * targetContextSize.height, (int)targetBytesPerRow) == NULL)
    {
        TGLog(@"error decoding webp");
    }
    //TG_TIMESTAMP_MEASURE(webp)
    
    for (int y = 0; y < targetContextSize.height; y++)
    {
        for (int x = 0; x < targetContextSize.width; x++)
        {
            uint32_t *color = ((uint32_t *)&targetMemory[y * targetBytesPerRow + x * 4]);
            
            uint32_t a = (*color >> 24) & 0xff;
            uint32_t r = ((*color >> 16) & 0xff) * a;
            uint32_t g = ((*color >> 8) & 0xff) * a;
            uint32_t b = (*color & 0xff) * a;
            
            r = (r + 1 + (r >> 8)) >> 8;
            g = (g + 1 + (g >> 8)) >> 8;
            b = (b + 1 + (b >> 8)) >> 8;
            
            *color = (a << 24) | (r << 16) | (g << 8) | b;
        }
        
        for (size_t i = y * targetBytesPerRow + targetContextSize.width * 4; i < (targetBytesPerRow >> 2); i++)
        {
            *((uint32_t *)&targetMemory[i]) = 0;
        }
    }
    
    UIGraphicsPopContext();
    
    if (compressedData != NULL)
    {
        NSData *gzippedData = [[[NSData alloc] initWithBytesNoCopy:targetMemory length:(int)(targetBytesPerRow * targetContextSize.height) freeWhenDone:false] compressLZ4];
        NSMutableData *compressed = [[NSMutableData alloc] init];
        int32_t magic = compressedMagic;
        [compressed appendBytes:&magic length:4];
        [compressed appendBytes:&width length:4];
        [compressed appendBytes:&height length:4];
        [compressed appendData:gzippedData];
        *compressedData = compressed;
    }
    
    CGImageRef bitmapImage = CGBitmapContextCreateImage(targetContext);
    UIImage *image = [[UIImage alloc] initWithCGImage:bitmapImage scale:1.0f orientation:UIImageOrientationUp];
    CGImageRelease(bitmapImage);
    
    CGContextRelease(targetContext);
    free(targetMemory);
    
    return image;
}

+ (UIImage *)convertFromGZippedData:(NSString *)filePath size:(CGSize)__unused size
{
    //TG_TIMESTAMP_DEFINE(gzip)
    NSData *compressedData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:nil];
    if (compressedData == nil || compressedData.length < 12)
        return nil;
    int32_t magic = 0;
    int width = 0;
    int height = 0;
    [compressedData getBytes:&magic range:NSMakeRange(0, 4)];
    if (magic != compressedMagic)
        return nil;
    [compressedData getBytes:&width range:NSMakeRange(4, 4)];
    [compressedData getBytes:&height range:NSMakeRange(8, 4)];
    NSData *data = [[compressedData subdataWithRange:NSMakeRange(12, compressedData.length - 12)] decompressLZ4];
    compressedData = nil;
    
    const struct { int width, height; } targetContextSize = { width, height};
    
    size_t targetBytesPerRow = ((4 * (int)targetContextSize.width) + 15) & (~15);
    
    int memorySize = (int)(targetBytesPerRow * targetContextSize.height);
    
    if (memorySize != (int)data.length)
    {
        return nil;
    }
    
    void *targetMemory = (void *)data.bytes;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
    
    CGContextRef targetContext = CGBitmapContextCreate(targetMemory, (int)targetContextSize.width, (int)targetContextSize.height, 8, targetBytesPerRow, colorSpace, bitmapInfo);
    
    CGImageRef bitmapImage = CGBitmapContextCreateImage(targetContext);
    UIImage *image = [[UIImage alloc] initWithCGImage:bitmapImage scale:1.0f orientation:UIImageOrientationUp];
    CGImageRelease(bitmapImage);
    
    CGContextRelease(targetContext);
    //TG_TIMESTAMP_MEASURE(gzip)
    
    return image;
}

#pragma mark - Error statuses

+ (NSString *)statusForVP8Code:(VP8StatusCode)code
{
    NSString *errorString;
    switch (code) {
        case VP8_STATUS_OUT_OF_MEMORY:
            errorString = @"OUT_OF_MEMORY";
            break;
        case VP8_STATUS_INVALID_PARAM:
            errorString = @"INVALID_PARAM";
            break;
        case VP8_STATUS_BITSTREAM_ERROR:
            errorString = @"BITSTREAM_ERROR";
            break;
        case VP8_STATUS_UNSUPPORTED_FEATURE:
            errorString = @"UNSUPPORTED_FEATURE";
            break;
        case VP8_STATUS_SUSPENDED:
            errorString = @"SUSPENDED";
            break;
        case VP8_STATUS_USER_ABORT:
            errorString = @"USER_ABORT";
            break;
        case VP8_STATUS_NOT_ENOUGH_DATA:
            errorString = @"NOT_ENOUGH_DATA";
            break;
        default:
            errorString = @"UNEXPECTED_ERROR";
            break;
    }
    return errorString;
}
@end
