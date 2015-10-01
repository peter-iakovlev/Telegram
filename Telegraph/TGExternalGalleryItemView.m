#import "TGExternalGalleryItemView.h"

#import "TGExternalGalleryItem.h"
#import "TGWebPageMediaAttachment.h"

#import "TGFont.h"

@interface TGGalleryTextTitleView : UIView
{
    UILabel *_titleLabel;
}

@end

@implementation TGGalleryTextTitleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = TGMediumSystemFontOfSize(17);
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)setText:(NSString *)text
{
    _titleLabel.text = text;
    [_titleLabel sizeToFit];
    _titleLabel.frame = [self titleFrameForSize:self.frame.size];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    _titleLabel.frame = [self titleFrameForSize:frame.size];
}

- (CGRect)titleFrameForSize:(CGSize)size
{
    CGSize titleSize = [_titleLabel.text sizeWithFont:_titleLabel.font];
    titleSize.width = MIN(titleSize.width, size.width);
    return CGRectMake(CGFloor((size.width - titleSize.width) / 2.0f), CGFloor((44.0f - titleSize.height) / 2.0f), titleSize.width, titleSize.height);
}

@end

@interface TGExternalGalleryItemView ()
{
    TGGalleryTextTitleView *_titleView;
}

@end

@implementation TGExternalGalleryItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _titleView = [[TGGalleryTextTitleView alloc] init];
    }
    return self;
}

- (void)setItem:(id<TGModernGalleryItem>)item synchronously:(bool)synchronously
{
    [super setItem:item synchronously:synchronously];
    
    [_titleView setText:((TGExternalGalleryItem *)item).webPage.siteName];
}

- (UIView *)headerView
{
    return _titleView;
}

@end
