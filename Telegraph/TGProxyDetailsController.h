#import "TGCollectionMenuController.h"

@class TGProxyItem;

@interface TGProxyDetailsController : TGCollectionMenuController

@property (nonatomic, copy) void (^completionBlock)(TGProxyItem *);

- (instancetype)initWithProxy:(TGProxyItem *)proxy;

@end
