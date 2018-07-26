#import "TGProxyCollectionItem.h"

#import "TGProxyCollectionItemView.h"

@interface TGProxyCollectionItem ()
{
    SMetaDisposable *_statusDisposable;
    SMetaDisposable *_availabilityDisposable;
    
    TGProxyCachedAvailability *_availability;
    TGConnectionState _state;
}
@end

@implementation TGProxyCollectionItem

- (instancetype)initWithProxy:(TGProxyItem *)proxy removeRequested:(void (^)())removeRequested
{
    self = [super init];
    if (self != nil)
    {
        _proxy = proxy;
        _removeRequested = [removeRequested copy];
        
        _statusDisposable = [[SMetaDisposable alloc] init];
        _availabilityDisposable = [[SMetaDisposable alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_statusDisposable dispose];
    [_availabilityDisposable dispose];
}

- (Class)itemViewClass
{
    return [TGProxyCollectionItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, 63.0f);
}

- (void)setSelected:(bool)selected {
    _selected = selected;
    [((TGProxyCollectionItemView *)self.boundView) setIsChecked:selected];
}

- (void)itemSelected:(id)__unused actionTarget
{
    if (_pressed != nil)
        _pressed();
}

- (void)setProxy:(TGProxyItem *)proxy {
    _proxy = proxy;
    [(TGProxyCollectionItemView *)self.boundView setProxy:_proxy];
}

- (void)bindView:(TGProxyCollectionItemView *)view
{
    [super bindView:view];
    
    [view setProxy:_proxy];
    [view setIsChecked:_selected];
    [view setStatus:_state];
    [view setAvailability:_availability];
    __weak TGProxyCollectionItem *weakSelf = self;
    view.infoPressed = ^
    {
        __strong TGProxyCollectionItem *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if (strongSelf->_infoPressed)
                strongSelf->_infoPressed();
        }
    };
    view.removeRequested = ^
    {
        __strong TGProxyCollectionItem *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if (strongSelf->_removeRequested)
                strongSelf->_removeRequested();
        }
    };
    view.enableEditing = _removeRequested != nil;
}

- (void)unbindView
{
    
}

- (void)setStatusSignal:(SSignal *)signal
{
    __weak TGProxyCollectionItem *weakSelf = self;
    [_statusDisposable setDisposable:[[signal deliverOn:[SQueue mainQueue]] startWithNext:^(NSNumber *next)
    {
        __strong TGProxyCollectionItem *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            TGConnectionState state = (TGConnectionState)next.integerValue;
            strongSelf->_state = state;
            [(TGProxyCollectionItemView *)strongSelf.boundView setStatus:state];
        }
    }]];
}

- (void)setAvailabilitySignal:(SSignal *)signal
{
    __weak TGProxyCollectionItem *weakSelf = self;
    [_availabilityDisposable setDisposable:[[signal deliverOn:[SQueue mainQueue]] startWithNext:^(TGProxyCachedAvailability *next)
    {
        __strong TGProxyCollectionItem *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            strongSelf->_availability = next;
            [(TGProxyCollectionItemView *)strongSelf.boundView setAvailability:next];
        }
    }]];
}

@end
