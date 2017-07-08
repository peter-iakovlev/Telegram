#import "TGModernUnreadHeaderView.h"

#import "TGImageUtils.h"
#import "TGFont.h"

@interface TGModernUnreadHeaderView ()
{
    UIImageView *_backgroundView;
    UILabel *_labelView;
}

@property (nonatomic, strong) NSString *viewIdentifier;
@property (nonatomic, strong) NSString *viewStateIdentifier;

@end

@implementation TGModernUnreadHeaderView

+ (void)drawHeaderForContainerWidth:(CGFloat)containerWidth inContext:(CGContextRef)context andBindBackgroundToContainer:(UIView *)backgroundContainer atPosition:(CGPoint)position
{
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ModernConversationUnreadSeparator.png"]];
    CGRect backgroundFrame = CGRectMake(0.0f, 3.0f, containerWidth, 25.0f);
    backgroundImageView.frame = CGRectOffset(backgroundFrame, position.x, position.y);
    [backgroundContainer addSubview:backgroundImageView];
    
    static UIFont *font = nil;
    static CGColorRef color = NULL;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        font = TGSystemFontOfSize(13.0f);
        color = CGColorRetain(UIColorRGB(0x86868d).CGColor);
    });
    
    NSString *text = TGLocalized(@"Conversation.UnreadMessages");
    CGSize textSize = [text sizeWithFont:font];
    
    CGContextSetFillColorWithColor(context, color);
    CGPoint textOrigin = CGPointMake(CGFloor((containerWidth - textSize.width) / 2) + 1, 7.0f + TGRetinaPixel);
    [text drawAtPoint:textOrigin withFont:font];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.viewIdentifier = @"_unread";
        
        static UIImage *backgroundImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            backgroundImage = [UIImage imageNamed:@"ModernConversationUnreadSeparator.png"];
        });
        
        _backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
        [self addSubview:_backgroundView];
        
        _labelView = [[UILabel alloc] init];
        _labelView.backgroundColor = [UIColor clearColor];
        _labelView.textColor = UIColorRGB(0x86868d);
        _labelView.font = TGSystemFontOfSize(13.0f);
        _labelView.text = TGLocalized(@"Conversation.UnreadMessages");
        _labelView.transform = CGAffineTransformMakeRotation((CGFloat)M_PI);
        [_labelView sizeToFit];
        [self addSubview:_labelView];
    }
    return self;
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
