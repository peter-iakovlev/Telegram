#import "TGCollectionMenuController.h"

@class MTSocksProxySettings;

@interface TGProxySetupController : TGCollectionMenuController

@property (nonatomic, copy) void (^completion)(MTSocksProxySettings *settings, bool inactive);

- (instancetype)initWithCurrentSettings;

@end
