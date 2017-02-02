#import "TGProgressAlert.h"

#import <LegacyDatabase/LegacyDatabase.h>

@interface TGProgressAlert ()
{
    UIView *_dimView;
    UIView *_backgroundView;
    UILabel *_textLabel;
    UIView *_progressView;
    UIView *_separatorView;
    UIButton *_cancelButton;
}

@end

@implementation TGProgressAlert

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _dimView = [[UIView alloc] init];
        _dimView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
        [self addSubview:_dimView];
        
        static UIImage *backgroundImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            CGFloat radius = 8.0f;
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(radius * 2.0f, radius * 2.0f), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, radius * 2.0f, radius * 2.0f));
            backgroundImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:(NSInteger)radius topCapHeight:(NSInteger)radius];
            UIGraphicsEndImageContext();
        });
        _backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
        [self addSubview:_backgroundView];
        
        _textLabel = [[UILabel alloc] init];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textColor = [UIColor blackColor];
        _textLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        [self addSubview:_textLabel];
        
        _separatorView = [[UIView alloc] init];
        _separatorView.backgroundColor = TGColorWithHex(0xcccccc);
        [self addSubview:_separatorView];
        
        _progressView = [[UIView alloc] init];
        _progressView.backgroundColor = TGColorWithHex(0x007ee5);
        [self addSubview:_progressView];
        
        _cancelButton = [[UIButton alloc] init];
        NSString *cancelText = NSLocalizedString(@"Common.Cancel", nil);
        if (cancelText.length == 0 || [cancelText isEqualToString:@"Common.Cancel"]) {
            cancelText = NSLocalizedString(@"Share.Cancel", nil);
        }
        
        [_cancelButton setTitle:cancelText forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelPressed) forControlEvents:UIControlEventTouchUpInside];
        [_cancelButton setTitleColor:TGColorWithHex(0x007ee5) forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[TGColorWithHex(0x007ee5) colorWithAlphaComponent:0.6f] forState:UIControlStateHighlighted];
        [self addSubview:_cancelButton];
    }
    return self;
}

- (void)cancelPressed
{
    if (_cancel)
        _cancel();
}

- (void)setText:(NSString *)text
{
    _text = text;
    _textLabel.text = text;
    [self setNeedsLayout];
}

- (void)setProgress:(CGFloat)progress
{
    [self setProgress:progress animated:false];
}

- (void)setProgress:(CGFloat)progress animated:(bool)animated
{
    _progress = progress;
    
    CGRect progressFrame = CGRectMake(_separatorView.frame.origin.x, _separatorView.frame.origin.y - 2.0f + _separatorView.frame.size.height, (CGFloat)(floor(_separatorView.frame.size.width * _progress * 2.0f) / 2.0f), 2.0f);
    if (!CGRectEqualToRect(progressFrame, _progressView.frame))
    {
        if (animated)
        {
            [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
            {
                _progressView.frame = progressFrame;
            } completion:nil];
        }
        else
        {
            _progressView.frame = progressFrame;
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _dimView.frame = self.bounds;
    
    CGSize backgroundSize = CGSizeMake(270.0f, 102.0f);
    
    _backgroundView.frame = CGRectMake((self.frame.size.width - backgroundSize.width) / 2.0f, (self.frame.size.height - backgroundSize.height) / 2.0f, backgroundSize.width, backgroundSize.height);
    CGFloat separatorHeight = 1.0f / [UIScreen mainScreen].scale;
    _separatorView.frame = CGRectMake(_backgroundView.frame.origin.x, _backgroundView.frame.origin.y + 57.0f + separatorHeight, _backgroundView.frame.size.width, separatorHeight);
    
    CGRect progressFrame = CGRectMake(_separatorView.frame.origin.x, _separatorView.frame.origin.y + separatorHeight - 2.0f, (CGFloat)(floor(_separatorView.frame.size.width * _progress * 2.0f) / 2.0f), 2.0f);
    if (!CGRectEqualToRect(progressFrame, _progressView.frame))
        _progressView.frame = progressFrame;
    
    [_textLabel sizeToFit];
    _textLabel.frame = CGRectMake(_backgroundView.frame.origin.x + (_backgroundView.frame.size.width - _textLabel.frame.size.width) / 2.0f, _backgroundView.frame.origin.y + 18.0f, _textLabel.frame.size.width, _textLabel.frame.size.height);
    _cancelButton.frame = CGRectMake(_backgroundView.frame.origin.x, _backgroundView.frame.origin.y + _backgroundView.frame.size.height - 45.0f, _backgroundView.frame.size.width, 45.0f);
}

@end
