#import <Foundation/Foundation.h>

#import <SSignalKit/SSignalKit.h>

#import "TGGroupInvitationInfo.h"

@class TGUser;

@interface TGGroupManagementSignals : NSObject

+ (SSignal *)makeGroupWithTitle:(NSString *)title users:(NSArray *)users;
+ (SSignal *)exportGroupInvitationLink:(int32_t)groupId;
+ (SSignal *)groupInvitationLinkInfo:(NSString *)hash;
+ (SSignal *)acceptGroupInvitationLink:(NSString *)hash;
+ (SSignal *)updateGroupPhoto:(int64_t)peerId uploadedFile:(SSignal *)uploadedFile;
+ (SSignal *)inviteUserWithId:(int32_t)userId toGroupWithId:(int32_t)groupId;
+ (SSignal *)toggleGroupHasAdmins:(int64_t)peerId hasAdmins:(bool)hasAdmins;
+ (SSignal *)toggleUserIsAdmin:(int64_t)peerId user:(TGUser *)user isAdmin:(bool)isAdmin;
+ (SSignal *)migrateGroup:(int64_t)peerId;

@end
