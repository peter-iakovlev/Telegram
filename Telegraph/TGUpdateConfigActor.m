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

#import "TGApplicationFeatures.h"
#import "TGApplicationFeatureDescription.h"

#import "TGTimer.h"

#import "TGTelegramNetworking.h"

#import "TGLocalization.h"
#import "TGLocalizationSignals.h"

static NSTimeInterval configInvalidationDate = 0.0;

static bool sharedExperimentalPasscodeBlurDisabled = false;
static bool sharedExperimentalPasscodeBlurDisabledInitialized = false;

@interface TGUpdateConfigActor () <ASWatcher>
{
    bool _inviteReceived;
    bool _configReceived;
    bool _userReceived;
    
    TGTimer *_timer;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGUpdateConfigActor

+ (NSString *)genericPath
{
    return @"/tg/service/updateConfig/@";
}

- (instancetype)initWithPath:(NSString *)path
{
    self = [super initWithPath:path];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)execute:(NSDictionary *)__unused options
{
    if ([self.path hasSuffix:@"(background)"])
    {
        [self _updateBackgroundActor];
    }
    else
    {
        [self addCancelToken:[TGTelegraphInstance doRequestInviteText:self]];
        
        {
            MTRequest *request = [[MTRequest alloc] init];
            request.dependsOnPasswordEntry = false;
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
}

- (void)_updateBackgroundActor
{
    [_timer invalidate];
    _timer = nil;
    
    [ActionStageInstance() removeWatcher:self];
    
    [ActionStageInstance() requestActor:@"/tg/service/updateConfig/(task)" options:nil flags:0 watcher:self];
}

- (void)_maybeComplete
{
    if (_inviteReceived && _configReceived && _userReceived)
        [ActionStageInstance() actionCompleted:self.path result:nil];
}

- (void)inviteTextRequestSuccess:(TLhelp_InviteText *)inviteText
{
    if ([inviteText isKindOfClass:[TLhelp_InviteText class]]) {
        TGDispatchOnMainThread(^
        {
            if (inviteText.message.length != 0)
            {
                [[NSUserDefaults standardUserDefaults] setObject:inviteText.message forKey:@"TG_inviteText"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        });
    }
    
    _inviteReceived = true;
    [self _maybeComplete];
}

- (void)inviteTextRequestFailed
{
    _inviteReceived = true;
    [self _maybeComplete];
}

+ (BOOL)cachedExperimentalPasscodeBlurDisabled {
    if (sharedExperimentalPasscodeBlurDisabledInitialized) {
        return sharedExperimentalPasscodeBlurDisabled;
    } else {
        NSData *data = [TGDatabaseInstance() customProperty:@"experimentalPasscodeBlurDisabled"];
        int32_t experimentalPasscodeBlurDisabled = 0;
        if (data.length == 4) {
            [data getBytes:&experimentalPasscodeBlurDisabled];
        }
        sharedExperimentalPasscodeBlurDisabled = experimentalPasscodeBlurDisabled != 0;
        sharedExperimentalPasscodeBlurDisabledInitialized = true;
        return sharedExperimentalPasscodeBlurDisabled;
    }
}

- (void)configRequestSuccess:(TLConfig *)config
{
    int32_t experimentalPasscodeBlurDisabled = 0;
    if (config.flags & (1 << 28)) {
        experimentalPasscodeBlurDisabled = true;
        [TGDatabaseInstance() setCustomProperty:@"experimentalPasscodeBlurDisabled" value:[NSData dataWithBytes:&experimentalPasscodeBlurDisabled length:4]];
    }
    
    sharedExperimentalPasscodeBlurDisabled = experimentalPasscodeBlurDisabled != 0;
    sharedExperimentalPasscodeBlurDisabledInitialized = true;
    
    NSData *phoneCallsEnabledData = [TGDatabaseInstance() customProperty:@"phoneCallsEnabled"];
    int32_t previousPhoneCallsEnabled = false;
    if (phoneCallsEnabledData.length == 4) {
        [phoneCallsEnabledData getBytes:&previousPhoneCallsEnabled];
    }
    
    int32_t maxChatParticipants = MAX(100, config.chat_size_max);
    [TGDatabaseInstance() setCustomProperty:@"maxChatParticipants" value:[NSData dataWithBytes:&maxChatParticipants length:4]];
    
    int32_t maxChannelGroupMembers = config.megagroup_size_max;
    [TGDatabaseInstance() setCustomProperty:@"maxChannelGroupMembers" value:[NSData dataWithBytes:&maxChannelGroupMembers length:4]];
    
    int32_t maxSavedGifs = config.saved_gifs_limit;
    [TGDatabaseInstance() setCustomProperty:@"maxSavedGifs" value:[NSData dataWithBytes:&maxSavedGifs length:4]];
    
    int32_t maxSavedStickers = config.stickers_recent_limit;
    [TGDatabaseInstance() setCustomProperty:@"maxSavedStickers" value:[NSData dataWithBytes:&maxSavedStickers length:4]];
    
    int32_t maxChannelMessageEditTime = config.edit_time_limit;
    [TGDatabaseInstance() setCustomProperty:@"maxChannelMessageEditTime" value:[NSData dataWithBytes:&maxChannelMessageEditTime length:4]];
		
    int32_t phoneCallsEnabled = config.flags & (1 << 1);
    [TGDatabaseInstance() setCustomProperty:@"phoneCallsEnabled" value:[NSData dataWithBytes:&phoneCallsEnabled length:4]];
    
    int32_t callReceiveTimeout = config.call_receive_timeout_ms;
    [TGDatabaseInstance() setCustomProperty:@"callReceiveTimeout" value:[NSData dataWithBytes:&callReceiveTimeout length:4]];
    
    int32_t callRingTimeout = config.call_ring_timeout_ms;
    [TGDatabaseInstance() setCustomProperty:@"callRingTimeout" value:[NSData dataWithBytes:&callRingTimeout length:4]];
    
    int32_t callConnectTimeout = config.call_connect_timeout_ms;
    [TGDatabaseInstance() setCustomProperty:@"callConnectTimeout" value:[NSData dataWithBytes:&callConnectTimeout length:4]];
    
    int32_t callPacketTimeout = config.call_packet_timeout_ms;
    [TGDatabaseInstance() setCustomProperty:@"callPacketTimeout" value:[NSData dataWithBytes:&callPacketTimeout length:4]];
    
    int32_t maxPinnedChats = config.pinned_dialogs_count_max;
    [TGDatabaseInstance() setCustomProperty:@"maxPinnedChats" value:[NSData dataWithBytes:&maxPinnedChats length:4]];
    
    if (phoneCallsEnabled != previousPhoneCallsEnabled) {
        TGLog(@"phoneCallsEnabled changed to %d", phoneCallsEnabled);
        
        [TGDatabaseInstance() clearCachedUserLinks];
        
        bool enabled = (phoneCallsEnabled != 0);
        [ActionStageInstance() dispatchResource:@"/tg/calls/enabled" resource:[[SGraphObjectNode alloc] initWithObject:@(enabled)]];
    }
    
    [TGDatabaseInstance() setSuggestedLocalizationCode:config.suggested_lang_code];
    
    if (config.lang_pack_version != currentNativeLocalization().version) {
        [TGTelegraphInstance.disposeOnLogout add:[[TGLocalizationSignals pollLocalization] startWithNext:nil]];
    }
    
    //[TGApplicationFeatures setLargeGroupMemberCountLimit:(NSUInteger)config.chat_big_size];
    
    /*NSMutableArray *features = [[NSMutableArray alloc] init];
    for (TLDisabledFeature *disabledFeature in config.disabled_features)
    {
        TGApplicationFeatureDescription *feature = [[TGApplicationFeatureDescription alloc] initWithIdentifier:disabledFeature.feature enabled:false disabledMessage:disabledFeature.n_description];
        [features addObject:feature];
    }
    
    [TGApplicationFeatures rawUpdate:features];
    
    configInvalidationDate = config.expires;*/
 
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

- (void)actorCompleted:(int)__unused status path:(NSString *)__unused path result:(id)__unused result
{
    [_timer invalidate];
    
    NSTimeInterval timeout = MAX(60.0, configInvalidationDate - [[TGTelegramNetworking instance] approximateRemoteTime])
    ;
    __weak TGUpdateConfigActor *weakSelf = self;
    _timer = [[TGTimer alloc] initWithTimeout:timeout repeat:false completion:^
    {
        __strong TGUpdateConfigActor *strongSelf = weakSelf;
        [strongSelf _updateBackgroundActor];
    } queue:[ActionStageInstance() globalStageDispatchQueue]];
    [_timer start];
}

@end
