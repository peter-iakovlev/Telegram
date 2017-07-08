/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGSwitchCollectionItem.h"

#import "ASHandle.h"

#import "TGSwitchCollectionItemView.h"

@interface TGSwitchCollectionItem () <TGSwitchCollectionItemViewDelegate>
{
    
}

@end

@implementation TGSwitchCollectionItem

- (instancetype)initWithTitle:(NSString *)title isOn:(bool)isOn
{
    self = [super init];
    if (self != nil)
    {
        self.highlightable = false;
        self.selectable = false;
        
        _title = title;
        _isOn = isOn;
        
        _isEnabled = true;
    }
    return self;
}

- (Class)itemViewClass
{
    if (_isPermission) {
        return [TGPermissionSwitchCollectionItemView class];
    } else {
        return [TGSwitchCollectionItemView class];
    }
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, 44);
}

- (void)bindView:(TGCollectionItemView *)view
{
    [super bindView:view];
    
    [((TGSwitchCollectionItemView *)view) setFullSeparator:_fullSeparator];
    [((TGSwitchCollectionItemView *)view) setTitle:_title];
    [((TGSwitchCollectionItemView *)view) setIsOn:_isOn animated:false];
    [((TGSwitchCollectionItemView *)view) setIsEnabled:_isEnabled];
    ((TGSwitchCollectionItemView *)view).delegate = self;
}

- (void)unbindView
{
    ((TGSwitchCollectionItemView *)[self boundView]).delegate = self;
    
    [super unbindView];
}

- (void)setTitle:(NSString *)title
{
    if (!TGStringCompare(_title, title))
    {
        _title = title;
        
        if ([self boundView] != nil)
            [((TGSwitchCollectionItemView *)[self boundView]) setTitle:_title];
    }
}

- (void)setIsOn:(bool)isOn
{
    [self setIsOn:isOn animated:true];
}

- (void)setIsOn:(bool)isOn animated:(bool)animated
{
    if (_isOn != isOn)
    {
        _isOn = isOn;
        
        if ([self boundView] != nil)
            [((TGSwitchCollectionItemView *)[self boundView]) setIsOn:_isOn animated:animated];
    }
}

- (void)switchCollectionItemViewChangedValue:(TGSwitchCollectionItemView *)switchItemView isOn:(bool)isOn
{
    if (switchItemView == [self boundView])
    {
        _isOn = isOn;
        
        if (_toggled)
            _toggled(isOn, self);
        [_interfaceHandle requestAction:@"switchItemChanged" options:@{@"item": self, @"value": @(_isOn)}];
    }
}

@end
