/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGUserInfoButtonCollectionItem.h"

#import "TGUserInfoButtonCollectionItemView.h"

@interface TGUserInfoButtonCollectionItem ()
{
    SEL _action;
}

@end

@implementation TGUserInfoButtonCollectionItem

- (instancetype)initWithTitle:(NSString *)title action:(SEL)action
{
    self = [super init];
    if (self != nil)
    {
        self.transparent = true;
        
        _title = title;
        _action = action;
        
        _titleColor = TGAccentColor();
    }
    return self;
}

- (Class)itemViewClass
{
    return [TGUserInfoButtonCollectionItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, 44.0f);
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

- (void)bindView:(TGUserInfoButtonCollectionItemView *)view
{
    [super bindView:view];
    
    [view setTitle:_title];
    [view setTitleColor:_titleColor];
    [view setEditing:_editing];
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    
    [((TGUserInfoButtonCollectionItemView *)self.boundView) setTitle:_title];
}

- (void)setEditing:(bool)editing
{
    _editing = editing;
    
    [((TGUserInfoButtonCollectionItemView *)self.boundView) setEditing:_editing];
}

@end
