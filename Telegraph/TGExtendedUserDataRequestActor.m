#import "TGExtendedUserDataRequestActor.h"

#import <LegacyComponents/ActionStage.h>
#import <LegacyComponents/SGraphObjectNode.h>
#import "TGUpdateStateRequestBuilder.h"
#import "TGUserDataRequestBuilder.h"

#import "TGTelegraph.h"
#import "TGDatabase.h"

#import "TGUser+Telegraph.h"

#import "TGTelegramNetworking.h"

#import "TLUser$modernUser.h"

#import "TGBotSignals.h"

#import "TLUserFull$userFull.h"

#import "TLPeerNotifySettings$peerNotifySettings.h"

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
    
    NSNumber *peerSoundId = nil;
    NSNumber *peerMuteUntil = nil;
    NSNumber *peerPreviewText = nil;
    NSNumber *messagesMuted = nil;
    
    if ([userDesc.notify_settings isKindOfClass:[TLPeerNotifySettings$peerNotifySettings class]])
    {
        TLPeerNotifySettings$peerNotifySettings *concreteSettings = (TLPeerNotifySettings$peerNotifySettings *)userDesc.notify_settings;
        if (concreteSettings.flags & (1 << 0)) {
            peerPreviewText = @(concreteSettings.showPreviews);
        }
        if (concreteSettings.flags & (1 << 1)) {
            messagesMuted = @(concreteSettings.silent);
        }
        if (concreteSettings.flags & (1 << 2)) {
            if (concreteSettings.mute_until > [[TGTelegramNetworking instance] approximateRemoteTime])
                peerMuteUntil = @(concreteSettings.mute_until);
            else
                peerMuteUntil = @0;
        }
        if (concreteSettings.flags & (1 << 3))
        {
            if (concreteSettings.sound.length == 0)
                peerSoundId = @(0);
            else if ([concreteSettings.sound isEqualToString:@"default"])
                peerSoundId = @(1);
            else
                peerSoundId = @([concreteSettings.sound intValue]);
        }
    }
    
    [TGDatabaseInstance() storePeerNotificationSettings:user.uid soundId:peerSoundId muteUntil:peerMuteUntil previewText:peerPreviewText messagesMuted:messagesMuted writeToActionQueue:false completion:^(bool changed)
    {
        if (changed)
        {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            if (peerSoundId != nil)
                dict[@"soundId"] = peerSoundId;
            if (peerMuteUntil != nil)
                dict[@"muteUntil"] = peerMuteUntil;
            if (peerPreviewText != nil)
                dict[@"previewText"] = peerPreviewText;
            if (messagesMuted != nil)
                dict[@"messagesMuted"] = messagesMuted;
            
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
