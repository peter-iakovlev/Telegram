#import "TGWebpageFooterModel.h"

#import "TGModernFlatteningViewModel.h"
#import "TGModernColorViewModel.h"

#import "TGWebPageMediaAttachment.h"

@interface TGWebpageFooterModel ()
{
    TGModernColorViewModel *_lineModel;
    bool _isInvoice;
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

- (instancetype)initWithContext:(TGModernViewContext *)context incoming:(bool)incoming webpage:(TGWebPageMediaAttachment *)webpage
{
    self = [super init];
    if (self != nil)
    {
        _context = context;
        _lineModel = [[TGModernColorViewModel alloc] initWithColor:colorForLine(incoming) cornerRadius:1.0f];
        if ([webpage.pageType isEqualToString:@"invoice"]) {
            _isInvoice = true;
        } else {
            [self addSubmodel:_lineModel];
        }
    }
    return self;
}

- (CGSize)contentSizeForContainerSize:(CGSize)__unused containerSize contentSize:(CGSize)__unused contentSize infoWidth:(CGFloat)__unused infoWidth needsContentsUpdate:(bool *)__unused needsContentsUpdate
{
    return CGSizeMake(32.0f, 32.0f);
}

- (void)layoutContentInRect:(CGRect)__unused rect bottomInset:(CGFloat *)__unused bottomInset
{
}

- (void)layoutForContainerSize:(CGSize)containerSize contentSize:(CGSize)contentSize infoWidth:(CGFloat)infoWidth needsContentUpdate:(bool *)needsContentUpdate bottomInset:(bool *)hasBottomInset
{
    CGSize webpageSize = [self contentSizeForContainerSize:CGSizeMake(containerSize.width - 2.0f - 2.0f, containerSize.height) contentSize:contentSize infoWidth:infoWidth needsContentsUpdate:needsContentUpdate];
    CGFloat bottomInset = 0.0f;
    [self layoutContentInRect:CGRectMake(_isInvoice ? -9.0 : 2.0f, 7.0f, MAX(webpageSize.width, contentSize.width), webpageSize.height) bottomInset:&bottomInset];
    _lineModel.frame = CGRectMake(2.0f, 7.0f, 2.0f, webpageSize.height - 7.0f - 2.0f - bottomInset);
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, webpageSize.width - (_isInvoice ? 10.0 : 0.0), webpageSize.height);
    if (hasBottomInset) {
        *hasBottomInset = bottomInset > FLT_EPSILON;
    }
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

- (bool)fitContentToWebpage {
    return false;
}

- (TGWebpageFooterModelAction)webpageActionAtPoint:(CGPoint)__unused point
{
    return TGWebpageFooterModelActionNone;
}

- (bool)activateWebpageContents
{
    return false;
}

- (bool)webpageContentsActivated
{
    return false;
}

- (void)activateMediaPlayback
{
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

- (void)updateMediaProgressVisible:(bool)mediaProgressVisible mediaProgress:(float)mediaProgress animated:(bool)__unused animated {
    _mediaProgressVisible = mediaProgressVisible;
    _mediaProgress = mediaProgress;
}

- (void)imageDataInvalidated:(NSString *)__unused imageUrl {
}

- (void)stopInlineMedia:(int32_t)__unused excludeMid {
}

- (void)resumeInlineMedia {
}

- (void)updateMessageId:(int32_t)__unused messageId {
}

- (bool)isPreviewableAtPoint:(CGPoint)__unused point {
    return false;
}

@end
