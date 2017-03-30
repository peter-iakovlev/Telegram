/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGContactsController.h"

#import "TGNavigationController.h"

@class TGConversation;

@interface TGSelectContactController : TGContactsController <TGNavigationControllerItem>

@property (nonatomic) bool shouldBeRemovedFromNavigationAfterHiding;

@property (nonatomic, strong) ASHandle *actionsHandle;

@property (nonatomic, strong) TGConversation *channelConversation;
@property (nonatomic, strong) NSString *channelLink;

@property (nonatomic, copy) void (^onChannelMembersInvited)(NSArray *users);
@property (nonatomic, copy) void (^onCreateLink)();
@property (nonatomic, copy) void (^onCall)(TGUser *);

- (id)initWithCreateGroup:(bool)createGroup createEncrypted:(bool)createEncrypted createBroadcast:(bool)createBroadcast createChannel:(bool)createChannel inviteToChannel:(bool)inviteToChannel showLink:(bool)showLink;

- (id)initWithCreateGroup:(bool)createGroup createEncrypted:(bool)createEncrypted createBroadcast:(bool)createBroadcast createChannel:(bool)createChannel inviteToChannel:(bool)inviteToChannel showLink:(bool)showLink call:(bool)call;

@end
