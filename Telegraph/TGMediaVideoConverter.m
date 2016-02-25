#import "TGMediaVideoConverter.h"

#import <CommonCrypto/CommonDigest.h>
#import <sys/stat.h>
#import "MP4Atom.h"

#import "TGImageUtils.h"
#import "TGPhotoEditorUtils.h"

#import "TGVideoEditAdjustments.h"

@interface TGMediaVideoConversionPresetSettings : NSObject

@property (nonatomic, readonly) CGSize maximumResultSize;
@property (nonatomic, readonly) NSDictionary *videoSettings;

@property (nonatomic, readonly) bool hasAudio;
@property (nonatomic, readonly) NSDictionary *audioInputSettings;
@property (nonatomic, readonly) NSDictionary *audioOutputSettings;

+ (TGMediaVideoConversionPresetSettings *)settingsForPreset:(TGMediaVideoConversionPreset)preset;

@end

@implementation TGMediaVideoConverter

#pragma mark - Miscellaneous

+ (SQueue *)converterQueue
{
    static dispatch_once_t onceToken;
    static SQueue *queue;
    dispatch_once(&onceToken, ^
    {
        queue = [[SQueue alloc] init];
    });
    return queue;
}

+ (CGRect)_normalizeCropRect:(CGRect)cropRect
{
    return CGRectIntegral(cropRect);
}

+ (CGSize)_renderSizeWithCropSize:(CGSize)cropSize
{
    CGFloat blockSize = 16.0f;
    
    CGFloat renderWidth = CGFloor(cropSize.width / blockSize) * blockSize;
    CGFloat renderHeight = CGFloor(cropSize.height * renderWidth / cropSize.width);
    if (fmodf((float)renderHeight, (float)blockSize) != 0)
        renderHeight = CGFloor(cropSize.height / blockSize) * blockSize;
    return CGSizeMake(renderWidth, renderHeight);
}

+ (MP4Atom *)_findMdat:(MP4Atom *)atom
{
    if (atom == nil)
        return nil;
    
    if (atom.type == (OSType)'mdat')
        return atom;
    
    while (true)
    {
        MP4Atom *child = [atom nextChild];
        if (child == nil)
            break;
        
        MP4Atom *result = [self _findMdat:child];
        if (result != nil)
            return result;
    }
    
    return nil;
}

#pragma mark - 

+ (CGSize)_outputDimensionsForVideoTrack:(AVAssetTrack *)track presetSettings:(TGMediaVideoConversionPresetSettings *)settings adjustments:(TGMediaVideoEditAdjustments *)adjustments
{
    CGSize normalizedDimensions = CGRectApplyAffineTransform((CGRect){ CGPointZero, track.naturalSize }, track.preferredTransform).size;
    CGRect cropRect = [adjustments cropAppliedForAvatar:false] ? adjustments.cropRect : (CGRect){ CGPointZero, normalizedDimensions };
    
    CGSize outputDimensions = TGFitSize(cropRect.size, settings.maximumResultSize);
    if ([adjustments cropAppliedForAvatar:false])
        outputDimensions = [self _renderSizeWithCropSize:outputDimensions];
    
    if (TGOrientationIsSideward(adjustments.cropOrientation, NULL))
        outputDimensions = CGSizeMake(outputDimensions.height, outputDimensions.width);
    
    return outputDimensions;
}

#pragma mark - Signals

