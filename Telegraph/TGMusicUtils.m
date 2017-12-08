#import "TGMusicUtils.h"

#import <AVFoundation/AVFoundation.h>
#import <LegacyComponents/LegacyComponents.h>

@interface TGMusicID3ArtworkReader : NSObject

+ (UIImage *)albumArtworkForURL:(NSURL *)url;

@end

@implementation TGMusicUtils

+ (void)albumArtworkForURL:(NSURL *)url completion:(void (^)(UIImage *))completion
{
    if (completion == nil)
        return;
    
    AVAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    if (asset == nil)
    {
        completion(nil);
        return;
    }
    
    [asset loadValuesAsynchronouslyForKeys:@[@"commonMetadata"] completionHandler:^
    {
        NSArray *artworks = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata withKey:AVMetadataCommonKeyArtwork keySpace:AVMetadataKeySpaceCommon];
        if (artworks == nil)
        {
            completion(nil);
            return;
        }
        else
        {
            UIImage *image = nil;
            bool hasData = false;
            for (AVMetadataItem *item in artworks)
            {
                if ([item.keySpace isEqualToString:AVMetadataKeySpaceID3])
                {
                    if ([item.value respondsToSelector:@selector(objectForKey:)])
                    {
                        image = [UIImage imageWithData:[(id)item.value objectForKey:@"data"]];
                        hasData = true;
                    }
                    else if ([item.value isKindOfClass:[NSData class]])
                    {
                        image = [UIImage imageWithData:(id)item.value];
                        hasData = true;
                    }
                }
                else if ([item.keySpace isEqualToString:AVMetadataKeySpaceiTunes])
                    image = [UIImage imageWithData:(id)item.value];
            }
            
            if (image != nil)
            {
                CGSize screenSize = TGScreenSize();
                CGFloat screenSide = MIN(screenSize.width, screenSize.height);
                CGFloat scale = TGIsRetina() ? 1.7f : 1.0f;
                CGSize pixelSize = CGSizeMake(screenSide * scale, screenSide * scale);
                image = TGScaleImageToPixelSize(image, TGFitSize(CGSizeMake(image.size.width * image.scale, image.size.height * image.scale), pixelSize));
                completion(image);
            }
            else if (hasData)
            {
                image = [TGMusicID3ArtworkReader albumArtworkForURL:url];
                completion(image);
            }
            else
            {
                completion(nil);
            }
        }
    }];
}

@end

const uint8_t TGID3v2[5] = {0x49, 0x44, 0x33, 0x02, 0x00};
const uint8_t TGID3v3[5] = {0x49, 0x44, 0x33, 0x03, 0x00};
const NSUInteger TGID3VersionOffset = 3;
const NSUInteger TGID3SizeOffset = 6;
const NSUInteger TGID3TagOffset = 10;
const NSUInteger TGID3ArtOffset = 12;

const NSUInteger TGID3v2FrameOffset = 6;
const NSUInteger TGID3v3FrameOffset = 10;

const uint8_t TGID3v2Artwork[3] = {0x50, 0x49, 0x43};
const uint8_t TGID3v3Artwork[4] = {0x41, 0x50, 0x49, 0x43};

const uint8_t TGJPGMagic[3] = {0xff, 0xd8, 0xff};
const uint8_t TGPNGMagic[4] = {0x89, 0x50, 0x4e, 0x47};

#define BYTE                8
#define VERSION_OFFSET      3
#define TAG_SIZE_OFFSET     6
#define TAG_OFFSET          10
#define ART_FRAME_OFFSET    12
#define LYRICS_FRAME_OFFSET 11

#define V2_FRAME_OFFSET     6
#define V2_ALBUM            @[@((uint8)0x54), @((uint8)0x41), @((uint8)0x4C)]
#define V2_ARTIST           @[@((uint8)0x54), @((uint8)0x50), @((uint8)0x31)]
#define V2_HEADER           @[@((uint8)0x49), @((uint8)0x44), @((uint8)0x33), @((uint8)0x02), @((uint8)0x00), @((uint8)0x00)]
#define V2_LYRICS           @[@((uint8)0x55), @((uint8)0x4C), @((uint8)0x54)]
#define V2_TITLE            @[@((uint8)0x54), @((uint8)0x54), @((uint8)0x32)]

