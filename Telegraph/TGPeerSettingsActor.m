#import "TGPeerSettingsActor.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGDatabase.h"

#import "TGTelegraph.h"

#import "TGUpdateStateRequestBuilder.h"

#import "TGTelegramNetworking.h"

int cachedMessageSettingsVersion = -1;
int cachedGroupSettingsVersion = -1;

@interface TGPeerSettingsActor ()

@property (nonatomic) int64_t peerId;

@property (nonatomic) bool force;

@end

@implementation TGPeerSettingsActor

@synthesize peerId = _peerId;

@synthesize force = _force;

+ (NSString *)genericPath
{
    return @"/tg/peerSettings/@";
}

- (void)prepare:(NSDictionary *)options
{
    if ([[options objectForKey:@"force"] boolValue])
        self.requestQueueName = @"settings";
}

- (void)execute:(NSDictionary *)options
{
    _peerId = [[options objectForKey:@"peerId"] longLongValue];
    if (_peerId == 0)
    {
        [ActionStageInstance() nodeRetrieveFailed:self.path];
        return;
    }
    
    bool cachedOnly = [self.path hasSuffix:@"cachedOnly)"];
    
    _force = [[options objectForKey:@"force"] boolValue];
    
    bool notFound = false;
    
    int soundId = 0;
    int muteUntil = 0;
    bool previewText = true;
    bool photoNotificationsEnabled = true;
    
    [TGDatabaseInstance() loadPeerNotificationSettings:_peerId soundId:&soundId muteUntil:&muteUntil previewText:&previewText photoNotificationsEnabled:&photoNotificationsEnabled notFound:&notFound];
    
    if ((notFound || _force) && !cachedOnly)
    {
        self.cancelToken = [TGTelegraphInstance doRequestPeerNotificationSettings:_peerId accessHash:[options[@"accessHash"] longLongValue] actor:self];
    }
    else
    {
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:muteUntil], @"muteUntil", [NSNumber numberWithInt:soundId], @"soundId", [NSNumber numberWithBool:previewText], @"previewText", [[NSNumber alloc] initWithBool:photoNotificationsEnabled], @"photoNotificationsEnabled", nil];
        
        [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphObjectNode alloc] initWithObject:dict]];
        
        if ((_peerId == INT_MAX - 1 && cachedMessageSettingsVersion < [TGUpdateStateRequestBuilder stateVersion]) || (_peerId == INT_MAX - 2 && cachedGroupSettingsVersion < [TGUpdateStateRequestBuilder stateVersion]))
        {
            [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/peerSettings/(%lld,force)", _peerId] options:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithLongLong:_peerId], @"peerId", [[NSNumber alloc] initWithBool:true], @"force", nil] watcher:TGTelegraphInstance];
        }
    }
}

- (void)peerNotifySettingsRequestSuccess:(TLPeerNotifySettings *)settings
{
    int peerSoundId = 0;
    int muteUntil = 0;
    bool previewText = true;
    bool photoNotificationsEnabled = true;
    
    if ([settings isKindOfClass:[TLPeerNotifySettings$peerNotifySettings class]])
    {
        TLPeerNotifySettings$peerNotifySettings *concreteSettings = (TLPeerNotifySettings$peerNotifySettings *)settings;
        muteUntil = concreteSettings.mute_until;
        if (muteUntil <= [[TGTelegramNetworking instance] approximateRemoteTime])
            muteUntil = 0;
        
        if (concreteSettings.sound.length == 0)
            peerSoundId = 0;
        else if ([concreteSettings.sound isEqualToString:@"default"])
            peerSoundId = 1;
        else
            peerSoundId = [concreteSettings.sound intValue];
        
        photoNotificationsEnabled = concreteSettings.events_mask & 1;
        
        previewText = concreteSettings.show_previews;
    }
    
    TGChangeNotificationSettingsFutureAction *action = (TGChangeNotificationSettingsFutureAction *)[TGDatabaseInstance() loadFutureAction:_peerId type:TGChangeNotificationSettingsFutureActionType];
    
    if (action != nil)
    {
        muteUntil = action.muteUntil;
        peerSoundId = action.soundId;
        previewText = action.previewText;
        photoNotificationsEnabled = action.photoNotificationsEnabled;
    }
    else if ([TGDatabaseInstance() loadFutureAction:0 type:TGClearNotificationsFutureActionType] != nil)
    {
        muteUntil = 0;
        peerSoundId = 1;
        previewText = true;
        photoNotificationsEnabled = true;
    }
    
    if (_peerId == INT_MAX - 1)
        cachedMessageSettingsVersion = [TGUpdateStateRequestBuilder stateVersion];
    else if (_peerId == INT_MAX - 2)
        cachedGroupSettingsVersion = [TGUpdateStateRequestBuilder stateVersion];
    
    bool force = _force;
    int64_t peerId = _peerId;
    
    [TGDatabaseInstance() storePeerNotificationSettings:_peerId soundId:peerSoundId muteUntil:muteUntil previewText:previewText photoNotificationsEnabled:photoNotificationsEnabled writeToActionQueue:false completion:^(bool changed)
    {
        if (changed && force)
        {
            [ActionStageInstance() dispatchOnStageQueue:^
            {
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:muteUntil], @"muteUntil", [NSNumber numberWithInt:peerSoundId], @"soundId", [[NSNumber alloc] initWithBool:previewText], @"previewText", [[NSNumber alloc] initWithBool:photoNotificationsEnabled], @"photoNotificationsEnabled", nil];
                
                [ActionStageInstance() dispatchResource:[NSString stringWithFormat:@"/tg/peerSettings/(%lld)", peerId] resource:[[SGraphObjectNode alloc] initWithObject:dict]];
            }];
        }
    }];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:muteUntil], @"muteUntil", [NSNumber numberWithInt:peerSoundId], @"soundId", [NSNumber numberWithBool:previewText], @"previewText", [[NSNumber alloc] initWithBool:photoNotificationsEnabled], @"photoNotificationsEnabled", nil];
    
    [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphObjectNode alloc] initWithObject:dict]];
}

- (void)peerNotifySettingsRequestFailed
{
    [ActionStageInstance() nodeRetrieveFailed:self.path];
}

@end
