#import "TGVideoMessagePIPController.h"

#import "TGImageUtils.h"
#import "TGObserverProxy.h"

#import "TGAppDelegate.h"
#import "TGTelegraph.h"
#import "TGOverlayControllerWindow.h"

#import "TGNativeAudioPlayer.h"

#import "TGVideoMessagePIPView.h"

#import "TGEmbedPIPController.h"

typedef enum
{
    TGVideoMessagePIPCornerNone,
    TGVideoMessagePIPCornerTopLeft,
    TGVideoMessagePIPCornerTopRight,
    TGVideoMessagePIPCornerBottomRight,
    TGVideoMessagePIPCornerBottomLeft
} TGVideoMessagePIPCorner;

const CGFloat TGVideoMessagePIPViewSide = 123.0f;
const CGFloat TGVideoMessagePIPViewMargin = 10.0f;
const CGFloat TGVideoMessagePIPDefaultStatusBarHeight = 20.0f;
const CGFloat TGVideoMessagePIPPortraitNavigationBarHeight = 44.0f;
const CGFloat TGVideoMessagePIPLandscapeNavigationBarHeight = 32.0f;
const CGFloat TGVideoMessagePIPPlayerBarHeight = 37.0f;
const CGFloat TGVideoMessagePIPAngleEpsilon = 30.0f;

static TGVideoMessagePIPCorner defaultCorner = TGVideoMessagePIPCornerTopRight;

@interface TGVideoMessagePIPWindow : TGOverlayControllerWindow

@end

@interface TGVideoMessagePIPController () <UIGestureRecognizerDelegate>
{
    TGVideoMessagePIPWindow *_window;
    
    SMetaDisposable *_statusDisposable;
    SMetaDisposable *_messageDisposable;
    
    TGVideoMessagePIPView *_pipView;
    
    TGVideoMessagePIPCorner _currentCorner;
    TGMusicPlayerItem *_currentItem;
    bool _visible;
    
    UIPanGestureRecognizer *_panGestureRecognizer;
    bool _highVelocityOnGestureStart;
    
    CGFloat _keyboardHeight;
    TGObserverProxy *_keyboardWillChangeFrameProxy;
}
@end

@implementation TGVideoMessagePIPController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _statusDisposable = [[SMetaDisposable alloc] init];
        _messageDisposable = [[SMetaDisposable alloc] init];
        [self subscribe];
        
        _keyboardWillChangeFrameProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification];
    }
    return self;
}

- (void)dealloc
{
    [_statusDisposable dispose];
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _pipView = [[TGVideoMessagePIPView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, TGVideoMessagePIPViewSide, TGVideoMessagePIPViewSide)];
    _pipView.onTap = ^
    {
        [[TGTelegraphInstance musicPlayer] controlPlayPause];
    };
    [self.view addSubview:_pipView];
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    _panGestureRecognizer.delegate = self;
    [_pipView addGestureRecognizer:_panGestureRecognizer];
}

- (void)_setupWindow
{
    if (_window != nil)
        return;
    
    TGVideoMessagePIPWindow *window = [[TGVideoMessagePIPWindow alloc] initWithFrame:TGAppDelegateInstance.rootController.applicationBounds];
    window.keepKeyboard = true;
    window.backgroundColor = [UIColor clearColor];
    window.rootViewController = self;
    window.windowLevel = 100000000.0f + 0.001f;
    window.hidden = false;
    _window = window;
}

- (void)_destroyWindow
{
    [_window dismiss];
    _window = nil;
}

- (void)subscribe
{
    __weak TGVideoMessagePIPController *weakSelf = self;
    [_statusDisposable setDisposable:[[[[TGTelegraphInstance musicPlayer] playingStatus] deliverOn:[SQueue mainQueue]] startWithNext:^(TGMusicPlayerStatus *next)
    {
        __strong TGVideoMessagePIPController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf updateWithStatus:next];
    }]];
}

