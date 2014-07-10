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

@implementation TGUpdateConfigActor

+ (NSString *)genericPath
{
    return @"/tg/service/updateConfig";
}

- (void)execute:(NSDictionary *)__unused options
{
    self.cancelToken = [TGTelegraphInstance doRequestInviteText:self];
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
    
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

- (void)inviteTextRequestFailed
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

@end
