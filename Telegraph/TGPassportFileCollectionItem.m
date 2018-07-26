#import "TGPassportFileCollectionItem.h"
#import "TGPassportFileCollectionItemView.h"

#import <LegacyComponents/TGFont.h>

@implementation TGPassportFileCollectionItem
{
        CGSize _calculatedSize;
}

- (instancetype)initWithTitle:(NSString *)title action:(void (^)(TGPassportFileCollectionItem *))action removeRequested:(void (^)(TGPassportFileCollectionItem *))removeRequested
{
    self = [super init];
    if (self != nil)
    {
        _title = title;
        self.action = [action copy];
        self.removeRequested = [removeRequested copy];
    }
    return self;
}

- (Class)itemViewClass
{
    return [TGPassportFileCollectionItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize safeAreaInset:(UIEdgeInsets)safeAreaInset
{    
    static UIFont *font = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        font = TGSystemFontOfSize(14);
    });
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:_subtitle ?: @""];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByWordWrapping;
    style.lineSpacing = 2.0f;
    style.paragraphSpacing = 0.0f;
    [attributedText addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attributedText.length)];
    [attributedText addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, attributedText.length)];
    
    CGSize textSize = [attributedText boundingRectWithSize:CGSizeMake(containerSize.width - 90.0f - 14.0f - safeAreaInset.left - safeAreaInset.right, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:NULL].size;
    
    textSize.width = CGCeil(textSize.width);
    textSize.height = CGCeil(textSize.height);
    
    _calculatedSize = CGSizeMake(textSize.width, textSize.height);
    [(TGPassportFileCollectionItemView *)self.boundView setCalculatedSize:_calculatedSize];
    
    return CGSizeMake(containerSize.width, MAX(64.0f, 46.0f + _calculatedSize.height));
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    [(TGPassportFileCollectionItemView *)self.boundView setTitle:_title];
}

- (void)setSubtitle:(NSString *)subtitle
{
    _subtitle = subtitle;
    [(TGPassportFileCollectionItemView *)self.boundView setSubtitle:_subtitle];
}

- (void)setIcon:(UIImage *)icon
{
    _icon = icon;
    [(TGPassportFileCollectionItemView *)self.boundView setIcon:_icon];
}

- (void)setImageSignal:(SSignal *)imageSignal
{
    _imageSignal = imageSignal;
    [(TGPassportFileCollectionItemView *)self.boundView setImageSignal:_imageSignal];
}

- (void)setProgressSignal:(SSignal *)progressSignal
{
    _progressSignal = progressSignal;
    [(TGPassportFileCollectionItemView *)self.boundView setProgressSignal:_progressSignal];
}

- (void)setIsRequired:(bool)isRequired
{
    _isRequired = isRequired;
    [(TGPassportFileCollectionItemView *)self.boundView setIsRequired:_isRequired];
}

- (void)setImageViewHidden:(bool)imageViewHidden
{
    _imageViewHidden = imageViewHidden;
    [(TGPassportFileCollectionItemView *)self.boundView setImageViewHidden:_imageViewHidden];
}

- (void)bindView:(TGPassportFileCollectionItemView *)view
{
    [super bindView:view];
    
    [view setTitle:_title];
    [view setSubtitle:_subtitle];
    [view setIcon:_icon];
    [view setImageSignal:_imageSignal];
    [view setIsRequired:_isRequired];
    [view setImageViewHidden:_imageViewHidden];
    [view setProgressSignal:_progressSignal];
    [view setCalculatedSize:_calculatedSize];
    
    __weak TGPassportFileCollectionItem *weakSelf = self;
    view.removeRequested = ^
    {
        __strong TGPassportFileCollectionItem *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if (strongSelf->_removeRequested)
                strongSelf->_removeRequested(strongSelf);
        }
    };
    view.enableEditing = _removeRequested != nil;
}

- (void)unbindView
{
    [super unbindView];
}

- (void)resetAnimated:(bool)animated
{
    [(TGPassportFileCollectionItemView *)self.boundView setShowsEditingOptions:false animated:animated];
}

- (void)itemSelected:(id)__unused actionTarget
{
    if (self.action != nil)
        self.action(self);
}

- (CGSize)imageSize
{
    return [(TGPassportFileCollectionItemView *)self.view imageSize];
}

- (UIView *)imageView
{
    return [(TGPassportFileCollectionItemView *)self.view imageView];
}

@end
