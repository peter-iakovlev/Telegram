#import <Foundation/Foundation.h>

#import <SSignalKit/SSignalKit.h>

#import <LegacyDatabase/LegacyDatabase.h>

#import "TGPeerId.h"
#import "TGFileLocation.h"

@interface TGChatListAvatarSignal : NSObject

+ (SSignal *)chatListAvatarWithContext:(TGShareContext *)context location:(TGFileLocation *)location;
+ (SSignal *)chatListAvatarWithContext:(TGShareContext *)context letters:(NSString *)letters peerId:(TGPeerId)peerId;

@end
