#import "TGFeedConversationInputPanel.h"

#import <LegacyComponents/TGFont.h>
#import <LegacyComponents/TGImageUtils.h>

#import "TGPresentation.h"

@interface TGFeedConversationInputPanel ()
{
    UIEdgeInsets _safeAreaInset;
    CALayer *_stripeLayer;
    UISegmentedControl *_segmentedControl;
}

@end

@implementation TGFeedConversationInputPanel

- (CGFloat)baseHeight
{
    static CGFloat value = 0.0f;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        value = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 45.0f : 56.0f;
    });
    
    return value;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.backgroundColor = UIColorRGB(0xf7f7f7);
        
        _stripeLayer = [[CALayer alloc] init];
        _stripeLayer.backgroundColor = UIColorRGB(0xb2b2b2).CGColor;
        [self.layer addSublayer:_stripeLayer];
        
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[TGLocalized(@"Feed.Feed"), TGLocalized(@"Feed.Channels")]];
        _segmentedControl.selectedSegmentIndex = 0;
        [_segmentedControl addTarget:self action:@selector(segmentedControlChanged) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_segmentedControl];
    }
    return self;
}

- (void)setSelectedSection:(NSInteger)selectedSection {
    _segmentedControl.selectedSegmentIndex = selectedSection;
}

- (void)segmentedControlChanged
{
    if (self.sectionChanged != nil)
        self.sectionChanged(_segmentedControl.selectedSegmentIndex);
}

- (void)setPresentation:(TGPresentation *)presentation
{
    [super setPresentation:presentation];
    
    self.backgroundColor = presentation.pallete.barBackgroundColor;
    _stripeLayer.backgroundColor = presentation.pallete.barSeparatorColor.CGColor;
    
    [_segmentedControl setBackgroundImage:presentation.images.segmentedControlBackgroundImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [_segmentedControl setBackgroundImage:presentation.images.segmentedControlSelectedImage forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [_segmentedControl setBackgroundImage:presentation.images.segmentedControlSelectedImage forState:UIControlStateSelected | UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [_segmentedControl setBackgroundImage:presentation.images.segmentedControlHighlightedImage forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [_segmentedControl setDividerImage:presentation.images.segmentedControlDividerImage forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    [_segmentedControl setTitleTextAttributes:@{UITextAttributeTextColor:presentation.pallete.navigationButtonColor, UITextAttributeTextShadowColor: [UIColor clearColor], UITextAttributeFont: TGSystemFontOfSize(13)} forState:UIControlStateNormal];
    [_segmentedControl setTitleTextAttributes:@{UITextAttributeTextColor:presentation.pallete.accentContrastColor, UITextAttributeTextShadowColor: [UIColor clearColor], UITextAttributeFont: TGSystemFontOfSize(13)} forState:UIControlStateSelected];
}

- (void)adjustForSize:(CGSize)size keyboardHeight:(CGFloat)keyboardHeight duration:(NSTimeInterval)duration animationCurve:(int)animationCurve contentAreaHeight:(CGFloat)contentAreaHeight safeAreaInset:(UIEdgeInsets)safeAreaInset
{
    [self _adjustForSize:size keyboardHeight:keyboardHeight duration:duration animationCurve:animationCurve contentAreaHeight:contentAreaHeight safeAreaInset:safeAreaInset];
}

- (void)_adjustForSize:(CGSize)size keyboardHeight:(CGFloat)keyboardHeight duration:(NSTimeInterval)duration animationCurve:(int)animationCurve contentAreaHeight:(CGFloat)__unused contentAreaHeight safeAreaInset:(UIEdgeInsets)safeAreaInset
{
    _safeAreaInset = safeAreaInset;
    
    dispatch_block_t block = ^
    {
        CGSize messageAreaSize = size;
        
        self.frame = CGRectMake(0, messageAreaSize.height - keyboardHeight - [self baseHeight] - safeAreaInset.bottom, messageAreaSize.width, [self baseHeight] + safeAreaInset.bottom);
        [self layoutSubviews];
    };
    
    if (duration > DBL_EPSILON)
        [UIView animateWithDuration:duration delay:0 options:animationCurve << 16 animations:block completion:nil];
    else
        block();
}

- (void)changeToSize:(CGSize)size keyboardHeight:(CGFloat)keyboardHeight duration:(NSTimeInterval)duration contentAreaHeight:(CGFloat)contentAreaHeight safeAreaInset:(UIEdgeInsets)safeAreaInset
{
    [self _adjustForSize:size keyboardHeight:keyboardHeight duration:duration animationCurve:0 contentAreaHeight:contentAreaHeight safeAreaInset:safeAreaInset];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _stripeLayer.frame = CGRectMake(0.0f, -TGScreenPixel, self.frame.size.width, TGScreenPixel);
    
    _segmentedControl.frame = CGRectMake(TGScreenPixelFloor((self.frame.size.width - 220.0f) / 2.0f), 9.0f, 220.0f, _segmentedControl.frame.size.height);
}

@end