- (void)updateWithStatus:(TGMusicPlayerStatus *)status
{
    if (status != nil)
    {
        bool changed = true;
        if (_currentItem.peerId == status.item.peerId && [_currentItem.key isEqual:status.item.key])
            changed = false;
        
        if (changed)
        {
            TGMusicPlayerItem *item = status.item;
            _currentItem = item;
            
            if (!_currentItem.isVoice || !_currentItem.isVideo)
            {
                if (_visible)
                    [self hideViewWithCompletion:nil];
                
                [_messageDisposable setDisposable:nil];
            }
            else
            {
                int32_t messageId = [(NSNumber *)item.key int32Value];
                __weak TGVideoMessagePIPController *weakSelf = self;
                [_messageDisposable setDisposable:[self.messageVisibilitySignal(status.item.peerId, messageId) startWithNext:^(NSNumber *next)
                {
                    __strong TGVideoMessagePIPController *strongSelf = weakSelf;
                    if (strongSelf == nil)
                        return;
                    
                    if (!next.boolValue)
                    {
                        [strongSelf showViewForStatus:status completion:nil];
                    }
                    else
                    {
                        if (strongSelf->_visible)
                            [strongSelf hideViewWithCompletion:nil];
                    }
                }]];
            }
        }
        
        [_pipView setStatus:status];
    }
    else
    {
        [_messageDisposable setDisposable:nil];
        [self dismissController];
    }
}

#pragma mark -

- (void)showViewForStatus:(TGMusicPlayerStatus *)status completion:(void (^)(void))completion
{
    [self _setupWindow];
 
    TGMusicPlayerItem *item = status.item;
    bool isSwitch = false;
    if (_visible && (_pipView.item.peerId != item.peerId || ![_pipView.item.key isEqual:item.key]))
        isSwitch = true;
    
    bool wasHidden = !_visible;
    _visible = true;
    
    TGModernGalleryVideoView *videoView = [TGVideoMessagePIPController videoViewForStatus:status pip:true];
    [TGVideoMessagePIPController acquireVideoViewForPIP:videoView];
    
    if (wasHidden)
    {
        [_pipView setVideoView:videoView];
        
        [TGEmbedPIPController dismissPictureInPicture];
        
        _currentCorner = defaultCorner;
        CGRect frame = [self _rectForViewForSize:self.view.frame.size atCorner:_currentCorner hidden:true];
        _pipView.frame = frame;
        
        [self animateViewWithOptions:kNilOptions block:^
        {
            _pipView.frame = [self _rectForViewForSize:self.view.frame.size atCorner:_currentCorner hidden:false];
        } completion:^(__unused BOOL finished)
        {
            if (completion != nil)
                completion();
        }];
    }
    else if (isSwitch)
    {
        UIView *snapshotView = [_pipView snapshotViewAfterScreenUpdates:false];
        snapshotView.frame = _pipView.frame;
        [_pipView.superview addSubview:snapshotView];
        
        [_pipView setVideoView:videoView];
        _pipView.frame = [self _rectForViewForSize:self.view.frame.size atCorner:_currentCorner hidden:true];
        
        [self animateViewWithOptions:kNilOptions block:^
        {
            _pipView.frame = [self _rectForViewForSize:self.view.frame.size atCorner:_currentCorner hidden:false];
            snapshotView.frame = [self _rectForViewForSize:self.view.frame.size atCorner:_currentCorner hidden:true];
        } completion:^(__unused BOOL finished)
        {
            [snapshotView removeFromSuperview];
            
            if (completion != nil)
                completion();
        }];
    }
    
    _pipView.item = item;
}

- (void)hideViewWithCompletion:(void (^)(void))completion
{
    [TGVideoMessagePIPController releaseVideoView:_pipView.videoView];
    
    _visible = false;
    [self animateViewWithOptions:kNilOptions block:^
    {
        _pipView.frame = [self _rectForViewForSize:self.view.frame.size atCorner:_currentCorner hidden:true];
    } completion:^(__unused BOOL finished)
    {
        if (completion != nil)
            completion();
    }];
}

- (void)dismissController
{
    _currentItem = nil;
    
    [self hideViewWithCompletion:^
    {
        [self _destroyWindow];
    }];
}

