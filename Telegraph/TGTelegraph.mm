#import "TGTelegraph.h"

#import "TGTelegramNetworking.h"
#import <MTProtoKit/MTProtoKit.h>

#import <Intents/Intents.h>

#import "TGPeerIdAdapter.h"

#import "TGAppDelegate.h"

#import "UIDevice+PlatformInfo.h"

#import <thirdparty/AFNetworking/AFNetworking.h>

#import "TGTimer.h"

#import "SGraphObjectNode.h"

#import "TGSchema.h"

#import "TGRawHttpRequest.h"

#import <AddressBook/AddressBook.h>

#import "TGDatabase.h"

#import "TGUser+Telegraph.h"

#import "NSObject+TGLock.h"

#import "TGLogoutRequestBuilder.h"
#import "TGSendCodeRequestBuilder.h"
#import "TGSignInRequestBuilder.h"
#import "TGSignUpRequestBuilder.h"
#import "TGSendInvitesActor.h"
#import "TGPushActionsRequestBuilder.h"
#import "TGUpdatePresenceActor.h"
#import "TGRevokeSessionsActor.h"

#import "TGApplyUpdatesActor.h"
#import "TGUpdateStateRequestBuilder.h"
#import "TGApplyStateRequestBuilder.h"
#import "TGSynchronizationStateRequestActor.h"
#import "TGSynchronizeActionQueueActor.h"
#import "TGSynchronizeServiceActionsActor.h"

#import "TGUserDataRequestBuilder.h"
#import "TGExtendedUserDataRequestActor.h"
#import "TGBlockListRequestActor.h"
#import "TGChangePeerBlockStatusActor.h"
#import "TGChangeNameActor.h"
#import "TGChangePrivacySettingsActor.h"
#import "TGUpdateUserStatusesActor.h"

#import "TGDialogListRequestBuilder.h"
#import "TGDialogListSearchActor.h"
#import "TGMessagesSearchActor.h"

#import "TGSynchronizeContactsActor.h"
#import "TGContactListRequestBuilder.h"
#import "TGSuggestedContactsRequestActor.h"
#import "TGContactsGlobalSearchActor.h"
#import "TGContactListSearchActor.h"
#import "TGLocationServicesStateActor.h"

#import "TGConversationHistoryAsyncRequestActor.h"
#import "TGConversationHistoryRequestActor.h"
#import "TGConversationChatInfoRequestActor.h"
#import "TGReportDeliveryActor.h"
#import "TGConversationActivityRequestBuilder.h"
#import "TGConversationChangeTitleRequestActor.h"
#import "TGConversationChangePhotoActor.h"
#import "TGConversationCreateChatRequestActor.h"
#import "TGConversationAddMemberRequestActor.h"
#import "TGConversationDeleteMemberRequestActor.h"
#import "TGConversationDeleteMessagesActor.h"
#import "TGConversationDeleteActor.h"
#import "TGConversationClearHistoryActor.h"

#import "TGTimelineHistoryRequestBuilder.h"
#import "TGTimelineUploadPhotoRequestBuilder.h"
#import "TGTimelineRemoveItemsRequestActor.h"
#import "TGTimelineAssignProfilePhotoActor.h"
#import "TGDeleteUserAvatarActor.h"

#import "TGUserDataRequestBuilder.h"
#import "TGPeerSettingsActor.h"
#import "TGChangePeerSettingsActor.h"
#import "TGResetPeerNotificationsActor.h"
#import "TGExtendedChatDataRequestActor.h"

#import "TGProfilePhotoListActor.h"
#import "TGDeleteProfilePhotoActor.h"

#import "TGConversationAddMessagesActor.h"

#import "TGLocationRequestActor.h"
#import "TGLocationReverseGeocodeActor.h"
#import "TGSaveGeocodingResultActor.h"

#import "TGFileDownloadActor.h"
#import "TGFileUploadActor.h"
#import "TGDocumentDownloadActor.h"
#import "TGMultipartFileDownloadActor.h"

#import "TGCheckImageStoredActor.h"

#import "TGVideoDownloadActor.h"

#import "TGCheckUpdatesActor.h"
#import "TGWallpaperListRequestActor.h"
#import "TGImageSearchActor.h"

#import "TGSynchronizePreferencesActor.h"

#import "TGRequestEncryptedChatActor.h"
#import "TGEncryptedChatResponseActor.h"
#import "TGDiscardEncryptedChatActor.h"

#import "TGModernRemoteWallpaperListActor.h"

#import "TGICloudFileDownloadActor.h"

#import "TGRemoteImageView.h"
#import "TGImageUtils.h"
#import "TGStringUtils.h"
#import "TGInterfaceAssets.h"

#import "TGInterfaceManager.h"

#import "TGModernSendCommonMessageActor.h"
#import "TGModernSendSecretMessageActor.h"

#import "TGUpdateConfigActor.h"
#import "TGDownloadMessagesActor.h"

#import "TGWebSearchController.h"
#import "TGModernSendCommonMessageActor.h"

#import "TGEmbedPIPController.h"

#import "TGUpdateMediaHistoryActor.h"

#import "TGRecentHashtagsSignal.h"

#import "TGTimer.h"

#import "TGGoogleDriveController.h"

#import "TLRPCmessages_sendMessage_manual.h"
#import "TLRPCmessages_sendMedia_manual.h"

#import "TGStickersSignals.h"
#import "TGMaskStickersSignals.h"

#import <libkern/OSAtomic.h>

#include <set>
#include <map>

#import "TGBridgeServer.h"

#import "TGGlobalMessageSearchSignals.h"
#import "TGChannelManagementSignals.h"
#import "TGChannelStateSignals.h"
#import "TGGroupManagementSignals.h"
#import "TGRecentContextBotsSignal.h"
#import "TGRecentGifsSignal.h"
#import "TGRecentStickersSignal.h"
#import "TGRecentMaskStickersSignal.h"

#import "TGBotContextResultAttachment.h"
#import "TLRPCmessages_sendInlineBotResult.h"

#import "TLaccount_updateProfile$updateProfile.h"

#import "TGPeerInfoSignals.h"

#import "TLRPCauth_sendCode.h"

#import "FetchResources.h"

#import "../../config.h"

@interface TGTypingRecord : NSObject

@property (nonatomic) NSTimeInterval date;
@property (nonatomic) NSString *type;

@end

@implementation TGTypingRecord

- (instancetype)initWithDate:(NSTimeInterval)date type:(NSString *)type
{
    self = [super init];
    if (self != nil)
    {
        _date = date;
        _type = type;
    }
    return self;
}

@end

static bool readIntFromString(NSString *string, int &offset, unichar delimiter, int *pResult)
{
    int length = (int)string.length;
    for (int i = offset; i < length; i++)
    {
        unichar c = [string characterAtIndex:i];
        if (c == delimiter || i == length - 1)
        {
            if (pResult != NULL)
                *pResult = [[string substringWithRange:NSMakeRange(offset, i - offset + (i == length - 1 ? 1 : 0))] intValue];
            offset = i + 1;
            
            return true;
        }
        else if (c < '0' || c > '9')
        {
            return false;
        }
    }
    
    return false;
}

static bool extractTwoSizes(NSString *string, NSString *prefix, CGSize *firstSize, CGSize *secondSize)
{
    int value = 0;
    CGSize size = CGSizeZero;
    
    int offset = (int)prefix.length;
    
    if (readIntFromString(string, offset, 'x', &value))
        size.width = value;
    else
        return false;
    
    if (readIntFromString(string, offset, ',', &value))
        size.height = value;
    else
        return false;
    
    if (firstSize != NULL)
        *firstSize = size;
    
    value = 0;
    size = CGSizeZero;
    
    if (readIntFromString(string, offset, 'x', &value))
        size.width = value;
    else
        return false;
    
    if (readIntFromString(string, offset, 0, &value))
        size.height = value;
    else
        return false;
    
    if (secondSize != NULL)
        *secondSize = size;
    
    return true;
}

TGTelegraph *TGTelegraphInstance = nil;

typedef std::map<int, std::pair<TGUser *, int > >::iterator UserDataToDispatchIterator;

@interface TGTelegraph ()
{
    std::map<int, TGUserPresence> _userPresenceToDispatch;
    std::map<int, std::pair<TGUser *, int> > _userDataToDispatch;
    
    std::map<int, int> _userPresenceExpiration;
    
    std::map<int, int> _userLinksToDispatch;
    
    TG_SYNCHRONIZED_DEFINE(_activityManagerByConversationId);
    NSMutableDictionary *_activityManagerByConversationId;
    
    SDisposableSet *_channelTasksDisposable;
}

@property (nonatomic, strong) NSMutableArray *runningRequests;
@property (nonatomic, strong) NSMutableArray *retryRequestTimers;

@property (nonatomic, strong) NSMutableArray *userDataUpdatesSubscribers;
@property (nonatomic, strong) TGTimer *userUpdatesSubscriptionTimer;

@property (nonatomic, strong) TGTimer *updatePresenceTimer;
@property (nonatomic, strong) TGTimer *updateRelativeTimestampsTimer;

@property (nonatomic) bool willDispatchUserData;
@property (nonatomic) bool willDispatchUserPresence;
@property (nonatomic, strong) TGTimer *userPresenceExpirationTimer;

@property (nonatomic, strong) TGTimer *usersTypingServiceTimer;
@property (nonatomic, strong) NSMutableDictionary *typingUserRecordsByConversation;
@property (nonatomic, strong) NSMutableDictionary *typingUserRecordsByConversationMainThread;

@end

@implementation TGTelegraph

