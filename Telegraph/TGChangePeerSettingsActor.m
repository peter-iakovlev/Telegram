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
    
    NSNumber *currentSoundId = nil;
    NSNumber *currentMuteUntil = nil;
    NSNumber *currentPreviewText = nil;
    NSNumber *currentMessagesMuted = nil;
    [TGDatabaseInstance() loadPeerNotificationSettings:peerId soundId:&currentSoundId muteUntil:&currentMuteUntil previewText:&currentPreviewText messagesMuted:&currentMessagesMuted notFound:NULL];
    
    NSNumber *nSoundId = [options objectForKey:@"soundId"];
    NSNumber *nMuteUntil = [options objectForKey:@"muteUntil"];
    NSNumber *nPreviewText = [options objectForKey:@"previewText"];
    NSNumber *nMessagesMuted = options[@"messagesMuted"];
    
    NSNumber *peerSoundId = currentSoundId;
    if (nSoundId != nil)
        peerSoundId = nSoundId.intValue != INT32_MIN ? nSoundId : nil;
    
    NSNumber *peerMuteUntil = currentMuteUntil;
    if (nMuteUntil != nil)
        peerMuteUntil = nMuteUntil.intValue != INT32_MIN ? nMuteUntil : nil;
    
    NSNumber *peerPreviewText = currentPreviewText;
    if (nPreviewText != nil)
        peerPreviewText = nPreviewText.intValue != INT32_MIN ? nPreviewText : nil;
    
    NSNumber *messagesMuted = currentMessagesMuted;
    if (nMessagesMuted != nil)
        messagesMuted = nMessagesMuted.intValue != INT32_MIN ? nMessagesMuted : nil;
    
    if (nMuteUntil != nil || nSoundId != nil || nPreviewText != nil || nMessagesMuted != nil)
    {
        [TGDatabaseInstance() storePeerNotificationSettings:peerId soundId:peerSoundId muteUntil:peerMuteUntil previewText:peerPreviewText messagesMuted:messagesMuted writeToActionQueue:true completion:nil];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        if (peerSoundId != nil)
            dict[@"soundId"] = peerSoundId;
        if (peerMuteUntil != nil)
            dict[@"muteUntil"] = peerMuteUntil;
        if (peerPreviewText != nil)
            dict[@"previewText"] = peerPreviewText;
        if (messagesMuted != nil)
            dict[@"messagesMuted"] = messagesMuted;
        
        [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/peerSettings/(%lld)", peerId] resource:[[SGraphObjectNode alloc] initWithObject:dict]];

        [ActionStageInstance() requestActor:@"/tg/service/synchronizeserviceactions/(settings)" options:nil watcher:TGTelegraphInstance];
        
        [TGDatabaseInstance() processAndScheduleMute];
    }
    
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

@end