+ (SSignal *)convertSignalForAVAsset:(AVAsset *)avAsset preset:(TGMediaVideoConversionPreset)preset adjustments:(TGMediaVideoEditAdjustments *)adjustments
{
    NSURL *fileUrl = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%x.tmp", (int)arc4random()]]];
    
    NSError *error;
    AVAssetWriter *assetWriter = [AVAssetWriter assetWriterWithURL:fileUrl fileType:AVFileTypeMPEG4 error:&error];
    
    if (assetWriter == nil || error != nil)
        return [SSignal fail:error];
    
    AVAssetTrack *videoTrack = [avAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;

    CGSize outputVideoDimensions = [self _outputDimensionsForVideoTrack:videoTrack presetSettings:nil adjustments:adjustments];
    NSDictionary *videoSettings = nil;
    
    AVAssetWriterInput *videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    videoWriterInput.expectsMediaDataInRealTime = true;
    
    if (![assetWriter canAddInput:videoWriterInput])
        return [SSignal fail:nil];
    
    [assetWriter addInput:videoWriterInput];
    
    AVMutableComposition *composition = [[AVMutableComposition alloc] init];
    AVMutableVideoComposition *videoComposition = nil;
    AVAssetTrack *videoTrackToRead = nil;
    
    AVAssetTrack *audioTrack = [avAsset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    
//    [assetWriter startWriting];
//    [assetWriter startSessionAtSourceTime:kCMTimeZero];
//    [reader startReading];
//    
    
    
//    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
//    {
//        TGMediaVideoConverter *converter = [[TGMediaVideoConverter alloc] initWithAVAsset:avAsset preset:preset adjustments:adjustments];
//        
//        return [[SBlockDisposable alloc] initWithBlock:^
//        {
//            [converter cancel];
//        }];
//    }];
}

+ (SSignal *)hashSignalForAVAsset:(AVAsset *)avAsset adjustments:(TGMediaVideoEditAdjustments *)adjustments
{
    if ([adjustments trimApplied] || [adjustments cropAppliedForAvatar:false] || [adjustments rotationApplied])
        return [SSignal single:nil];
    
    NSURL *fileUrl = nil;
    NSData *timingData = nil;
    
    if ([avAsset isKindOfClass:[AVURLAsset class]])
    {
        fileUrl = ((AVURLAsset *)avAsset).URL;
    }
    else
    {
        AVComposition *composition = (AVComposition *)avAsset;
        AVCompositionTrack *videoTrack = nil;
        for (AVCompositionTrack *track in composition.tracks)
        {
            if ([track.mediaType isEqualToString:AVMediaTypeVideo])
            {
                videoTrack = track;
                break;
            }
        }
        
        if (videoTrack != nil)
        {
            AVCompositionTrackSegment *firstSegment = videoTrack.segments.firstObject;
            
            NSMutableData *timingData = [[NSMutableData alloc] init];
            for (AVCompositionTrackSegment *segment in videoTrack.segments)
            {
                CMTimeRange targetRange = segment.timeMapping.target;
                CMTimeValue startTime = targetRange.start.value / targetRange.start.timescale;
                CMTimeValue duration = targetRange.duration.value / targetRange.duration.timescale;
                [timingData appendBytes:&startTime length:sizeof(startTime)];
                [timingData appendBytes:&duration length:sizeof(duration)];
            }
            
            fileUrl = firstSegment.sourceURL;
        }
    }
    
    return [SSignal defer:^SSignal *
    {
        NSError *error;
        NSData *fileData = [NSData dataWithContentsOfURL:fileUrl options:NSDataReadingMappedIfSafe error:&error];
        if (error == nil)
            return [SSignal single:[self _hashForVideoWithFileData:fileData timingData:timingData]];
        else
            return [SSignal fail:error];
    }];
}

+ (NSString *)_hashForVideoWithFileData:(NSData *)fileData timingData:(NSData *)timingData
{
    const NSUInteger bufSize = 1024;
    const NSUInteger numberOfBuffersToRead = 32;
    uint8_t buf[bufSize];
    NSUInteger size = fileData.length;
    
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    
    CC_MD5_Update(&md5, &size, sizeof(size));
    const char *SDString = "SD";
    CC_MD5_Update(&md5, SDString, (CC_LONG)strlen(SDString));
    
    if (timingData != nil)
        CC_MD5_Update(&md5, timingData.bytes, (CC_LONG)timingData.length);
    
    for (NSUInteger i = 0; (i < size) && (i < bufSize * numberOfBuffersToRead); i += bufSize)
    {
        [fileData getBytes:buf range:NSMakeRange(i, bufSize)];
        CC_MD5_Update(&md5, buf, bufSize);
    }
    
    for (NSUInteger i = size - MIN(size, bufSize * numberOfBuffersToRead); i < size; i += bufSize)
    {
        [fileData getBytes:buf range:NSMakeRange(i, bufSize)];
        CC_MD5_Update(&md5, buf, bufSize);
    }
    
    unsigned char md5Buffer[16];
    CC_MD5_Final(md5Buffer, &md5);
    NSString *hash = [[NSString alloc] initWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", md5Buffer[0], md5Buffer[1], md5Buffer[2], md5Buffer[3], md5Buffer[4], md5Buffer[5], md5Buffer[6], md5Buffer[7], md5Buffer[8], md5Buffer[9], md5Buffer[10], md5Buffer[11], md5Buffer[12], md5Buffer[13], md5Buffer[14], md5Buffer[15]];
    
    return hash;
}

@end


@implementation TGMediaVideoConversionResult

@end


const CGSize TGMediaVideoConversionAnimationResultSize = { 320.0f, 320.0f };
const CGSize TGMediaVideoConversionCompressedResultSize = { 640.0f, 640.0f };

@implementation TGMediaVideoConversionPresetSettings

+ (TGMediaVideoConversionPresetSettings *)settingsForPreset:(TGMediaVideoConversionPreset)preset
{
    switch (preset)
    {
        case TGMediaVideoConversionPresetPassthrough:
        {
            
        }
            break;
            
        case TGMediaVideoConversionPresetCompressed:
        {
            
        }
            break;
            
        case TGMediaVideoConversionPresetAnimation:
        {
            
        }
            break;
            
        default:
            break;
    }
}

@end