- (id)init
{
    self = [super initWithBaseURL:nil];
    if (self != nil)
    {
        TGTelegraphInstance = self;
        
        TG_SYNCHRONIZED_INIT(_activityManagerByConversationId);
        
        _musicPlayer = [[TGMusicPlayer alloc] init];
        
        self.stringEncoding = NSUTF8StringEncoding;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];

        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:false];
        
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
            TGLog(@"Running with %@ (version %@)", bundleIdentifier, [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]);
            
            int32_t apiId = 0;
            NSString *apiHash = @"";
            SETUP_API_ID(apiId)
            SETUP_API_HASH(apiHash)
            
            assert(apiId != 0);
            assert(apiHash.length != 0);
            
            _apiId = [[NSString alloc] initWithFormat:@"%d", apiId];
            _apiHash = apiHash;
            
            _runningRequests = [[NSMutableArray alloc] init];
            
            _retryRequestTimers = [[NSMutableArray alloc] init];
            
            [TGDatabaseInstance() setMessageCleanupBlock:^(TGMediaAttachment *attachment)
            {
                if ([attachment isKindOfClass:[TGLocalMessageMetaMediaAttachment class]])
                {
                    TGLocalMessageMetaMediaAttachment *messageMeta = (TGLocalMessageMetaMediaAttachment *)attachment;
                    [ActionStageInstance() dispatchOnStageQueue:^
                    {
                        static NSFileManager *fileManager = [[NSFileManager alloc] init];
                        
                        [messageMeta.imageUrlToDataFile enumerateKeysAndObjectsUsingBlock:^(__unused NSString *imageUrl, NSString *filePath, __unused BOOL *stop)
                        {
                            NSError *error = nil;
                            [fileManager removeItemAtPath:filePath error:&error];
                        }];
                    }];
                }
            }];

            [TGDatabaseInstance() setCleanupEverythingBlock:^
            {
                NSString *documentsDirectory = [TGAppDelegate documentsPath];
                NSFileManager *fileManager = [[NSFileManager alloc] init];
                
                NSString *videosPath = [documentsDirectory stringByAppendingPathComponent:@"video"];
                for (NSString *fileName in [fileManager contentsOfDirectoryAtPath:videosPath error:nil])
                {
                    [fileManager removeItemAtPath:[videosPath stringByAppendingPathComponent:fileName] error:nil];
                }
                
                NSString *filesPath = [documentsDirectory stringByAppendingPathComponent:@"files"];
                for (NSString *fileName in [fileManager contentsOfDirectoryAtPath:filesPath error:nil])
                {
                    [fileManager removeItemAtPath:[videosPath stringByAppendingPathComponent:fileName] error:nil];
                }
                
                NSString *audioPath = [documentsDirectory stringByAppendingPathComponent:@"audio"];
                for (NSString *fileName in [fileManager contentsOfDirectoryAtPath:audioPath error:nil])
                {
                    [fileManager removeItemAtPath:[videosPath stringByAppendingPathComponent:fileName] error:nil];
                }
            }];
            
            _updatePresenceTimer = [[TGTimer alloc] initWithTimeout:60.0 repeat:true completion:^
            {
                [self updatePresenceNow];
            } queue:[ActionStageInstance() globalStageDispatchQueue]];
            [_updatePresenceTimer start];
            
            _updateRelativeTimestampsTimer = [[TGTimer alloc] initWithTimeout:30.0 repeat:true completion:^
            {
                [ActionStageInstance() dispatchResource:@"/as/updateRelativeTimestamps" resource:nil];
            } queue:[ActionStageInstance() globalStageDispatchQueue]];
            if ([UIApplication sharedApplication] != nil && [[UIApplication sharedApplication] applicationState] != UIApplicationStateBackground)
                [_updateRelativeTimestampsTimer start];
            
            _typingUserRecordsByConversation = [[NSMutableDictionary alloc] init];
            _usersTypingServiceTimer = [[TGTimer alloc] initWithTimeout:1.0 repeat:false completion:^
            {
                [self updateUserTypingStatuses];
            } queue:[ActionStageInstance() globalStageDispatchQueue]];
            
            _userDataUpdatesSubscribers = [[NSMutableArray alloc] init];
            _userUpdatesSubscriptionTimer = [[TGTimer alloc] initWithTimeout:10 * 60.0 repeat:true completion:^
            {
                [self updateUserUpdatesSubscriptions];
            } queue:[ActionStageInstance() globalStageDispatchQueue]];
            
            //[[AFNetworkActivityIndicatorManager sharedManager] setEnabled:true];
            
            NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:(256) diskCapacity:0 diskPath:nil];
            [NSURLCache setSharedURLCache:sharedCache];

            [ASActor registerActorClass:[TGLogoutRequestBuilder class]];
            [ASActor registerActorClass:[TGSendCodeRequestBuilder class]];
            [ASActor registerActorClass:[TGSignInRequestBuilder class]];
            [ASActor registerActorClass:[TGSignUpRequestBuilder class]];
            [ASActor registerActorClass:[TGSendInvitesActor class]];
            [ASActor registerActorClass:[TGPushActionsRequestBuilder class]];
            [ASActor registerActorClass:[TGUpdatePresenceActor class]];
            [ASActor registerActorClass:[TGRevokeSessionsActor class]];
            
            [ASActor registerActorClass:[TGApplyUpdatesActor class]];
            
            [ASActor registerActorClass:[TGFileDownloadActor class]];
            [ASActor registerActorClass:[TGFileUploadActor class]];
            [ASActor registerActorClass:[TGDocumentDownloadActor class]];
            [ASActor registerActorClass:[TGMultipartFileDownloadActor class]];
            
            [ASActor registerActorClass:[TGCheckImageStoredActor class]];
            
            [ASActor registerActorClass:[TGUpdateStateRequestBuilder class]];
            [ASActor registerActorClass:[TGApplyStateRequestBuilder class]];
            [ASActor registerActorClass:[TGSynchronizationStateRequestActor class]];
            [ASActor registerActorClass:[TGSynchronizeActionQueueActor class]];
            [ASActor registerActorClass:[TGSynchronizeServiceActionsActor class]];
            
            [ASActor registerActorClass:[TGUserDataRequestBuilder class]];
            [ASActor registerActorClass:[TGExtendedUserDataRequestActor class]];
            [ASActor registerActorClass:[TGPeerSettingsActor class]];
            [ASActor registerActorClass:[TGChangePeerSettingsActor class]];
            [ASActor registerActorClass:[TGResetPeerNotificationsActor class]];
            [ASActor registerActorClass:[TGExtendedChatDataRequestActor class]];
            [ASActor registerActorClass:[TGBlockListRequestActor class]];
            [ASActor registerActorClass:[TGChangePeerBlockStatusActor class]];
            [ASActor registerActorClass:[TGChangeNameActor class]];
            [ASActor registerActorClass:[TGChangePrivacySettingsActor class]];
            [ASActor registerActorClass:[TGUpdateUserStatusesActor class]];
            
            [ASActor registerActorClass:[TGDialogListRequestBuilder class]];
            [ASActor registerActorClass:[TGDialogListSearchActor class]];
            [ASActor registerActorClass:[TGMessagesSearchActor class]];
            
            [ASActor registerActorClass:[TGSynchronizeContactsActor class]];
            [ASActor registerActorClass:[TGContactListRequestBuilder class]];
            [ASActor registerActorClass:[TGSuggestedContactsRequestActor class]];
            [ASActor registerActorClass:[TGContactsGlobalSearchActor class]];
            [ASActor registerActorClass:[TGContactListSearchActor class]];
            [ASActor registerActorClass:[TGLocationServicesStateActor class]];
            
            [ASActor registerActorClass:[TGConversationHistoryAsyncRequestActor class]];
            [ASActor registerActorClass:[TGConversationHistoryRequestActor class]];
            [ASActor registerActorClass:[TGConversationChatInfoRequestActor class]];
            [ASActor registerActorClass:[TGReportDeliveryActor class]];
            [ASActor registerActorClass:[TGConversationActivityRequestBuilder class]];
            [ASActor registerActorClass:[TGConversationChangeTitleRequestActor class]];
            [ASActor registerActorClass:[TGConversationChangePhotoActor class]];
            [ASActor registerActorClass:[TGConversationCreateChatRequestActor class]];
            [ASActor registerActorClass:[TGConversationAddMemberRequestActor class]];
            [ASActor registerActorClass:[TGConversationDeleteMemberRequestActor class]];
            [ASActor registerActorClass:[TGConversationDeleteMessagesActor class]];
            [ASActor registerActorClass:[TGConversationDeleteActor class]];
            [ASActor registerActorClass:[TGConversationClearHistoryActor class]];
            
            [ASActor registerActorClass:[TGProfilePhotoListActor class]];
            [ASActor registerActorClass:[TGDeleteProfilePhotoActor class]];
            
            [ASActor registerActorClass:[TGTimelineHistoryRequestBuilder class]];
            [ASActor registerActorClass:[TGTimelineUploadPhotoRequestBuilder class]];
            [ASActor registerActorClass:[TGTimelineRemoveItemsRequestActor class]];
            [ASActor registerActorClass:[TGTimelineAssignProfilePhotoActor class]];
            [ASActor registerActorClass:[TGDeleteUserAvatarActor class]];
            
            [ASActor registerActorClass:[TGConversationAddMessagesActor class]];

            [ASActor registerActorClass:[TGLocationRequestActor class]];
            [ASActor registerActorClass:[TGLocationReverseGeocodeActor class]];
            [ASActor registerActorClass:[TGSaveGeocodingResultActor class]];
            
            [ASActor registerActorClass:[TGVideoDownloadActor class]];
            
            [ASActor registerActorClass:[TGCheckUpdatesActor class]];
            [ASActor registerActorClass:[TGWallpaperListRequestActor class]];
            [ASActor registerActorClass:[TGImageSearchActor class]];
            
            [ASActor registerActorClass:[TGSynchronizePreferencesActor class]];

            [ASActor registerActorClass:[TGRequestEncryptedChatActor class]];
            [ASActor registerActorClass:[TGEncryptedChatResponseActor class]];
            [ASActor registerActorClass:[TGDiscardEncryptedChatActor class]];
            
            [ASActor registerActorClass:[TGModernSendCommonMessageActor class]];
            [ASActor registerActorClass:[TGModernSendSecretMessageActor class]];
            
            [ASActor registerActorClass:[TGModernRemoteWallpaperListActor class]];
            [ASActor registerActorClass:[TGUpdateConfigActor class]];
            [ASActor registerActorClass:[TGDownloadMessagesActor class]];
            
            [ASActor registerActorClass:[TGICloudFileDownloadActor class]];
        }];
        
        [TGRemoteImageView registerImageProcessor:^UIImage *(UIImage *source)
        {
            return TGScaleAndRoundCorners(source, CGSizeMake(56, 56), CGSizeZero, 5, nil, false, nil);
        } withName:@"avatar56"];
        
        [TGRemoteImageView registerImageProcessor:^UIImage *(UIImage *source)
        {
            return TGScaleAndRoundCornersWithOffset(source, CGSizeMake(30, 30), CGPointMake(2, 2), CGSizeMake(32, 32), 5, nil, false, nil);
        } withName:@"avatarAuthor"];
        
        [TGRemoteImageView registerImageProcessor:^UIImage *(UIImage *source)
        {
            return TGScaleAndRoundCorners(source, CGSizeMake(40, 40), CGSizeZero, 4, nil, false, nil);
        } withName:@"avatar40"];
        
        [TGRemoteImageView registerImageProcessor:^UIImage *(UIImage *source)
        {
            return TGScaleAndRoundCorners(source, CGSizeMake(27, 27), CGSizeZero, 0, nil, true, nil);
        } withName:@"avatar27"];
        
        [TGRemoteImageView registerImageProcessor:^UIImage *(UIImage *source)
        {
            return TGScaleAndRoundCorners(source, CGSizeMake(56, 56), CGSizeMake(27, 56), 0, nil, true, nil);
        } withName:@"avatar56_half"];
        
        [TGRemoteImageView registerImageProcessor:^UIImage *(UIImage *source)
        {
            return TGScaleAndRoundCornersWithOffsetAndFlags(source, CGSizeMake(69, 69), CGPointMake(0.5f, 0), CGSizeMake(70, 70), 10, [TGInterfaceAssets profileAvatarOverlay], false, nil, TGScaleImageScaleOverlay);
        } withName:@"profileAvatar"];
        
        [TGRemoteImageView registerImageProcessor:^UIImage *(UIImage *source)
        {
            return TGScaleAndRoundCornersWithOffset(source, CGSizeMake(69, 69), CGPointMake(1, 0.5f), CGSizeMake(71, 71), 9, [UIImage imageNamed:@"LoginProfilePhotoOverlay.png"], false, nil);
        } withName:@"signupProfileAvatar"];
        
        [TGRemoteImageView registerImageProcessor:^UIImage *(UIImage *source)
        {
            UIImage *rawImage = [UIImage imageNamed:@"LoginBigPhotoOverlay.png"];
            return TGScaleAndRoundCornersWithOffsetAndFlags(source, CGSizeMake(180, 180), CGPointMake(3.5f, 3.0f), CGSizeMake(187, 187), 8, [rawImage stretchableImageWithLeftCapWidth:(int)(rawImage.size.width / 2) topCapHeight:(int)(rawImage.size.height / 2)], false, nil, TGScaleImageScaleOverlay);
        } withName:@"inactiveAvatar"];
        
        [TGRemoteImageView registerImageProcessor:^UIImage *(UIImage *source)
        {
            return TGScaleAndRoundCornersWithOffset(source, CGSizeMake(35, 35), CGPointZero, CGSizeMake(35, 35), 4, nil, false, nil);
        } withName:@"titleAvatar"];
        
        [TGRemoteImageView registerImageProcessor:^UIImage *(UIImage *source)
        {
            return TGScaleAndRoundCornersWithOffset(source, CGSizeMake(40, 40), CGPointMake(2, 2), CGSizeMake(44, 44), 4, [TGInterfaceAssets memberListAvatarOverlay], false, nil);
        } withName:@"memberListAvatar"];
        
        [TGRemoteImageView registerImageProcessor:^UIImage *(UIImage *source)
        {
            return TGScaleAndRoundCornersWithOffset(source, CGSizeMake(38, 38), CGPointMake(0.0f, 0.0f), CGSizeMake(38, 38), 19, nil, false, nil);
        } withName:@"conversationAvatar"];
        
        [TGRemoteImageView registerImageProcessor:^UIImage *(UIImage *source)
        {
            return TGScaleAndRoundCornersWithOffset(source, CGSizeMake(33, 33), CGPointMake(0.5f, 0.0f), CGSizeMake(34, 34), 4, [TGInterfaceAssets notificationAvatarOverlay], false, nil);
        } withName:@"notificationAvatar"];
        
        [TGRemoteImageView registerImageProcessor:^UIImage *(UIImage *source)
        {
            return TGScaleAndRoundCornersWithOffset(source, CGSizeMake(30, 30), CGPointZero, CGSizeMake(30, 30), 3, nil, false, nil);
        } withName:@"inlineMessageAvatar"];
        
        [TGRemoteImageView registerImageProcessor:^UIImage *(UIImage *source)
        {
            return TGScaleAndRoundCornersWithOffsetAndFlags(source, CGSizeMake(149.5f, 149), CGPointMake(0.5f, 0.5f), CGSizeMake(150, 150), 8, [[TGInterfaceAssets instance] conversationUserPhotoOverlay], false, nil, TGScaleImageScaleOverlay);
        } withName:@"conversationUserPhoto"];
        
        [TGRemoteImageView registerImageUniversalProcessor:^UIImage *(NSString *name, UIImage *source)
        {
            CGSize size = CGSizeZero;
            int n = 6;
            bool invalid = false;
            for (int i = n; i < (int)name.length; i++)
            {
                unichar c = [name characterAtIndex:i];
                if (c == 'x')
                {
                    if (i == n)
                        invalid = true;
                    else
                    {
                        size.width = [[name substringWithRange:NSMakeRange(n, i - n)] intValue];
                        n = i + 1;
                    }
                    break;
                }
                else if (c < '0' || c > '9')
                {
                    invalid = true;
                    break;
                }
            }
            if (!invalid)
            {
                for (int i = n; i < (int)name.length; i++)
                {
                    unichar c = [name characterAtIndex:i];
                    if (c < '0' || c > '9')
                    {
                        invalid = true;
                        break;
                    }
                    else if (i == (int)name.length - 1)
                    {
                        size.height = [[name substringFromIndex:n] intValue];
                    }
                }
            }
            if (!invalid)
            {
                if (CGSizeEqualToSize(source.size, size))
                    return source;
                return TGScaleImage(source, size);
            }
            
            return nil;
        } withBaseName:@"scale"];
        
        [TGRemoteImageView registerImageUniversalProcessor:^UIImage *(NSString *name, UIImage *source)
        {
            CGSize size = CGSizeZero;
            int n = 7;
            bool invalid = false;
            for (int i = n; i < (int)name.length; i++)
            {
                unichar c = [name characterAtIndex:i];
                if (c == 'x')
                {
                    if (i == n)
                        invalid = true;
                    else
                    {
                        size.width = [[name substringWithRange:NSMakeRange(n, i - n)] intValue];
                        n = i + 1;
                    }
                    break;
                }
                else if (c < '0' || c > '9')
                {
                    invalid = true;
                    break;
                }
            }
            if (!invalid)
            {
                for (int i = n; i < (int)name.length; i++)
                {
                    unichar c = [name characterAtIndex:i];
                    if (c < '0' || c > '9')
                    {
                        invalid = true;
                        break;
                    }
                    else if (i == (int)name.length - 1)
                    {
                        size.height = [[name substringFromIndex:n] intValue];
                    }
                }
            }
            if (!invalid)
            {
                return TGScaleAndRoundCornersWithOffsetAndFlags(source, size, CGPointZero, size, (int)size.width / 2, nil, false, nil, TGScaleImageScaleSharper);
            }
            
            return nil;
        } withBaseName:@"circle"];
        
        [TGRemoteImageView registerImageProcessor:^UIImage *(UIImage *source)
        {
            CGSize imageSize = source.screenSize;
            if (imageSize.width < 1)
                imageSize.width = 1;
            if (imageSize.height < 1)
                imageSize.height = 1;
            
            if (imageSize.width < imageSize.height)
            {
                imageSize.height = (int)(imageSize.height * 90.0f / imageSize.width);
                imageSize.width = 90;
            }
            else
            {
                imageSize.width = (int)(imageSize.width * 90.0f / imageSize.height);
                imageSize.height = 90;
            }
            imageSize = TGFitSize(imageSize, CGSizeMake(200, 200));
            return TGScaleAndRoundCorners(source, imageSize, imageSize, 0, nil, true, nil);
        } withName:@"mediaListImage"];
        
        [TGRemoteImageView registerImageProcessor:^UIImage *(UIImage *source)
        {
            CGSize imageSize = source.screenSize;
            if (imageSize.width < 1)
                imageSize.width = 1;
            if (imageSize.height < 1)
                imageSize.height = 1;
            
            if (imageSize.width < imageSize.height)
            {
                imageSize.height = (int)(imageSize.height * 75.0f / imageSize.width);
                imageSize.width = 75.0f;
            }
            else
            {
                imageSize.width = (int)(imageSize.width * 75.0f / imageSize.height);
                imageSize.height = 75.0f;
            }
            
            //imageSize = TGFitSize(imageSize, CGSizeMake(200, 200));
            
            return TGScaleAndRoundCorners(source, imageSize, CGSizeMake(75, 75), 0, nil, true, nil);
        } withName:@"mediaGridImage"];
        
        [TGRemoteImageView registerImageProcessor:^UIImage *(UIImage *source)
        {
            CGSize imageSize = source.screenSize;
            if (imageSize.width < 1)
                imageSize.width = 1;
            if (imageSize.height < 1)
                imageSize.height = 1;
            
            const float imageSide = 100.0f;
            
            if (imageSize.width < imageSize.height)
            {
                imageSize.height = (int)(imageSize.height * imageSide / imageSize.width);
                imageSize.width = imageSide;
            }
            else
            {
                imageSize.width = (int)(imageSize.width * imageSide / imageSize.height);
                imageSize.height = imageSide;
            }
            
            //imageSize = TGFitSize(imageSize, CGSizeMake(200, 200));
            
            return TGScaleAndRoundCorners(source, imageSize, CGSizeMake(imageSide, imageSide), 0, nil, true, nil);
        } withName:@"mediaGridImageLarge"];
        
        [TGRemoteImageView registerImageProcessor:^UIImage *(UIImage *source)
         {
             CGSize imageSize = source.screenSize;
             if (imageSize.width < 1)
                 imageSize.width = 1;
             if (imageSize.height < 1)
                 imageSize.height = 1;
             
             const float imageSide = 118.0f;
             
             if (imageSize.width < imageSize.height)
             {
                 imageSize.height = (int)(imageSize.height * imageSide / imageSize.width);
                 imageSize.width = imageSide;
             }
             else
             {
                 imageSize.width = (int)(imageSize.width * imageSide / imageSize.height);
                 imageSize.height = imageSide;
             }
             
             return TGScaleAndRoundCornersWithOffsetAndFlags(source, imageSize, CGPointZero, CGSizeMake(imageSide, imageSide), 8, nil, false, nil, TGScaleImageRoundCornersByOuterBounds);
         } withName:@"downloadingOverlayImage"];
        
        [TGRemoteImageView registerImageProcessor:^UIImage *(UIImage *source)
        {
            return TGScaleImageToPixelSize(source, TGFitSize(source.pixelSize, CGSizeMake(1024, 1024)));
        } withName:@"maybeScale"];
        
        /*[TGRemoteImageView registerImageUniversalProcessor:^UIImage *(NSString *name, UIImage *source)
        {
            CGSize size = extractSize(name, @"attachmentImageIncoming:");
            if (size.width > 0 && size.height > 0)
                return TGAttachmentImage(source, size, size, true, false);
            return nil;
        } withBaseName:@"attachmentImageIncoming"];*/
        
        [TGRemoteImageView registerImageUniversalProcessor:^UIImage *(NSString *name, UIImage *source)
        {
            CGSize resultSize = CGSizeZero;
            CGSize imageSize = CGSizeZero;
            if (extractTwoSizes(name, @"attachmentImageOutgoing:", &resultSize, &imageSize))
                return TGAttachmentImage(source, imageSize, resultSize, false, false);
            
            return nil;
        } withBaseName:@"attachmentImageOutgoing"];
        
        [TGRemoteImageView registerImageUniversalProcessor:^UIImage *(NSString *name, UIImage *source)
        {
            CGSize resultSize = CGSizeZero;
            CGSize imageSize = CGSizeZero;
            if (extractTwoSizes(name, @"secretAttachmentImageOutgoing:", &resultSize, &imageSize))
                return TGSecretAttachmentImage(source, imageSize, resultSize);
            
            return nil;
        } withBaseName:@"secretAttachmentImageOutgoing"];
        
        [TGRemoteImageView registerImageProcessor:^UIImage *(UIImage *source)
        {
            return TGAttachmentImage(source, CGSizeZero, CGSizeMake(100, 100), true, true);
        } withName:@"attachmentLocationIncoming"];
        
        [TGRemoteImageView registerImageProcessor:^UIImage *(UIImage *source)
        {
            return TGAttachmentImage(source, CGSizeMake(100, 106), CGSizeMake(100, 100), false, true);
        } withName:@"attachmentLocationOutgoing"];
        
        _genericTasksSignalManager = [[SMulticastSignalManager alloc] init];
        _channelStatesSignalManager = [[SMulticastSignalManager alloc] init];
        _channelTasksDisposable = [[SDisposableSet alloc] init];
        _disposeOnLogout = [[SDisposableSet alloc] init];
        _checkLocalizationDisposable = [[SMetaDisposable alloc] init];
        _callManager = [[TGCallManager alloc] init];
        _mediaBox = [[MediaBox alloc] initWithBasePath:[[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"mediacache"]];
        [[TGInterfaceManager instance] setupCallManager:_callManager];
    }
    return self;
}

- (TGModernConversationActivityManager *)activityManagerForConversationId:(int64_t)conversationId accessHash:(int64_t)accessHash
{
    TG_SYNCHRONIZED_BEGIN(_activityManagerByConversationId);
    if (_activityManagerByConversationId == nil)
        _activityManagerByConversationId = [[NSMutableDictionary alloc] init];
    TGModernConversationActivityManager *activityManager = _activityManagerByConversationId[@(conversationId)];
    if (activityManager == nil)
    {
        activityManager = [[TGModernConversationActivityManager alloc] init];
        activityManager.sendActivityUpdate = ^(NSString *type, NSString *previousType)
        {
            [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversation/(%lld)/activity/(%@)", conversationId, type == nil ? @"cancel" : type] options:@{@"accessHash": @(accessHash), @"previousType": previousType == nil ? @"" : previousType} watcher:self];
        };
        _activityManagerByConversationId[@(conversationId)] = activityManager;
    }
    TG_SYNCHRONIZED_END(_activityManagerByConversationId);
    
    return activityManager;
}

- (void)doLogout
{
    [self doLogout:nil];
}

- (void)doLogout:(NSString *)presetPhoneNumber
{    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [TGAppDelegateInstance resetLoginState];
        
        [TGDatabaseInstance() clearSpotlightIndex:nil];
        
        [ActionStageInstance() removeWatcher:self];
        
        [TGSuggestedContactsRequestActor clearCache];
        
        [[TGInterfaceAssets instance] clearColorMapping];
        
        [TGWebSearchController clearRecents];
        [TGRecentHashtagsSignal clearRecentHashtags];
        
        [TGGlobalMessageSearchSignals clearRecentResults];
        
        [TGModernSendCommonMessageActor clearRemoteMediaMapping];
        
        [TGGoogleDriveController unlinkCurrentSession];
        
        [[TGTelegramNetworking instance] removeCredentialsForExtensions];
        
        [TGStickersSignals clearCache];
        [TGMaskStickersSignals clearCache];
        TGAppDelegateInstance.alwaysShowStickersMode = 0;
        
        [_callManager reset];
        
        _genericTasksSignalManager = [[SMulticastSignalManager alloc] init];
        _channelStatesSignalManager = [[SMulticastSignalManager alloc] init];
        
        self.clientUserId = 0;
        self.clientIsActivated = false;
        [TGAppDelegateInstance saveSettings];
        
        [[TGDatabase instance] dropDatabase];
        [[TGTelegramNetworking instance] restartWithCleanCredentials];
        [TGAppDelegateInstance setIsManuallyLocked:false];
        
        _userLinksToDispatch.clear();
        _userDataToDispatch.clear();
        _userPresenceToDispatch.clear();
        
        TG_SYNCHRONIZED_BEGIN(_activityManagerByConversationId);
        [_activityManagerByConversationId removeAllObjects];
        TG_SYNCHRONIZED_END(_activityManagerByConversationId);
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [TGEmbedPIPController dismissPictureInPicture];
            [[TGInterfaceManager instance] dismissAllBanners];
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            
            [TGAppDelegateInstance presentLoginController:true animated:false showWelcomeScreen:false phoneNumber:presetPhoneNumber phoneCode:nil phoneCodeHash:nil codeSentToTelegram:false codeSentViaPhone:false profileFirstName:nil profileLastName:nil resetAccountState:nil];
        });
        
        [_channelTasksDisposable dispose];
        _channelTasksDisposable = [[SDisposableSet alloc] init];
        
        [_disposeOnLogout dispose];
        _disposeOnLogout = [[SDisposableSet alloc] init];
        
        [_checkLocalizationDisposable dispose];
        _checkLocalizationDisposable = [[SMetaDisposable alloc] init];
        
        [TGChannelStateSignals clearChannelStates];
        
        [TGRecentContextBotsSignal clearRecentBots];
        [TGRecentGifsSignal clearRecentGifs];
        [TGRecentStickersSignal clearRecentStickers];
        [TGRecentMaskStickersSignal clearRecentStickers];
                
        [[[TGBridgeServer instanceSignal] onNext:^(TGBridgeServer *server) {
            [server setAuthorized:false userId:0];
        }] startWithNext:nil];
        
        [_musicPlayer setPlaylist:nil initialItemKey:nil metadata:nil];
        
        [ActionStageInstance() dispatchResource:@"/tg/loggedOut" resource:nil];
    }];
}

- (void)stateUpdateRequired
{
    if (_clientUserId != 0)
        [ActionStageInstance() requestActor:@"/tg/service/updatestate" options:nil watcher:self];
}

- (void)setClientUserId:(int)clientUserId
{
    _clientUserId = clientUserId;
    
    [TGDatabaseInstance() setLocalUserId:clientUserId];
}

#pragma mark - Dispatch

- (void)didEnterBackground:(NSNotification *)__unused notification
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [_updateRelativeTimestampsTimer invalidate];
    }];
}

- (void)willEnterForeground:(NSNotification *)__unused notification
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [self updateUserTypingStatuses];
        
        [TGApplyUpdatesActor clearDelayedNotifications];
        
        [ActionStageInstance() dispatchResource:@"/as/updateRelativeTimestamps" resource:nil];
        
        [_updateRelativeTimestampsTimer invalidate];
        [_updateRelativeTimestampsTimer start];
    }];
}

