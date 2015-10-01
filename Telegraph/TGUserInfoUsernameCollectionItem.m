#import "TGUserInfoUsernameCollectionItem.h"

#import "TGUserInfoUsernameCollectionItemView.h"

@interface TGUserInfoUsernameCollectionItem ()
{
    NSString *_label;
}

@end

@implementation TGUserInfoUsernameCollectionItem

- (instancetype)initWithLabel:(NSString *)label username:(NSString *)username
{
    self = [super init];
    if (self != nil)
    {
        self.transparent = true;
        self.deselectAutomatically = true;
        
        _label = label;
        _username = username;
    }
    return self;
}

- (Class)itemViewClass
{
    return [TGUserInfoUsernameCollectionItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, 61.0f);
}

- (void)bindView:(TGUserInfoUsernameCollectionItemView *)view
{
    [super bindView:view];
    
    [view setLabel:_label];
    [view setUsername:_username];
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
    if (action == @selector(copy:))
        return true;
    
    return false;
}

- (void)itemPerformAction:(SEL)action
{
    if (action == @selector(copy:))
    {
        if (_username.length != 0)
            [[UIPasteboard generalPasteboard] setString:_username];
    }
}

- (void)itemSelected:(id)actionTarget {
    if ([actionTarget respondsToSelector:_action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [actionTarget performSelector:_action withObject:nil];
#pragma clang diagnostic pop
    }
}

@end
