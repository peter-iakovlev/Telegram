#import <Foundation/Foundation.h>

#import <SSignalKit/SSignalKit.h>

@interface TGPeerInfoSignals : NSObject

+ (SSignal *)resolveBotDomain:(NSString *)query;
+ (SSignal *)resolveBotDomain:(NSString *)query contextBotsOnly:(bool)contextBotsOnly;

+ (SSignal *)dismissReportSpamForPeers;

@end
