#import "TGExtendedUserDataRequestActor.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"
#import "TGUpdateStateRequestBuilder.h"
#import "TGUserDataRequestBuilder.h"

#import "TGTelegraph.h"
#import "TGDatabase.h"

#import "TGUser+Telegraph.h"

#import "TGTelegramNetworking.h"

#import "TLUser$modernUser.h"

#import "TGBotSignals.h"

#import "TLUserFull$userFull.h"

@implementation TGExtendedUserDataRequestActor

+ (NSString *)genericPath
{
    return @"/tg/completeUsers/@";
}

- (void)execute:(NSDictionary *)__unused options
{
    int uid = [[options objectForKey:@"uid"] intValue];
    if (uid == 0)
    {
        [ActionStageInstance() nodeRetrieveFailed:self.path];
        return;
    }
    
    bool outdated = false;
    int userLink = [TGDatabaseInstance() loadUserLink:uid outdated:&outdated];
    
    if ([self.path hasSuffix:@"force)"])
    {
        self.cancelToken = [TGTelegraphInstance doRequestExtendedUserData:uid actor:self];
    }
    else
    {
        if (outdated)
        {
            [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/completeUsers/(%d,force)", uid] options:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithInt:uid], @"uid", nil] watcher:TGTelegraphInstance];
        }
        
        NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
        [resultDict setObject:[[NSNumber alloc] initWithInt:userLink] forKey:@"userLink"];
        [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphObjectNode alloc] initWithObject:resultDict]];
    }
}

- (void)extendedUserDataRequestSuccess:(TLUserFull$userFull *)userDesc
{   
    TGUser *user = [[TGUser alloc] initWithTelegraphUserDesc:userDesc.link.user];
    [TGUserDataRequestBuilder executeUserObjectsUpdate:[NSArray arrayWithObject:user]];
    
    int userLink = extractUserLink(userDesc.link);
    [TGUserDataRequestBuilder executeUserLinkUpdates:[[NSArray alloc] initWithObjects:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:((TLUser$modernUser *)userDesc.link.user).n_id], [[NSNumber alloc] initWithInt:userLink], nil], nil]];
    
    int peerSoundId = 0;
    int peerMuteUntil = 0;
    bool peerPreviewText = true;
    bool messagesMuted = true;
    
    if ([userDesc.notify_settings isKindOfClass:[TLPeerNotifySettings$peerNotifySettings class]])
    {
        TLPeerNotifySettings$peerNotifySettings *concreteSettings = (TLPeerNotifySettings$peerNotifySettings *)userDesc.notify_settings;
        
        if (concreteSettings.sound.length == 0)
            peerSoundId = 0;
        else if ([concreteSettings.sound isEqualToString:@"default"])
            peerSoundId = 1;
        else
            peerSoundId = [concreteSettings.sound intValue];
        
        peerMuteUntil = concreteSettings.mute_until;
        if (peerMuteUntil <= [[TGTelegramNetworking instance] approximateRemoteTime])
            peerMuteUntil = 0;
        
        peerPreviewText = concreteSettings.flags & (1 << 0);
        messagesMuted = concreteSettings.flags & (1 << 1);
    }
    
    [TGDatabaseInstance() storePeerNotificationSettings:user.uid soundId:peerSoundId muteUntil:peerMuteUntil previewText:peerPreviewText messagesMuted:messagesMuted writeToActionQueue:false completion:^(bool changed)
    {
        if (changed)
        {
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:peerMuteUntil], @"muteUntil", [NSNumber numberWithInt:peerSoundId], @"soundId", [[NSNumber alloc] initWithBool:messagesMuted], @"messagesMuted", nil];
            [ActionStageInstance() dispatchResource:[NSString stringWithFormat:@"/tg/peerSettings/(%d)", user.uid] resource:[[SGraphObjectNode alloc] initWithObject:dict]];
        }
    }];
    
    TGBotInfo *botInfo = [TGBotSignals botInfoForInfo:userDesc.bot_info];
    if (botInfo != nil)
        [TGDatabaseInstance() storeBotInfo:botInfo forUserId:user.uid];
    
    [TGDatabaseInstance() updateCachedUserData:user.uid block:^TGCachedUserData *(TGCachedUserData *data) {
        if (data == nil) {
            data = [[TGCachedUserData alloc] initWithAbout:nil groupsInCommonCount:0 groupsInCommon:nil supportsCalls:0 callsPrivate:0];
        }
        return [[[data updateGroupsInCommonCount:userDesc.common_chats_count] updateSupportsCalls:userDesc.flags & (1 << 4)] updateCallsPrivate:userDesc.flags & (1 << 5)];
    }];
    
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
    [resultDict setObject:[[NSNumber alloc] initWithInt:userLink] forKey:@"userLink"];
    [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphObjectNode alloc] initWithObject:resultDict]];
}

- (void)extendedUserDataRequestFailed
{
    [ActionStageInstance() nodeRetrieveFailed:self.path];
}

@end
