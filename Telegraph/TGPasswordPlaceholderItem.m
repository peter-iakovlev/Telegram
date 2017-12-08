#import "TGPasswordPlaceholderItem.h"
#import "TGPasswordPlaceholderItemView.h"

#import <LegacyComponents/TGImageUtils.h>
#import <LegacyComponents/TGViewController.h>

@interface TGPasswordPlaceholderItem ()
{
    UIImage *_icon;
    NSString *_title;
    NSString *_text;
}
@end

@implementation TGPasswordPlaceholderItem

- (instancetype)initWithIcon:(UIImage *)icon title:(NSString *)title text:(NSString *)text
{
    self = [super init];
    if (self != nil)
    {
        self.transparent = true;
        self.highlightable = false;
        self.selectable = false;
        
        _icon = icon;
        _title = title;
        _text = text;
    }
    return self;
}

- (void)bindView:(TGCollectionItemView *)view
{
    [super bindView:view];
    
    [(TGPasswordPlaceholderItemView *)self.boundView setIcon:_icon title:_title text:_text];
}

- (Class)itemViewClass
{
    return [TGPasswordPlaceholderItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize safeAreaInset:(UIEdgeInsets)__unused safeAreaInset
{
    if (containerSize.width > containerSize.height)
        return CGSizeMake(containerSize.width, TGScreenPixel);
    
    CGFloat height = 0.0f;
    if ([TGViewController hasTallScreen])
        height = 406.0f;
    else if ([TGViewController hasVeryLargeScreen])
        height = 386.0f;
    else if ([TGViewController hasLargeScreen])
        height = 350.0f;
    else if ([TGViewController isWidescreen])
        height = 334.0f;
    else
        height = 250.0f;
    
    return CGSizeMake(containerSize.width, height);
}

@end
