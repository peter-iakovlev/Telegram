/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGUserInfoEditingPhoneCollectionItem.h"

#import "TGUserInfoEditingPhoneCollectionItemView.h"

@interface TGUserInfoEditingPhoneCollectionItem () <TGUserInfoEditingPhoneCollectionItemViewDelegate>

@end

@implementation TGUserInfoEditingPhoneCollectionItem

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.transparent = true;
        self.selectable = false;
    }
    return self;
}

- (Class)itemViewClass
{
    return [TGUserInfoEditingPhoneCollectionItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, 44.0f);
}

- (void)bindView:(TGUserInfoEditingPhoneCollectionItemView *)view
{
    [super bindView:view];
    
    view.delegate = self;
    
    [view setLabel:_label];
    [view setPhone:_phone];
}

- (void)unbindView
{
    ((TGUserInfoEditingPhoneCollectionItemView *)[self boundView]).delegate = nil;
    
    [super unbindView];
}

- (void)setLabel:(NSString *)label
{
    _label = label;
    
    [(TGUserInfoEditingPhoneCollectionItemView *)[self boundView] setLabel:_label];
}

- (void)setPhone:(NSString *)phone
{
    _phone = phone;
    
    [(TGUserInfoEditingPhoneCollectionItemView *)[self boundView] setPhone:_phone];
}

- (void)makePhoneFieldFirstResponder
{
    [(TGUserInfoEditingPhoneCollectionItemView *)[self boundView] makePhoneFieldFirstResponder];
}

- (void)editingPhoneItemViewPhoneChanged:(TGUserInfoEditingPhoneCollectionItemView *)editingPhoneItemView phone:(NSString *)phone
{
    if (editingPhoneItemView == [self boundView])
    {
        _phone = phone;
    }
}

- (void)editingPhoneItemViewRequestedDelete:(TGUserInfoEditingPhoneCollectionItemView *)editingPhoneItemView
{
    if (editingPhoneItemView == [self boundView])
    {
        id<TGUserInfoEditingPhoneCollectionItemDelegate> delegate = _delegate;
        if ([delegate respondsToSelector:@selector(editingPhoneItemRequestedDelete:)])
            [delegate editingPhoneItemRequestedDelete:self];
    }
}

- (void)editingPhoneItemViewLabelPressed:(TGUserInfoEditingPhoneCollectionItemView *)editingPhoneItemView
{
    if (editingPhoneItemView == [self boundView])
    {
        id<TGUserInfoEditingPhoneCollectionItemDelegate> delegate = _delegate;
        if ([delegate respondsToSelector:@selector(editingPhoneItemRequestedLabelSelection:)])
            [delegate editingPhoneItemRequestedLabelSelection:self];
    }
}

@end
