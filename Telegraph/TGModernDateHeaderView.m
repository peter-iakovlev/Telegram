#import "TGModernDateHeaderView.h"

#import "TGTelegraphConversationMessageAssetsSource.h"
#import "TGDateUtils.h"
#import "TGFont.h"
#import "TGImageUtils.h"

@interface TGModernDateHeaderView ()
{
    UILabel *_dateLabel;
    UIImageView *_backgroundImageView;
    
    int _date;
}

@property (nonatomic, strong) NSString *viewIdentifier;
@property (nonatomic, strong) NSString *viewStateIdentifier;

@end

@implementation TGModernDateHeaderView

+ (void)drawDate:(int)date forContainerWidth:(CGFloat)containerWidth inContext:(CGContextRef)context andBindBackgroundToContainer:(UIView *)__unused backgroundContainer atPosition:(CGPoint)__unused position
{
    static UIFont *font = nil;
    static CGColorRef color = NULL;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        font = TGMediumSystemFontOfSize(13.0f);
        color = CGColorRetain([UIColor whiteColor].CGColor);
    });
    
    NSString *text = [TGDateUtils stringForDialogTime:date * 24 * 60 * 60];
    CGSize textSize = [text sizeWithFont:font];
    CGPoint textOrigin = CGPointMake(TGRetinaFloor((containerWidth - textSize.width) / 2), TGRetinaFloor((27.0f - textSize.height) / 2) + TGRetinaPixel);
    
    UIImage *backgroundImage = [[TGTelegraphConversationMessageAssetsSource instance] systemMessageBackground];
    CGRect backgroundFrame = CGRectMake(textOrigin.x - 10, textOrigin.y - 2, textSize.width + 20, backgroundImage.size.height);
    [backgroundImage drawInRect:backgroundFrame blendMode:kCGBlendModeCopy alpha:1.0f];
    
    CGContextSetFillColorWithColor(context, color);
    [text drawAtPoint:textOrigin withFont:font];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.viewIdentifier = @"_date";
        
        _backgroundImageView = [[UIImageView alloc] initWithImage:[[TGTelegraphConversationMessageAssetsSource instance] systemMessageBackground]];
        [self addSubview:_backgroundImageView];
        
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.transform = CGAffineTransformMakeRotation((float)M_PI);
        _dateLabel.textColor = [[TGTelegraphConversationMessageAssetsSource instance] messageActionTextColor];
        _dateLabel.font = TGMediumSystemFontOfSize(13.0f);
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_dateLabel];
        
        _date = INT_MIN;
    }
    return self;
}

- (void)willBecomeRecycled
{
}

- (void)setDate:(int)date
{
    if (_date != date)
    {
        _date = date;
        
        _dateLabel.text = [TGDateUtils stringForDialogTime:_date * 24 * 60 * 60];
        CGRect dateFrame = _dateLabel.frame;
        dateFrame.size = [_dateLabel.text sizeWithFont:_dateLabel.font];
        _dateLabel.frame = dateFrame;
        
        _viewStateIdentifier = [[NSString alloc] initWithFormat:@"date/%d", _date];
        
        [self setNeedsLayout];
    }
}

- (void)updateAssets
{
    _backgroundImageView.image = [[TGTelegraphConversationMessageAssetsSource instance] systemMessageBackground];
}

- (void)layoutSubviews
{
    CGRect bounds = self.bounds;
    
    CGFloat dateOffset = iosMajorVersion() >= 7 ? -1.0f : -TGRetinaPixel;
    CGRect dateFrame = _dateLabel.frame;
    dateFrame.origin = CGPointMake(TGRetinaFloor((bounds.size.width - dateFrame.size.width) / 2), TGRetinaFloor((bounds.size.height - dateFrame.size.height) / 2) + TGRetinaPixel + dateOffset);
    _dateLabel.frame = dateFrame;
    
    _backgroundImageView.frame = CGRectMake(dateFrame.origin.x - 10, dateFrame.origin.y - 2 + (iosMajorVersion() >= 7 ? 0.0f : TGRetinaPixel), dateFrame.size.width + 20, _backgroundImageView.frame.size.height);
}

@end
