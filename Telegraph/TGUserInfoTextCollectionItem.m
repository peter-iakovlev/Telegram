#import "TGUserInfoTextCollectionItem.h"

#import "TGUserInfoTextCollectionItemView.h"

@implementation TGUserInfoTextCollectionItem

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.selectable = false;
        self.transparent = true;
        _title = TGLocalized(@"Profile.BotInfo");
    }
    return self;
}

- (Class)itemViewClass
{
    return [TGUserInfoTextCollectionItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, [TGUserInfoTextCollectionItemView heightForWidth:containerSize.width text:_text]);
}

- (void)bindView:(TGUserInfoTextCollectionItemView *)view
{
    [super bindView:view];
    
    [view setTitle:_title];
    [view setText:_text];
}

- (void)setText:(NSString *)text
{
    _text = text;
    [((TGUserInfoTextCollectionItemView *)self.boundView) setText:_text];
}

- (void)unbindView
{
    [super unbindView];
}

- (bool)itemWantsMenu
{
    return true;
}

- (bool)itemCanPerformAction:(SEL)action
{
    return action == @selector(copy:);
}

- (void)itemPerformAction:(SEL)action
{
    if (action == @selector(copy:))
    {
        if (_text.length != 0)
            [[UIPasteboard generalPasteboard] setString:_text];
    }
}

@end
