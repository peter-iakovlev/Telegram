#import "TGEditableCollectionItemView.h"
#import "TGProxySignals.h"

@class TGProxyItem;

@interface TGProxyCollectionItemView : TGEditableCollectionItemView

@property (nonatomic, copy) void (^removeRequested)();
@property (nonatomic, copy) void (^infoPressed)();

- (void)setProxy:(TGProxyItem *)proxy;
- (void)setIsChecked:(bool)isChecked;

- (void)setStatus:(TGConnectionState)status;
- (void)setAvailability:(TGProxyCachedAvailability *)availability;

@end
