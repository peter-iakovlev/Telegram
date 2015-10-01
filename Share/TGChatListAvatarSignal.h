#import <Foundation/Foundation.h>

#import <SSignalKit/SSignalKit.h>

#import "TGPeerId.h"
#import "TGShareContext.h"
#import "TGFileLocation.h"

@interface TGChatListAvatarSignal : NSObject

+ (SSignal *)chatListAvatarWithContext:(TGShareContext *)context location:(TGFileLocation *)location;
+ (SSignal *)chatListAvatarWithContext:(TGShareContext *)context letters:(NSString *)letters peerId:(TGPeerId)peerId;

@end
