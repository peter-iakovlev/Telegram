#import "TGChangePeerSettingsActor.h"

#import <LegacyComponents/LegacyComponents.h>

#import <LegacyComponents/ActionStage.h>
#import <LegacyComponents/SGraphObjectNode.h>

#import "TGDatabase.h"

#import "TGTelegraph.h"

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
    bool currentMessagesMuted = false;
    [TGDatabaseInstance() loadPeerNotificationSettings:peerId soundId:&currentSoundId muteUntil:&currentMuteUntil previewText:&currentPreviewText messagesMuted:&currentMessagesMuted notFound:NULL];
    
    NSNumber *nMuteUntil = [options objectForKey:@"muteUntil"];
    NSNumber *nSoundId = [options objectForKey:@"soundId"];
    NSNumber *nPreviewText = [options objectForKey:@"previewText"];
    NSNumber *nMessagesMuted = options[@"messagesMuted"];
    
    if (nMuteUntil != nil || nSoundId != nil || nPreviewText != nil || nMessagesMuted != nil)
    {
        int serverSoundId = nSoundId != nil ? [nSoundId intValue] : currentSoundId;
        [TGDatabaseInstance() storePeerNotificationSettings:peerId soundId:serverSoundId muteUntil:(nMuteUntil != nil ? [nMuteUntil intValue] : currentMuteUntil) previewText:(nPreviewText != nil ? [nPreviewText boolValue] : currentPreviewText) messagesMuted:[nMessagesMuted boolValue] writeToActionQueue:true completion:nil];
        
        [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/peerSettings/(%lld)", peerId] resource:[[SGraphObjectNode alloc] initWithObject:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithInt:nSoundId != nil ? [nSoundId intValue] : currentSoundId], @"soundId", [[NSNumber alloc] initWithInt:nMuteUntil != nil ? [nMuteUntil intValue] : currentMuteUntil], @"muteUntil", [[NSNumber alloc] initWithBool:nPreviewText != nil ? [nPreviewText boolValue] : currentPreviewText], @"previewText", nMessagesMuted == nil ? @(currentMessagesMuted) : nMessagesMuted, @"messagesMuted", nil]]];

        [ActionStageInstance() requestActor:@"/tg/service/synchronizeserviceactions/(settings)" options:nil watcher:TGTelegraphInstance];
        
        [TGDatabaseInstance() processAndScheduleMute];
    }
    
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

@end