#pragma mark -

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint translation = [gestureRecognizer translationInView:self.view];
    CGPoint velocity = [gestureRecognizer velocityInView:self.view];
    
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            CGFloat velocityVal = sqrt(velocity.x * velocity.x + velocity.y * velocity.y);
            _highVelocityOnGestureStart = (velocityVal > 500);
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            if (_highVelocityOnGestureStart)
            {
                _highVelocityOnGestureStart = false;
                return;
            }
            
            _pipView.center = CGPointMake(_pipView.center.x + translation.x, _pipView.center.y + translation.y);
            
            [self targetCornerForLocation:_pipView.center dismiss:NULL];
            
            [gestureRecognizer setTranslation:CGPointZero inView:self.view];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            CGFloat velocityVal = sqrt(velocity.x * velocity.x + velocity.y * velocity.y);
            
            TGVideoMessagePIPCorner targetCorner = _currentCorner;
            
            bool shouldDismiss = false;
            if (velocityVal > 500)
                targetCorner = [self targetCornerForVelocity:velocity dismiss:&shouldDismiss];
            else
                targetCorner = [self targetCornerForLocation:_pipView.center dismiss:&shouldDismiss];
            
            UIViewAnimationOptions options = !shouldDismiss ? UIViewAnimationOptionAllowUserInteraction : kNilOptions;
            [self animateViewWithOptions:options block:^
            {
                [self layoutViewForSize:self.view.frame.size atCorner:targetCorner hidden:shouldDismiss];
            } completion:nil];
            
            if (shouldDismiss && self.requestedDismissal != nil)
                self.requestedDismissal();
                
        }
            break;
            
        default:
            break;
    }
}

- (CGRect)_rectForViewForSize:(CGSize)containerSize atCorner:(TGVideoMessagePIPCorner)corner hidden:(bool)hidden
{
    CGSize size = CGSizeMake(TGVideoMessagePIPViewSide, TGVideoMessagePIPViewSide);
    CGSize statusBarSize = [UIApplication sharedApplication].statusBarFrame.size;
    CGFloat statusBarHeight = MIN(statusBarSize.width, statusBarSize.height);
    statusBarHeight = MAX(TGVideoMessagePIPDefaultStatusBarHeight, statusBarHeight);
    
    bool isLandscape = containerSize.width > containerSize.height;
    
    CGFloat topBarHeight = (isLandscape && !TGIsPad() && ![TGViewController hasVeryLargeScreen]) ? TGVideoMessagePIPLandscapeNavigationBarHeight : TGVideoMessagePIPPortraitNavigationBarHeight;
    CGFloat topMargin = TGVideoMessagePIPViewMargin + TGVideoMessagePIPPlayerBarHeight + topBarHeight + statusBarHeight;
    CGFloat bottomMargin = TGVideoMessagePIPViewMargin + 44.0f + _keyboardHeight;
    
    CGFloat bottomY = self.view.frame.size.height - bottomMargin - size.height;
    CGFloat topY = MIN(bottomY, topMargin);
    
    CGFloat hideOffset = size.width * 1.3f;
    
    switch (corner)
    {
        case TGVideoMessagePIPCornerTopLeft:
        {
            CGRect rect = CGRectMake(TGVideoMessagePIPViewMargin, topY, size.width, size.height);
            if (hidden)
                rect.origin.x -= hideOffset;
            return rect;
        }
        case TGVideoMessagePIPCornerBottomRight:
        {
            CGRect rect = CGRectMake(self.view.frame.size.width - TGVideoMessagePIPViewMargin - size.width, bottomY, size.width, size.height);
            if (hidden)
                rect.origin.x += hideOffset;
            return rect;
        }
            
        case TGVideoMessagePIPCornerBottomLeft:
        {
            CGRect rect = CGRectMake(TGVideoMessagePIPViewMargin, bottomY, size.width, size.height);
            if (hidden)
                rect.origin.x -= hideOffset;
            return rect;
        }
            
        case TGVideoMessagePIPCornerTopRight:
        default:
        {
            CGRect rect = CGRectMake(self.view.frame.size.width - TGVideoMessagePIPViewMargin - size.width, topY, size.width, size.height);
            if (hidden)
                rect.origin.x += hideOffset;
            return rect;
        }
    }
}

- (void)layoutViewForSize:(CGSize)size atCorner:(TGVideoMessagePIPCorner)corner
{
    [self layoutViewForSize:size atCorner:corner hidden:false];
}

- (void)layoutViewForSize:(CGSize)size atCorner:(TGVideoMessagePIPCorner)corner hidden:(bool)hidden
{
    _currentCorner = corner;
    _pipView.frame = [self _rectForViewForSize:size atCorner:corner hidden:hidden];
    
    defaultCorner = corner;
}

