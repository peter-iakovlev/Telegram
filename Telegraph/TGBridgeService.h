#import "TGBridgeServer.h"

@interface TGBridgeService : NSObject

@property (nonatomic, weak) TGBridgeServer *server;

- (instancetype)initWithServer:(TGBridgeServer *)server;

@end
