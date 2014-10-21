#import "TGSecretPeerMediaGalleryVideoItemView.h"

#import "TGFont.h"
#import "TGImageUtils.h"
#import "TGTimerTarget.h"
#import "TGStringUtils.h"

#import "TGRemoteImageView.h"
#import "TGCircularProgressView.h"

#import "TGSecretPeerMediaGalleryVideoItem.h"

@interface TGSecretPeerMediaGalleryVideoItemView ()
{
    UIImageView *_infoBackgroundView;
    UIImageView *_timerFrameView;
    TGCircularProgressView *_progressView;
    UILabel *_progressLabel;
    
    NSTimer *_countdownAnimationTimer;
    NSTimer *_labelUpdateTimer;
    
    NSTimeInterval _startTime;
    NSTimeInterval _endTime;
    
    bool _scheduledDismiss;
}

@end

@implementation TGSecretPeerMediaGalleryVideoItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        static UIImage *timeBackgroundImage = nil;
        static UIImage *timerFrameImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            {
                CGFloat side = 28.0f;
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(side, side), false, 0.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                
                //!placeholder
                CGContextSetFillColorWithColor(context, UIColorRGBA(0x000000, 0.6f).CGColor);
                CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, side, side));
                
                timeBackgroundImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:(int)(side / 2) topCapHeight:(int)(side / 2)];
                UIGraphicsEndImageContext();
            }
            {
                CGFloat side = 21.0f;
                CGFloat stroke = 1.25f;
                
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(side, side), false, 0.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                
                //!placeholder
                CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
                CGContextSetLineWidth(context, stroke);
                CGContextStrokeEllipseInRect(context, CGRectMake(stroke / 2.0f, stroke / 2.0f, side - stroke, side - stroke));
                
                timerFrameImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
        });
        
        _infoBackgroundView = [[UIImageView alloc] initWithImage:timeBackgroundImage];
        [self addSubview:_infoBackgroundView];
        
        _timerFrameView = [[UIImageView alloc] initWithImage:timerFrameImage];
        _timerFrameView.frame = CGRectMake(0.0f, 0.0f, 21.0f, 21.0f);
        [self addSubview:_timerFrameView];
        
        _progressView = [[TGCircularProgressView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 16.0f, 16.0f)];
        [_progressView setProgress:1.0f];
        [self addSubview:_progressView];
        
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.backgroundColor = [UIColor clearColor];
        _progressLabel.textColor = [UIColor whiteColor];
        _progressLabel.font = TGSystemFontOfSize(13.0f);
        [self addSubview:_progressLabel];
    }
    return self;
}

- (void)dealloc
{
    [self invalidateTimer];
}

- (void)prepareForRecycle
{
    [super prepareForRecycle];
    
    [self invalidateTimer];
    
    _scheduledDismiss = false;
}

- (void)setItem:(TGSecretPeerMediaGalleryVideoItem *)item synchronously:(bool)synchronously
{
    [super setItem:item synchronously:synchronously];
    
    _startTime = item.messageCountdownTime;
    _endTime = _startTime + item.messageLifetime;

    if (ABS(_startTime) > DBL_EPSILON)
    {
        _infoBackgroundView.hidden = false;
        _timerFrameView.hidden = false;
        _progressView.hidden = false;
        _progressLabel.hidden = false;
        
        [self updateProgress];
        [self updateLabel];
        [self startTimer];
    }
    else
    {
        _infoBackgroundView.hidden = true;
        _timerFrameView.hidden = true;
        _progressView.hidden = true;
        _progressLabel.hidden = true;
    }

}

- (void)invalidateTimer
{
    if (_countdownAnimationTimer != nil)
    {
        [_countdownAnimationTimer invalidate];
        _countdownAnimationTimer = nil;
    }
    
    if (_labelUpdateTimer != nil)
    {
        [_labelUpdateTimer invalidate];
        _labelUpdateTimer = nil;
    }
}

- (void)startTimer
{
    [self invalidateTimer];
    
    _countdownAnimationTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(countdownAnimationTimerEvent) interval:0.04 repeat:true];
    _labelUpdateTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(updateLabelTimerEvent) interval:0.15 repeat:true];
}

- (void)countdownAnimationTimerEvent
{
    [self updateProgress];
}

- (void)updateLabelTimerEvent
{
    [self updateLabel];
}

- (void)updateProgress
{
    float progress = (float)((_endTime - CFAbsoluteTimeGetCurrent()) / (_endTime - _startTime));
    if ((1.0f - progress) * 360.0f < 2.0f)
        progress = 1.0f;
    
    [_progressView setProgress:MAX(0.0f, MIN(progress, 1.0f))];
}

- (void)updateLabel
{
    int remainingSeconds = MAX(0, (int)(_endTime - CFAbsoluteTimeGetCurrent()));
    
    NSString *text = nil;
    
    text = [TGStringUtils stringForShortMessageTimerSeconds:remainingSeconds];
    
    if (!TGStringCompare(text, _progressLabel.text))
    {
        _progressLabel.text = text;
        [_progressLabel sizeToFit];
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat infoBackgroundWidth = 3.0f * 2.0f + 21.0f + _progressLabel.frame.size.width + 12.0f;
    _infoBackgroundView.frame = CGRectMake(self.frame.size.width - 7.0f - infoBackgroundWidth, 7.0f, infoBackgroundWidth, 28.0f);
    
    CGSize timerSize = _timerFrameView.frame.size;
    _timerFrameView.frame = CGRectMake(CGRectGetMaxX(_infoBackgroundView.frame) - 3.5f - timerSize.width, _infoBackgroundView.frame.origin.y + 3.5f, timerSize.width, timerSize.height);
    
    CGSize progressSize = _progressView.frame.size;
    _progressView.frame = CGRectMake(_timerFrameView.frame.origin.x + ((timerSize.width - progressSize.width) / 2.0f), _timerFrameView.frame.origin.y + ((timerSize.height - progressSize.height) / 2.0f), progressSize.width, progressSize.height);
    
    _progressLabel.frame = CGRectMake(_infoBackgroundView.frame.origin.x + 9.0f, _infoBackgroundView.frame.origin.y + 5.0f + TGRetinaPixel, _progressLabel.frame.size.width, _progressLabel.frame.size.height);
}

- (bool)dismissControllerNowOrSchedule
{
    _scheduledDismiss = true;
    
    return false;
}

- (bool)shouldLoopVideo:(NSUInteger)__unused currentLoopCount
{
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
