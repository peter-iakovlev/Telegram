/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGUpdateConfigActor.h"

#import "ActionStage.h"

#import "TGTelegraph.h"

#import <MTProtoKit/MTRequest.h>
#import "TGTelegramNetworking.h"

#import "TGUserDataRequestBuilder.h"

@interface TGUpdateConfigActor ()
{
    bool _inviteReceived;
    bool _configReceived;
    bool _userReceived;
}

@end

@implementation TGUpdateConfigActor

+ (NSString *)genericPath
{
    return @"/tg/service/updateConfig";
}

- (void)execute:(NSDictionary *)__unused options
{
    [self addCancelToken:[TGTelegraphInstance doRequestInviteText:self]];
    
    {
        MTRequest *request = [[MTRequest alloc] init];
        
        request.body = [[TLRPChelp_getConfig$help_getConfig alloc] init];
        
        __weak TGUpdateConfigActor *weakSelf = self;
        [request setCompleted:^(TLConfig *result, __unused NSTimeInterval timestamp, id error)
        {
            [ActionStageInstance() dispatchOnStageQueue:^
            {
                __strong TGUpdateConfigActor *strongSelf = weakSelf;
                if (error == nil)
                    [strongSelf configRequestSuccess:result];
                else
                    [strongSelf configRequestFailed];
            }];
        }];
        
        [self addCancelToken:request.internalId];
        [[TGTelegramNetworking instance] addRequest:request];
    }
    {
        MTRequest *request = [[MTRequest alloc] init];
        
        TLRPCusers_getUsers$users_getUsers *getUsers = [[TLRPCusers_getUsers$users_getUsers alloc] init];
        
        getUsers.n_id = @[[[TLInputUser$inputUserSelf alloc] init]];
        request.body = getUsers;
        
        __weak TGUpdateConfigActor *weakSelf = self;
        [request setCompleted:^(id result, __unused NSTimeInterval timestamp, id error)
        {
            [ActionStageInstance() dispatchOnStageQueue:^
            {
                __strong TGUpdateConfigActor *strongSelf = weakSelf;
                if (error == nil)
                    [strongSelf getUsersSuccess:result];
                else
                    [strongSelf getUsersFailed];
            }];
        }];
        
        [self addCancelToken:request.internalId];
        [[TGTelegramNetworking instance] addRequest:request];
    }
}

- (void)_maybeComplete
{
    if (_inviteReceived && _configReceived && _userReceived)
        [ActionStageInstance() actionCompleted:self.path result:nil];
}

- (void)inviteTextRequestSuccess:(TLhelp_InviteText *)inviteText
{
    TGDispatchOnMainThread(^
    {
        if (inviteText.message.length != 0)
        {
            [[NSUserDefaults standardUserDefaults] setObject:inviteText.message forKey:@"TG_inviteText"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    });
    
    _inviteReceived = true;
    [self _maybeComplete];
}

- (void)inviteTextRequestFailed
{
    _inviteReceived = true;
    [self _maybeComplete];
}

- (void)configRequestSuccess:(TLConfig *)config
{
    int32_t maxChatParticipants = MAX(100, config.chat_size_max);
    int32_t maxBroadcastReceivers = MAX(100, config.broadcast_size_max);
    [TGDatabaseInstance() setCustomProperty:@"maxChatParticipants" value:[NSData dataWithBytes:&maxChatParticipants length:4]];
    [TGDatabaseInstance() setCustomProperty:@"maxBroadcastReceivers" value:[NSData dataWithBytes:&maxBroadcastReceivers length:4]];
 
    _configReceived = true;
    [self _maybeComplete];
}

- (void)configRequestFailed
{
    _configReceived = true;
    [self _maybeComplete];
}

- (void)getUsersSuccess:(NSArray *)users
{
    [TGUserDataRequestBuilder executeUserDataUpdate:users];
    
    _userReceived = true;
    [self _maybeComplete];
}

- (void)getUsersFailed
{
    _userReceived = true;
    [self _maybeComplete];
}

@end
