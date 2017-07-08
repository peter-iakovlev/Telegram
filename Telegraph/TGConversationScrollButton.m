#import "TGConversationScrollButton.h"

#import "TGFont.h"
#import "TGImageUtils.h"

@interface TGConversationScrollButton () {
    UIImageView *_badgeBackround;
    UILabel *_badgeLabel;
}

@end

@implementation TGConversationScrollButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, 38.0f, 38.0f)];
    if (self != nil) {
        static UIImage *image = nil;
        static UIImage *badgeBackgroundImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(38.0f, 38.0f), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.5f, 0.5f, 37.0f, 37.0f));
            CGContextSetStrokeColorWithColor(context, UIColorRGB(0xb2b2b2).CGColor);
            CGContextSetLineWidth(context, TGScreenPixel);
            CGContextStrokeEllipseInRect(context, CGRectMake(0.25f, 0.25f, 37.5f, 37.5f));
            
            CGFloat arrowLineWidth = 1.5f;
            CGFloat scale = (int)TGScreenScaling();
            if (scale >= 3.0)
                arrowLineWidth = 5.0f / 3.0f;
            
            CGContextSetLineWidth(context, arrowLineWidth);
            CGContextSetStrokeColorWithColor(context, UIColorRGB(0x858e99).CGColor);
            CGContextSetLineCap(context, kCGLineCapRound);
            CGContextSetLineJoin(context, kCGLineJoinRound);
            CGContextBeginPath(context);
            CGPoint position = CGPointMake(9.0f - TGRetinaPixel, 15.0f);
            CGContextMoveToPoint(context, position.x + 1.0f, position.y + 1.0f);
            CGContextAddLineToPoint(context, position.x + 10.0f, position.y + 10.0f);
            CGContextAddLineToPoint(context, position.x + 19.0f, position.y + 1.0f);
            CGContextStrokePath(context);
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(22.0f, 22.0f), false, 0.0f);
            context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, TGAccentColor().CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 22.0f, 22.0f));
            badgeBackgroundImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:11 topCapHeight:11];
            UIGraphicsEndImageContext();
        });
        [self setImage:image forState:UIControlStateNormal];
        
        _badgeBackround = [[UIImageView alloc] initWithImage:badgeBackgroundImage];
        _badgeLabel = [[UILabel alloc] init];
        _badgeLabel.backgroundColor = [UIColor clearColor];
        _badgeLabel.textColor = [UIColor whiteColor];
        _badgeLabel.font = TGSystemFontOfSize(14);
        [self addSubview:_badgeBackround];
        [self addSubview:_badgeLabel];
        
        _badgeLabel.hidden = true;
        _badgeBackround.hidden = true;
    }
    return self;
}

- (void)setBadgeCount:(NSInteger)badgeCount {
    if (_badgeCount != badgeCount) {
        _badgeCount = badgeCount;
        
        if (badgeCount <= 0) {
            _badgeLabel.hidden = true;
            _badgeBackround.hidden = true;
        } else {
            _badgeLabel.hidden = false;
            _badgeBackround.hidden = false;
            _badgeLabel.text = [NSString stringWithFormat:@"%d", (int)badgeCount];
            [_badgeLabel sizeToFit];
            [self setNeedsLayout];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!_badgeLabel.hidden) {
        _badgeLabel.frame = CGRectMake(TGRetinaFloor((self.frame.size.width - _badgeLabel.frame.size.width) / 2.0f), -11.0f, _badgeLabel.frame.size.width, _badgeLabel.frame.size.height);
        CGFloat backgroundWidth = MAX(22.0f, _badgeLabel.frame.size.width + 12.0f);
        _badgeBackround.frame = CGRectMake(TGRetinaFloor((self.frame.size.width - backgroundWidth) / 2.0f), _badgeLabel.frame.origin.y - 3.0f + TGRetinaPixel, backgroundWidth, _badgeBackround.frame.size.height);
    }
}

@end
