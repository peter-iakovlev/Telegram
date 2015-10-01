#import "TGPeerNotificationSettingsSignals.h"

#import "TGDatabase.h"
#import "ActionStage.h"
#import "TGTelegramNetworking.h"
#import "TGTelegraph.h"

#import "TGPeerIdAdapter.h"

@interface TGPeerNotificationSettingsHelper : NSObject <ASWatcher>
{
    int64_t _peerId;
    void (^_settingsUpdated)(TGPeerNotificationSettings *);
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGPeerNotificationSettingsHelper

- (NSString *)peerSettingsPath
{
    return [NSString stringWithFormat:@"/tg/peerSettings/(%" PRId64 ")", _peerId];
}

- (instancetype)initWithPeerId:(int64_t)peerId settingsUpdated:(void (^)(TGPeerNotificationSettings *))settingsUpdated
{
    self = [super init];
    if (self != nil)
    {
        _peerId = peerId;
        _settingsUpdated = [settingsUpdated copy];
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        
        [ActionStageInstance() watchForPath:[self peerSettingsPath] watcher:self];
    }
    return self;
}

- (void)dealloc
{
    [ActionStageInstance() removeWatcher:self fromPath:[self peerSettingsPath]];
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path isEqualToString:[self peerSettingsPath]])
    {
        NSDictionary *notificationSettings = ((SGraphObjectNode *)resource).object;
        
        int muteUntil = [notificationSettings[@"muteUntil"] intValue];
        if (muteUntil <= [[TGTelegramNetworking instance] approximateRemoteTime])
            muteUntil = 0;
        
        TGPeerNotificationSettings *updatedSettings = [[TGPeerNotificationSettings alloc] initWithMuteUntil:muteUntil];
        
        if (_settingsUpdated)
            _settingsUpdated(updatedSettings);
    }
}

@end

@implementation TGPeerNotificationSettings

- (instancetype)initWithMuteUntil:(int32_t)muteUntil
{
    self = [super init];
    if (self != nil)
    {
        _muteUntil = muteUntil;
    }
    return self;
}

@end

@implementation TGPeerNotificationSettingsSignals

+ (SSignal *)notificationSettingsWithPeerId:(int64_t)peerId
{
    SSignal *updatedSettings = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        TGPeerNotificationSettingsHelper *helper = [[TGPeerNotificationSettingsHelper alloc] initWithPeerId:peerId settingsUpdated:^(TGPeerNotificationSettings *settings)
        {
            [subscriber putNext:settings];
        }];
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            [helper description]; //keep reference
        }];
    }];
    
    return [[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        int soundId = 0;
        int muteUntil = 0;
        bool previewText = true;
        bool photoNotificationsEnabled = true;
        bool notFound = false;
        
        [TGDatabaseInstance() loadPeerNotificationSettings:peerId soundId:&soundId muteUntil:&muteUntil previewText:&previewText photoNotificationsEnabled:&photoNotificationsEnabled notFound:&notFound];
        [subscriber putNext:[[TGPeerNotificationSettings alloc] initWithMuteUntil:muteUntil]];
        [subscriber putCompletion];
        
        return nil;
    }] then:updatedSettings];
}

+ (SSignal *)updatePeerNotificationSettingsWithPeerId:(int64_t)peerId settings:(TGPeerNotificationSettings *)settings
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        static int actionId = 0;
        
        void (^muteBlock)(int64_t, int32_t, NSNumber *) = ^(int64_t peerId, int32_t muteUntil, NSNumber *accessHash)
        {
            NSMutableDictionary *options = [NSMutableDictionary dictionaryWithDictionary:@{ @"peerId": @(peerId), @"muteUntil": @(muteUntil) }];
            if (accessHash != nil)
                options[@"accessHash"] = accessHash;
            
            [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/changePeerSettings/(%" PRId64 ")/(signal%d)", peerId, actionId++] options:options watcher:TGTelegraphInstance];
            
            [subscriber putCompletion];
        };
        
        if (TGPeerIdIsChannel(peerId))
        {
            [[[TGDatabaseInstance() existingChannel:peerId] take:1] startWithNext:^(TGConversation *channel)
            {
                muteBlock(peerId, settings.muteUntil, @(channel.accessHash));
            }];
        }
        else
        {
            muteBlock(peerId, settings.muteUntil, nil);
        }
        
        return nil;
    }];
}

@end
