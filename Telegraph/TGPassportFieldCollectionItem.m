#import "TGPassportFieldCollectionItem.h"
#import "TGPassportFieldCollectionItemView.h"

#import <LegacyComponents/TGFont.h>

@interface TGPassportFieldCollectionItem ()
{
    CGSize _calculatedSize;
}
@end

@implementation TGPassportFieldCollectionItem

- (instancetype)initWithTitle:(NSString *)title action:(SEL)action
{
    self = [super init];
    if (self != nil)
    {
        _title = title;
        _action = action;
    }
    return self;
}

- (Class)itemViewClass
{
    return [TGPassportFieldCollectionItemView class];
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
    if (_errors.count > 0) {
        NSString *text = TGLocalized(@"Passport.CorrectErrors");
        if (text.length > 0)
            attributedText = [[NSMutableAttributedString alloc] initWithString:text];
        else
            attributedText = [[NSMutableAttributedString alloc] initWithString:[_errors componentsJoinedByString:@"\n"]];
    }
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByWordWrapping;
    style.lineSpacing = 2.0f;
    style.paragraphSpacing = 0.0f;
    [attributedText addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attributedText.length)];
    [attributedText addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, attributedText.length)];
    
    CGSize textSize = [attributedText boundingRectWithSize:CGSizeMake(containerSize.width - 15.0f - 40.0f - safeAreaInset.left - safeAreaInset.right, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:NULL].size;
    
    textSize.width = CGCeil(textSize.width);
    textSize.height = CGCeil(textSize.height);
    
    _calculatedSize = CGSizeMake(textSize.width, textSize.height);
    [(TGPassportFieldCollectionItemView *)self.boundView setCalculatedSize:_calculatedSize];
    
    return CGSizeMake(containerSize.width, MAX(64.0f, 48.0f + _calculatedSize.height));
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    [(TGPassportFieldCollectionItemView *)self.boundView setTitle:_title];
}

- (void)setSubtitle:(NSString *)subtitle
{
    _subtitle = subtitle;
    [(TGPassportFieldCollectionItemView *)self.boundView setSubtitle:_subtitle];
}

- (void)setErrors:(NSArray *)errors
{
    _errors = errors;
    [(TGPassportFieldCollectionItemView *)self.boundView setErrors:_errors];
}

- (void)setIsChecked:(bool)isChecked
{
    _isChecked = isChecked;
    [(TGPassportFieldCollectionItemView *)self.boundView setIsChecked:_isChecked];
}

- (void)setIsRequired:(bool)isRequired
{
    _isRequired = isRequired;
     [(TGPassportFieldCollectionItemView *)self.boundView setIsRequired:_isRequired];
}

- (void)bindView:(TGCollectionItemView *)view
{
    [super bindView:view];
    
    [(TGPassportFieldCollectionItemView *)view setTitle:_title];
    [(TGPassportFieldCollectionItemView *)view setSubtitle:_subtitle];
    [(TGPassportFieldCollectionItemView *)view setErrors:_errors];
    [(TGPassportFieldCollectionItemView *)view setIsChecked:_isChecked];
    [(TGPassportFieldCollectionItemView *)view setIsRequired:_isRequired];
    [(TGPassportFieldCollectionItemView *)view setCalculatedSize:_calculatedSize];
}

- (void)unbindView
{
    [super unbindView];
}


- (void)itemSelected:(id)actionTarget
{
    if (_action != NULL && [actionTarget respondsToSelector:_action])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [actionTarget performSelector:_action];
#pragma clang diagnostic pop
    }
}

@end
