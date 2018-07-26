#import "TGCollectionItem.h"
#import <SSignalKit/SSignalKit.h>

@class TGProxyItem;

@interface TGProxyCollectionItem : TGCollectionItem

@property (nonatomic, strong) TGProxyItem *proxy;
@property (nonatomic, assign) bool selected;
@property (nonatomic, copy) void (^infoPressed)(void);
@property (nonatomic, copy) void (^removeRequested)(void);
@property (nonatomic, copy) void (^pressed)(void);

- (instancetype)initWithProxy:(TGProxyItem *)proxy removeRequested:(void (^)())removeRequested;

- (void)setStatusSignal:(SSignal *)signal;
- (void)setAvailabilitySignal:(SSignal *)signal;

@end
