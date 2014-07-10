/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGImageView.h"

#import "TGImageManager.h"
#import <MTProtoKit/MTTime.h>

NSString *TGImageViewOptionKeepCurrentImageAsPlaceholder = @"TGImageViewOptionKeepCurrentImageAsPlaceholder";
NSString *TGImageViewOptionEmbeddedImage = @"TGImageViewOptionEmbeddedImage";
NSString *TGImageViewOptionSynchronous = @"TGImageViewOptionSynchronous";

@interface TGImageView ()
{
    id _loadToken;
    int _version;
    
    UIImageView *_transitionOverlayView;
}

@end

@implementation TGImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
    }
    return self;
}

- (void)dealloc
{
    if (_loadToken != nil)
        [[TGImageManager instance] cancelTaskWithId:_loadToken];
}

- (void)loadUri:(NSString *)uri withOptions:(NSDictionary *)__unused options
{
    _version++;
    
    UIImage *image = nil;
    
    if (options[TGImageViewOptionEmbeddedImage] != nil)
        image = options[TGImageViewOptionEmbeddedImage];
    else
        image = [[TGImageManager instance] loadImageSyncWithUri:uri canWait:[options[TGImageViewOptionSynchronous] boolValue] decode:true];
    
    if (image != nil)
        [self _commitImage:image loadTime:0.0];
    else
    {
        if (![options[TGImageViewOptionKeepCurrentImageAsPlaceholder] boolValue])
        {
            UIImage *placeholderImage = [[TGImageManager instance] loadAttributeSyncForUri:uri attribute:@"placeholder"];
            if (placeholderImage != nil)
                [self _commitImage:placeholderImage loadTime:0.0];
        }
        
        MTAbsoluteTime loadStartTime = MTAbsoluteSystemTime();
        
        __weak TGImageView *weakSelf = self;
        int version = _version;
        _loadToken = [[TGImageManager instance] beginLoadingImageAsyncWithUri:uri decode:true progress:nil completion:^(UIImage *image)
        {
            TGDispatchOnMainThread(^
            {
                __strong TGImageView *strongSelf = weakSelf;
                if (strongSelf != nil && strongSelf->_version == version)
                    [strongSelf _commitImage:image loadTime:(NSTimeInterval)(MTAbsoluteSystemTime() - loadStartTime)];
                else
                    TGLog(@"[TGImageView _commitImage version mismatch]");
            });
        }];
    }
}

- (void)_commitImage:(UIImage *)image loadTime:(NSTimeInterval)loadTime
{
    NSTimeInterval transitionDuration = 0.0;
    
    if (loadTime > DBL_EPSILON)
        transitionDuration = 0.16;
    
    [self performTransitionToImage:image duration:transitionDuration];
}

- (void)reset
{
    _version++;
    
    if (_loadToken != nil)
    {
        [[TGImageManager instance] cancelTaskWithId:_loadToken];
        _loadToken = nil;
    }
    
    [self _commitImage:nil loadTime:0.0];
}

- (void)performTransitionToImage:(UIImage *)image duration:(NSTimeInterval)duration
{
    if (self.image != nil && duration > DBL_EPSILON)
    {
        if (_transitionOverlayView == nil)
            _transitionOverlayView = [[UIImageView alloc] init];
        
        _transitionOverlayView.frame = self.bounds;
        [self insertSubview:_transitionOverlayView atIndex:0];
        
        _transitionOverlayView.image = self.image;
        _transitionOverlayView.alpha = 1.0;
        
        [UIView animateWithDuration:duration animations:^
        {
            _transitionOverlayView.alpha = 0.0;
        } completion:^(__unused BOOL finished)
        {
            _transitionOverlayView.image = nil;
            [_transitionOverlayView removeFromSuperview];
        }];
    }

    self.image = image;
}

@end
