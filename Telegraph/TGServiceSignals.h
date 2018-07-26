#import <SSignalKit/SSignalKit.h>

@interface TGDeepLinkInfo : NSObject

@property (nonatomic, readonly) bool updateNeeded;
@property (nonatomic, readonly) NSString *message;
@property (nonatomic, readonly) NSArray *entities;

@end

@interface TGServiceSignals : NSObject

+ (SSignal *)appChangelogMessages:(NSString *)previousVersion;
+ (SSignal *)reportSpam:(int64_t)peerId accessHash:(int64_t)accessHash;
+ (SSignal *)deepLinkInfo:(NSString *)path;

@end
