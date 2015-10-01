#import "TGModernGalleryVideoFooterView.h"

#import "TGModernButton.h"

@interface TGModernGalleryVideoFooterView ()
{
    TGModernButton *_playPauseButton;
}

@end

@implementation TGModernGalleryVideoFooterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _playPauseButton = [[TGModernButton alloc] init];
        _playPauseButton.exclusiveTouch = true;
        [_playPauseButton setImage:[self playImage] forState:UIControlStateNormal];
        _playPauseButton.modernHighlight = true;
        [_playPauseButton addTarget:self action:@selector(playPauseButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_playPauseButton];
    }
    return self;
}

- (UIImage *)playImage
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(23.0f, 23.0f), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextBeginPath(context);
        
        CGContextMoveToPoint(context, 3.0f, 0.0f);
        CGContextAddLineToPoint(context, 23.5f, 11.25f);
        CGContextAddLineToPoint(context, 3.0f, 22.5f);
        CGContextClosePath(context);
        
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextFillPath(context);
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    return image;
}

- (UIImage *)pauseImage
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(21.0f, 23.0f), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGFloat width = 4.0f;
        CGFloat spacing = 6.0f;
        CGFloat spacingTop = 1.0f;
        
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextFillRect(context, CGRectMake(CGFloor((21.0f - spacing - width * 2.0f) / 2.0f), spacingTop, width, 22.5f - spacingTop * 2.0f));
        CGContextFillRect(context, CGRectMake(CGFloor((21.0f - spacing - width * 2.0f) / 2.0f) + width + spacing, spacingTop, width, 22.5f - spacingTop * 2.0f));
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    return image;
}

- (void)setIsPlaying:(bool)isPlaying
{
    _isPlaying = isPlaying;
    
    [_playPauseButton setImage:_isPlaying ? [self pauseImage] : [self playImage] forState:UIControlStateNormal];
}

- (void)playPauseButtonPressed
{
    if (_isPlaying)
    {
        if (_pausePressed)
            _pausePressed();
    }
    else
    {
        if (_playPressed)
            _playPressed();
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if (view == _playPauseButton)
        return view;
    
    return nil;
}

- (void)layoutSubviews
{
    CGSize buttonSize = {60.0f, 44.0f};
    _playPauseButton.frame = (CGRect){{CGFloor((self.frame.size.width - buttonSize.width) / 2.0f), CGFloor((self.frame.size.height - buttonSize.height) / 2.0f)}, buttonSize};
}

@end
