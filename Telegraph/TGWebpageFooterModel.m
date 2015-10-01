#import "TGWebpageFooterModel.h"

#import "TGModernFlatteningViewModel.h"
#import "TGModernColorViewModel.h"

@interface TGWebpageFooterModel ()
{
    TGModernColorViewModel *_lineModel;
}

@end

@implementation TGWebpageFooterModel

static UIColor *colorForLine(bool incoming)
{
    static UIColor *incomingColor = nil;
    static UIColor *outgoingColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        incomingColor = UIColorRGB(0x3ca7fe);
        outgoingColor = UIColorRGB(0x29cc10);
    });
    return incoming ? incomingColor : outgoingColor;
}

- (instancetype)initWithWithIncoming:(bool)incoming
{
    self = [super init];
    if (self != nil)
    {
        _lineModel = [[TGModernColorViewModel alloc] initWithColor:colorForLine(incoming)];
        [self addSubmodel:_lineModel];
    }
    return self;
}

- (CGSize)contentSizeForContainerSize:(CGSize)__unused containerSize contentSize:(CGSize)__unused contentSize needsContentsUpdate:(bool *)__unused needsContentsUpdate
{
    return CGSizeMake(32.0f, 32.0f);
}

- (void)layoutContentInRect:(CGRect)__unused rect bottomInset:(CGFloat *)__unused bottomInset
{
}

- (void)layoutForContainerSize:(CGSize)containerSize contentSize:(CGSize)contentSize needsContentUpdate:(bool *)needsContentUpdate
{
    CGSize webpageSize = [self contentSizeForContainerSize:CGSizeMake(containerSize.width - 2.0f - 2.0f, containerSize.height) contentSize:contentSize needsContentsUpdate:needsContentUpdate];
    CGFloat bottomInset = 0.0f;
    [self layoutContentInRect:CGRectMake(2.0f, 7.0f, MAX(webpageSize.width, contentSize.width), webpageSize.height) bottomInset:&bottomInset];
    _lineModel.frame = CGRectMake(2.0f, 7.0f, 2.0f, webpageSize.height - 7.0f - 2.0f - bottomInset);
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, webpageSize.width + 0.0f, webpageSize.height);
}

- (void)bindSpecialViewsToContainer:(UIView *)__unused container viewStorage:(TGModernViewStorage *)__unused viewStorage atItemPosition:(CGPoint)__unused itemPosition
{
}

- (void)updateSpecialViewsPositions:(CGPoint)__unused itemPosition
{
}

- (bool)preferWebpageSize
{
    return false;
}

- (bool)hasWebpageActionAtPoint:(CGPoint)__unused point
{
    return false;
}

- (bool)activateWebpageContents
{
    return false;
}

- (bool)webpageContentsActivated
{
    return false;
}

- (NSString *)linkAtPoint:(CGPoint)__unused point regionData:(__autoreleasing NSArray **)__unused regionData
{
    return nil;
}

- (UIView *)referenceViewForImageTransition
{
    return nil;
}

- (void)setMediaVisible:(bool)__unused mediaVisible
{
}

+ (UIColor *)colorForAccentText:(bool)incoming
{
    static UIColor *incomingColor = nil;
    static UIColor *outgoingColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        incomingColor = UIColorRGB(0x3ca7fe);
        outgoingColor = UIColorRGB(0x00a700);
    });
    return incoming ? incomingColor : outgoingColor;
}

@end
