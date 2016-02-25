#import "TGGifConverter.h"

#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

static const int32_t FPS = 600;

@implementation TGGifConverter

+ (SSignal *)convertGifToMp4:(NSData *)data {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        __block bool cancelled = false;
        SAtomic *assetWriterRef = [[SAtomic alloc] initWithValue:nil];
        
        [[SQueue concurrentDefaultQueue] dispatch:^{
            CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
            unsigned char *bytes = (unsigned char *)data.bytes;
            NSError* error = nil;
            
            if (!CGImageSourceGetStatus(source) == kCGImageStatusComplete) {
                CFRelease(source);
                [subscriber putError:nil];
                return;
            }
            
            size_t sourceWidth = bytes[6] + (bytes[7]<<8), sourceHeight = bytes[8] + (bytes[9]<<8);
            //size_t sourceFrameCount = CGImageSourceGetCount(source);
            __block size_t currentFrameNumber = 0;
            __block Float64 totalFrameDelay = 0.f;
                
            NSString *uuidString = nil;
            {
                CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
                uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
                CFRelease(uuid);
            }
            
            NSURL *outFilePath = [[NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:true] URLByAppendingPathComponent:[uuidString stringByAppendingPathExtension:@"mp4"]];
            
            AVAssetWriter* videoWriter = [[AVAssetWriter alloc] initWithURL: outFilePath
                                                                   fileType: AVFileTypeMPEG4
                                                                      error: &error];
            [assetWriterRef swap:videoWriter];
            if (error) {
                CFRelease(source);
                [subscriber putError:nil];
                return;
            }
            
            if (sourceWidth > 800 || sourceWidth == 0) {
                CFRelease(source);
                [subscriber putError:nil];
                return;
            }
            
            if (sourceHeight > 800 || sourceHeight == 0) {
                CFRelease(source);
                [subscriber putError:nil];
                return;
            }
            
            size_t totalFrameCount = CGImageSourceGetCount(source);
            
            if (totalFrameCount <= 0) {
                CFRelease(source);
                [subscriber putError:nil];
                return;
            }
            
            NSDictionary *videoCleanApertureSettings =
            @{
              AVVideoCleanApertureWidthKey: @((NSInteger)sourceWidth),
              AVVideoCleanApertureHeightKey: @((NSInteger)sourceHeight),
              AVVideoCleanApertureHorizontalOffsetKey: @10,
              AVVideoCleanApertureVerticalOffsetKey: @10
              };
            
            NSDictionary *videoAspectRatioSettings =
            @{
              AVVideoPixelAspectRatioHorizontalSpacingKey: @3,
              AVVideoPixelAspectRatioVerticalSpacingKey: @3
              };
            
            NSDictionary *codecSettings =
            @{
              AVVideoAverageBitRateKey: @(500000),
              AVVideoCleanApertureKey: videoCleanApertureSettings,
              AVVideoPixelAspectRatioKey: videoAspectRatioSettings
              };
            
            NSDictionary *videoSettings = @{AVVideoCodecKey : AVVideoCodecH264,
                                              AVVideoCompressionPropertiesKey: codecSettings,
                                            AVVideoWidthKey : @(sourceWidth),
                                            AVVideoHeightKey : @(sourceHeight)};
            
            AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType: AVMediaTypeVideo
                                                                                      outputSettings: videoSettings];
            videoWriterInput.expectsMediaDataInRealTime = YES;
            
            if (![videoWriter canAddInput: videoWriterInput]) {
                CFRelease(source);
                [subscriber putError:nil];
                return;
            }
            [videoWriter addInput: videoWriterInput];
            
            NSDictionary* attributes = @{
                                         (NSString*)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32ARGB),
                                         (NSString*)kCVPixelBufferWidthKey : @(sourceWidth),
                                         (NSString*)kCVPixelBufferHeightKey : @(sourceHeight),
                                         (NSString*)kCVPixelBufferCGImageCompatibilityKey : @YES,
                                         (NSString*)kCVPixelBufferCGBitmapContextCompatibilityKey : @YES
                                         };
            
            AVAssetWriterInputPixelBufferAdaptor* adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput: videoWriterInput sourcePixelBufferAttributes: attributes];
            
            [videoWriter startWriting];
            [videoWriter startSessionAtSourceTime: CMTimeMakeWithSeconds(totalFrameDelay, FPS)];
            
            while (!cancelled) {
                if(videoWriterInput.isReadyForMoreMediaData) {
                    NSDictionary* options = @{(NSString*)kCGImageSourceTypeIdentifierHint : (id)kUTTypeGIF};
                    CGImageRef imgRef = CGImageSourceCreateImageAtIndex(source, currentFrameNumber, (__bridge CFDictionaryRef)options);
                    if (imgRef) {
                        CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(source, currentFrameNumber, NULL);
                        CFDictionaryRef gifProperties = CFDictionaryGetValue(properties, kCGImagePropertyGIFDictionary);
                        
                        if( gifProperties ) {
                            CVPixelBufferRef pxBuffer = [self newBufferFrom: imgRef
                                                        withPixelBufferPool: adaptor.pixelBufferPool
                                                              andAttributes: adaptor.sourcePixelBufferAttributes];
                            if( pxBuffer ) {
                                float frameDuration = 0.1f;
                                NSNumber *delayTimeUnclampedProp = CFDictionaryGetValue(gifProperties, kCGImagePropertyGIFUnclampedDelayTime);
                                if (delayTimeUnclampedProp) {
                                    frameDuration = [delayTimeUnclampedProp floatValue];
                                } else {
                                    NSNumber *delayTimeProp = CFDictionaryGetValue(gifProperties, kCGImagePropertyGIFDelayTime);
                                    if(delayTimeProp) {
                                        frameDuration = [delayTimeProp floatValue];
                                    }
                                }
                                
                                if (frameDuration < 0.011f)
                                    frameDuration = 0.100f;
                                
                                CMTime time = CMTimeMakeWithSeconds(totalFrameDelay, FPS);
                                totalFrameDelay += frameDuration;
                                
                                if( ![adaptor appendPixelBuffer: pxBuffer withPresentationTime: time] ) {
                                    TGLog(@"Could not save pixel buffer!: %@", videoWriter.error);
                                    CFRelease(properties);
                                    CGImageRelease(imgRef);
                                    CVBufferRelease(pxBuffer);
                                    break;
                                }
                                
                                CVBufferRelease(pxBuffer);
                            }
                        }
                        
                        if( properties ) CFRelease(properties);
                        CGImageRelease(imgRef);
                        
                        currentFrameNumber++;
                    }
                    else {
                        //was no image returned -> end of file?
                        [videoWriterInput markAsFinished];
                        
                        void (^videoSaveFinished)(void) = ^{
                            [subscriber putNext:[outFilePath path]];
                            [subscriber putCompletion];
                        };
                        
                        [videoWriter finishWritingWithCompletionHandler:videoSaveFinished];
                        break;
                    }
                }
                else {
                    [NSThread sleepForTimeInterval:0.1];
                }
            };
            
            CFRelease(source);
        }];
        
        return [[SBlockDisposable alloc] initWithBlock:^{
            cancelled = true;
            [assetWriterRef swap:nil];
        }];
    }];
};

