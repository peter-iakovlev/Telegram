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

- (void)setChecking:(bool)checking {
    _checking = checking;
    self.highlightDisabled = checking;
}

- (void)setIsChecked:(bool)isChecked
{
    _isChecked = isChecked;
    
    if ([self boundView] != nil)
        [(TGUserInfoUsernameCollectionItemView *)[self boundView] setIsChecked:_isChecked animated:true];
}

- (void)bindView:(TGUserInfoUsernameCollectionItemView *)view
{
    [super bindView:view];
    
    [view setLabel:_label];
    [view setUsername:_username];
    [view setLastInList:_lastInList];
    [view setChecking:_checking];
    [view setIsChecked:_isChecked animated:false];
}

- (void)unbindView
{
    [super unbindView];
}

- (bool)itemWantsMenu
{
    return !_checking;
}

- (bool)itemCanPerformAction:(SEL)action
{
    if (!_checking && action == @selector(copy:))
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
    if (self.checking)
    {
        self.isChecked = !self.isChecked;
        return;
    }
    
    if ([actionTarget respondsToSelector:_action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if ([NSStringFromSelector(_action) rangeOfString:@":"].location != NSNotFound)
            [actionTarget performSelector:_action withObject:self];
        else
            [actionTarget performSelector:_action];
#pragma clang diagnostic pop
    }
}

@end
