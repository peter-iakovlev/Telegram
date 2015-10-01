/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGSupportPeerActor.h"

#import "TGUserDataRequestBuilder.h"

#import "ActionStage.h"

#import "TGTelegraph.h"
#import "TGDatabase.h"

#import "TLUser$modernUser.h"

@implementation TGSupportPeerActor

+ (void)load
{
    [ASActor registerActorClass:self];
}

+ (NSString *)genericPath
{
    return @"/tg/support/preferredPeer";
}

- (void)execute:(NSDictionary *)__unused options
{
    __weak TGSupportPeerActor *weakSelf = self;
    self.cancelToken = [TGTelegraphInstance doRequestPrefferredSuportPeer:^(TLhelp_Support *supportDesc)
    {
        __strong TGSupportPeerActor *strongSelf = weakSelf;
        [strongSelf requestCompleted:supportDesc];
    } fail:^
    {
        __strong TGSupportPeerActor *strongSelf = weakSelf;
        [strongSelf requestFailed];
    }];
}

- (void)requestCompleted:(TLhelp_Support *)supportDesc
{
    [TGUserDataRequestBuilder executeUserDataUpdate:@[supportDesc.user]];
    
    int32_t uid = ((TLUser$modernUser *)supportDesc.user).n_id;
    [TGDatabaseInstance() setCustomProperty:@"supportAccountUid" value:[[NSData alloc] initWithBytes:&uid length:4]];
    
    [ActionStageInstance() actionCompleted:self.path result:@{@"uid": @(uid)}];
}

- (void)requestFailed
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

@end
