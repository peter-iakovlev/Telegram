#import "TGGroupInviteSheetMoreCell.h"

#import "TGFont.h"

@interface TGGroupInviteSheetMoreCell () {
    UIImageView *_circleView;
    UILabel *_countLabel;
}

@end

@implementation TGGroupInviteSheetMoreCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        static UIImage *circleImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(60.0f, 60.0f), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, UIColorRGB(0x50a2e7).CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 60.0f, 60.0f));
            circleImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        });
        _circleView = [[UIImageView alloc] initWithImage:circleImage];
        [self.contentView addSubview:_circleView];
        
        _countLabel = [[UILabel alloc] init];
        _countLabel.backgroundColor = [UIColor clearColor];
        _countLabel.textColor = [UIColor whiteColor];
        _countLabel.font = TGMediumSystemFontOfSize(20.0f);
        [self.contentView addSubview:_countLabel];
    }
    return self;
}

- (void)setCount:(NSUInteger)count {
    if (count > 1000) {
        _countLabel.text = [[NSString alloc] initWithFormat:@"+%dK", (int)count / 1000];
    } else {
        _countLabel.text = [[NSString alloc] initWithFormat:@"+%d", (int)count];
    }
    [_countLabel sizeToFit];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _circleView.center = CGPointMake(CGFloor(self.bounds.size.width / 2.0f), _circleView.center.y);
    _countLabel.center = _circleView.center;
}

@end
