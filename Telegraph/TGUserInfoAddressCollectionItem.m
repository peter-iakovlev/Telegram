#import "TGUserInfoAddressCollectionItem.h"
#import <LegacyComponents/TGLocationSignals.h>

#import "TGUserInfoAddressCollectionItemView.h"

@interface TGUserInfoAddressCollectionItem ()
{
    SMetaDisposable *_geocodeDisposable;
    CLPlacemark *_placemark;
}
@end

@implementation TGUserInfoAddressCollectionItem

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        
    }
    return self;
}

- (void)dealloc
{
    [_geocodeDisposable dispose];
}

- (Class)itemViewClass
{
    return [TGUserInfoAddressCollectionItemView class];
}

- (void)bindView:(TGUserInfoAddressCollectionItemView *)view
{
    [super bindView:view];
    
    [view setPlacemark:_placemark];
}

- (void)setAddress:(NSDictionary *)address
{
    if ([_address isEqual:address])
        return;
    
    _address = address;
    _placemark = nil;
    self.selectable = false;
    
    if (_geocodeDisposable == nil)
        _geocodeDisposable = [[SMetaDisposable alloc] init];
    
    __weak TGUserInfoAddressCollectionItem *weakSelf = self;
    [_geocodeDisposable setDisposable:[[[TGLocationSignals geocodeAddressDictionary:_address] deliverOn:[SQueue mainQueue]] startWithNext:^(CLPlacemark *next)
    {
        __strong TGUserInfoAddressCollectionItem *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        strongSelf.selectable = next != nil;
        strongSelf->_placemark = next;
        [(TGUserInfoAddressCollectionItemView *)strongSelf.boundView setPlacemark:next];
    }]];
}

- (CLPlacemark *)placemark
{
    return _placemark;
}

- (CGFloat)maximumWidth
{
    return [super maximumWidth] - 100.0f;
}

- (void)itemSelected:(id)actionTarget
{
    if (self.checking)
    {
        self.isChecked = !self.isChecked;
        return;
    }
    
    if (self.selectable && _action != NULL && [actionTarget respondsToSelector:_action])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if ([NSStringFromSelector(_action) rangeOfString:@":"].location != NSNotFound)
            [actionTarget performSelector:_action withObject:self];
        else
            [actionTarget performSelector:_action];
#pragma clang diagnostic pop
    }
}

- (bool)itemWantsMenu
{
    return !self.checking;
}

- (bool)itemCanPerformAction:(SEL)action
{
    if (!self.checking && action == @selector(copy:))
        return true;
    
    return false;
}

- (void)itemPerformAction:(SEL)action
{
    if (action == @selector(copy:))
    {
        if (self.text.length > 0)
        {
            NSString *text = [self.text stringByReplacingOccurrencesOfString:@"\n" withString:@", "];
            [[UIPasteboard generalPasteboard] setString:text];
        }
    }
}

@end
