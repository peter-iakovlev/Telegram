#import "TGSignalImageViewWithProgress.h"

#import "TGMessageImageViewOverlayView.h"

@interface TGSignalImageViewWithProgress ()
{
    TGMessageImageViewOverlayView *_overlayView;
    CGFloat _progress;
}

@end

@implementation TGSignalImageViewWithProgress

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.legacyAutomaticProgress = false;
        _overlayView = [[TGMessageImageViewOverlayView alloc] initWithFrame:CGRectMake(CGFloor((frame.size.width - 50.0f) / 2.0f), CGFloor((frame.size.height - 50.0f) / 2.0f), 50.0f, 50.0f)];
        [_overlayView setOverlayStyle:TGMessageImageViewOverlayStyleDefault];
        [_overlayView setRadius:50.0f];
        [self addSubview:_overlayView];
        _overlayView.hidden = true;
        _progress = -1.0f;
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    _overlayView.frame = CGRectMake(CGFloor((frame.size.width - 50.0f) / 2.0f), CGFloor((frame.size.height - 50.0f) / 2.0f), 50.0f, 50.0f);
}

- (void)_updateProgress:(float)value
{
    [super _updateProgress:value];
    
    _progress = value;
    if (_progress < -FLT_EPSILON || _progress > 1.0f + FLT_EPSILON)
    {
        [_overlayView setProgress:1.0f cancelEnabled:false animated:true];
        [UIView animateWithDuration:0.2 animations:^
        {
            _overlayView.alpha = 0.0f;
        } completion:^(BOOL finished)
        {
            if (finished)
            {
                _overlayView.hidden = true;
                [_overlayView setNone];
            }
        }];
    }
    else
    {
        _overlayView.hidden = false;
        _overlayView.alpha = 1.0f;
        [_overlayView setProgress:value cancelEnabled:false animated:true];
    }
}

- (CGFloat)progress
{
    return _progress;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    if (_progress < -FLT_EPSILON || _progress > 1.0f + FLT_EPSILON)
    {
        _overlayView.hidden = true;
        [_overlayView setNone];
    }
    else
    {
        _overlayView.hidden = false;
        _overlayView.alpha = 1.0f;
        [_overlayView setProgress:progress cancelEnabled:false animated:false];
    }
}

@end