- (void)dispatchUserDataChanges:(TGUser *)user changes:(int)changes
{
    if (user == nil)
        return;
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        _userDataToDispatch[user.uid] = std::pair<TGUser *, int>(user, changes);
        
        if (!_willDispatchUserData)
        {
            _willDispatchUserData = true;
            
            dispatch_async([ActionStageInstance() globalStageDispatchQueue], ^
            {
                _willDispatchUserData = false;
                
                bool updatedPresenceExpiration = false;

                NSMutableArray *changedUsers = [[NSMutableArray alloc] init];
                NSMutableArray *userPresenceChanges = [[NSMutableArray alloc] init];
                
                for (UserDataToDispatchIterator it = _userDataToDispatch.begin(); it != _userDataToDispatch.end(); it++)
                {
                    TGUser *user = it->second.first;
                    int difference = it->second.second;
                    
                    if (difference != 0)
                    {
                        if ((difference & TGUserFieldsAllButPresenceMask) != 0 || (difference & TGUserFieldPresenceOnline) != 0)
                        {
                            [changedUsers addObject:user];
                            
                            if (user.presence.online)
                            {
                                updatedPresenceExpiration = true;
                                _userPresenceExpiration[user.uid] = user.presence.lastSeen;
                            }
                            else
                                _userPresenceExpiration.erase(user.uid);
                        }
                        else if ((difference & TGUserFieldsAllButPresenceMask) == 0)
                        {
                            [userPresenceChanges addObject:user];
                            
                            if (user.presence.online)
                            {
                                updatedPresenceExpiration = true;
                                _userPresenceExpiration[user.uid] = user.presence.lastSeen;
                            }
                            else
                                _userPresenceExpiration.erase(user.uid);
                        }
                    }
                }
                
                if (changedUsers.count != 0)
                {
                    //TGLog(@"===== %d users changed", changedUsers.count);
                    [ActionStageInstance() dispatchResource:@"/tg/userdatachanges" resource:[[SGraphObjectNode alloc] initWithObject:changedUsers]];
                }
                
                if (userPresenceChanges.count != 0)
                {
                    [ActionStageInstance() dispatchResource:@"/tg/userpresencechanges" resource:[[SGraphObjectNode alloc] initWithObject:userPresenceChanges]];
                }
                
                _userDataToDispatch.clear();
                
                if (updatedPresenceExpiration)
                    [self updateUsersPresences:false];
            });
        }
    }];
}

- (void)dispatchUserPresenceChanges:(int64_t)userId presence:(TGUserPresence)presence
{
    std::shared_ptr<std::map<int, TGUserPresence> > presenceMap(new std::map<int, TGUserPresence>());
    presenceMap->insert(std::make_pair((int)userId, presence));
    [self dispatchMultipleUserPresenceChanges:presenceMap];
}

- (void)dispatchMultipleUserPresenceChanges:(std::shared_ptr<std::map<int, TGUserPresence> >)presenceMap
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        for (std::map<int, TGUserPresence>::const_iterator it = presenceMap->begin(); it != presenceMap->end(); it++)
        {
            _userPresenceToDispatch[it->first] = it->second;
        }

        if (!_willDispatchUserPresence)
        {
            _willDispatchUserPresence = true;
            dispatch_async([ActionStageInstance() globalStageDispatchQueue], ^
            {
                _willDispatchUserPresence = false;

                [self dispatchMultipleUserPresenceChangesNow];
            });
        }
    }];
}

- (void)dispatchMultipleUserPresenceChangesNow
{
    NSMutableArray *userPresenceChanges = [[NSMutableArray alloc] init];
    
    NSMutableArray *storeUsers = [[NSMutableArray alloc] init];
    
    bool updatedPresenceExpiration = false;
    
    int clientUserId = TGTelegraphInstance.clientUserId;
    
    for (std::map<int, TGUserPresence>::iterator it = _userPresenceToDispatch.begin(); it != _userPresenceToDispatch.end(); it++)
    {
        TGUser *databaseUser = [[TGDatabase instance] loadUser:(int)(it->first)];
        if (databaseUser != nil)
        {
            if (databaseUser.presence.online != it->second.online || databaseUser.presence.lastSeen != it->second.lastSeen)
            {
                //TGLog(@"===== Presence (%@): %s, %d -> %s, %d", databaseUser.displayName, databaseUser.presence.online ? "online" : "offline", databaseUser.presence.lastSeen, it->second.online ? "online" : "offline", it->second.lastSeen);
                
                TGUser *user = [databaseUser copy];
                
                TGUserPresence presence = it->second;
                if (it->first == clientUserId)
                {
                    presence.online = true;
                    presence.lastSeen = INT_MAX;
                    presence.temporaryLastSeen = INT_MAX;
                }
                
                user.presence = presence;
                
                if (user.presence.online)
                {
                    updatedPresenceExpiration = true;
                    if (user.presence.temporaryLastSeen != 0)
                        _userPresenceExpiration[user.uid] = user.presence.temporaryLastSeen;
                    else
                        _userPresenceExpiration[user.uid] = user.presence.lastSeen;
                }
                else
                    _userPresenceExpiration.erase(user.uid);
                
                [storeUsers addObject:user];
                
                //if (databaseUser.presence.online != it->second.online || databaseUser.presence.lastSeen != it->second.lastSeen)
                    [userPresenceChanges addObject:user];
            }
        }
    }
    
    if (storeUsers.count != 0)
        [[TGDatabase instance] storeUsers:storeUsers];
    
    if (userPresenceChanges.count != 0)
        [ActionStageInstance() dispatchResource:@"/tg/userpresencechanges" resource:[[SGraphObjectNode alloc] initWithObject:userPresenceChanges]];
    
    _userPresenceToDispatch.clear();
    
    if (updatedPresenceExpiration)
        [self updateUsersPresences:false];
}

- (void)updateUsersPresences:(bool)nonRecursive
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        int currentUnixTime = (int)[[TGTelegramNetworking instance] globalTime];
        
        int nextPresenceExpiration = INT_MAX;
        for (std::map<int, int>::iterator it = _userPresenceExpiration.begin(); it != _userPresenceExpiration.end(); it++)
        {
            if (it->second < nextPresenceExpiration)
                nextPresenceExpiration = it->second;
            
#ifdef DEBUG
            __unused int delay = it->second - currentUnixTime;
            //TGLog(@"%@ will go offline in %d m %d s", [TGDatabaseInstance() loadUser:it->first].displayName, delay / 60, delay % 60);
#endif
        }
        
        if (nextPresenceExpiration != INT_MAX)
        {
            if (nextPresenceExpiration - currentUnixTime < 0)
            {
                if (nonRecursive)
                {
                    dispatch_async([ActionStageInstance() globalStageDispatchQueue], ^
                    {
                        [self updateUsersPresencesNow];
                    });
                }
                else
                    [self updateUsersPresencesNow];
            }
            else
            {
                if (_userPresenceExpirationTimer == nil || _userPresenceExpirationTimer.timeoutDate < nextPresenceExpiration - 1)
                {
                    //if (_userPresenceExpirationTimer != nil)
                    //TGLog(@"%d < %d", (int)(_userPresenceExpirationTimer.timeoutDate), nextPresenceExpiration - 1);
                    _userPresenceExpirationTimer = [[TGTimer alloc] initWithTimeout:(nextPresenceExpiration - currentUnixTime) repeat:false completion:^
                    {
                        [self updateUsersPresencesNow];
                    } queue:[ActionStageInstance() globalStageDispatchQueue]];
                    [_userPresenceExpirationTimer start];
                }
                else if (_userPresenceExpirationTimer != nil)
                {
                    //TGLog(@"Use running expiration timer");
                }
            }
        }
    }];
}

- (void)updateUsersPresencesNow
{
    _userPresenceExpirationTimer = nil;
    
    int currentUnixTime = (int)[[TGTelegramNetworking instance] globalTime];
    
    std::vector<std::pair<int, TGUserPresence> > expired;
    for (std::map<int, int>::iterator it = _userPresenceExpiration.begin(); it != _userPresenceExpiration.end(); it++)
    {
        if (it->second <= currentUnixTime + 1)
        {
            TGUser *user = [TGDatabaseInstance() loadUser:it->first];
            TGUserPresence presence;
            presence.online = false;
            presence.lastSeen = user.presence.lastSeen > 0 ? it->second : user.presence.lastSeen;
            presence.temporaryLastSeen = 0;
            expired.push_back(std::pair<int, TGUserPresence>(it->first, presence));
            
#ifdef DEBUG
            TGLog(@"%@ did go offline", [TGDatabaseInstance() loadUser:it->first].displayName);
#endif
        }
    }
    
    for (std::vector<std::pair<int, TGUserPresence> >::iterator it = expired.begin(); it != expired.end(); it++)
    {
        _userPresenceExpiration.erase(it->first);
        
        _userPresenceToDispatch[it->first] = it->second;
    }
    
    if (!_userPresenceToDispatch.empty())
    {
        [self dispatchMultipleUserPresenceChangesNow];
    }
    
    [self updateUsersPresences:true];
}

- (void)updateUserTypingStatuses
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        TGLog(@"===== Updating typing statuses");
        NSTimeInterval currentTime = CFAbsoluteTimeGetCurrent();
        
        std::set<int64_t> conversationsWithoutTypingUsers;
        std::set<int64_t> *pConversationsWithoutTypingUsers = &conversationsWithoutTypingUsers;
        
        __block NSTimeInterval nextTypingUpdate = DBL_MAX;
        
        [_typingUserRecordsByConversation enumerateKeysAndObjectsUsingBlock:^(NSNumber *nConversationId, NSMutableDictionary *typingUserRecords, __unused BOOL *stop)
        {
            int64_t conversationId = [nConversationId longLongValue];
            
            std::set<int> usersStoppedTyping;
            std::set<int> *pUsersStoppedTyping = &usersStoppedTyping;
            
            [typingUserRecords enumerateKeysAndObjectsUsingBlock:^(NSNumber *nUid, TGTypingRecord *record, __unused BOOL *stop)
            {
                if (ABS(currentTime - record.date) > 6.0)
                {
                    pUsersStoppedTyping->insert([nUid intValue]);
                }
                else if (record.date + 6.0 < nextTypingUpdate)
                    nextTypingUpdate = record.date + 6.0;
            }];
            
            if (!usersStoppedTyping.empty())
            {
                for (std::set<int>::iterator it = usersStoppedTyping.begin(); it != usersStoppedTyping.end(); it++)
                {
                    [typingUserRecords removeObjectForKey:[NSNumber numberWithInt:*it]];
                }
                
                NSMutableDictionary *typingUsersActivitiesDict = [[NSMutableDictionary alloc] init];
                [typingUserRecords enumerateKeysAndObjectsUsingBlock:^(NSNumber *nUid, TGTypingRecord *record, __unused BOOL *stop)
                {
                    typingUsersActivitiesDict[nUid] = record.type;
                }];
                
                if (typingUserRecords.count == 0)
                    pConversationsWithoutTypingUsers->insert(conversationId);
                
                [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/typing", conversationId] resource:[[SGraphObjectNode alloc] initWithObject:typingUsersActivitiesDict]];
                [ActionStageInstance() dispatchResource:@"/tg/conversation/*/typing" resource:[[SGraphObjectNode alloc] initWithObject:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithLongLong:conversationId], @"conversationId", typingUsersActivitiesDict, @"typingUsers", nil]]];
            }
        }];
        
        for (std::set<int64_t>::iterator it = conversationsWithoutTypingUsers.begin(); it != conversationsWithoutTypingUsers.end(); it++)
        {
            [_typingUserRecordsByConversation removeObjectForKey:[NSNumber numberWithLongLong:*it]];
        }
        
        NSMutableDictionary *dictForMainThread = [[NSMutableDictionary alloc] init];
        [_typingUserRecordsByConversation enumerateKeysAndObjectsUsingBlock:^(NSNumber *nConversationId, NSMutableDictionary *typingUsers, __unused BOOL *stop)
        {
            NSMutableDictionary *typingUsersActivitiesDict = [[NSMutableDictionary alloc] init];
            [typingUsers enumerateKeysAndObjectsUsingBlock:^(NSNumber *nUid, TGTypingRecord *record, __unused BOOL *stop)
            {
                typingUsersActivitiesDict[nUid] = record.type;
            }];
            
            dictForMainThread[nConversationId] = typingUsersActivitiesDict;
        }];
        
        TGDispatchOnMainThread(^
        {
            _typingUserRecordsByConversationMainThread = dictForMainThread;
        });
        
        if (nextTypingUpdate < DBL_MAX - DBL_EPSILON && nextTypingUpdate - CFAbsoluteTimeGetCurrent() > 0)
        {
            [_usersTypingServiceTimer resetTimeout:nextTypingUpdate - CFAbsoluteTimeGetCurrent()];
        }
    }];
}

- (void)dispatchUserActivity:(int)uid inConversation:(int64_t)conversationId type:(NSString *)type
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        NSNumber *key = [[NSNumber alloc] initWithLongLong:conversationId];
        NSMutableDictionary *typingUserRecords = [_typingUserRecordsByConversation objectForKey:key];
        NSNumber *userKey = [[NSNumber alloc] initWithInt:uid];
        
        if (type != nil)
        {
            if (typingUserRecords == nil)
            {
                typingUserRecords = [[NSMutableDictionary alloc] init];
                [_typingUserRecordsByConversation setObject:typingUserRecords forKey:key];
            }
            
            bool updated = false;
            if ([typingUserRecords objectForKey:userKey] == nil || !TGStringCompare(((TGTypingRecord *)typingUserRecords[userKey]).type, type))
                updated = true;
            
            [typingUserRecords setObject:[[TGTypingRecord alloc] initWithDate:CFAbsoluteTimeGetCurrent() type:type] forKey:userKey];
            
            if (updated)
            {
                NSMutableDictionary *typingUsersActivitiesDict = [[NSMutableDictionary alloc] init];
                [typingUserRecords enumerateKeysAndObjectsUsingBlock:^(NSNumber *nUid, TGTypingRecord *record, __unused BOOL *stop)
                {
                    typingUsersActivitiesDict[nUid] = record.type;
                }];
                
                [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/typing", conversationId] resource:[[SGraphObjectNode alloc] initWithObject:typingUsersActivitiesDict]];
                [ActionStageInstance() dispatchResource:@"/tg/conversation/*/typing" resource:[[SGraphObjectNode alloc] initWithObject:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithLongLong:conversationId], @"conversationId", typingUsersActivitiesDict, @"typingUsers", nil]]];
            }
        }
        else
        {
            if (typingUserRecords != nil && [typingUserRecords objectForKey:userKey] != nil)
            {
                [typingUserRecords removeObjectForKey:userKey];
            }
            
            NSMutableDictionary *typingUsersActivitiesDict = [[NSMutableDictionary alloc] init];
            [typingUserRecords enumerateKeysAndObjectsUsingBlock:^(NSNumber *nUid, TGTypingRecord *record, __unused BOOL *stop)
            {
                typingUsersActivitiesDict[nUid] = record.type;
            }];
            
            [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/typing", conversationId] resource:[[SGraphObjectNode alloc] initWithObject:typingUsersActivitiesDict]];
            [ActionStageInstance() dispatchResource:@"/tg/conversation/*/typing" resource:[[SGraphObjectNode alloc] initWithObject:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithLongLong:conversationId], @"conversationId", typingUsersActivitiesDict, @"typingUsers", nil]]];
            
            if (typingUserRecords.count == 0)
                [_typingUserRecordsByConversation removeObjectForKey:key];
        }
        
        TGUser *user = [TGDatabaseInstance() loadUser:uid];
        if (user.presence.online == false)
        {
            int timeout = 60;
#if TARGET_IPHONE_SIMULATOR
            timeout = 10;
#endif
            TGUserPresence presence = (TGUserPresence){.online = true, .lastSeen = user.presence.lastSeen > 1000 ? ((int)[[TGTelegramNetworking instance] globalTime]) : user.presence.lastSeen, .temporaryLastSeen = (int)([[TGTelegramNetworking instance] globalTime] + timeout)};
            [self dispatchUserPresenceChanges:uid presence:presence];
        }
        
        [self updateUserTypingStatuses];
    }];
}

- (NSDictionary *)typingUserActivitiesInConversationFromMainThread:(int64_t)conversationId
{
    return _typingUserRecordsByConversationMainThread[@(conversationId)];
}

- (void)updatePresenceNow
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        bool online = [UIApplication sharedApplication] != nil && [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
        
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            if (_clientUserId != 0)
            {
                if (online)
                {
                    [ActionStageInstance() removeWatcher:self fromPath:@"/tg/service/updatepresence/(offline)"];
                    [ActionStageInstance() removeWatcher:self fromPath:@"/tg/service/updatepresence/(timeout)"];
                    [ActionStageInstance() requestActor:@"/tg/service/updatepresence/(online)" options:nil watcher:self];
                }
                else
                {
                    [ActionStageInstance() removeWatcher:self fromPath:@"/tg/service/updatepresence/(online)"];
                    [ActionStageInstance() removeWatcher:self fromPath:@"/tg/service/updatepresence/(timeout)"];
                    [ActionStageInstance() requestActor:@"/tg/service/updatepresence/(offline)" options:nil watcher:self];
                }
            }
        }];
    });
}

- (int)serviceUserUid
{
    return 777000;
}

- (int)createServiceUserIfNeeded
{
    if ([TGDatabaseInstance() loadUser:[self serviceUserUid]] == nil)
    {
        TGUser *user = [[TGUser alloc] init];
        user.uid = [self serviceUserUid];
        user.phoneNumber = @"42777";
        user.firstName = @"Telegram";
        user.lastName = @"";
        
        [TGDatabaseInstance() storeUsers:[[NSArray alloc] initWithObjects:user, nil]];
    }
    
    return [self serviceUserUid];
}

- (int)voipSupportUserUid
{
    return 4244000;
}

- (int)createVoipSupportUserIfNeeded
{
    if ([TGDatabaseInstance() loadUser:[self voipSupportUserUid]] == nil)
    {
        TGUser *user = [[TGUser alloc] init];
        user.uid = [self voipSupportUserUid];
        user.phoneNumber = @"4244000";
        user.firstName = @"VoIP Support";
        user.lastName = @"";
        
        [TGDatabaseInstance() storeUsers:[[NSArray alloc] initWithObjects:user, nil]];
    }
    
    return [self voipSupportUserUid];
}

- (void)locationTranslationSettingsUpdated
{
    bool locationTranslationEnabled = TGAppDelegateInstance.locationTranslationEnabled;
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        if (locationTranslationEnabled)
        {
            [ActionStageInstance() requestActor:@"/tg/liveNearby" options:nil watcher:self];
        }
        else
        {
            [ActionStageInstance() removeWatcher:self fromPath:@"/tg/liveNearby"];
        }
    }];
}

- (void)dispatchUserLinkChanged:(int)uid link:(int)link
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        _userLinksToDispatch[uid] = link;
        
        dispatch_async([ActionStageInstance() globalStageDispatchQueue], ^
        {
            for (std::map<int, int>::iterator it = _userLinksToDispatch.begin(); it != _userLinksToDispatch.end(); it++)
            {
                [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/userLink/(%d)", it->first] resource:[[SGraphObjectNode alloc] initWithObject:[[NSNumber alloc] initWithInt:it->second]]];
            }
            
            _userLinksToDispatch.clear();
        });
    }];
}

