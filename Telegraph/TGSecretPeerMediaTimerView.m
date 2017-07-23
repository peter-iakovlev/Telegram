#import "TGSecretPeerMediaTimerView.h"

#import "TGCircularProgressView.h"
#import "TGFont.h"

@interface TGSecretPeerMediaTimerView () {
}

@end

@implementation TGSecretPeerMediaTimerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
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

@end
