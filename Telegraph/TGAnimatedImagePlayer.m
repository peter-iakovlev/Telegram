/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGAnimatedImagePlayer.h"

#import "ASQueue.h"
#import "TGTimerTarget.h"

#import <ImageIO/ImageIO.h>

#import "TGImageBlur.h"

@interface TGAnimatedImagePlayer ()
{
    CGImageSourceRef _source;
    NSTimer *_timer;
    int _frameCount;
    int _currentFrame;
    NSMutableArray *_frameQueue;
    NSTimeInterval _frameDelay;
}

@end

@implementation TGAnimatedImagePlayer

- (instancetype)initWithDelegate:(id<TGAnimatedImagePlayerDelegate>)delegate path:(NSString *)path
{
    self = [super init];
    if (self != nil)
    {
        _delegate = delegate;
        _path = path;
    }
    return self;
}

- (void)dealloc
{
    CGImageSourceRef source = _source;
    _source = NULL;
    
    [_timer invalidate];
    
    [[TGAnimatedImagePlayer procesingQueue] dispatchOnQueue:^
    {
        if (source != NULL)
            CFRelease(source);
    }];
}

+ (ASQueue *)procesingQueue
{
    static ASQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        queue = [[ASQueue alloc] initWithName:"org.telegram.TGAnimatedImagePlayer_processingQueue"];
    });
    
    return queue;
}

- (void)play
{
    [[TGAnimatedImagePlayer procesingQueue] dispatchOnQueue:^
    {
        if (_source == NULL)
        {
            _source = CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:_path], NULL);
            
            if (_source != NULL)
            {
                _frameCount = CGImageSourceGetCount(_source);
                
                if (_frameCount > 0)
                {
                    _frameDelay = 1.0;
                    
                    CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(_source, 0, NULL);
                    if (properties != NULL)
                    {
                        CFDictionaryRef const gifProperties = CFDictionaryGetValue(properties, kCGImagePropertyGIFDictionary);
                        if (gifProperties)
                        {
                            NSNumber *number = (__bridge NSNumber *)CFDictionaryGetValue(gifProperties, kCGImagePropertyGIFUnclampedDelayTime);
                            if (number == NULL || [number doubleValue] < DBL_EPSILON)
                                number = (__bridge NSNumber *)CFDictionaryGetValue(gifProperties, kCGImagePropertyGIFDelayTime);
                            
                            if ([number doubleValue] > 0)
                                _frameDelay = [number doubleValue];
                        }
                        CFRelease(properties);
                    }
                    
                    _frameQueue = [[NSMutableArray alloc] init];
                    for (int i = 0; i < _frameCount; i++)
                    {
                        [_frameQueue addObject:[NSNull null]];
                    }
                    
                    _currentFrame = 0;
                    
                    NSTimeInterval frameDelay = _frameDelay;
                    TGDispatchOnMainThread(^
                    {
                        [_timer invalidate];
                        
                        _timer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(_processFrame) interval:frameDelay repeat:true runLoopModes:NSDefaultRunLoopMode];
                    });
                }
            }
        }
        else
        {
            NSTimeInterval frameDelay = _frameDelay;
            TGDispatchOnMainThread(^
            {
                if (_timer == nil)
                {
                    _timer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(_processFrame) interval:frameDelay repeat:true runLoopModes:NSDefaultRunLoopMode];
                }
            });
        }
    }];
}

- (void)_processFrame
{
    [[TGAnimatedImagePlayer procesingQueue] dispatchOnQueue:^
    {
        if (_source == NULL || _frameCount == 0)
            return;
        
        int frameIndex = _currentFrame % _frameCount;
        _currentFrame++;
        
        if ([_frameQueue[frameIndex] isKindOfClass:[NSNull class]])
            [self _loadFrame:frameIndex];
        
        if (![_frameQueue[frameIndex] isKindOfClass:[NSNull class]])
        {
            UIImage *image = _frameQueue[frameIndex];
            TGDispatchOnMainThread(^
            {
                id<TGAnimatedImagePlayerDelegate> delegate = _delegate;
                if ([delegate respondsToSelector:@selector(animationFrameReady:)])
                    [delegate animationFrameReady:image];
            });
        }
        
        [self _bufferAndUnloadFrames];
    }];
}

- (void)_loadFrame:(int)index
{
    if (_source == NULL || _frameCount == 0)
        return;
    
    CGImageRef image = CGImageSourceCreateImageAtIndex(_source, index, NULL);
    if (image != NULL)
    {
        UIImage *frameImage = [[UIImage alloc] initWithCGImage:image];
        CGImageRelease(image);
        
        if (_filter != nil)
            frameImage = _filter(frameImage);
        if (frameImage != NULL)
            _frameQueue[index] = frameImage;
    }
}

- (void)_bufferAndUnloadFrames
{
    NSMutableSet *requiredFrames = [[NSMutableSet alloc] init];
    
    int bufferCount = 1;
    
    for (int i = _currentFrame; i <= _currentFrame + bufferCount && i < _currentFrame + _frameCount; i++)
    {
        int frameIndex = i % _frameCount;
        [requiredFrames addObject:@(frameIndex)];
        
        if ([_frameQueue[frameIndex] isKindOfClass:[NSNull class]])
        {
            if ((_currentFrame % bufferCount == 0) || i == _currentFrame)
                [self _loadFrame:frameIndex];
        }
    }
    
    for (int i = 0; i < _frameCount; i++)
    {
        if (![requiredFrames containsObject:@(i)])
            _frameQueue[i] = [NSNull null];
    }
}

- (void)stop
{
    TGDispatchOnMainThread(^
    {
        [_timer invalidate];
        _timer = nil;
    });
    
    [[TGAnimatedImagePlayer procesingQueue] dispatchOnQueue:^
    {
        if (_source != NULL)
        {
            CFRelease(_source);
            _source = NULL;
        }
    }];
}

- (void)pause
{
    TGDispatchOnMainThread(^
    {
        [_timer invalidate];
        _timer = nil;
    });
}

@end
