#import "TGInstantPageFooterButtonView.h"

@interface TGInstantPageFooterButtonView () {
    UILabel *_label;
    UIView *_backgroundView;
    void (^_openFeedback)();
}

@end

@implementation TGInstantPageFooterButtonView

+ (NSAttributedString *)attributedString {
    static NSAttributedString *string = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        string = [[NSAttributedString alloc] initWithString:TGLocalized(@"InstantPage.FeedbackButton") attributes:@{NSFontAttributeName: [UIFont systemFontOfSize: 13.0], NSForegroundColorAttributeName: UIColorRGB(0x79828b)}];
    });
    return string;
}

+ (UIEdgeInsets)insets {
    return UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
}

+ (CGFloat)heightForWidth:(CGFloat)width {
    UIEdgeInsets insets = [self insets];
    CGSize size = [[self attributedString] boundingRectWithSize:CGSizeMake(width - insets.left - insets.right, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    return size.height + insets.top + insets.bottom;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = UIColorRGB(0xe8eaec);
        [self addSubview:_backgroundView];
        
        _label = [[UILabel alloc] init];
        _label.backgroundColor = [UIColor clearColor];
        _label.attributedText = [TGInstantPageFooterButtonView attributedString];
        [self addSubview:_label];
        _label.userInteractionEnabled = false;
        
        static UIImage *defaultImage = nil;
        static UIImage *highlightedImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(1.0f, 1.0f), true, 1.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, UIColorRGB(0xe8eaec).CGColor);
            CGContextFillRect(context, CGRectMake(0.0f, 0.0f, 1.0f, 1.0f));
            defaultImage = UIGraphicsGetImageFromCurrentImageContext();
            CGContextSetFillColorWithColor(context, UIColorRGB(0xd3d6d7).CGColor);
            CGContextFillRect(context, CGRectMake(0.0f, 0.0f, 1.0f, 1.0f));
            highlightedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        });
        
        [self setBackgroundImage:defaultImage forState:UIControlStateNormal];
        [self setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
        
        [self addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize bounds = self.bounds.size;
    
    UIEdgeInsets insets = [TGInstantPageFooterButtonView insets];
    CGSize size = [_label.attributedText boundingRectWithSize:CGSizeMake(bounds.width - insets.left - insets.right, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    _label.frame = CGRectMake(CGFloor((bounds.width - size.width) / 2.0f), CGFloor((bounds.height - size.height) / 2.0f), size.width, size.height);
    
    _backgroundView.frame = CGRectMake(0.0f, bounds.height, bounds.width, 4000.0f);
}

- (void)setIsVisible:(bool)__unused isVisible {
}

- (void)setOpenFeedback:(void (^)())openFeedback {
    _openFeedback = [openFeedback copy];
}

- (void)buttonPressed {
    if (_openFeedback) {
        _openFeedback();
    }
}

@end