+ (CVPixelBufferRef) newBufferFrom: (CGImageRef) frame
               withPixelBufferPool: (CVPixelBufferPoolRef) pixelBufferPool
                     andAttributes: (NSDictionary*) attributes {
    NSParameterAssert(frame);
    
    size_t width = CGImageGetWidth(frame);
    size_t height = CGImageGetHeight(frame);
    size_t bpc = 8;
    CGColorSpaceRef colorSpace =  CGColorSpaceCreateDeviceRGB();
    
    CVPixelBufferRef pxBuffer = NULL;
    CVReturn status = kCVReturnSuccess;
    
    if( pixelBufferPool )
        status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferPool, &pxBuffer);
    else {
        status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef)attributes, &pxBuffer);
    }
    
    NSAssert(status == kCVReturnSuccess, @"Could not create a pixel buffer");
    
    CVPixelBufferLockBaseAddress(pxBuffer, 0);
    void *pxData = CVPixelBufferGetBaseAddress(pxBuffer);
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pxBuffer);
    
    
    CGContextRef context = CGBitmapContextCreate(pxData,
                                                 width,
                                                 height,
                                                 bpc,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    NSAssert(context, @"Could not create a context");
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), frame);
    
    CVPixelBufferUnlockBaseAddress(pxBuffer, 0);
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return pxBuffer;
}

@end
