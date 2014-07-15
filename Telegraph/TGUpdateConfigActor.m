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

@interface TGUpdateConfigActor ()
{
    bool _inviteReceived;
    bool _configReceived;
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
}

- (void)inviteTextRequestSuccess:(TLhelp_InviteText *)inviteText
{
    _inviteReceived = true;
    
    TGDispatchOnMainThread(^
    {
        if (inviteText.message.length != 0)
        {
            [[NSUserDefaults standardUserDefaults] setObject:inviteText.message forKey:@"TG_inviteText"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    });
    
    if (_inviteReceived && _configReceived)
        [ActionStageInstance() actionCompleted:self.path result:nil];
}

- (void)inviteTextRequestFailed
{
    _inviteReceived = true;
    
    if (_inviteReceived && _configReceived)
        [ActionStageInstance() actionFailed:self.path reason:-1];
}

- (void)configRequestSuccess:(TLConfig *)config
{
    _configReceived = true;
    
    int32_t maxChatParticipants = MAX(100, config.chat_size_max);
    int32_t maxBroadcastReceivers = MAX(100, config.broadcast_size_max);
    [TGDatabaseInstance() setCustomProperty:@"maxChatParticipants" value:[NSData dataWithBytes:&maxChatParticipants length:4]];
    [TGDatabaseInstance() setCustomProperty:@"maxBroadcastReceivers" value:[NSData dataWithBytes:&maxBroadcastReceivers length:4]];
    
    if (_inviteReceived && _configReceived)
        [ActionStageInstance() actionCompleted:self.path result:nil];
}

- (void)configRequestFailed
{
    _configReceived = true;
    
    if (_inviteReceived && _configReceived)
        [ActionStageInstance() actionFailed:self.path reason:-1];
}

@end
