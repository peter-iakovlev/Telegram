#import "TGCallBackgroundView.h"

#import "UIImage+ImageEffects.h"
#import "TGImageUtils.h"

#import "TGCallSession.h"
#import "TGMediaSignals.h"
#import "TGUser.h"

@interface TGCallBackgroundView ()
{
    SMetaDisposable *_disposable;
    TGUser *_user;
    bool _big;
    
    UIImageView *_transitionView;
    UIView *_dimView;
}
@end

@implementation TGCallBackgroundView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.contentMode = UIViewContentModeScaleAspectFill;
        _dimView = [[UIView alloc] initWithFrame:self.bounds];
        _dimView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _dimView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
        [self addSubview:_dimView];
    }
    return self;
}

- (void)setState:(TGCallSessionState *)state
{
    if (_disposable != nil)
        return;
    
    if (state.peer == nil || _user != nil)
        return;
    
    _user = state.peer;
    
    if (state.peer.photoUrlSmall.length == 0)
    {
        CGSize screenSize = TGScreenSize();
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(8.0f, screenSize.height), true, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGColorRef colors[2] =
        {
            CGColorRetain(UIColorRGB(0x466f92).CGColor),
            CGColorRetain(UIColorRGB(0x244f74).CGColor)
        };
        
        CFArrayRef colorsArray = CFArrayCreate(kCFAllocatorDefault, (const void **)&colors, 2, NULL);
        CGFloat locations[2] = {0.0f, 1.0f};
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colorsArray, (CGFloat const *)&locations);
        
        CFRelease(colorsArray);
        CFRelease(colors[0]);
        CFRelease(colors[1]);
        
        CGColorSpaceRelease(colorSpace);
        
        CGContextDrawLinearGradient(context, gradient, CGPointMake(0.0f, 0.0f), CGPointMake(0.0f, screenSize.height), 0);
    
        [self setImage:UIGraphicsGetImageFromCurrentImageContext() big:true empty:true];
        UIGraphicsEndImageContext();
        
        _dimView.hidden = true;

        return;
    }
    
    SSignal *smallSignal = [[TGMediaSignals avatarPathWithReference:[[TGImageFileReference alloc] initWithUrl:state.peer.photoUrlSmall]] map:^UIImage *(NSString *path)
    {
        return [[UIImage imageWithContentsOfFile:path] applyBlurWithRadius:4.0f tintColor:nil saturationDeltaFactor:1.0f maskImage:nil];
    }];
    
    SSignal *bigSignal = [[TGMediaSignals avatarPathWithReference:[[TGImageFileReference alloc] initWithUrl:state.peer.photoUrlBig]] map:^UIImage *(NSString *path)
    {
        return [UIImage imageWithContentsOfFile:path];
    }];
    
    SSignal *signal = [SSignal combineSignals:@[smallSignal, bigSignal] withInitialStates:@[ [NSNull null], [NSNull null] ]];
    
    __weak TGCallBackgroundView *wealSelf = self;
    _disposable = [[SMetaDisposable alloc] init];
    [_disposable setDisposable:[[signal deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *next)
    {
        __strong TGCallBackgroundView *strongSelf = wealSelf;
        if (strongSelf == nil)
            return;
        
        UIImage *smallImage = [next.firstObject isKindOfClass:[NSNull class]] ? nil : next.firstObject;
        UIImage *bigImage = [next.lastObject isKindOfClass:[NSNull class]] ? nil : next.lastObject;
        
        if (bigImage)
            [strongSelf setImage:bigImage big:true empty:false];
        else if (smallImage)
            [strongSelf setImage:smallImage big:false empty:false];
    }]];
}

- (void)setImage:(UIImage *)image big:(bool)big empty:(bool)empty
{
    if (self.image != nil && !_big && big)
    {
        _transitionView = [[UIImageView alloc] initWithFrame:self.bounds];
        _transitionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _transitionView.contentMode = self.contentMode;
        _transitionView.image = self.image;
        [self insertSubview:_transitionView belowSubview:_dimView];
        
        [UIView animateWithDuration:0.15 animations:^
        {
            _transitionView.alpha = 0.0f;
        } completion:^(__unused BOOL finished)
        {
            [_transitionView removeFromSuperview];
            _transitionView = nil;
        }];
    }
    if (big && !_big)
        _big = true;
    [self setImage:image empty:empty];
}

- (void)setImage:(UIImage *)image empty:(bool)empty
{
    [super setImage:image];
    
    if (self.imageChanged != nil)
        self.imageChanged(empty ? nil : image);
}

@end
