#import "TGAcceleratedVideoView.h"

#import <SSignalKit/SSignalKit.h>

#import <AVFoundation/AVFoundation.h>

@interface TGAcceleratedVideoFrame : NSObject

@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, readonly) NSTimeInterval timestamp;

@end

@implementation TGAcceleratedVideoFrame

- (instancetype)initWithImage:(UIImage *)image timestamp:(NSTimeInterval)timestamp {
    self = [super init];
    if (self != nil) {
        _image = image;
        _timestamp = timestamp;
    }
    return self;
}

@end

@interface TGAcceleratedVideoFrameQueue : NSObject
{
    SQueue *_queue;
    
    NSUInteger _maxFrames;
    NSUInteger _fillFrames;
    NSTimeInterval _previousFrameTimestamp;
    
    TGAcceleratedVideoFrame *(^_requestFrame)();
    void (^_drawFrame)(TGAcceleratedVideoFrame *videoFrame, int32_t sessionId);
    
    NSMutableArray *_frames;
    
    STimer *_timer;
    
    int32_t _sessionId;
}

@end

@implementation TGAcceleratedVideoFrameQueue

- (instancetype)initWithRequestFrame:(TGAcceleratedVideoFrame *(^)())requestFrame drawFrame:(void (^)(TGAcceleratedVideoFrame *, int32_t sessionId))drawFrame {
    self = [super init];
    if (self != nil) {
        _queue = [[SQueue alloc] init];
        
        _maxFrames = 6;
        _fillFrames = 2;
        
        _requestFrame = [requestFrame copy];
        _drawFrame = [drawFrame copy];
        
        _frames = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dispatch:(void (^)())block {
    [_queue dispatch:block];
}

- (void)beginRequests:(int32_t)sessionId {
    [_queue dispatch:^{
        _sessionId = sessionId;
        [_timer invalidate];
        _timer = nil;
        
        [self checkQueue];
    }];
}

- (void)pauseRequests {
    [_queue dispatch:^{
        [_timer invalidate];
        _timer = nil;
        _previousFrameTimestamp = 0.0;
        [_frames removeAllObjects];
    }];
}

- (void)checkQueue {
    [_timer invalidate];
    _timer = nil;
    
    NSTimeInterval nextDelay = 1.0;
    
    if (_frames.count != 0) {
        TGAcceleratedVideoFrame *firstFrame = _frames[0];
        [_frames removeObjectAtIndex:0];
        
        if (firstFrame.timestamp <= _previousFrameTimestamp) {
            nextDelay = 0.05;
        } else {
            nextDelay = MIN(5.0, firstFrame.timestamp - _previousFrameTimestamp);
        }
        
        _previousFrameTimestamp = firstFrame.timestamp;
        
        if (firstFrame.timestamp <= DBL_EPSILON) {
            nextDelay = 0.0;
        } else {
            if (_drawFrame) {
                _drawFrame(firstFrame, _sessionId);
            }
        }
    }
    
    if (_frames.count <= _fillFrames) {
        while (_frames.count < _maxFrames) {
            TGAcceleratedVideoFrame *frame = nil;
            if (_requestFrame) {
                frame = _requestFrame();
            }
            
            if (frame == nil) {
                break;
            } else {
                [_frames addObject:frame];
            }
        }
    }
    
    __weak TGAcceleratedVideoFrameQueue *weakSelf = self;
    _timer = [[STimer alloc] initWithTimeout:nextDelay repeat:false completion:^{
        __strong TGAcceleratedVideoFrameQueue *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf checkQueue];
        }
    } queue:_queue];
    [_timer start];
}

@end

@interface TGAcceleratedVideoView () {
    UIImageView *_imageView;
    
    NSString *_path;
    
    TGAcceleratedVideoFrameQueue *_frameQueue;
    
    AVAssetReader *_reader;
    AVAssetReaderTrackOutput *_output;
    
    int32_t _sessionId;
}

@end

@implementation TGAcceleratedVideoView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _imageView = [[UIImageView alloc] init];
        _imageView.frame = self.bounds;
        
        [self addSubview:_imageView];
        
        __weak TGAcceleratedVideoView *weakSelf = self;
        _frameQueue = [[TGAcceleratedVideoFrameQueue alloc] initWithRequestFrame:^TGAcceleratedVideoFrame *{
            __strong TGAcceleratedVideoView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                return [strongSelf readNextFrame];
            }
            return nil;
        } drawFrame:^(TGAcceleratedVideoFrame *videoFrame, int32_t sessionId) {
            TGDispatchOnMainThread(^{
                __strong TGAcceleratedVideoView *strongSelf = weakSelf;
                if (strongSelf != nil && strongSelf->_sessionId == sessionId) {
                    strongSelf->_imageView.image = videoFrame.image;
                }
            });
        }];
    }
    return self;
}

- (void)dealloc {
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    _imageView.frame = self.bounds;
}

- (void)setPath:(NSString *)path {
    _imageView.image = nil;
    _sessionId++;
    
    [_frameQueue dispatch:^{
        _path = path;
        [_reader cancelReading];
        _reader = nil;
        _output = nil;
        
        if (_path.length == 0) {
            [_frameQueue pauseRequests];
        } else {
            [_frameQueue beginRequests:_sessionId];
        }
    }];
}

- (TGAcceleratedVideoFrame *)readNextFrame {
    for (int i = 0; i < 2; i++) {
        if (_reader == nil) {
            AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:_path] options:nil];
            AVAssetTrack *track = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
            if (track != nil) {
                _output = [[AVAssetReaderTrackOutput alloc] initWithTrack:track outputSettings:@{(NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)}];
                _output.alwaysCopiesSampleData = false;
                
                _reader = [[AVAssetReader alloc] initWithAsset:asset error:nil];
                [_reader addOutput:_output];
                
                if (![_reader startReading]) {
                    TGLog(@"Failed to begin reading video frames");
                    _reader = nil;
                }
            }
        }
        
        if (_reader != nil) {
            CMSampleBufferRef sampleVideo = NULL;
            if (([_reader status] == AVAssetReaderStatusReading) && (sampleVideo = [_output copyNextSampleBuffer])) {
                CMTime presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleVideo);
                NSTimeInterval presentationSeconds = CMTimeGetSeconds(presentationTime);
                TGAcceleratedVideoFrame *videoFrame = [[TGAcceleratedVideoFrame alloc] initWithImage:[self imageFromSampleBuffer:sampleVideo] timestamp:presentationSeconds];
                CFRelease(sampleVideo);
                
                return videoFrame;
            } else {
                [_reader cancelReading];
                _reader = nil;
                _output = nil;
            }
        }
    }
    
    return nil;
}

- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return image;
}

@end
