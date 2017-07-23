#import <Foundation/Foundation.h>

#import <SSignalKit/SSignalKit.h>
#import <LegacyDatabase/LegacyDatabase.h>

@class TGUserModel;

@interface TGChatListSignal : NSObject

+ (TGUserModel *)userModelWithApiUser:(Api70_User *)user;

+ (SSignal *)remoteChatListWithContext:(TGShareContext *)context;



@end
