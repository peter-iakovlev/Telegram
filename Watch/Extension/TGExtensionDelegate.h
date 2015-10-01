#import <Foundation/Foundation.h>

@class TGNeoChatsController;
@class TGFileCache;

@interface TGExtensionDelegate : NSObject <WKExtensionDelegate>

@property (nonatomic, readonly) TGFileCache *audioCache;
@property (nonatomic, readonly) TGFileCache *imageCache;

@property (nonatomic, readonly) TGNeoChatsController *chatsController;

+ (instancetype)instance;

@end