- (void)subscribeToUserUpdates:(ASHandle *)watcherHandle
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        if (![_userDataUpdatesSubscribers containsObject:watcherHandle])
            [_userDataUpdatesSubscribers addObject:watcherHandle];
    }];
}

- (void)unsubscribeFromUserUpdates:(ASHandle *)watcherHandle
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [_userDataUpdatesSubscribers removeObject:watcherHandle];
    }];
}

- (void)updateUserUpdatesSubscriptions
{
    NSMutableArray *freeOnMainThreadObjects = [[NSMutableArray alloc] init];
    
    NSMutableSet *uidSet = [[NSMutableSet alloc] init];
    
    int count = (int)_userDataUpdatesSubscribers.count;
    for (int i = 0; i < count; i++)
    {
        ASHandle *watcherHandle = [_userDataUpdatesSubscribers objectAtIndex:i];
        
        id<ASWatcher> watcher = watcherHandle.delegate;
        if (watcher != nil)
            [freeOnMainThreadObjects addObject:watcher];
        else
        {
            [_userDataUpdatesSubscribers removeObjectAtIndex:i];
            i--;
            count--;
            
            continue;
        }
        
        if ([watcher respondsToSelector:@selector(actionStageActionRequested:options:)])
        {
            [watcher actionStageActionRequested:@"updateUserDataSubscription" options:[[NSDictionary alloc] initWithObjectsAndKeys:uidSet, @"uidSet", nil]];
        }
    }
    
    if (uidSet.count != 0)
    {
        
    }
    
    if (freeOnMainThreadObjects.count != 0)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [freeOnMainThreadObjects removeAllObjects];
        });
    }
}

#pragma mark - Common logic

- (void)setClientIsActivated:(bool)clientIsActivated
{
    if (clientIsActivated)
    {
        TGLog(@"Activating user");
    }
    
    _clientIsActivated = clientIsActivated;
}

- (void)processEncryptedPasscode
{
//    TGAuthorizedContext *authorizedContext = [[TGAuthorizedContext alloc] initWithUserId:(int32_t)uid];
//    _authorizedContextPipe.sink(authorizedContext);
}

- (void)processAuthorizedWithUserId:(int)uid clientIsActivated:(bool)clientIsActivated
{
    if (iosMajorVersion() >= 10) {
        TGDispatchOnMainThread(^{
            [INPreferences requestSiriAuthorization:^(__unused INSiriAuthorizationStatus status) {
            }];
        });
    }
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
#if TGUseModernNetworking
        if (uid != 0)
        {
            [[TGTelegramNetworking instance].context updateAuthTokenForDatacenterWithId:[TGTelegramNetworking instance].mtProto.datacenterId authToken:@(uid)];
        }
#endif
        
        TGLog(@"Starting with user id %d activated: %d", uid, clientIsActivated ? 1 : 0);
        
        [[TGTelegramNetworking instance] exportCredentialsForExtensions];
        
        self.clientUserId = uid;
        self.clientIsActivated = clientIsActivated;
        [TGAppDelegateInstance saveSettings];
        
        if (_clientUserId != 0)
        {
            [TGAppDelegateInstance resetLoginState];
            
            TGUser *user = [[TGDatabase instance] loadUser:uid];
            
            if (user != nil)
            {
                TGUserPresence presence;
                presence.online = true;
                presence.lastSeen = (int)(CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970);
                presence.temporaryLastSeen = 0;
                user.presence = presence;
                [[TGDatabase instance] storeUsers:[NSArray arrayWithObject:user]];
            }
            
            [TGUpdateStateRequestBuilder scheduleInitialUpdates];
            
            [ActionStageInstance() requestActor:@"/tg/service/updatestate" options:nil watcher:self];
            
            [ActionStageInstance() requestActor:@"/tg/synchronizeContacts/(sync)" options:nil watcher:TGTelegraphInstance];
            
            TGDispatchOnMainThread(^
            {
                [TGAppDelegateInstance reloadSettingsController:uid];
                
                [TGAppDelegateInstance setupShortcutItems];
            });
            
            if (TGAppDelegateInstance.locationTranslationEnabled)
                [ActionStageInstance() requestActor:@"/tg/liveNearby" options:nil watcher:self];
            
            [TGDatabaseInstance() processAndScheduleSelfDestruct];
            [TGDatabaseInstance() processAndScheduleMediaCleanup];
            [TGDatabaseInstance() processAndScheduleMute];
            
            if (iosMajorVersion() >= 7 && user.phoneNumber.length != 0)
            {
                TGDispatchOnMainThread(^
                {
                    NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
                    if (!TGStringCompare(user.phoneNumber, [store objectForKey:@"telegram_currentPhoneNumber"]))
                    {
                        [store setObject:user.phoneNumber forKey:@"telegram_currentPhoneNumber"];
                        [store synchronize];
                    }
                });
            }
            
            [[[TGBridgeServer instanceSignal] onNext:^(TGBridgeServer *server) {
                [server setAuthorized:true userId:uid];
            }] startWithNext:nil];
            
            [_channelTasksDisposable add:[[TGChannelManagementSignals deleteChannelMessages] startWithNext:nil]];
            [_channelTasksDisposable add:[[TGChannelManagementSignals readChannelMessages] startWithNext:nil]];
            [_channelTasksDisposable add:[[TGChannelManagementSignals leaveChannels] startWithNext:nil]];
            [_channelTasksDisposable add:[[TGPeerInfoSignals dismissReportSpamForPeers] startWithNext:nil]];
            [_channelTasksDisposable add:[[TGGroupManagementSignals validatePeerReadStates:[TGDatabaseInstance() conversationsForReadStateValidation]] startWithNext:nil]];
            [_channelTasksDisposable add:[[TGGroupManagementSignals synchronizePeerMessageDrafts:[TGDatabaseInstance() synchronizePeerMessageDraftPeers]] startWithNext:nil]];
            [_channelTasksDisposable add:[[TGGroupManagementSignals synchronizePinnedConversations] startWithNext:nil]];
            
            TGDispatchAfter(2.0, dispatch_get_main_queue(), ^{
                [TGDatabaseInstance() updateSpotlightIndex];
            });
            
            [_mediaBox setFetchResource:^SSignal * _Nonnull(id<MediaResource> resource, NSRange range) {
                TGNetworkMediaTypeTag mediaTypeTag = (TGNetworkMediaTypeTag)[[resource mediaType] intValue];
                return fetchResource(resource, range, mediaTypeTag);
            }];
        }
    }];
}

- (void)processUnauthorized
{
    TGDispatchOnMainThread(^
    {
        [TGAppDelegateInstance setupShortcutItems];
    });
    
    [[[TGBridgeServer instanceSignal] onNext:^(TGBridgeServer *server) {
        [server setAuthorized:false userId:0];
    }] startWithNext:nil];
}

#pragma mark - Protocol

- (NSMutableDictionary *)operationTimeoutTimers
{
    static NSMutableDictionary *dictionary = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        dictionary = [[NSMutableDictionary alloc] init];
    });
    
    return dictionary;
}

- (void)registerTimeout:(AFHTTPRequestOperation *)operation duration:(NSTimeInterval)duration
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        NSTimer *timer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:duration] interval:0.0 target:self selector:@selector(timeoutTimerEvent:) userInfo:operation repeats:false];
        [[self operationTimeoutTimers] setObject:timer forKey:[NSNumber numberWithInt:(int)[operation hash]]];
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        });
    }];
}

- (void)removeTimeout:(AFHTTPRequestOperation *)operation
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        NSNumber *key = [NSNumber numberWithInt:(int)[operation hash]];
        NSTimer *timer = [[self operationTimeoutTimers] objectForKey:key];
        if (timer != nil)
        {
            [[self operationTimeoutTimers] removeObjectForKey:key];
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [timer invalidate];
            });
        }
        else
        {
            //TGLog(@"***** removeTimeout: timer not found");
        }
    }];
}

- (void)timeoutTimerEvent:(NSTimer *)timer
{
    AFHTTPRequestOperation *operation = timer.userInfo;
    TGLog(@"===== Request timeout: %@", operation.request.URL);
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        if ([operation isKindOfClass:[AFHTTPRequestOperation class]])
        {
            [operation cancel];
        }
        else
        {
            TGLog(@"***** timeoutTimerEvent: invalid operation key");
        }
        
        [[self operationTimeoutTimers] removeObjectForKey:[NSNumber numberWithInt:(int)[operation hash]]];
    }];
}

#pragma mark - Request processing

- (void)cancelRequestByToken:(NSObject *)token
{
    [self cancelRequestByToken:token softCancel:false];
}

- (void)cancelRequestByToken:(NSObject *)token softCancel:(bool)__unused softCancel
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        if ([token isKindOfClass:[TGRawHttpRequest class]])
        {
            [(TGRawHttpRequest *)token cancel];
        }
        else
        {
            [[TGTelegramNetworking instance] cancelRpc:token];
        }
    }];
}

#pragma mark - Requests

- (void)rawHttpRequestCompleted:(TGRawHttpRequest *)request response:(NSData *)response error:(NSError *)error
{
    if (request.cancelled)
    {
        [request dispose];
        return;
    }
    
    if (error != nil)
    {
        request.retryCount++;
        
        if (request.retryCount >= request.maxRetryCount && request.maxRetryCount > 0)
        {
            if (request.completionBlock)
                request.completionBlock(nil);
            [request dispose];
        }
        else
        {
            TGLog(@"Http error: %@", error);
            
            int64_t delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, [ActionStageInstance() globalStageDispatchQueue], ^
            {
                [self enqueueRawHttpRequest:request];
            });
        }
    }
    else
    {
        if (request.completionBlock)
            request.completionBlock(response);
        [request dispose];
    }
}

- (void)enqueueRawHttpRequest:(TGRawHttpRequest *)request
{
    NSMutableURLRequest *urlRequest = nil;
    urlRequest = [self requestWithMethod:@"GET" path:request.url parameters:nil];
    for (NSString *field in request.httpHeaders.allKeys)
    {
        [urlRequest setValue:request.httpHeaders[field] forHTTPHeaderField:field];
    }
    
    if ([request.url rangeOfString:@"googleusercontent.com/docs/securesc"].location != NSNotFound)
    {
        NSString *authValue = [[NSString alloc] initWithFormat:@"Bearer %@", [TGGoogleDriveController accessToken]];
        [urlRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
    }
    
    AFHTTPRequestOperation *httpOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    
    NSMutableIndexSet *acceptableCodes = [[NSMutableIndexSet alloc] initWithIndexSet:httpOperation.acceptableStatusCodes];
    for (NSNumber *nCode in request.acceptCodes)
    {
        [acceptableCodes addIndex:[nCode intValue]];
    }
    httpOperation.acceptableStatusCodes = acceptableCodes;
    
    [httpOperation setSuccessCallbackQueue:[ActionStageInstance() globalStageDispatchQueue]];
    [httpOperation setFailureCallbackQueue:[ActionStageInstance() globalStageDispatchQueue]];
    
    [httpOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, __unused id responseObject)
    {
        NSData *receivedData = [operation responseData];
        [self rawHttpRequestCompleted:request response:receivedData error:nil];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error)
    {
        [self rawHttpRequestCompleted:request response:nil error:error];
    }];
    
    if (request.progressBlock != nil)
    {
        __block float previousProgress = 0.0f;
        [httpOperation setDownloadProgressBlock:^(__unused NSInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead)
        {
            if (totalBytesExpectedToRead <= 0 && request.expectedFileSize > 0)
                totalBytesExpectedToRead = request.expectedFileSize;

            if (totalBytesExpectedToRead > 0 && totalBytesRead > 0)
            {
                float progress = ((float)totalBytesRead) / ((float)totalBytesExpectedToRead);
                if (progress > previousProgress) {
                    request.progressBlock(progress);
                    previousProgress = progress;
                }
            }
        }];
    }
    
    request.operation = httpOperation;
    [self enqueueHTTPRequestOperation:httpOperation];
}

- (id)doGetAppPrefs:(TGSynchronizePreferencesActor *)actor
{
    TLRPChelp_getAppPrefs$help_getAppPrefs *getAppPrefs = [[TLRPChelp_getAppPrefs$help_getAppPrefs alloc] init];
    getAppPrefs.api_id = [_apiId intValue];
    getAppPrefs.api_hash = _apiHash;
    
    return [[TGTelegramNetworking instance] performRpc:getAppPrefs completionBlock:^(TLhelp_AppPrefs *result, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor preferencesRequestSuccess:result];
        }
        else
        {
            [actor preferencesRequestFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric | TGRequestClassHidesActivityIndicator | TGRequestClassEnableUnauthorized datacenterId:TG_DEFAULT_DATACENTER_ID];
}

- (NSObject *)doRequestRawHttp:(NSString *)url maxRetryCount:(int)maxRetryCount acceptCodes:(NSArray *)acceptCodes actor:(id<TGRawHttpActor>)actor
{
    return [self doRequestRawHttp:url maxRetryCount:maxRetryCount acceptCodes:acceptCodes httpHeaders:nil actor:actor];
}

- (NSObject *)doRequestRawHttp:(NSString *)url maxRetryCount:(int)maxRetryCount acceptCodes:(NSArray *)acceptCodes httpHeaders:(NSDictionary *)httpHeaders actor:(id<TGRawHttpActor>)actor
{
    return [self doRequestRawHttp:url maxRetryCount:maxRetryCount acceptCodes:acceptCodes httpHeaders:httpHeaders expectedFileSize:-1 actor:actor];
}

- (NSObject *)doRequestRawHttp:(NSString *)url maxRetryCount:(int)maxRetryCount acceptCodes:(NSArray *)acceptCodes httpHeaders:(NSDictionary *)httpHeaders expectedFileSize:(NSInteger)expectedFileSize actor:(id<TGRawHttpActor>)actor
{
    TGRawHttpRequest *request = [[TGRawHttpRequest alloc] init];
    request.url = url;
    request.acceptCodes = acceptCodes;
    request.httpHeaders = httpHeaders;
    request.maxRetryCount = maxRetryCount;
    request.expectedFileSize = expectedFileSize;
    request.completionBlock = ^(NSData *response)
    {
        if (response != nil)
        {
            [actor httpRequestSuccess:url response:response];
        }
        else
        {
            [actor httpRequestFailed:url];
        }
    };
    
    if ([actor respondsToSelector:@selector(httpRequestProgress:progress:)])
    {
        request.progressBlock = ^(float progress)
        {
            [actor httpRequestProgress:url progress:progress];
        };
    }
    
    //[self enqueueRawHttpRequest:request];
    
    void (^progressBlock)(float) = nil;
    if ([actor respondsToSelector:@selector(httpRequestProgress:progress:)])
    {
        progressBlock = ^(float progress)
        {
            [actor httpRequestProgress:url progress:progress];
        };
    }
    
    return [self doRequestRawHttp:url maxRetryCount:maxRetryCount acceptCodes:acceptCodes httpHeaders:httpHeaders expectedFileSize:expectedFileSize progressBlock:progressBlock completionBlock:^(NSData *response)
    {
        if (response != nil)
            [actor httpRequestSuccess:url response:response];
        else
            [actor httpRequestFailed:url];
    }];
}

- (NSObject *)doRequestRawHttp:(NSString *)url maxRetryCount:(int)maxRetryCount acceptCodes:(NSArray *)acceptCodes httpHeaders:(NSDictionary *)httpHeaders expectedFileSize:(NSInteger)expectedFileSize progressBlock:(void (^)(float progress))progressBlock completionBlock:(void (^)(NSData *response))completionBlock
{
    TGRawHttpRequest *request = [[TGRawHttpRequest alloc] init];
    request.url = url;
    request.acceptCodes = acceptCodes;
    request.httpHeaders = httpHeaders;
    request.maxRetryCount = maxRetryCount;
    request.expectedFileSize = expectedFileSize;
    request.completionBlock = completionBlock;
    request.progressBlock = progressBlock;
    
    [self enqueueRawHttpRequest:request];
    
    return request;
}

- (NSObject *)doRequestRawHttpFile:(NSString *)url actor:(id<TGRawHttpFileActor>)__unused actor
{
    NSMutableURLRequest *urlRequest = nil;
    urlRequest = [self requestWithMethod:@"GET" path:url parameters:nil];
    AFHTTPRequestOperation *httpOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [httpOperation setSuccessCallbackQueue:[ActionStageInstance() globalStageDispatchQueue]];
    [httpOperation setFailureCallbackQueue:[ActionStageInstance() globalStageDispatchQueue]];
    
    [httpOperation setOutputStream:[NSOutputStream outputStreamToFileAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"test.bin"] append:false]];

    TGLog(@"Request started");
    [httpOperation setCompletionBlockWithSuccess:^(__unused AFHTTPRequestOperation *operation, __unused id responseObject)
    {
        TGLog(@"Request completed");
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error)
    {
        TGLog(@"Request failed: %@", error);
    }];
    
    [self enqueueHTTPRequestOperation:httpOperation];
    
    return nil;
}

