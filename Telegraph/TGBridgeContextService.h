#import <Foundation/Foundation.h>

@class TGBridgeServer;

@interface TGBridgeContextService : NSObject

- (instancetype)initWithServer:(TGBridgeServer *)server;

@end