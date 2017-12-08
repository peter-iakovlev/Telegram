#import "TGSecretPeerMediaGalleryVideoItemView.h"

#import <AVFoundation/AVFoundation.h>
#import "TGTelegraph.h"
#import <LegacyComponents/TGUser.h>
#import <LegacyComponents/TGFont.h>
#import <LegacyComponents/TGImageUtils.h>
#import <LegacyComponents/TGTimerTarget.h>
#import <LegacyComponents/TGStringUtils.h>

#import <LegacyComponents/TGRemoteImageView.h>

#import "TGSecretPeerMediaGalleryVideoItem.h"

#import "TGSecretPeerMediaTimerView.h"

@interface TGSecretPeerMediaGalleryVideoItemView ()
{
    TGSecretPeerMediaTimerView *_timerView;
    
    NSTimer *_countdownAnimationTimer;
    
    NSTimeInterval _startTime;
    NSTimeInterval _endTime;
    
    bool _scheduledDismiss;
    bool _didLoop;
    
    UIView *_titleLabelContainer;
    UILabel *_titleLabel;
    
    UIView *_footerLabelContainer;
    UILabel *_footerLabel;
    
    UIEdgeInsets _safeAreaInset;
}

@end

@implementation TGSecretPeerMediaGalleryVideoItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _timerView = [[TGSecretPeerMediaTimerView alloc] init];
        
        _titleLabelContainer = [[UIView alloc] init];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = TGLocalized(@"SecretVideo.Title");
        _titleLabel.font = TGBoldSystemFontOfSize(17.0f);
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor whiteColor];
        [_titleLabel sizeToFit];
        
        _titleLabel.frame = CGRectOffset(_titleLabel.frame, 0.0f, 11.0f);
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [_titleLabelContainer addSubview:_titleLabel];
        
        _footerLabelContainer = [[UIView alloc] init];
        
        _footerLabel = [[UILabel alloc] init];
        _footerLabel.backgroundColor = [UIColor clearColor];
        _footerLabel.font = TGSystemFontOfSize(16.0f);
        _footerLabel.textColor = [UIColor whiteColor];
        _footerLabel.textAlignment = NSTextAlignmentCenter;
        _footerLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [_footerLabelContainer addSubview:_footerLabel];
    }
    return self;
}

- (void)dealloc
{
    [self invalidateTimer];
}

- (void)setSafeAreaInset:(UIEdgeInsets)safeAreaInset
{
    _safeAreaInset = safeAreaInset;
    [self layoutSubviews];
}

- (void)prepareForRecycle
{
    [super prepareForRecycle];
    
    [self invalidateTimer];
    
    _scheduledDismiss = false;
}

- (UIView *)headerView
{
    return _titleLabelContainer;
}

- (UIView *)footerView
{
    return _footerLabelContainer;
}

- (void)setItem:(TGSecretPeerMediaGalleryVideoItem *)item synchronously:(bool)synchronously
{
    [self updateFooter:item];
    [super setItem:item synchronously:synchronously];
    
    NSTimeInterval duration = ((TGVideoMediaAttachment *)item.media).duration + 1.0;
    NSTimeInterval currentTime = CFAbsoluteTimeGetCurrent();
    
    if (item.messageCountdownTime > FLT_EPSILON && duration > item.messageCountdownTime + item.messageLifetime - currentTime)
    {
        _startTime = currentTime;
        _endTime =  _startTime + duration;
    }
    else
    {
        _startTime = item.messageCountdownTime;
        _endTime = _startTime + item.messageLifetime;
    }
    
    if (ABS(_startTime) > DBL_EPSILON)
    {
        _timerView.hidden = false;
        
        [self updateProgress];
        [self startTimer];
    }
    else
    {
        _timerView.hidden = true;
    }
    
    if (_timerView.superview == nil) {
        [[self.delegate overlayContainerView] addSubview:_timerView];
    }
}

- (void)invalidateTimer
{
    if (_countdownAnimationTimer != nil)
    {
        [_countdownAnimationTimer invalidate];
        _countdownAnimationTimer = nil;
    }
}

- (void)startTimer
{
    [self invalidateTimer];
    
    _countdownAnimationTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(countdownAnimationTimerEvent) interval:0.02 repeat:true];
}

- (void)countdownAnimationTimerEvent
{
    [self updateProgress];
}

- (void)updateProgress
{
    float progress = (float)((_endTime - CFAbsoluteTimeGetCurrent()) / (_endTime - _startTime));
    if ((1.0f - progress) * 360.0f < 2.0f)
        progress = 1.0f;
    
    [_timerView.progressView setProgress:MAX(0.0f, MIN(progress, 1.0f))];
}

- (void)updateFooter:(TGSecretPeerMediaGalleryVideoItem *)item
{
    if ([item.author isKindOfClass:[TGUser class]] && [item.peer isKindOfClass:[TGUser class]])
    {
        TGUser *user = (TGUser *)item.author;
        TGUser *peer = (TGUser *)item.peer;
        if (user.uid == TGTelegraphInstance.clientUserId)
        {
            _footerLabel.text = [NSString stringWithFormat:TGLocalized(@"SecretVideo.NotViewedYet"), peer.displayFirstName];
            [_footerLabel sizeToFit];
            [self layoutSubviews];
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat topInset = UIEdgeInsetsEqualToEdgeInsets(_safeAreaInset, UIEdgeInsetsZero) ? 20.0f : _safeAreaInset.top;
    _timerView.infoBackgroundView.frame = CGRectMake(self.frame.size.width - 28.0f - 9.0f - _safeAreaInset.right, topInset + 7.0f, 28.0f, 28.0f);
    
    CGSize timerSize = _timerView.progressView.frame.size;
    _timerView.progressView.frame = CGRectMake(_timerView.infoBackgroundView.frame.origin.x + 1.0f, _timerView.infoBackgroundView.frame.origin.y + 1.0f, timerSize.width, timerSize.height);
    
    CGFloat innerPadding = 24.0f;
    _footerLabel.frame = CGRectMake(-innerPadding, 12.0f, self.frame.size.width - 88.0f + innerPadding * 2.0f, _footerLabel.frame.size.height);
}

- (bool)dismissControllerNowOrSchedule
{
    if (_didLoop) {
        return true;
    } else {
        _scheduledDismiss = true;
        return false;
    }
}

- (bool)shouldLoopVideo:(NSUInteger)__unused currentLoopCount
{
    _didLoop = true;
    
    if (_scheduledDismiss)
    {
        _scheduledDismiss = false;
        
        id<TGModernGalleryItemViewDelegate> delegate = self.delegate;
        [delegate itemViewIsReadyForScheduledDismiss:self];
        
        return false;
    }
    
    return true;
}

@end
