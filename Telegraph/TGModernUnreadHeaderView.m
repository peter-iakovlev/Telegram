#import "TGModernUnreadHeaderView.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGPresentation.h"

@interface TGModernUnreadHeaderView ()
{
    UIImageView *_backgroundView;
    UILabel *_labelView;
}

@property (nonatomic, strong) NSString *viewIdentifier;
@property (nonatomic, strong) NSString *viewStateIdentifier;

@end

@implementation TGModernUnreadHeaderView

+ (void)drawHeaderForContainerWidth:(CGFloat)containerWidth inContext:(CGContextRef)context andBindBackgroundToContainer:(UIView *)backgroundContainer atPosition:(CGPoint)position presentation:(TGPresentation *)presentation
{
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:presentation.images.chatUnreadBackground];
    CGRect backgroundFrame = CGRectMake(0.0f, 3.0f, containerWidth, 25.0f);
    backgroundImageView.frame = CGRectOffset(backgroundFrame, position.x, position.y);
    [backgroundContainer addSubview:backgroundImageView];
    
    static UIFont *font = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        font = TGSystemFontOfSize(13.0f);
    });
    
    NSString *text = TGLocalized(@"Conversation.UnreadMessages");
    CGSize textSize = [text sizeWithFont:font];
    
    CGContextSetFillColorWithColor(context, presentation.pallete.chatUnreadTextColor.CGColor);
    CGPoint textOrigin = CGPointMake(CGFloor((containerWidth - textSize.width) / 2) + 1, 7.0f + TGRetinaPixel);
    [text drawAtPoint:textOrigin withFont:font];
}

- (id)initWithFrame:(CGRect)frame presentation:(TGPresentation *)presentation
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.viewIdentifier = @"_unread";
        
        _backgroundView = [[UIImageView alloc] initWithImage:presentation.images.chatUnreadBackground];
        [self addSubview:_backgroundView];
        
        _labelView = [[UILabel alloc] init];
        _labelView.backgroundColor = [UIColor clearColor];
        _labelView.textColor = presentation.pallete.chatUnreadTextColor;
        _labelView.font = TGSystemFontOfSize(13.0f);
        _labelView.text = TGLocalized(@"Conversation.UnreadMessages");
        _labelView.transform = CGAffineTransformMakeRotation((CGFloat)M_PI);
        [_labelView sizeToFit];
        [self addSubview:_labelView];
    }
    return self;
}
- (void)setPresentation:(TGPresentation *)presentation
{
    _backgroundView.image = presentation.images.chatUnreadBackground;
    _labelView.textColor = presentation.pallete.chatUnreadTextColor;
}

- (void)willBecomeRecycled
{
}

- (void)updateAssets
{
}

- (void)layoutSubviews
{
    _backgroundView.frame = CGRectMake(0.0f, 3.0f, self.frame.size.width, 25.0f);
    CGRect labelFrame = _labelView.frame;
    labelFrame.origin = CGPointMake(CGFloor((self.frame.size.width - labelFrame.size.width) / 2.0f), 7.0f + TGRetinaPixel);
    _labelView.frame = labelFrame;
}

@end