- (TGVideoMessagePIPCorner)targetCornerForVelocity:(CGPoint)velocity dismiss:(bool *)dismiss
{
    CGFloat x = velocity.x;
    CGFloat y = velocity.y;
    
    double angle = atan2(y, x) * 180.0f / M_PI * -1;
    if (angle < 0) angle += 360.0f;
    
    TGVideoMessagePIPCorner corner = _currentCorner;
    bool shouldHide = false;
    
    switch (_currentCorner)
    {
        case TGVideoMessagePIPCornerTopLeft:
            if ((angle > 0 && angle < 90 - TGVideoMessagePIPAngleEpsilon) || angle > 360 - TGVideoMessagePIPAngleEpsilon)
            {
                corner = TGVideoMessagePIPCornerTopRight;
            }
            else if (angle > 180 + TGVideoMessagePIPAngleEpsilon && angle < 270 + TGVideoMessagePIPAngleEpsilon)
            {
                corner = TGVideoMessagePIPCornerBottomLeft;
            }
            else if (angle > 270 + TGVideoMessagePIPAngleEpsilon && angle < 360 - TGVideoMessagePIPAngleEpsilon)
            {
                corner = TGVideoMessagePIPCornerBottomRight;
            }
            else
            {
                shouldHide = true;
            }
            break;
            
        case TGVideoMessagePIPCornerTopRight:
            if (angle > 90 + TGVideoMessagePIPAngleEpsilon && angle < 180 + TGVideoMessagePIPAngleEpsilon)
            {
                corner = TGVideoMessagePIPCornerTopLeft;
            }
            else if (angle > 270 - TGVideoMessagePIPAngleEpsilon && angle < 360 - TGVideoMessagePIPAngleEpsilon)
            {
                corner = TGVideoMessagePIPCornerBottomRight;
            }
            else if (angle > 180 + TGVideoMessagePIPAngleEpsilon && angle < 270 - TGVideoMessagePIPAngleEpsilon)
            {
                corner = TGVideoMessagePIPCornerBottomLeft;
            }
            else if (!shouldHide)
            {
                shouldHide = true;
            }
            break;
            
        case TGVideoMessagePIPCornerBottomLeft:
            if (angle > 90 - TGVideoMessagePIPAngleEpsilon && angle < 180 - TGVideoMessagePIPAngleEpsilon)
            {
                corner = TGVideoMessagePIPCornerTopLeft;
            }
            else if (angle < TGVideoMessagePIPAngleEpsilon || angle > 270 + TGVideoMessagePIPAngleEpsilon)
            {
                corner = TGVideoMessagePIPCornerBottomRight;
            }
            else if (angle > TGVideoMessagePIPAngleEpsilon && angle < 90 - TGVideoMessagePIPAngleEpsilon)
            {
                corner = TGVideoMessagePIPCornerTopRight;
            }
            else if (!shouldHide)
            {
                shouldHide = true;
            }
            break;
            
        case TGVideoMessagePIPCornerBottomRight:
            if (angle > TGVideoMessagePIPAngleEpsilon && angle < 90 + TGVideoMessagePIPAngleEpsilon)
            {
                corner = TGVideoMessagePIPCornerTopRight;
            }
            else if (angle > 180 - TGVideoMessagePIPAngleEpsilon && angle < 270 - TGVideoMessagePIPAngleEpsilon)
            {
                corner = TGVideoMessagePIPCornerBottomLeft;
            }
            else if (angle > 90 + TGVideoMessagePIPAngleEpsilon && angle < 180 - TGVideoMessagePIPAngleEpsilon)
            {
                corner = TGVideoMessagePIPCornerTopLeft;
            }
            else if (!shouldHide)
            {
                shouldHide = true;
            }
            break;
            
        default:
            break;
    }
    
    if (shouldHide && dismiss != NULL)
        *dismiss = true;
        
    
    return corner;
}

- (TGVideoMessagePIPCorner)targetCornerForLocation:(CGPoint)location dismiss:(bool *)dismiss
{
    bool right = false;
    bool bottom = false;
    
    if (location.x > self.view.frame.size.width / 2.0f)
        right = true;
    if (location.y > (self.view.frame.size.height - _keyboardHeight) / 2.0f)
        bottom = true;
    
    if (dismiss != NULL && (location.x < 0.0f - TGVideoMessagePIPViewSide / 2.0f || location.x > self.view.frame.size.width - TGVideoMessagePIPViewSide / 2.0f))
    {
        *dismiss = true;
    }
    
    if (!right && !bottom)
        return TGVideoMessagePIPCornerTopLeft;
    else if (right && !bottom)
        return TGVideoMessagePIPCornerTopRight;
    else if (!right && bottom)
        return TGVideoMessagePIPCornerBottomLeft;
    else
        return TGVideoMessagePIPCornerBottomRight;
}

