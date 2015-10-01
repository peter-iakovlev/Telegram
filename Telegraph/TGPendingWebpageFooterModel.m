#import "TGPendingWebpageFooterModel.h"

#import "TGModernTextViewModel.h"

#import "TGFont.h"

@interface TGPendingWebpageFooterModel ()
{
    TGModernTextViewModel *_labelModel;
}

@end

@implementation TGPendingWebpageFooterModel

static CTFontRef textFont()
{
    static CTFontRef font = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        font = TGCoreTextSystemFontOfSize(15.0f);
    });
    return font;
}

- (instancetype)initWithWithIncoming:(bool)incoming
{
    self = [super initWithWithIncoming:incoming];
    if (self != nil)
    {
        _labelModel = [[TGModernTextViewModel alloc] initWithText:TGLocalized(@"ContentPreview.Pending") font:textFont()];
        _labelModel.textColor = [TGWebpageFooterModel colorForAccentText:incoming];
        [self addSubmodel:_labelModel];
    }
    return self;
}

- (CGSize)contentSizeForContainerSize:(CGSize)containerSize contentSize:(CGSize)__unused topContentSize needsContentsUpdate:(bool *)needsContentsUpdate
{
    CGSize contentContainerSize = CGSizeMake(containerSize.width - 10.0f, containerSize.height);
    
    if ([_labelModel layoutNeedsUpdatingForContainerSize:contentContainerSize])
    {
        if (needsContentsUpdate)
            *needsContentsUpdate = true;
        [_labelModel layoutForContainerSize:contentContainerSize];
    }
    
    CGSize contentSize = CGSizeZero;
    
    contentSize.height += 2.0 + 2.0f + 10.0f;
    
    contentSize.width = MAX(contentSize.width, _labelModel.frame.size.width + 10.0f);
    contentSize.height += _labelModel.frame.size.height;
    
    return contentSize;
}

- (void)layoutContentInRect:(CGRect)rect bottomInset:(CGFloat *)__unused bottomInset
{
    _labelModel.frame = CGRectMake(rect.origin.x + 10.0f, rect.origin.y + 0.0f, _labelModel.frame.size.width, _labelModel.frame.size.height);
}

@end