- (NSObject *)doUploadFilePart:(int64_t)fileId partId:(int)partId data:(NSData *)data actor:(id<TGFileUploadActor>)actor
{
    TLRPCupload_saveFilePart$upload_saveFilePart *saveFilePart = [[TLRPCupload_saveFilePart$upload_saveFilePart alloc] init];
    saveFilePart.file_id = fileId;
    saveFilePart.file_part = partId;
    saveFilePart.bytes = data;
    
    return [[TGTelegramNetworking instance] performRpc:saveFilePart completionBlock:^(id<TLObject> response, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil && [((NSNumber *)response) boolValue])
        {
            [actor filePartUploadSuccess:partId];
        }
        else
        {
            [actor filePartUploadFailed:partId];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassUploadMedia | TGRequestClassFailOnServerErrors];
}

- (NSObject *)doUploadBigFilePart:(int64_t)fileId partId:(int)partId data:(NSData *)data totalParts:(int)totalParts actor:(id<TGFileUploadActor>)actor
{
    TLRPCupload_saveBigFilePart$upload_saveBigFilePart *saveBigFilePart = [[TLRPCupload_saveBigFilePart$upload_saveBigFilePart alloc] init];
    saveBigFilePart.file_id = fileId;
    saveBigFilePart.file_part = partId;
    saveBigFilePart.file_total_parts = totalParts;
    saveBigFilePart.bytes = data;
    
    return [[TGTelegramNetworking instance] performRpc:saveBigFilePart completionBlock:^(id<TLObject> response, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil && [((NSNumber *)response) boolValue])
        {
            [actor filePartUploadSuccess:partId];
        }
        else
        {
            [actor filePartUploadFailed:partId];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassUploadMedia | TGRequestClassFailOnServerErrors];
}

- (bool)isMigrateToDatacenterError:(NSString *)text datacenterId:(NSInteger *)datacenterId
{
    NSArray *migratePrefixes = @[
        @"PHONE_MIGRATE_",
        @"NETWORK_MIGRATE_",
        @"USER_MIGRATE_"
    ];
    
    for (NSString *prefix in migratePrefixes)
    {
        NSRange range = [text rangeOfString:prefix];
        if (range.location != NSNotFound)
        {
            NSScanner *scanner = [[NSScanner alloc] initWithString:text];
            [scanner setScanLocation:range.location + range.length];
            
            NSInteger scannedDatacenterId = 0;
            if ([scanner scanInteger:&scannedDatacenterId] && scannedDatacenterId != 0)
            {
                if (datacenterId != NULL)
                {
                    *datacenterId = scannedDatacenterId;
                    
                    return true;
                }
            }
        }
    }
    
    return false;
}

- (NSObject *)doSendConfirmationCode:(NSString *)phoneNumber requestBuilder:(TGSendCodeRequestBuilder *)requestBuilder
{
    TLRPCauth_sendCode *sendCode = [[TLRPCauth_sendCode alloc] init];
    sendCode.flags = 0;
    sendCode.phone_number = phoneNumber;
    sendCode.api_id = [_apiId intValue];
    sendCode.api_hash = _apiHash;
    
    sendCode.lang_code = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    return [[TGTelegramNetworking instance] performRpc:sendCode completionBlock:^(id<TLObject> response, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [requestBuilder sendCodeRequestSuccess:(TLauth_SentCode *)response];
        }
        else
        {
            TGSendCodeError errorCode = TGSendCodeErrorUnknown;
            
            NSString *errorType = error.errorDescription;
            if ([errorType isEqualToString:@"PHONE_NUMBER_INVALID"])
                errorCode = TGSendCodeErrorInvalidPhone;
            else if ([errorType hasPrefix:@"FLOOD_WAIT"])
                errorCode = TGSendCodeErrorFloodWait;
            else if ([errorType isEqualToString:@"PHONE_NUMBER_FLOOD"]) {
                errorCode = TGSendCodeErrorPhoneFlood;
            }
            else
            {
                NSInteger datacenterId = 0;
                if ([self isMigrateToDatacenterError:errorType datacenterId:&datacenterId] && datacenterId != 0)
                {
                    [requestBuilder sendCodeRedirect:datacenterId];
                    return;
                }
            }

            [requestBuilder sendCodeRequestFailed:errorCode];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric | TGRequestClassFailOnServerErrors | TGRequestClassFailOnFloodErrors];
}

- (NSObject *)doSendConfirmationSms:(NSString *)phoneNumber phoneHash:(NSString *)phoneHash requestBuilder:(TGSendCodeRequestBuilder *)requestBuilder
{
    TLRPCauth_resendCode$auth_resendCode *resendCode = [[TLRPCauth_resendCode$auth_resendCode alloc] init];
    resendCode.phone_number = phoneNumber;
    resendCode.phone_code_hash = phoneHash;
    
    return [[TGTelegramNetworking instance] performRpc:resendCode completionBlock:^(id<TLObject> response, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [requestBuilder sendSmsRequestSuccess:response];
        }
        else
        {
            TGSendCodeError errorCode = TGSendCodeErrorUnknown;
            
            NSString *errorType = error.errorDescription;
            if ([errorType isEqualToString:@"PHONE_NUMBER_INVALID"])
                errorCode = TGSendCodeErrorInvalidPhone;
            else if ([errorType hasPrefix:@"FLOOD_WAIT"])
                errorCode = TGSendCodeErrorFloodWait;
            else if ([errorType isEqualToString:@"PHONE_NUMBER_FLOOD"]) {
                errorCode = TGSendCodeErrorPhoneFlood;
            }
            else
            {
                NSInteger datacenterId = 0;
                if ([self isMigrateToDatacenterError:errorType datacenterId:&datacenterId] && datacenterId != 0)
                {
                    [requestBuilder sendCodeRedirect:datacenterId];
                    return;
                }
            }
            
            [requestBuilder sendCodeRequestFailed:errorCode];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric | TGRequestClassFailOnServerErrors | TGRequestClassFailOnFloodErrors];
}

- (NSObject *)doSendPhoneCall:(NSString *)phoneNumber phoneHash:(NSString *)phoneHash requestBuilder:(TGSendCodeRequestBuilder *)requestBuilder
{
    TLRPCauth_resendCode$auth_resendCode *resendCode = [[TLRPCauth_resendCode$auth_resendCode alloc] init];
    resendCode.phone_number = phoneNumber;
    resendCode.phone_code_hash = phoneHash;
    
    return [[TGTelegramNetworking instance] performRpc:resendCode completionBlock:^(__unused id<TLObject> response, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
            [requestBuilder sendCallRequestSuccess];
        else
        {
            NSString *errorType = error.errorDescription;
            
            NSInteger datacenterId = 0;
            if ([self isMigrateToDatacenterError:errorType datacenterId:&datacenterId] && datacenterId != 0)
                [requestBuilder sendCallRedirect:datacenterId];
            else
                [requestBuilder sendCallRequestFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric | TGRequestClassFailOnServerErrors];
}

- (NSObject *)doSignUp:(NSString *)phoneNumber phoneHash:(NSString *)phoneHash phoneCode:(NSString *)phoneCode firstName:(NSString *)firstName lastName:(NSString *)lastName requestBuilder:(TGSignUpRequestBuilder *)requestBuilder
{
    TLRPCauth_signUp$auth_signUp *signUp = [[TLRPCauth_signUp$auth_signUp alloc] init];
    signUp.phone_number = phoneNumber;
    signUp.phone_code_hash = phoneHash;
    signUp.phone_code = phoneCode;
    signUp.first_name = firstName;
    signUp.last_name = lastName;
    
    return [[TGTelegramNetworking instance] performRpc:signUp completionBlock:^(id<TLObject> response, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [requestBuilder signUpSuccess:(TLauth_Authorization *)response];
        }
        else
        {
            NSString *errorType = error.errorDescription;
            
            TGSignUpResult result = TGSignUpResultInternalError;
            
            if ([errorType isEqualToString:@"PHONE_CODE_INVALID"])
                result = TGSignUpResultInvalidToken;
            else if ([errorType isEqualToString:@"PHONE_CODE_EXPIRED"])
                result = TGSignUpResultTokenExpired;
            else if ([errorType hasPrefix:@"FLOOD_WAIT"])
                result = TGSignUpResultFloodWait;
            else if ([errorType hasPrefix:@"FIRSTNAME_INVALID"])
                result = TGSignUpResultInvalidFirstName;
            else if ([errorType hasPrefix:@"LASTNAME_INVALID"])
                result = TGSignUpResultInvalidLastName;
            else
            {
                NSInteger datacenterId = 0;
                if ([self isMigrateToDatacenterError:errorType datacenterId:&datacenterId] && datacenterId != 0)
                {
                    [requestBuilder signUpRedirect:datacenterId];
                    return;
                }
            }
            
            [requestBuilder signUpFailed:result];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric | TGRequestClassFailOnServerErrors];
}

- (NSObject *)doSignIn:(NSString *)phoneNumber phoneHash:(NSString *)phoneHash phoneCode:(NSString *)phoneCode requestBuilder:(TGSignInRequestBuilder *)requestBuilder
{
    TLRPCauth_signIn$auth_signIn *signIn = [[TLRPCauth_signIn$auth_signIn alloc] init];
    signIn.phone_number = phoneNumber;
    signIn.phone_code_hash = phoneHash;
    signIn.phone_code = phoneCode;
    
    return [[TGTelegramNetworking instance] performRpc:signIn completionBlock:^(id<TLObject> response, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [requestBuilder signInSuccess:(TLauth_Authorization *)response];
        }
        else
        {
            NSString *errorType = error.errorDescription;
            if ([errorType isEqualToString:@"PHONE_CODE_INVALID"])
                [requestBuilder signInFailed:TGSignInResultInvalidToken];
            else if ([errorType isEqualToString:@"PHONE_CODE_EXPIRED"])
                [requestBuilder signInFailed:TGSignInResultTokenExpired];
            else if ([errorType hasPrefix:@"PHONE_NUMBER_UNOCCUPIED"])
                [requestBuilder signInFailed:TGSignInResultNotRegistered];
            else if ([errorType hasPrefix:@"FLOOD_WAIT"])
                [requestBuilder signInFailed:TGSignInResultFloodWait];
            else if ([errorType hasPrefix:@"SESSION_PASSWORD_NEEDED"])
                [requestBuilder signInFailed:TGSignInResultPasswordRequired];
            else
            {
                NSInteger datacenterId = 0;
                if ([self isMigrateToDatacenterError:errorType datacenterId:&datacenterId] && datacenterId != 0)
                    [requestBuilder signInRedirect:datacenterId];
                else
                    [requestBuilder signInFailed:TGSignInResultInvalidToken];
            }
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric | TGRequestClassFailOnServerErrors | TGRequestClassFailOnFloodErrors | TGRequestClassPassthroughPasswordNeeded];
}

- (NSObject *)doRequestLogout:(TGLogoutRequestBuilder *)actor
{
    TLRPCauth_logOut$auth_logOut *logout = [[TLRPCauth_logOut$auth_logOut alloc] init];
    
    return [[TGTelegramNetworking instance] performRpc:logout completionBlock:^(__unused id<TLObject> response, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor logoutSuccess];
        }
        else
        {
            [actor logoutFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric];
}

- (NSObject *)doSendInvites:(NSArray *)phones text:(NSString *)text actor:(TGSendInvitesActor *)actor
{
    TLRPCauth_sendInvites$auth_sendInvites *sendInvites = [[TLRPCauth_sendInvites$auth_sendInvites alloc] init];
    sendInvites.phone_numbers = phones;
    sendInvites.message = text;
    
    return [[TGTelegramNetworking instance] performRpc:sendInvites completionBlock:^(__unused id<TLObject> response, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor sendInvitesSuccess];
        }
        else
        {
            [actor sendInvitesFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric | TGRequestClassHidesActivityIndicator];
}

- (NSString *)currentDeviceModel
{
    return [[UIDevice currentDevice] platformString];
}

- (id)doCheckUpdates:(TGCheckUpdatesActor *)actor
{
    TLRPChelp_getAppUpdate$help_getAppUpdate *getAppUpdate = [[TLRPChelp_getAppUpdate$help_getAppUpdate alloc] init];
    
    getAppUpdate.device_model = [self currentDeviceModel];
    getAppUpdate.system_version = [[UIDevice currentDevice] systemVersion];
    NSString *versionString = [[NSString alloc] initWithFormat:@"%@ (%@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    getAppUpdate.app_version = versionString;
    getAppUpdate.lang_code = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    return [[TGTelegramNetworking instance] performRpc:getAppUpdate completionBlock:^(id<TLObject> response, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor checkUpdatesSuccess:response];
        }
        else
        {
            [actor checkUpdatesFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric | TGRequestClassHidesActivityIndicator];
}

- (NSObject *)doSetPresence:(bool)online actor:(TGUpdatePresenceActor *)actor
{
    if (TGTelegraphInstance.clientUserId == 0)
        return nil;
    
    TGLog(@"===== Setting presence: %s", online ? "online" : "offline");
    TLRPCaccount_updateStatus$account_updateStatus *updateStatus = [[TLRPCaccount_updateStatus$account_updateStatus alloc] init];
    updateStatus.offline = !online;
    
    if (online)
    {
        int currentUnixTime = (int)[[TGTelegramNetworking instance] globalTime];
        
        TGUserPresence presence;
        presence.online = true;
        presence.lastSeen = currentUnixTime + 5 * 60;
        presence.temporaryLastSeen = 0;
        [TGTelegraphInstance dispatchUserPresenceChanges:TGTelegraphInstance.clientUserId presence:presence];
    }
    
    return [[TGTelegramNetworking instance] performRpc:updateStatus completionBlock:^(__unused id<TLObject> response, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor updatePresenceSuccess];
        }
        else
        {
            [actor updatePresenceFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric | TGRequestClassHidesActivityIndicator];
}

- (NSObject *)doRevokeOtherSessions:(TGRevokeSessionsActor *)actor
{
    TLRPCauth_resetAuthorizations$auth_resetAuthorizations *resetAuthorizations = [[TLRPCauth_resetAuthorizations$auth_resetAuthorizations alloc] init];
    
    return [[TGTelegramNetworking instance] performRpc:resetAuthorizations completionBlock:^(__unused id<TLObject> response, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor revokeSessionsSuccess];
        }
        else
        {
            [actor revokeSessionsFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric];
}

- (NSObject *)doUpdatePushSubscription:(bool)subscribe deviceToken:(NSString *)deviceToken requestBuilder:(TGPushActionsRequestBuilder *)requestBuilder
{
    TLMetaRpc *rpcRequest = nil;
    
    if (subscribe)
    {
        TLRPCaccount_registerDevice$account_registerDevice *registerDevice = [[TLRPCaccount_registerDevice$account_registerDevice alloc] init];
        
        registerDevice.token_type = 1;
        registerDevice.token = deviceToken;
        
        registerDevice.device_model = [self currentDeviceModel];
        registerDevice.system_version = [[UIDevice currentDevice] systemVersion];
        NSString *versionString = [[NSString alloc] initWithFormat:@"%@ (%@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
        registerDevice.app_version = versionString;
#ifdef DEBUG
        registerDevice.app_sandbox = true;
#else
        registerDevice.app_sandbox = false;
#endif
        registerDevice.lang_code = [self langCode];
        rpcRequest = registerDevice;
    }
    else
    {
        TLRPCaccount_unregisterDevice$account_unregisterDevice *unregisterDevice = [[TLRPCaccount_unregisterDevice$account_unregisterDevice alloc] init];
        
        unregisterDevice.token_type = 1;
        unregisterDevice.token = deviceToken;
        
        rpcRequest = unregisterDevice;
    }
    
    return [[TGTelegramNetworking instance] performRpc:rpcRequest completionBlock:^(__unused id<TLObject> response, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [requestBuilder pushSubscriptionUpdateSuccess];
        }
        else
        {
            [requestBuilder pushSubscriptionUpdateFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric];
}

- (NSObject *)doRequestUserData:(int)uid requestBuilder:(TGUserDataRequestBuilder *)requestBuilder
{
    TLRPCusers_getUsers$users_getUsers *getUsers = [[TLRPCusers_getUsers$users_getUsers alloc] init];
    getUsers.n_id = [NSArray arrayWithObject:[self createInputUserForUid:uid]];
    
    return [[TGTelegramNetworking instance] performRpc:getUsers completionBlock:^(id<TLObject> response, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [requestBuilder userDataRequestSuccess:(NSArray *)response];
        }
        else
        {
            [requestBuilder userDataRequestFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric];
}

- (NSObject *)doRequestExtendedUserData:(int)uid actor:(TGExtendedUserDataRequestActor *)actor
{
    TLRPCusers_getFullUser$users_getFullUser *getFullUser = [[TLRPCusers_getFullUser$users_getFullUser alloc] init];
    getFullUser.n_id = [self createInputUserForUid:uid];
    
    return [[TGTelegramNetworking instance] performRpc:getFullUser completionBlock:^(TLUserFull *result, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor extendedUserDataRequestSuccess:result];
        }
        else
        {
            [actor extendedUserDataRequestFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric];
}

- (id)doRequestContactStatuses:(TGUpdateUserStatusesActor *)actor
{
    return [[TGTelegramNetworking instance] performRpc:[[TLRPCcontacts_getStatuses$contacts_getStatuses alloc] init] completionBlock:^(id response, int64_t responseTime, TLError *error)
    {
        if (error == nil)
        {
            [actor contactStatusesRequestSuccess:response currentDate:(int)(responseTime / 4294967296L)];
        }
        else
        {
            [actor contactStatusesRequestFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric];
}

- (NSObject *)doRequestState:(TGUpdateStateRequestBuilder *)requestBuilder
{
    TLRPCupdates_getState$updates_getState *getState = [[TLRPCupdates_getState$updates_getState alloc] init];
    
    return [[TGTelegramNetworking instance] performRpc:getState completionBlock:^(id<TLObject> response, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [requestBuilder stateRequestSuccess:(TLupdates_State *)response];
        }
        else
        {
            [requestBuilder stateRequestFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric];
}

- (NSObject *)doRequestStateDelta:(int)pts date:(int)date qts:(int)qts requestBuilder:(TGUpdateStateRequestBuilder *)requestBuilder
{
    TLRPCupdates_getDifference$updates_getDifference *getDifference = [[TLRPCupdates_getDifference$updates_getDifference alloc] init];
    getDifference.pts = pts;
    getDifference.date = date;
    getDifference.qts = qts;
    
    if (pts == 0)
    {
        TGLog(@"Something bad happens...");
    }
    
    return [[TGTelegramNetworking instance] performRpc:getDifference completionBlock:^(id<TLObject> response, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [requestBuilder stateDeltaRequestSuccess:(TLupdates_Difference *)response];
        }
        else
        {
            [requestBuilder stateDeltaRequestFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric];
}

- (NSObject *)doRequestDialogsListWithOffset:(TGDialogListRemoteOffset *)offset limit:(int)limit requestBuilder:(TGDialogListRequestBuilder *)requestBuilder
{
    TLRPCmessages_getDialogs$messages_getDialogs *getDialogs = [[TLRPCmessages_getDialogs$messages_getDialogs alloc] init];
    getDialogs.offset_date = offset.date;
    getDialogs.offset_id = 0;
    getDialogs.offset_id = offset.messageId;
    getDialogs.offset_peer = offset.peerId == 0 ? [[TLInputPeer$inputPeerEmpty alloc] init] : [self createInputPeerForConversation:offset.peerId accessHash:offset.accessHash];
    getDialogs.limit = limit;
    
    return [[TGTelegramNetworking instance] performRpc:getDialogs completionBlock:^(TLmessages_Dialogs *dialogs, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [requestBuilder dialogListRequestSuccess:dialogs];
        }
        else
        {
            [requestBuilder dialogListRequestFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric];
}

- (NSObject *)doExportContacts:(NSArray *)contacts requestBuilder:(TGSynchronizeContactsActor *)requestActor
{
    NSMutableString *debugContactsString = [[NSMutableString alloc] init];
    
    NSMutableArray *contactsArray = [[NSMutableArray alloc] initWithCapacity:contacts.count];
    
    int index = -1;
    for (TGContactBinding *binding in contacts)
    {
        index++;
        
        TLInputContact$inputPhoneContact *inputContact = [[TLInputContact$inputPhoneContact alloc] init];
        inputContact.client_id = index;
        inputContact.phone = binding.phoneNumber;
        inputContact.first_name = binding.firstName;
        inputContact.last_name = binding.lastName;
        [contactsArray addObject:inputContact];
        
        [debugContactsString appendFormat:@"%@\t%@\t%@\n", binding.phoneNumber, binding.firstName, binding.lastName];
    }
    TGLog(@"Exporting %d contacts: %@", contacts.count, debugContactsString);
    
    TLRPCcontacts_importContacts$contacts_importContacts *importContacts = [[TLRPCcontacts_importContacts$contacts_importContacts alloc] init];
    
    importContacts.contacts = contactsArray;
    
    return [[TGTelegramNetworking instance] performRpc:importContacts completionBlock:^(TLcontacts_ImportedContacts *importedContacts, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            NSMutableString *debugImportedString = [[NSMutableString alloc] init];
            
            NSMutableArray *importedArray = [[NSMutableArray alloc] initWithCapacity:importedContacts.imported.count];
            for (TLImportedContact *importedContact in importedContacts.imported)
            {
                if (importedContact.client_id >= 0 && importedContact.client_id < (int)contactsArray.count)
                {
                    NSString *clientPhone = ((TLInputContact *)[contactsArray objectAtIndex:(int)importedContact.client_id]).phone;
                    
                    TGImportedPhone *importedPhone = [[TGImportedPhone alloc] init];
                    importedPhone.phone = clientPhone;
                    importedPhone.user_id = importedContact.user_id;
                    
                    [debugImportedString appendFormat:@"%@ -> %d\n", clientPhone, importedContact.user_id];
                    
                    [importedArray addObject:importedPhone];
                }
            }
            
            TGLog(@"Server imported: %@", debugImportedString);
            
            NSMutableArray *popularArray = [[NSMutableArray alloc] initWithCapacity:importedContacts.popular_invites.count];
            for (TLPopularContact *popularContact in importedContacts.popular_invites)
            {
                if (popularContact.client_id >= 0 && popularContact.client_id < (int)contactsArray.count)
                {
                    TGContactBinding *binding = [contacts objectAtIndex:popularContact.client_id];
                    [popularArray addObject:@{@"phoneId": @(binding.phoneId), @"importers": @(popularContact.importers)}];
                }
            }
            
            [requestActor exportContactsSuccess:importedArray popularContacts:popularArray users:importedContacts.users];
        }
        else
        {
            [requestActor exportContactsFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric];
}

- (NSObject *)doRequestContactList:(NSString *)hash actor:(TGSynchronizeContactsActor *)actor
{
    TLRPCcontacts_getContacts$contacts_getContacts *getContacts = [[TLRPCcontacts_getContacts$contacts_getContacts alloc] init];
    getContacts.n_hash = hash;
    
    return [[TGTelegramNetworking instance] performRpc:getContacts completionBlock:^(TLcontacts_Contacts *contacts, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor contactListRequestSuccess:contacts];
        }
        else
        {
            [actor contactListRequestFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric];
}

- (NSObject *)doRequestContactIdList:(TGSynchronizeContactsActor *)actor
{
    TLRPCcontacts_getContactIDs$contacts_getContactIDs *getContactIds = [[TLRPCcontacts_getContactIDs$contacts_getContactIDs alloc] init];
    
    return [[TGTelegramNetworking instance] performRpc:getContactIds completionBlock:^(id<TLObject> result, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor contactIdsRequestSuccess:(NSArray *)result];
        }
        else
        {
            [actor contactIdsRequestFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric];
}

- (NSObject *)doRequestSuggestedContacts:(int)limit actor:(TGSuggestedContactsRequestActor *)actor
{
    TLRPCcontacts_getSuggested$contacts_getSuggested *getSuggested = [[TLRPCcontacts_getSuggested$contacts_getSuggested alloc] init];
    getSuggested.limit = limit;
    
    return [[TGTelegramNetworking instance] performRpc:getSuggested completionBlock:^(TLcontacts_Suggested *result, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor suggestedContactsRequestSuccess:result];
        }
        else
        {
            [actor suggestedContactsRequestFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric];
}

- (NSObject *)doLocateContacts:(double)latitude longitude:(double)longitude radius:(int)radius discloseLocation:(bool)discloseLocation actor:(id<TGLocateContactsProtocol>)actor
{
    TLRPCcontacts_getLocated$contacts_getLocated *getLocated = [[TLRPCcontacts_getLocated$contacts_getLocated alloc] init];
    TLInputGeoPoint$inputGeoPoint *geoPoint = [[TLInputGeoPoint$inputGeoPoint alloc] init];
    geoPoint.lat = latitude;
    geoPoint.n_long = longitude;
    getLocated.geo_point = geoPoint;
    getLocated.radius = radius;
    getLocated.limit = 100;
    getLocated.hidden = !discloseLocation;
    
    return [[TGTelegramNetworking instance] performRpc:getLocated completionBlock:^(TLcontacts_Located *result, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor locateSuccess:result];
        }
        else
        {
            [actor locateFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric];
}

- (NSObject *)doSearchContacts:(NSString *)query limit:(int)limit actor:(TGContactsGlobalSearchActor *)actor
{
    TLRPCcontacts_search$contacts_search *search = [[TLRPCcontacts_search$contacts_search alloc] init];
    search.q = query;
    search.limit = limit;
    
    return [[TGTelegramNetworking instance] performRpc:search completionBlock:^(TLcontacts_Found *result, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor searchSuccess:result];
        }
        else
        {
            [actor searchFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric];
}

- (NSObject *)doSearchContactsByName:(NSString *)query limit:(int)limit completion:(void (^)(TLcontacts_Found *))completion
{
    TLRPCcontacts_search$contacts_search *search = [[TLRPCcontacts_search$contacts_search alloc] init];
    search.q = query;
    search.limit = limit;
    
    return [[TGTelegramNetworking instance] performRpc:search completionBlock:^(TLcontacts_Found *result, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            completion(result);
        }
        else
        {
            completion(nil);
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric];
}

- (NSObject *)doDeleteContacts:(NSArray *)uids actor:(id<TGContactDeleteActorProtocol>)actor
{
    TLRPCcontacts_deleteContacts$contacts_deleteContacts *deleteContacts = [[TLRPCcontacts_deleteContacts$contacts_deleteContacts alloc] init];
    NSMutableArray *inputUsers = [[NSMutableArray alloc] init];
    
    for (NSNumber *nUid in uids)
    {
        TLInputUser *inputUser = [self createInputUserForUid:[nUid intValue]];
        if (inputUser != nil)
            [inputUsers addObject:inputUser];
    }
    
    deleteContacts.n_id = inputUsers;
    
    id concreteRpc = deleteContacts;
    
/*#if defined(DEBUG)
    TLRPCcontacts_clearContact$contacts_clearContact *clearContact = [[TLRPCcontacts_clearContact$contacts_clearContact alloc] init];
    clearContact.n_id = [inputUsers objectAtIndex:0];
    concreteRpc = clearContact;
#endif*/

    return [[TGTelegramNetworking instance] performRpc:concreteRpc completionBlock:^(__unused id<TLObject> result, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor deleteContactsSuccess:uids];
        }
        else
        {
            [actor deleteContactsFailed:uids];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric];
}

- (TLInputPeer *)createInputPeerForConversation:(int64_t)conversationId accessHash:(int64_t)accessHash
{
    if (conversationId == 0)
    {
        return [[TLInputPeer$inputPeerEmpty alloc] init];
    }
    else if (TGPeerIdIsChannel(conversationId))
    {
        TLInputPeer$inputPeerChannel *channelPeer = [[TLInputPeer$inputPeerChannel alloc] init];
        channelPeer.channel_id = TGChannelIdFromPeerId(conversationId);
        channelPeer.access_hash = accessHash;
        return channelPeer;
    }
    else if (conversationId < 0)
    {
        TLInputPeer$inputPeerChat *chatPeer = [[TLInputPeer$inputPeerChat alloc] init];
        chatPeer.chat_id = -(int)conversationId;
        return chatPeer;
    }
    else if (conversationId == _clientUserId)
    {
        TLInputPeer$inputPeerSelf *selfPeer = [[TLInputPeer$inputPeerSelf alloc] init];
        return selfPeer;
    }
    else
    {
        if (accessHash != 0) {
            TLInputPeer$inputPeerUser *foreignPeer = [[TLInputPeer$inputPeerUser alloc] init];
            foreignPeer.user_id = (int)conversationId;
            foreignPeer.access_hash = accessHash;
            return foreignPeer;
        } else {
            TGUser *user = [TGDatabaseInstance() loadUser:(int)conversationId];
            if (user != nil)
            {
                TLInputPeer$inputPeerUser *foreignPeer = [[TLInputPeer$inputPeerUser alloc] init];
                foreignPeer.user_id = (int)conversationId;
                foreignPeer.access_hash = user.phoneNumberHash;
                return foreignPeer;
            }
        }

        return [[TLInputPeer$inputPeerEmpty alloc] init];
    }
}

- (TLInputUser *)createInputUserForUid:(int)uid
{
    if (uid == _clientUserId)
    {
        TLInputUser$inputUserSelf *selfUser = [[TLInputUser$inputUserSelf alloc] init];
        return selfUser;
    }
    else
    {
        TGUser *user = [TGDatabaseInstance() loadUser:uid];
        if (user != nil)
        {
            TLInputUser$inputUser *foreignUser = [[TLInputUser$inputUser alloc] init];
            foreignUser.user_id = uid;
            foreignUser.access_hash = user.phoneNumberHash;
            return foreignUser;
        }
        
        return nil;
    }
}

- (NSObject *)doRequestConversationHistory:(int64_t)conversationId accessHash:(int64_t)accessHash maxMid:(int)maxMid orOffset:(int)offset limit:(int)limit actor:(TGConversationHistoryAsyncRequestActor *)actor
{
    TLRPCmessages_getHistory$messages_getHistory *getHistory = [[TLRPCmessages_getHistory$messages_getHistory alloc] init];
    getHistory.peer = [self createInputPeerForConversation:conversationId accessHash:accessHash];
    if (maxMid >= 0)
        getHistory.offset_id = maxMid;
    getHistory.add_offset = offset;
    getHistory.limit = limit;
    
    return [[TGTelegramNetworking instance] performRpc:getHistory completionBlock:^(TLmessages_Messages *messages, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor conversationHistoryRequestSuccess:messages];
        }
        else
        {
            [actor conversationHistoryRequestFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric];
}

- (NSObject *)doRequestConversationMediaHistory:(int64_t)conversationId accessHash:(int64_t)accessHash maxMid:(int)maxMid maxDate:(int)maxDate limit:(int)limit actor:(TGUpdateMediaHistoryActor *)actor
{
    TLRPCmessages_search$messages_search *search = [[TLRPCmessages_search$messages_search alloc] init];
    search.peer = [self createInputPeerForConversation:conversationId accessHash:accessHash];
    search.q = @"";
    search.min_date = 0;
    search.max_date = maxDate;
    search.offset = 0;
    search.max_id = maxMid;
    search.limit = limit;
    search.filter = [[TLMessagesFilter$inputMessagesFilterPhotoVideo alloc] init];
    
    return [[TGTelegramNetworking instance] performRpc:search completionBlock:^(TLmessages_Messages *messages, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor mediaHistoryRequestSuccess:messages];
        }
        else
        {
            [actor mediaHistoryRequestFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric];
}

- (NSObject *)doConversationSendMessage:(int64_t)conversationId accessHash:(int64_t)accessHash messageText:(NSString *)messageText messageGuid:(NSString *)__unused messageGuid tmpId:(int64_t)tmpId replyMessageId:(int32_t)replyMessageId disableLinkPreviews:(bool)disableLinkPreviews postAsChannel:(bool)postAsChannel notifyMembers:(bool)notifyMembers entities:(NSArray *)entities actor:(TGModernSendCommonMessageActor *)actor
{
    TLRPCmessages_sendMessage_manual *sendMessage = [[TLRPCmessages_sendMessage_manual alloc] init];
    sendMessage.flags |= replyMessageId != 0 ? (1 << 0) : 0;
    if (disableLinkPreviews)
        sendMessage.flags |= (1 << 1);
    if (TGPeerIdIsChannel(conversationId)) {
        if (postAsChannel) {
            sendMessage.flags |= 16;
        }
        
        if (!notifyMembers) {
            sendMessage.flags |= (1 << 5);
        }
    }
    if (entities.count != 0) {
        sendMessage.flags |= (1 << 3);
        sendMessage.entities = entities;
    }
    sendMessage.peer = [self createInputPeerForConversation:conversationId accessHash:accessHash];
    sendMessage.message = messageText;
    sendMessage.random_id = tmpId;
    sendMessage.reply_to_msg_id = replyMessageId;
    
    return [[TGTelegramNetworking instance] performRpc:sendMessage completionBlock:^(id result, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor conversationSendMessageRequestSuccess:result];
        }
        else
        {
            [actor conversationSendMessageRequestFailed:[[TGTelegramNetworking instance] extractNetworkErrorType:error]];
        }
    } progressBlock:nil quickAckBlock:^
    {
        [actor conversationSendMessageQuickAck];
    } requiresCompletion:true requestClass:TGRequestClassGeneric | TGRequestClassFailOnServerErrors datacenterId:TG_DEFAULT_DATACENTER_ID];
}

- (NSObject *)doConversationSendLocation:(int64_t)conversationId accessHash:(int64_t)accessHash latitude:(double)latitude longitude:(double)longitude venue:(TGVenueAttachment *)venue messageGuid:(NSString *)messageGuid tmpId:(int64_t)tmpId replyMessageId:(int32_t)replyMessageId postAsChannel:(bool)postAsChannel notifyMembers:(bool)notifyMembers actor:(TGModernSendCommonMessageActor *)actor
{
    TLInputMedia *media = nil;
    
    TLInputGeoPoint$inputGeoPoint *geoPoint = [[TLInputGeoPoint$inputGeoPoint alloc] init];
    geoPoint.lat = latitude;
    geoPoint.n_long = longitude;
    
    if (venue != nil)
    {
        TLInputMedia$inputMediaVenue *venueMedia = [[TLInputMedia$inputMediaVenue alloc] init];
        venueMedia.geo_point = geoPoint;
        venueMedia.title = venue.title;
        venueMedia.address = venue.address;
        venueMedia.provider = venue.provider;
        venueMedia.venue_id = venue.venueId;
        media = venueMedia;
    }
    else
    {
        TLInputMedia$inputMediaGeoPoint *geoMedia = [[TLInputMedia$inputMediaGeoPoint alloc] init];
        geoMedia.geo_point = geoPoint;
        media = geoMedia;
    }
    
    if (media != nil)
    {
        return [self doConversationSendMedia:conversationId accessHash:accessHash media:media messageGuid:messageGuid tmpId:tmpId replyMessageId:replyMessageId postAsChannel:postAsChannel notifyMembers:notifyMembers actor:actor];
    }
    
    return nil;
}

- (NSObject *)doConversationBotContextResult:(int64_t)conversationId accessHash:(int64_t)accessHash botContextResult:(TGBotContextResultAttachment *)botContextResult tmpId:(int64_t)tmpId replyMessageId:(int32_t)replyMessageId postAsChannel:(bool)postAsChannel notifyMembers:(bool)notifyMembers actor:(TGModernSendCommonMessageActor *)actor {
    TLRPCmessages_sendInlineBotResult *sendContextBotResult = [[TLRPCmessages_sendInlineBotResult alloc] init];
    sendContextBotResult.peer = [self createInputPeerForConversation:conversationId accessHash:accessHash];
    
    if (replyMessageId != 0) {
        sendContextBotResult.flags |= (1 << 0);
    }
    
    if (TGPeerIdIsChannel(conversationId)) {
        if (postAsChannel) {
            sendContextBotResult.flags |= (1 << 4);
        }
        
        if (!notifyMembers) {
            sendContextBotResult.flags |= (1 << 5);
        }
    }
    
    sendContextBotResult.random_id = tmpId;
    sendContextBotResult.reply_to_msg_id = replyMessageId;
    
    sendContextBotResult.n_id = botContextResult.resultId;
    sendContextBotResult.query_id = botContextResult.queryId;
    
    return [[TGTelegramNetworking instance] performRpc:sendContextBotResult completionBlock:^(id message, __unused int64_t responseTime, TLError *error)
    {
        if (error == nil)
        {
            [actor conversationSendMessageRequestSuccess:message];
        }
        else
        {
            [actor conversationSendMessageRequestFailed:[[TGTelegramNetworking instance] extractNetworkErrorType:error]];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric | TGRequestClassFailOnServerErrors];
}

- (NSObject *)doConversationSendMedia:(int64_t)conversationId accessHash:(int64_t)accessHash media:(TLInputMedia *)media messageGuid:(NSString *)__unused messageGuid tmpId:(int64_t)tmpId replyMessageId:(int32_t)replyMessageId postAsChannel:(bool)postAsChannel notifyMembers:(bool)notifyMembers actor:(TGModernSendCommonMessageActor *)actor
{
    TLRPCmessages_sendMedia_manual *sendMedia = [[TLRPCmessages_sendMedia_manual alloc] init];
    sendMedia.flags |= replyMessageId != 0 ? (1 << 0) : 0;
    if (TGPeerIdIsChannel(conversationId)) {
        if (postAsChannel) {
            sendMedia.flags |= 16;
        }
        
        if (!notifyMembers) {
            sendMedia.flags |= (1 << 5);
        }
    }
    sendMedia.peer = [self createInputPeerForConversation:conversationId accessHash:accessHash];
    sendMedia.media = media;
    sendMedia.random_id = tmpId;
    sendMedia.reply_to_msg_id = replyMessageId;
    TGLog(@"sendMedia with random_id: %lld", tmpId);
    
    return [[TGTelegramNetworking instance] performRpc:sendMedia completionBlock:^(id message, __unused int64_t responseTime, TLError *error)
    {
        if (error == nil)
        {
            [actor conversationSendMessageRequestSuccess:message];
        }
        else
        {
            [actor conversationSendMessageRequestFailed:[[TGTelegramNetworking instance] extractNetworkErrorType:error]];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric | TGRequestClassFailOnServerErrors];
}

- (NSArray *)broadcastPeerIdsFromUserIds:(NSArray *)userIds
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (NSNumber *nUid in userIds)
    {
        id peer = [self createInputUserForUid:[nUid intValue]];
        if (peer != nil)
            [array addObject:peer];
    }
    
    return array;
}

- (NSObject *)doConversationForwardMessage:(int64_t)conversationId accessHash:(int64_t)accessHash messageId:(int)messageId fromPeer:(int64_t)fromPeer fromPeerAccessHash:(int64_t)fromPeerAccessHash postAsChannel:(bool)postAsChannel notifyMembers:(bool)notifyMembers tmpId:(int64_t)tmpId actor:(TGModernSendCommonMessageActor *)actor
{
    TLRPCmessages_forwardMessages$messages_forwardMessages *forwardMessages = [[TLRPCmessages_forwardMessages$messages_forwardMessages alloc] init];
    forwardMessages.to_peer = [self createInputPeerForConversation:conversationId accessHash:accessHash];
    forwardMessages.from_peer = [self createInputPeerForConversation:fromPeer accessHash:fromPeerAccessHash];
    forwardMessages.n_id = @[@(messageId)];
    forwardMessages.random_id = @[@(tmpId)];
    if (TGPeerIdIsChannel(conversationId)) {
        if (postAsChannel) {
            forwardMessages.flags |= 16;
        }
        if (!notifyMembers) {
            forwardMessages.flags |= (1 << 5);
        }
    }
    
    return [[TGTelegramNetworking instance] performRpc:forwardMessages completionBlock:^(TLUpdates *updates, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor conversationSendMessageRequestSuccess:updates];
        }
        else
        {
            [actor conversationSendMessageRequestFailed:[[TGTelegramNetworking instance] extractNetworkErrorType:error]];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric | TGRequestClassFailOnServerErrors];
}

- (NSObject *)doConversationReadHistory:(int64_t)conversationId accessHash:(int64_t)accessHash maxMid:(int)maxMid offset:(int)offset actor:(TGSynchronizeActionQueueActor *)actor
{
    TLRPCmessages_readHistory$messages_readHistory *readHistory = [[TLRPCmessages_readHistory$messages_readHistory alloc] init];
    readHistory.peer = [self createInputPeerForConversation:conversationId accessHash:accessHash];
    readHistory.max_id = maxMid;
    readHistory.offset = offset;
    
    return [[TGTelegramNetworking instance] performRpc:readHistory completionBlock:^(TLmessages_AffectedMessages *result, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor readMessagesSuccess:result];
        }
        else
        {
            [actor readMessagesFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric | TGRequestClassHidesActivityIndicator];
}

- (NSObject *)doReportDelivery:(int)maxMid actor:(TGReportDeliveryActor *)actor
{
    TLRPCmessages_receivedMessages$messages_receivedMessages *receivedMessages = [[TLRPCmessages_receivedMessages$messages_receivedMessages alloc] init];
    receivedMessages.max_id = maxMid;
    
    return [[TGTelegramNetworking instance] performRpc:receivedMessages completionBlock:^(id<TLObject> response, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor reportDeliverySuccess:maxMid deliveredMessages:(NSArray *)response];
        }
        else
        {
            [actor reportDeliveryFailed:maxMid];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric | TGRequestClassHidesActivityIndicator];
}

- (NSObject *)doReportConversationActivity:(int64_t)conversationId accessHash:(int64_t)accessHash activity:(id)activity actor:(TGConversationActivityRequestBuilder *)actor
{
    TLRPCmessages_setTyping$messages_setTyping *setTyping = [[TLRPCmessages_setTyping$messages_setTyping alloc] init];
    setTyping.peer = [self createInputPeerForConversation:conversationId accessHash:accessHash];
    setTyping.action = activity;
    
    return [[TGTelegramNetworking instance] performRpc:setTyping completionBlock:^(__unused id<TLObject> result, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor reportTypingActivitySuccess];
        }
        else
        {
            [actor reportTypingActivityFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric | TGRequestClassHidesActivityIndicator | TGRequestClassFailOnServerErrors];
}

- (NSObject *)doChangeConversationTitle:(int64_t)conversationId accessHash:(int64_t)accessHash title:(NSString *)title actor:(TGConversationChangeTitleRequestActor *)requestActor
{
    if (TGPeerIdIsChannel(conversationId)) {
        TLRPCchannels_editTitle$channels_editTitle *editTitle = [[TLRPCchannels_editTitle$channels_editTitle alloc] init];
        TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
        inputChannel.channel_id = TGChannelIdFromPeerId(conversationId);
        inputChannel.access_hash = accessHash;
        editTitle.channel = inputChannel;
        editTitle.title = title;
        
        return [[TGTelegramNetworking instance] performRpc:editTitle completionBlock:^(TLUpdates *updates, __unused int64_t responseTime, MTRpcError *error)
        {
            if (error == nil)
            {
                [requestActor conversationTitleChangeSuccess:updates];
            }
            else
            {
                [requestActor conversationTitleChangeFailed];
            }
        } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric];
    } else {
        TLRPCmessages_editChatTitle$messages_editChatTitle *editChatTitle = [[TLRPCmessages_editChatTitle$messages_editChatTitle alloc] init];
        editChatTitle.chat_id = TGGroupIdFromPeerId(conversationId);
        editChatTitle.title = title;
        
        return [[TGTelegramNetworking instance] performRpc:editChatTitle completionBlock:^(TLUpdates *updates, __unused int64_t responseTime, MTRpcError *error)
        {
            if (error == nil)
            {
                [requestActor conversationTitleChangeSuccess:updates];
            }
            else
            {
                [requestActor conversationTitleChangeFailed];
            }
        } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric];
    }
}

- (NSObject *)doChangeConversationPhoto:(int64_t)conversationId accessHash:(int64_t)accessHash photo:(TLInputChatPhoto *)photo actor:(TGConversationChangePhotoActor *)actor
{
    if (TGPeerIdIsChannel(conversationId)) {
        TLRPCchannels_editPhoto$channels_editPhoto *editPhoto = [[TLRPCchannels_editPhoto$channels_editPhoto alloc] init];
        TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
        inputChannel.channel_id = TGChannelIdFromPeerId(conversationId);
        inputChannel.access_hash = accessHash;
        editPhoto.channel = inputChannel;
        editPhoto.photo = photo;
        
        return [[TGTelegramNetworking instance] performRpc:editPhoto completionBlock:^(TLUpdates *updates, __unused int64_t responseTime, MTRpcError *error)
        {
            if (error == nil)
            {
                [actor conversationUpdateAvatarSuccess:updates];
            }
            else
            {
                [actor conversationUpdateAvatarFailed];
            }
        } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric | TGRequestClassFailOnServerErrors];
    } else {
        TLRPCmessages_editChatPhoto$messages_editChatPhoto *editChatPhoto = [[TLRPCmessages_editChatPhoto$messages_editChatPhoto alloc] init];
        editChatPhoto.chat_id = TGGroupIdFromPeerId(conversationId);
        editChatPhoto.photo = photo;
        
        return [[TGTelegramNetworking instance] performRpc:editChatPhoto completionBlock:^(TLUpdates *updates, __unused int64_t responseTime, MTRpcError *error)
        {
            if (error == nil)
            {
                [actor conversationUpdateAvatarSuccess:updates];
            }
            else
            {
                [actor conversationUpdateAvatarFailed];
            }
        } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric | TGRequestClassFailOnServerErrors];
    }
}

- (NSObject *)doCreateChat:(NSArray *)uidList title:(NSString *)title actor:(TGConversationCreateChatRequestActor *)actor
{
    TLRPCmessages_createChat$messages_createChat *createChat = [[TLRPCmessages_createChat$messages_createChat alloc] init];
    createChat.title = title;
    
    NSMutableArray *inputUsers = [[NSMutableArray alloc] init];
    for (NSNumber *nUid in uidList)
    {
        int uid = [nUid intValue];
        [inputUsers addObject:[self createInputUserForUid:uid]];
    }
    createChat.users = inputUsers;
    
    return [[TGTelegramNetworking instance] performRpc:createChat completionBlock:^(TLUpdates *updates, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor createChatSuccess:updates];
        }
        else
        {
            [actor createChatFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric | TGRequestClassFailOnServerErrors];
}

- (NSObject *)doAddConversationMember:(int64_t)conversationId uid:(int)uid actor:(TGConversationAddMemberRequestActor *)actor
{
    TLRPCmessages_addChatUser$messages_addChatUser *addChatUser = [[TLRPCmessages_addChatUser$messages_addChatUser alloc] init];
    addChatUser.chat_id = TGGroupIdFromPeerId(conversationId);
    
    addChatUser.user_id = [self createInputUserForUid:uid];
    addChatUser.fwd_limit = 100;
    
    return [[TGTelegramNetworking instance] performRpc:addChatUser completionBlock:^(TLUpdates *updates, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor addMemberSuccess:updates];
        }
        else
        {
            int reason = -1;
            if ([error.errorDescription rangeOfString:@"USER_LEFT_CHAT"].location != NSNotFound)
                reason = -2;
            else if ([error.errorDescription rangeOfString:@"USERS_TOO_MUCH"].location != NSNotFound)
                reason = -3;
            else if ([error.errorDescription rangeOfString:@"USER_NOT_MUTUAL_CONTACT"].location != NSNotFound)
                reason = -4;
            else if ([error.errorDescription rangeOfString:@"USER_PRIVACY_RESTRICTED"].location != NSNotFound) {
                reason = -5;
            }
            [actor addMemberFailed:reason];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric];
}

- (NSObject *)doDeleteConversationMember:(int64_t)conversationId uid:(int)uid actor:(id<TGDeleteChatMemberProtocol>)actor
{
    TLRPCmessages_deleteChatUser$messages_deleteChatUser *deleteChatUser = [[TLRPCmessages_deleteChatUser$messages_deleteChatUser alloc] init];
    deleteChatUser.chat_id = TGGroupIdFromPeerId(conversationId);
    
    deleteChatUser.user_id = [self createInputUserForUid:uid];
    
    return [[TGTelegramNetworking instance] performRpc:deleteChatUser completionBlock:^(TLUpdates *updates, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor deleteMemberSuccess:updates];
        }
        else
        {
            [actor deleteMemberFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric];
}

- (NSObject *)doDeleteMessages:(NSArray *)messageIds actor:(TGSynchronizeActionQueueActor *)actor
{
    TLRPCmessages_deleteMessages$messages_deleteMessages *deleteMessages = [[TLRPCmessages_deleteMessages$messages_deleteMessages alloc] init];
    deleteMessages.n_id = messageIds;
    
    return [[TGTelegramNetworking instance] performRpc:deleteMessages completionBlock:^(TLmessages_AffectedMessages *result, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor deleteMessagesSuccess:result];
        }
        else
        {
            [actor deleteMessagesFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric | TGRequestClassFailOnServerErrors];
}

- (NSObject *)doDeleteConversation:(int64_t)conversationId onlyClear:(bool)onlyClear maxId:(int32_t)maxId accessHash:(int64_t)accessHash offset:(int)__unused offset actor:(TGSynchronizeActionQueueActor *)actor
{
    TLRPCmessages_deleteHistory$messages_deleteHistory *deleteHistory = [[TLRPCmessages_deleteHistory$messages_deleteHistory alloc] init];
    deleteHistory.peer = [self createInputPeerForConversation:conversationId accessHash:accessHash];
    if (onlyClear) {
        deleteHistory.flags = (1 << 0);
    }
    deleteHistory.max_id = maxId;
    
    return [[TGTelegramNetworking instance] performRpc:deleteHistory completionBlock:^(TLmessages_AffectedHistory *result, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor deleteHistorySuccess:result];
        }
        else
        {
            [actor deleteHistoryFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric | TGRequestClassFailOnServerErrors];
}

- (NSObject *)doRequestTimeline:(int)timelineId maxItemId:(int64_t)maxItemId limit:(int)limit actor:(TGTimelineHistoryRequestBuilder *)actor
{
    TLRPCphotos_getWall$photos_getWall *getWall = [[TLRPCphotos_getWall$photos_getWall alloc] init];

    getWall.user_id = [self createInputUserForUid:timelineId];
    
    getWall.limit = limit;
    getWall.max_id = (int32_t)maxItemId;
    
    return [[TGTelegramNetworking instance] performRpc:getWall completionBlock:^(TLphotos_Photos *photos, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor timelineHistoryRequestSuccess:photos];
        }
        else
        {
            [actor timelineHistoryRequestFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric];
}

- (NSObject *)doUploadTimelinePhoto:(id)inputFile hasLocation:(bool)hasLocation latitude:(double)latitude longitude:(double)longitude actor:(TGTimelineUploadPhotoRequestBuilder *)actor
{
    TLRPCphotos_uploadProfilePhoto$photos_uploadProfilePhoto *uploadProfilePhoto = [[TLRPCphotos_uploadProfilePhoto$photos_uploadProfilePhoto alloc] init];
    
    if (hasLocation)
    {
        TLInputGeoPoint$inputGeoPoint *geoPoint = [[TLInputGeoPoint$inputGeoPoint alloc] init];
        geoPoint.lat = latitude;
        geoPoint.n_long = longitude;
        uploadProfilePhoto.geo_point = geoPoint;
    }
    else
    {
        TLInputGeoPoint$inputGeoPointEmpty *geoPoint = [[TLInputGeoPoint$inputGeoPointEmpty alloc] init];
        uploadProfilePhoto.geo_point = geoPoint;
    }
    
    uploadProfilePhoto.file = inputFile;
    uploadProfilePhoto.caption = @"";
    uploadProfilePhoto.crop = [[TLInputPhotoCrop$inputPhotoCropAuto alloc] init];
    
    return [[TGTelegramNetworking instance] performRpc:uploadProfilePhoto completionBlock:^(TLphotos_Photo *result, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor timelineUploadPhotoSuccess:result];
        }
        else
        {
            [actor timelineUploadPhotoFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric | TGRequestClassFailOnServerErrors];
}

- (NSObject *)doDeleteProfilePhotos:(NSArray *)items actor:(TGSynchronizeServiceActionsActor *)actor
{
    TLRPCphotos_deletePhotos$photos_deletePhotos *deletePhotos = [[TLRPCphotos_deletePhotos$photos_deletePhotos alloc] init];
    
    NSMutableArray *idsArray = [[NSMutableArray alloc] init];
    for (NSDictionary *itemDesc in items)
    {
        TLInputPhoto$inputPhoto *inputPhoto = [[TLInputPhoto$inputPhoto alloc] init];
        inputPhoto.n_id = [itemDesc[@"imageId"] longLongValue];
        inputPhoto.access_hash = [itemDesc[@"accessHash"] longLongValue];
        [idsArray addObject:inputPhoto];
    }
    deletePhotos.n_id = idsArray;
    
    return [[TGTelegramNetworking instance] performRpc:deletePhotos completionBlock:^(__unused id<TLObject> result, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor deleteProfilePhotosSucess:items];
        }
        else
        {
            [actor deleteProfilePhotosFailed:items];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric];
}

- (NSObject *)doAssignProfilePhoto:(int64_t)itemId accessHash:(int64_t)accessHash actor:(TGTimelineAssignProfilePhotoActor *)actor
{
    TLRPCphotos_updateProfilePhoto$photos_updateProfilePhoto *updateProfilePhoto = [[TLRPCphotos_updateProfilePhoto$photos_updateProfilePhoto alloc] init];
    TLInputPhoto$inputPhoto *inputPhoto = [[TLInputPhoto$inputPhoto alloc] init];
    inputPhoto.n_id = itemId;
    inputPhoto.access_hash = accessHash;
    updateProfilePhoto.n_id = inputPhoto;
    updateProfilePhoto.crop = [[TLInputPhotoCrop$inputPhotoCropAuto alloc] init];
    
    return [[TGTelegramNetworking instance] performRpc:updateProfilePhoto completionBlock:^(TLUserProfilePhoto *result, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor assignProfilePhotoRequestSuccess:result];
        }
        else
        {
            [actor assignProfilePhotoRequestFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric];
}

- (NSObject *)doSaveGeocodingResult:(double)latitude longitude:(double)longitude components:(NSDictionary *)components actor:(TGSaveGeocodingResultActor *)actor
{
    TLRPCgeo_saveGeoPlace$geo_saveGeoPlace *savePlace = [[TLRPCgeo_saveGeoPlace$geo_saveGeoPlace alloc] init];
    
    TLInputGeoPoint$inputGeoPoint *geoPoint = [[TLInputGeoPoint$inputGeoPoint alloc] init];
    geoPoint.lat = latitude;
    geoPoint.n_long = longitude;
    
    savePlace.geo_point = geoPoint;
    
    TLInputGeoPlaceName$inputGeoPlaceName *placeName = [[TLInputGeoPlaceName$inputGeoPlaceName alloc] init];
    placeName.country = [components objectForKey:@"country"];
    placeName.state = [components objectForKey:@"state"];
    placeName.city = [components objectForKey:@"city"];
    placeName.district = [components objectForKey:@"district"];
    placeName.street = [components objectForKey:@"street"];
    savePlace.place_name = placeName;
    
    return [[TGTelegramNetworking instance] performRpc:savePlace completionBlock:^(__unused id<TLObject> response, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor saveGeocodingResultSuccess];
        }
        else
        {
            [actor saveGeocodingResultFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric];
}

- (NSObject *)doRequestPeerNotificationSettings:(int64_t)peerId accessHash:(int64_t)accessHash actor:(id<TGPeerSettingsActorProtocol>)actor
{
    TLRPCaccount_getNotifySettings$account_getNotifySettings *getPeerNotifySettings = [[TLRPCaccount_getNotifySettings$account_getNotifySettings alloc] init];
    
    if (peerId == INT_MAX - 1)
    {
        getPeerNotifySettings.peer = [[TLInputNotifyPeer$inputNotifyUsers alloc] init];
    }
    else if (peerId == INT_MAX - 2)
    {
        getPeerNotifySettings.peer = [[TLInputNotifyPeer$inputNotifyChats alloc] init];
    }
    else
    {
        TLInputNotifyPeer$inputNotifyPeer *inputPeer = [[TLInputNotifyPeer$inputNotifyPeer alloc] init];
        inputPeer.peer = [self createInputPeerForConversation:peerId accessHash:accessHash];
        getPeerNotifySettings.peer = inputPeer;
    }
    
    return [[TGTelegramNetworking instance] performRpc:getPeerNotifySettings completionBlock:^(TLPeerNotifySettings *result, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor peerNotifySettingsRequestSuccess:result];
        }
        else
        {
            [actor peerNotifySettingsRequestFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric];
}

- (NSObject *)doRequestConversationData:(int64_t)conversationId actor:(TGExtendedChatDataRequestActor *)actor
{
    TLRPCmessages_getFullChat$messages_getFullChat *getFullChat = [[TLRPCmessages_getFullChat$messages_getFullChat alloc] init];
    getFullChat.chat_id = TGGroupIdFromPeerId(conversationId);
    
    return [[TGTelegramNetworking instance] performRpc:getFullChat completionBlock:^(TLmessages_ChatFull *chatFull, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor chatFullRequestSuccess:chatFull];
        }
        else
        {
            [actor chatFullRequestFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric];
}

- (id)doRequestPeerProfilePhotoList:(int64_t)peerId actor:(TGProfilePhotoListActor *)actor
{
    TLRPCphotos_getUserPhotos$photos_getUserPhotos *getPhotos = [[TLRPCphotos_getUserPhotos$photos_getUserPhotos alloc] init];
    
    getPhotos.user_id = [self createInputUserForUid:(int)peerId];
    getPhotos.offset = 0;
    getPhotos.limit = 80;
    getPhotos.max_id = 0;
    
    return [[TGTelegramNetworking instance] performRpc:getPhotos completionBlock:^(TLphotos_Photos *result, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor photoListRequestSuccess:result];
        }
        else
        {
            [actor photoListRequestFailed];
        }
    } progressBlock:nil quickAckBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric datacenterId:TG_DEFAULT_DATACENTER_ID];
}

- (NSObject *)doChangePeerNotificationSettings:(int64_t)peerId accessHash:(int64_t)accessHash muteUntil:(int)muteUntil soundId:(int)soundId previewText:(bool)previewText messagesMuted:(bool)messagesMuted actor:(TGSynchronizeServiceActionsActor *)actor
{
    TLRPCaccount_updateNotifySettings$account_updateNotifySettings *updatePeerNotifySettings = [[TLRPCaccount_updateNotifySettings$account_updateNotifySettings alloc] init];
    
    if (peerId == INT_MAX - 1)
    {
        updatePeerNotifySettings.peer = [[TLInputNotifyPeer$inputNotifyUsers alloc] init];
    }
    else if (peerId == INT_MAX - 2)
    {
        updatePeerNotifySettings.peer = [[TLInputNotifyPeer$inputNotifyChats alloc] init];
    }
    else
    {
        TLInputNotifyPeer$inputNotifyPeer *inputPeer = [[TLInputNotifyPeer$inputNotifyPeer alloc] init];
        inputPeer.peer = [self createInputPeerForConversation:peerId accessHash:accessHash];
        updatePeerNotifySettings.peer = inputPeer;
    }
    
    TLInputPeerNotifySettings$inputPeerNotifySettings *peerNotifySettings = [[TLInputPeerNotifySettings$inputPeerNotifySettings alloc] init];
    
    NSString *stringSoundId = nil;
    if (soundId == 0)
        stringSoundId = @"";
    else if (soundId == 1)
        stringSoundId = @"default";
    else
        stringSoundId = [[NSString alloc] initWithFormat:@"%d.m4a", soundId];
    
    peerNotifySettings.mute_until = muteUntil;
    peerNotifySettings.sound = stringSoundId;
    if (previewText) {
        peerNotifySettings.flags |= (1 << 0);
    }
    if (messagesMuted) {
        peerNotifySettings.flags |= (1 << 1);
    }
    
    updatePeerNotifySettings.settings = peerNotifySettings;
    
    return [[TGTelegramNetworking instance] performRpc:updatePeerNotifySettings completionBlock:^(TLPeerNotifySettings *result, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor changePeerNotificationSettingsSuccess:result];
        }
        else
        {
            [actor changePeerNotificationSettingsFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric];
}

- (NSObject *)doResetPeerNotificationSettings:(TGSynchronizeServiceActionsActor *)actor
{
    TLRPCaccount_resetNotifySettings$account_resetNotifySettings *resetPeerNotifySettings = [[TLRPCaccount_resetNotifySettings$account_resetNotifySettings alloc] init];
    
    return [[TGTelegramNetworking instance] performRpc:resetPeerNotifySettings completionBlock:^(id<TLObject> __unused response, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor resetPeerNotificationSettingsSuccess];
        }
        else
        {
            [actor resetPeerNotificationSettingsFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric];
}

- (NSObject *)doRequestBlockList:(TGBlockListRequestActor *)actor
{
    TLRPCcontacts_getBlocked$contacts_getBlocked *getBlocked = [[TLRPCcontacts_getBlocked$contacts_getBlocked alloc] init];
    getBlocked.offset = 0;
    getBlocked.limit = 10000;
    
    return [[TGTelegramNetworking instance] performRpc:getBlocked completionBlock:^(TLcontacts_Blocked *result, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor blockListRequestSuccess:result];
        }
        else
        {
            [actor blockListRequestFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric];
}

- (NSObject *)doChangePeerBlockStatus:(int64_t)peerId block:(bool)block actor:(TGSynchronizeServiceActionsActor *)actor
{
    TLMetaRpc *method = nil;
    
    if (block)
    {
        TLRPCcontacts_block$contacts_block *blockMethod = [[TLRPCcontacts_block$contacts_block alloc] init];
        blockMethod.n_id = [self createInputUserForUid:(int)peerId];
        method = blockMethod;
    }
    else
    {
        TLRPCcontacts_unblock$contacts_unblock *unblockMethod = [[TLRPCcontacts_unblock$contacts_unblock alloc] init];
        unblockMethod.n_id = [self createInputUserForUid:(int)peerId];
        method = unblockMethod;
    }
    
    return [[TGTelegramNetworking instance] performRpc:method completionBlock:^(__unused id<TLObject> response, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor changePeerBlockStatusSuccess];
        }
        else
        {
            [actor changePeerBlockStatusFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric];
}

- (NSObject *)doChangeName:(NSString *)firstName lastName:(NSString *)lastName actor:(TGChangeNameActor *)actor
{
    TLaccount_updateProfile$updateProfile *updateProfile = [[TLaccount_updateProfile$updateProfile alloc] init];
    updateProfile.flags = 1 | 2;
    updateProfile.first_name = firstName;
    updateProfile.last_name = lastName;
    
    return [[TGTelegramNetworking instance] performRpc:updateProfile completionBlock:^(TLUser *result, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor changeNameSuccess:result];
        }
        else
        {
            [actor changeNameFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric];
}

- (id)doRequestWallpaperList:(TGWallpaperListRequestActor *)actor
{
    TLRPCaccount_getWallPapers$account_getWallPapers *getWallpapers = [[TLRPCaccount_getWallPapers$account_getWallPapers alloc] init];
    return [[TGTelegramNetworking instance] performRpc:getWallpapers completionBlock:^(id<TLObject> result, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor wallpaperListRequestSuccess:(NSArray *)result];
        }
        else
        {
            [actor wallpaperListRequestFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric];
}

- (id)doRequestEncryptionConfig:(TGRequestEncryptedChatActor *)actor version:(int)version
{
    TLRPCmessages_getDhConfig$messages_getDhConfig *getDhConfig = [[TLRPCmessages_getDhConfig$messages_getDhConfig alloc] init];
    getDhConfig.version = version;
    getDhConfig.random_length = 256;
    
    return [[TGTelegramNetworking instance] performRpc:getDhConfig completionBlock:^(id<TLObject> response, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor dhRequestSuccess:response];
        }
        else
        {
            [actor dhRequestFailed];
        }
    } progressBlock:nil quickAckBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric datacenterId:TG_DEFAULT_DATACENTER_ID];
}

- (id)doRequestEncryptedChat:(int)uid randomId:(int64_t)randomId gABytes:(NSData *)gABytes actor:(TGRequestEncryptedChatActor *)actor
{
    TLRPCmessages_requestEncryption$messages_requestEncryption *requestEncryption = [[TLRPCmessages_requestEncryption$messages_requestEncryption alloc] init];
    requestEncryption.user_id = [self createInputUserForUid:uid];
    requestEncryption.random_id = (int32_t)randomId;
    requestEncryption.g_a = gABytes;
    
    return [[TGTelegramNetworking instance] performRpc:requestEncryption completionBlock:^(id<TLObject> response, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor encryptedChatRequestSuccess:response date:(int)(responseTime / 4294967296L)];
        }
        else
        {
            NSString *errorType = error.errorDescription;
            
            bool versionOutdated = false;
            if ([errorType isEqualToString:@"PARTICIPANT_VERSION_OUTDATED"])
                versionOutdated = true;
            
            [actor encryptedChatRequestFailed:versionOutdated];
        }
    } progressBlock:nil quickAckBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric | TGRequestClassFailOnServerErrors datacenterId:TG_DEFAULT_DATACENTER_ID];
}

- (id)doAcceptEncryptedChat:(int64_t)encryptedChatId accessHash:(int64_t)accessHash gBBytes:(NSData *)gBBytes keyFingerprint:(int64_t)keyFingerprint actor:(TGEncryptedChatResponseActor *)actor
{
    TLRPCmessages_acceptEncryption$messages_acceptEncryption *acceptEncryption = [[TLRPCmessages_acceptEncryption$messages_acceptEncryption alloc] init];
    
    TLInputEncryptedChat$inputEncryptedChat *inputEncryptedChat = [[TLInputEncryptedChat$inputEncryptedChat alloc] init];
    inputEncryptedChat.chat_id = (int32_t)encryptedChatId;
    inputEncryptedChat.access_hash = accessHash;
    
    acceptEncryption.peer = inputEncryptedChat;
    acceptEncryption.g_b = gBBytes;
    acceptEncryption.key_fingerprint = keyFingerprint;
    
    return [[TGTelegramNetworking instance] performRpc:acceptEncryption completionBlock:^(id<TLObject> response, int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor acceptEncryptedChatSuccess:response date:(int)(responseTime / 4294967296L)];
        }
        else
        {
            [actor acceptEncryptedChatFailed];
        }
    } progressBlock:nil quickAckBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric | TGRequestClassFailOnServerErrors datacenterId:TG_DEFAULT_DATACENTER_ID];
}

- (id)doRejectEncryptedChat:(int64_t)encryptedConversationId actor:(TGSynchronizeActionQueueActor *)actor
{
    TLRPCmessages_discardEncryption$messages_discardEncryption *discardEncryption = [[TLRPCmessages_discardEncryption$messages_discardEncryption alloc] init];
    discardEncryption.chat_id = (int32_t)encryptedConversationId;
    
    return [[TGTelegramNetworking instance] performRpc:discardEncryption completionBlock:^(__unused id<TLObject> response, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor rejectEncryptedChatSuccess];
        }
        else
        {
            [actor rejectEncryptedChatFailed];
        }
    } progressBlock:nil quickAckBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric | TGRequestClassFailOnServerErrors datacenterId:TG_DEFAULT_DATACENTER_ID];
}

- (id)doReportEncryptedConversationTypingActivity:(int64_t)encryptedConversationId accessHash:(int64_t)accessHash actor:(TGConversationActivityRequestBuilder *)actor
{
    TLRPCmessages_setEncryptedTyping$messages_setEncryptedTyping *setEncryptedTyping = [[TLRPCmessages_setEncryptedTyping$messages_setEncryptedTyping alloc] init];
    setEncryptedTyping.typing = true;
    
    TLInputEncryptedChat$inputEncryptedChat *inputEncryptedChat = [[TLInputEncryptedChat$inputEncryptedChat alloc] init];
    inputEncryptedChat.chat_id = (int32_t)encryptedConversationId;
    inputEncryptedChat.access_hash = accessHash;
    setEncryptedTyping.peer = inputEncryptedChat;
    
    return [[TGTelegramNetworking instance] performRpc:setEncryptedTyping completionBlock:^(__unused id<TLObject> result, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor reportTypingActivitySuccess];
        }
        else
        {
            [actor reportTypingActivityFailed];
        }
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric | TGRequestClassHidesActivityIndicator];
}

- (id)doSendEncryptedMessage:(int64_t)encryptedChatId accessHash:(int64_t)accessHash randomId:(int64_t)randomId data:(NSData *)data encryptedFile:(TLInputEncryptedFile *)encryptedFile actor:(TGModernSendSecretMessageActor *)actor
{
    if (encryptedFile == nil)
    {
        TLRPCmessages_sendEncrypted$messages_sendEncrypted *sendEncrypted = [[TLRPCmessages_sendEncrypted$messages_sendEncrypted alloc] init];

        TLInputEncryptedChat$inputEncryptedChat *inputEncryptedChat = [[TLInputEncryptedChat$inputEncryptedChat alloc] init];
        inputEncryptedChat.chat_id = (int32_t)encryptedChatId;
        inputEncryptedChat.access_hash = accessHash;
        sendEncrypted.peer = inputEncryptedChat;
        
        sendEncrypted.random_id = randomId;
        sendEncrypted.data = data;
        
        return [[TGTelegramNetworking instance] performRpc:sendEncrypted completionBlock:^(TLmessages_SentEncryptedMessage *result, __unused int64_t responseTime, MTRpcError *error)
        {
            if (error == nil)
            {
                [actor sendEncryptedMessageSuccess:result.date encryptedFile:nil];
            }
            else
            {
                [actor sendEncryptedMessageFailed];
            }
        } progressBlock:nil quickAckBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric | TGRequestClassFailOnServerErrors datacenterId:TG_DEFAULT_DATACENTER_ID];
    }
    else
    {
        TLRPCmessages_sendEncryptedFile$messages_sendEncryptedFile *sendEncrypted = [[TLRPCmessages_sendEncryptedFile$messages_sendEncryptedFile alloc] init];
        
        TLInputEncryptedChat$inputEncryptedChat *inputEncryptedChat = [[TLInputEncryptedChat$inputEncryptedChat alloc] init];
        inputEncryptedChat.chat_id = (int32_t)encryptedChatId;
        inputEncryptedChat.access_hash = accessHash;
        sendEncrypted.peer = inputEncryptedChat;
        
        sendEncrypted.random_id = randomId;
        sendEncrypted.data = data;
        
        sendEncrypted.file = encryptedFile;
        
        return [[TGTelegramNetworking instance] performRpc:sendEncrypted completionBlock:^(TLmessages_SentEncryptedMessage *result, __unused int64_t responseTime, MTRpcError *error)
        {
            if (error == nil)
            {
                [actor sendEncryptedMessageSuccess:result.date encryptedFile:[result isKindOfClass:[TLmessages_SentEncryptedMessage$messages_sentEncryptedFile class]] ? [(TLmessages_SentEncryptedMessage$messages_sentEncryptedFile *)result file] : nil];
            }
            else
            {
                [actor sendEncryptedMessageFailed];
            }
        } progressBlock:nil quickAckBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric | TGRequestClassFailOnServerErrors datacenterId:TG_DEFAULT_DATACENTER_ID];
    }
}

- (id)doSendEncryptedServiceMessage:(int64_t)encryptedChatId accessHash:(int64_t)accessHash randomId:(int64_t)randomId data:(NSData *)data actor:(TGSynchronizeServiceActionsActor *)actor
{
    TLRPCmessages_sendEncryptedService$messages_sendEncryptedService *sendEncryptedService = [[TLRPCmessages_sendEncryptedService$messages_sendEncryptedService alloc] init];
    
    TLInputEncryptedChat$inputEncryptedChat *inputEncryptedChat = [[TLInputEncryptedChat$inputEncryptedChat alloc] init];
    inputEncryptedChat.chat_id = (int32_t)encryptedChatId;
    inputEncryptedChat.access_hash = accessHash;
    sendEncryptedService.peer = inputEncryptedChat;
    
    sendEncryptedService.random_id = randomId;
    sendEncryptedService.data = data;
    
    return [[TGTelegramNetworking instance] performRpc:sendEncryptedService completionBlock:^(TLmessages_SentEncryptedMessage *result, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor sendEncryptedServiceMessageSuccess:result.date];
        }
        else
        {
            [actor sendEncryptedServiceMessageFailed];
        }
    } progressBlock:nil quickAckBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric | TGRequestClassFailOnServerErrors datacenterId:TG_DEFAULT_DATACENTER_ID];
}

- (id)doReadEncrytedHistory:(int64_t)encryptedConversationId accessHash:(int64_t)accessHash maxDate:(int32_t)maxDate actor:(TGSynchronizeActionQueueActor *)actor
{
    TLRPCmessages_readEncryptedHistory$messages_readEncryptedHistory *readEncryptedHistory = [[TLRPCmessages_readEncryptedHistory$messages_readEncryptedHistory alloc] init];

    TLInputEncryptedChat$inputEncryptedChat *inputEncryptedChat = [[TLInputEncryptedChat$inputEncryptedChat alloc] init];
    inputEncryptedChat.chat_id = (int32_t)encryptedConversationId;
    inputEncryptedChat.access_hash = accessHash;
    readEncryptedHistory.peer = inputEncryptedChat;
    
    readEncryptedHistory.max_date = maxDate;
    
    return [[TGTelegramNetworking instance] performRpc:readEncryptedHistory completionBlock:^(__unused id<TLObject> response, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor readEncryptedSuccess];
        }
        else
        {
            [actor readEncryptedFailed];
        }
    } progressBlock:nil quickAckBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric | TGRequestClassFailOnServerErrors datacenterId:TG_DEFAULT_DATACENTER_ID];
}

- (id)doReportQtsReceived:(int32_t)qts actor:(TGReportDeliveryActor *)actor
{
    TLRPCmessages_receivedQueue$messages_receivedQueue *receivedQueue = [[TLRPCmessages_receivedQueue$messages_receivedQueue alloc] init];
    receivedQueue.max_qts = qts;
    
    return [[TGTelegramNetworking instance] performRpc:receivedQueue completionBlock:^(id<TLObject> response, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor reportQtsSuccess:qts randomIds:(NSArray *)response];
        }
        else
        {
            [actor reportQtsFailed:qts];
        }
    } progressBlock:nil quickAckBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric | TGRequestClassHidesActivityIndicator datacenterId:TG_DEFAULT_DATACENTER_ID];
}

- (id)doRequestInviteText:(TGUpdateConfigActor *)actor
{
    TLRPChelp_getInviteText$help_getInviteText *getInviteText = [[TLRPChelp_getInviteText$help_getInviteText alloc] init];
    getInviteText.lang_code = [self langCode];
    
    return [[TGTelegramNetworking instance] performRpc:getInviteText completionBlock:^(id<TLObject> response, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            [actor inviteTextRequestSuccess:response];
        }
        else
            [actor inviteTextRequestFailed];
    } progressBlock:nil quickAckBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric datacenterId:TG_DEFAULT_DATACENTER_ID];
}

- (id)doDownloadMessages:(NSArray *)mids peerId:(int64_t)peerId accessHash:(int64_t)accessHash actor:(TGDownloadMessagesActor *)actor
{
    id rpc = nil;
    if (TGPeerIdIsChannel(peerId)) {
        TLRPCchannels_getMessages$channels_getMessages *getMessages = [[TLRPCchannels_getMessages$channels_getMessages alloc] init];
        TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
        inputChannel.channel_id = TGChannelIdFromPeerId(peerId);
        inputChannel.access_hash = accessHash;
        getMessages.channel = inputChannel;
        getMessages.n_id = mids;
        rpc = getMessages;
    } else {
        TLRPCmessages_getMessages$messages_getMessages *getMessages = [[TLRPCmessages_getMessages$messages_getMessages alloc] init];
        getMessages.n_id = mids;
        rpc = getMessages;
    }
    
    return [[TGTelegramNetworking instance] performRpc:rpc completionBlock:^(TLmessages_Messages *result, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
            [actor messagesRequestSuccess:result];
        else
            [actor messagesRequestFailed];
    } progressBlock:nil quickAckBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric datacenterId:TG_DEFAULT_DATACENTER_ID];
}

- (id)doRequestPrefferredSuportPeer:(void (^)(TLhelp_Support *supportDesc))completion fail:(void (^)())fail
{
    TLRPChelp_getSupport$help_getSupport *getSupport = [[TLRPChelp_getSupport$help_getSupport alloc] init];
    return [[TGTelegramNetworking instance] performRpc:getSupport completionBlock:^(TLhelp_Support *result, __unused int64_t responseTime, MTRpcError *error)
    {
        if (error == nil)
        {
            if (completion != nil)
                completion(result);
        }
        else
        {
            if (fail != nil)
                fail();
        }
    } progressBlock:nil quickAckBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric datacenterId:TG_DEFAULT_DATACENTER_ID];
}

- (id)doChangePasslockSettings:(bool)passlockEnabled completion:(void (^)(bool))completion
{
    TLRPCaccount_updateDeviceLocked$account_updateDeviceLocked *updateDeviceLocked = [[TLRPCaccount_updateDeviceLocked$account_updateDeviceLocked alloc] init];
    updateDeviceLocked.period = passlockEnabled ? 0 : -1;
    return [[TGTelegramNetworking instance] performRpc:updateDeviceLocked completionBlock:^(__unused id<TLObject> response, __unused int64_t responseTime, MTRpcError *error)
    {
        if (completion)
            completion(error == nil);
    } progressBlock:nil requiresCompletion:true requestClass:TGRequestClassGeneric datacenterId:TG_DEFAULT_DATACENTER_ID];
}

- (void)timeDifferenceChanged:(NSTimeInterval)timeDifference majorChange:(bool)majorChange
{
    [TGDatabaseInstance() setTimeDifferenceFromUTC:timeDifference];
    
    if (majorChange)
    {
        [TGDatabaseInstance() processAndScheduleSelfDestruct];
        [TGDatabaseInstance() processAndScheduleMediaCleanup];
        [TGDatabaseInstance() processAndScheduleMute];
    }
}

- (bool)useDifferentBackend
{
    return TGAppDelegateInstance.useDifferentBackend;
}

- (void)saveSettings
{
    [TGAppDelegateInstance saveSettings];
}

- (void)setNetworkActivity:(__unused bool)networkActivity
{
    //[[AFNetworkActivityIndicatorManager sharedManager] setActivityCount:networkActivity ? 1 : 0];
}

- (NSString *)apiId
{
    return _apiId;
}

- (NSString *)deviceModel
{
    return [self currentDeviceModel];
}

- (NSString *)systemVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

- (NSString *)appVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

- (NSString *)langCode
{
    return [[NSLocale preferredLanguages] objectAtIndex:0];
}

- (void)willSwitchBackends
{
    [TGDatabaseInstance() dropDatabase:true];
    [TGDatabaseInstance() closeDatabase];
    TGAppDelegateInstance.useDifferentBackend = !TGAppDelegateInstance.useDifferentBackend;
    TGTelegraphInstance.clientUserId = 0;
    TGTelegraphInstance.clientIsActivated = false;
    [TGAppDelegateInstance saveSettings];
}

@end