- (void)animateViewWithOptions:(UIViewAnimationOptions)options block:(void (^)(void))block completion:(void (^)(BOOL))completion
{
    if (iosMajorVersion() >= 7)
    {
        [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:1.4 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveLinear | options animations:block completion:completion];
    }
    else
    {
        [UIView animateWithDuration:0.35 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut | options animations:block completion:completion];
    }
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSTimeInterval duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] == nil ? 0.3 : [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    int curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    CGRect screenKeyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:screenKeyboardFrame fromView:nil];
    
    CGFloat keyboardHeight = (keyboardFrame.size.height <= FLT_EPSILON || keyboardFrame.size.width <= FLT_EPSILON) ? 0.0f :  (self.view.frame.size.height - keyboardFrame.origin.y);
    
    keyboardHeight = MAX(keyboardHeight, 0.0f);
    
    if (keyboardFrame.origin.y + keyboardFrame.size.height < self.view.frame.size.height - FLT_EPSILON)
        keyboardHeight = 0.0f;
    
    _keyboardHeight = keyboardHeight;
    
    if (_visible)
    {
        [UIView animateWithDuration:duration delay:0.0 options:curve animations:^
        {
            [self layoutViewForSize:self.view.frame.size atCorner:_currentCorner];
        } completion:nil];
    }
}

- (void)layoutControllerForSize:(CGSize)size duration:(NSTimeInterval)duration
{
    [super layoutControllerForSize:size duration:duration];
    [self layoutViewForSize:size atCorner:_currentCorner];
}

+ (TGModernGalleryVideoView *)videoViewForStatus:(TGMusicPlayerStatus *)status
{
    return [self videoViewForStatus:status pip:false];
}

+ (TGModernGalleryVideoView *)videoViewForStatus:(TGMusicPlayerStatus *)status pip:(bool)pip
{
    TGMusicPlayerItem *item = status.item;
    AVPlayer *player = nil;
    if ([status.player isKindOfClass:[TGNativeAudioPlayer class]])
        player = ((TGNativeAudioPlayer *)status.player).player;
    
    if (player == nil)
        return nil;
    
    NSString *key = [NSString stringWithFormat:@"%lld_%@", item.peerId, item.key];
    TGModernGalleryVideoView *videoView = [[self videoViews] objectForKey:key];
    if (videoView.player != player)
    {
        videoView = nil;
        [[self videoViews] removeObjectForKey:key];
    }
    
    if (!pip && [self viewAcquiredForPIP:videoView])
        return nil;
    
    if (videoView != nil)
        return videoView;
    
    videoView = [[TGModernGalleryVideoView alloc] initWithFrame:CGRectZero player:player key:key];
    videoView.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [[self videoViews] setObject:videoView forKey:key];
    
    return videoView;
}

+ (NSMapTable *)videoViews
{
    static dispatch_once_t onceToken;
    static NSMapTable *views;
    dispatch_once(&onceToken, ^
    {
        views = [NSMapTable strongToWeakObjectsMapTable];
    });
    return views;
}

+ (void)acquireVideoViewForPIP:(TGModernGalleryVideoView *)videoView
{
    if (videoView == nil)
        return;
    
    [[self pipVideoViews] addObject:videoView];
}

+ (void)releaseVideoView:(TGModernGalleryVideoView *)videoView
{
    if (videoView == nil)
        return;
    
    [[self pipVideoViews] removeObject:videoView];
}

+ (bool)viewAcquiredForPIP:(TGModernGalleryVideoView *)videoView
{
    for (TGModernGalleryVideoView *view in [self pipVideoViews])
    {
        if (view == videoView)
            return true;
    }
    return false;
}

+ (NSHashTable *)pipVideoViews
{
    static dispatch_once_t onceToken;
    static NSHashTable *views;
    dispatch_once(&onceToken, ^
    {
        views = [NSHashTable weakObjectsHashTable];
    });
    return views;
}

@end


@implementation TGVideoMessagePIPWindow

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    CGPoint localPoint = [[self.rootViewController view] convertPoint:point fromView:self];
    UIView *result = [[self.rootViewController view] hitTest:localPoint withEvent:event];
    if (result == self.rootViewController.view)
        return nil;
    
    return result;
}

@end
