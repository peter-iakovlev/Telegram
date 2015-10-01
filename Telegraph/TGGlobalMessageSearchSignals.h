#import <SSignalKit/SSignalKit.h>

@interface TGGlobalMessageSearchSignals : NSObject

+ (SSignal *)search:(NSString *)query includeMessages:(bool)includeMessages itemMapping:(id (^)(id))itemMapping;
+ (SSignal *)searchMessages:(NSString *)query peerId:(int64_t)peerId accessHash:(int64_t)accessHash itemMapping:(id (^)(id))itemMapping;

+ (void)clearRecentResults;
+ (void)addRecentPeerResult:(int64_t)peerId;
+ (void)removeRecentPeerResult:(int64_t)peerId;
+ (SSignal *)recentPeerResults:(id (^)(id))itemMapping;

@end
