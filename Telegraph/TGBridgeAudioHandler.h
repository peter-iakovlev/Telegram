#import "TGBridgeSubscriptionHandler.h"

@interface TGBridgeAudioHandler : TGBridgeSubscriptionHandler

+ (void)handleIncomingAudioWithURL:(NSURL *)url metadata:(NSDictionary *)metadata server:(TGBridgeServer *)server;

@end
