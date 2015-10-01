#import "TGChangePeerSettingsActor.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGDatabase.h"

#import "TGTelegraph.h"

#import "TGStringUtils.h"

@implementation TGChangePeerSettingsActor

+ (NSString *)genericPath
{
    return @"/tg/changePeerSettings/@/@";
}

- (void)execute:(NSDictionary *)options
{
    int64_t peerId = [[options objectForKey:@"peerId"] longLongValue];
    if (peerId == 0)
    {
        [ActionStageInstance() actionFailed:self.path reason:-1];
        return;
    }
    
    int currentSoundId = 0;
    int currentMuteUntil = 0;
    bool currentPreviewText = true;
    bool currentPhotoNotificationsEnabled = true;
    [TGDatabaseInstance() loadPeerNotificationSettings:peerId soundId:&currentSoundId muteUntil:&currentMuteUntil previewText:&currentPreviewText photoNotificationsEnabled:&currentPhotoNotificationsEnabled notFound:NULL];
    
    NSNumber *nMuteUntil = [options objectForKey:@"muteUntil"];
    NSNumber *nSoundId = [options objectForKey:@"soundId"];
    NSNumber *nPreviewText = [options objectForKey:@"previewText"];
    NSNumber *nPhotoNotificationsEnabled = options[@"photoNotificationsEnabled"];
    
    if (nMuteUntil != nil || nSoundId != nil || nPreviewText != nil || nPhotoNotificationsEnabled != nil)
    {
        int serverSoundId = nSoundId != nil ? [nSoundId intValue] : currentSoundId;
        [TGDatabaseInstance() storePeerNotificationSettings:peerId soundId:serverSoundId muteUntil:(nMuteUntil != nil ? [nMuteUntil intValue] : currentMuteUntil) previewText:(nPreviewText != nil ? [nPreviewText boolValue] : currentPreviewText) photoNotificationsEnabled:nPhotoNotificationsEnabled == nil || [nPhotoNotificationsEnabled boolValue] writeToActionQueue:true completion:nil];
        
        [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/peerSettings/(%lld)", peerId] resource:[[SGraphObjectNode alloc] initWithObject:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithInt:nSoundId != nil ? [nSoundId intValue] : currentSoundId], @"soundId", [[NSNumber alloc] initWithInt:nMuteUntil != nil ? [nMuteUntil intValue] : currentMuteUntil], @"muteUntil", [[NSNumber alloc] initWithBool:nPreviewText != nil ? [nPreviewText boolValue] : currentPreviewText], @"previewText", [[NSNumber alloc] initWithBool:nPhotoNotificationsEnabled != nil ? [nPhotoNotificationsEnabled boolValue] : currentPhotoNotificationsEnabled], @"photoNotificationsEnabled", nil]]];

        [ActionStageInstance() requestActor:@"/tg/service/synchronizeserviceactions/(settings)" options:nil watcher:TGTelegraphInstance];
        
        [TGDatabaseInstance() processAndScheduleMute];
    }
    
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

@end