#define V3_FRAME_OFFSET     10
#define V3_ALBUM            @[@((uint8)0x54), @((uint8)0x41), @((uint8)0x4C), @((uint8)0x42)]
#define V3_ARTIST           @[@((uint8)0x54), @((uint8)0x50), @((uint8)0x45), @((uint8)0x31)]
#define V3_HEADER           @[@((uint8)0x49), @((uint8)0x44), @((uint8)0x33), @((uint8)0x03), @((uint8)0x00), @((uint8)0x00)]
#define V3_LYRICS           @[@((uint8)0x55), @((uint8)0x53), @((uint8)0x4C), @((uint8)0x54)]
#define V3_TITLE            @[@((uint8)0x54), @((uint8)0x49), @((uint8)0x54), @((uint8)0x32)]

@implementation TGMusicID3ArtworkReader

+ (UIImage *)albumArtworkForURL:(NSURL *)url
{
    NSData *data = [NSData dataWithContentsOfMappedFile:url.path];
    if (data.length < 4)
        return nil;
    
    const uint8_t *bytes = data.bytes;
    
    if (!(memcmp(bytes, TGID3v2, 5) == 0 || memcmp(bytes, TGID3v3, 5) == 0))
        return nil;
    
    uint8_t version = bytes[TGID3VersionOffset];
    uint32_t size = [self getSize:bytes];
    const uint8_t *ptr = data.bytes + TGID3TagOffset;
    
    uint32_t pos = 0;
    while (pos < size)
    {
        const uint8_t * const frameBytes = ptr + pos;
        uint32_t frameSize = [self frameSize:frameBytes version:version];
        
        if ([self isArtworkFrame:frameBytes version:version])
        {
            uint32_t frameOffset = [self frameOffsetForVersion:version];
            const uint8_t *ptr = frameBytes + frameOffset;
            
            bool isJPEG = false;
            uint32_t imageOffset = UINT32_MAX;
            for (uint32_t i = 0; i < frameSize - 4; i++)
            {
                if (memcmp(ptr + i, TGJPGMagic, 3) == 0)
                {
                    imageOffset = i;
                    isJPEG = true;
                    break;
                }
                else if (memcmp(ptr + i, TGPNGMagic, 4) == 0)
                {
                    imageOffset = i;
                    break;
                }
            }
            
            if (imageOffset != UINT32_MAX)
            {
                if (isJPEG)
                {
                    NSMutableData *jpegData = [[NSMutableData alloc] initWithCapacity:frameSize + 1024];
                    
                    uint8_t previousByte = 0xff;
                    uint32_t skippedBytes = 0;
                    
                    for (NSUInteger i = 0; i < frameSize - imageOffset + skippedBytes; i++)
                    {
                        uint8_t byte = (uint8_t)ptr[imageOffset + i];
                        
                        if (byte == 0x00 && previousByte == 0xff)
                            skippedBytes++;
                        else
                            [jpegData appendBytes:&byte length:1];
                        
                        if (byte == 0xd9 && previousByte == 0xff)
                            break;
                        
                        previousByte = byte;
                    }
                    
                    return [UIImage imageWithData:jpegData];
                }
                else
                {
                    NSData *artworkData = [[NSData alloc] initWithBytes:ptr + imageOffset length:frameSize - imageOffset];
                    return [UIImage imageWithData:artworkData];
                }
            }
        }
        else if (frameBytes[0] == 0x00 && frameBytes[1] == 0x00 && frameBytes[2] == 0x00)
        {
            break;
        }
        
        pos += frameSize;
    }
    
    return nil;
}

+ (uint32_t)getSize:(const uint8_t *)bytes
{
    uint32_t size = CFSwapInt32HostToBig(*(const uint32_t *)(bytes + TGID3SizeOffset));
    uint32_t b1 = (size & 0x7F000000) >> 3;
    uint32_t b2 = (size & 0x007F0000) >> 2;
    uint32_t b3 = (size & 0x00007F00) >> 1;
    uint32_t b4 =  size & 0x0000007F;
    return b1 + b2 + b3 + b4;
}

+ (uint32_t)frameSize:(const uint8_t *)framePtr version:(uint8_t)version
{
    uint8_t offset = version == 2 ? 2 : 4;
    uint32_t size = CFSwapInt32HostToBig(*(uint32_t *)(framePtr + offset));
    
    if (version == 2)
        size &= 0x00FFFFFF;
    
    return size + [self frameOffsetForVersion:version];
}

+ (bool)isArtworkFrame:(const uint8_t *)frame version:(uint8_t)version
{
    if (version == 2)
        return memcmp(frame, TGID3v2Artwork, 3) == 0;
        
    return memcmp(frame, TGID3v3Artwork, 4) == 0;
}

+ (uint32_t)frameOffsetForVersion:(uint8_t)version
{
    return version == 2 ? TGID3v2FrameOffset : TGID3v3FrameOffset;
}

@end
