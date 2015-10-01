#import "TGDatabase.h"

#import "FMDatabase.h"

#import "ATQueue.h"

#import "TGUser.h"
#import "TGMessage.h"
#import "TGPeerIdAdapter.h"

#import "TGTelegraph.h"
#import "TGAppDelegate.h"

#import "NSObject+TGLock.h"

#import "TGStringUtils.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGCache.h"
#import "TGRemoteImageView.h"

#import "TGPreparedLocalAudioMessage.h"
#import "TGPreparedLocalDocumentMessage.h"

#import "PSKeyValueEncoder.h"
#import "PSKeyValueDecoder.h"

#import "TGGlobalMessageSearchSignals.h"

#include <map>
#include <set>
#include <tr1/unordered_map>
#include <tr1/memory>

#include <fcntl.h>
#import <sys/mman.h>

#import <CommonCrypto/CommonDigest.h>

#import <MTProtoKit/MTEncryption.h>

#include <inttypes.h>

#import "TGModernSendSecretMessageActor.h"

#import "TGTelegramNetworking.h"
#import "TGConversationAddMessagesActor.h"

#import "TGChannelList.h"

static const int32_t minReadIncomingMid_hash = 318137120;
static const int32_t lastCleanTime_hash = -1479533261;
static const int32_t pts_hash = 525160746;
static const int32_t lastMid_hash = -2005223851;
static const int32_t contactListState_hash = -1573512295;
static const int32_t latestSynchronizedMid_hash = -1095074628;
static const int32_t latestSynchronizedQts_hash = 578719706;
static const int32_t serviceEncryptedConversationCount_hash = -149140660;
static const int32_t reportedLayer_hash = -717538193;
static const int32_t layer_hash = 849537378;
static const int32_t seq_out_hash = -737765753;
static const int32_t seq_in_hash = -7646011;
static const int32_t sent_seq_out_hash = -1805599195;
static const int32_t resend_seq_in_hash = 1298242412;

#define TGDocumentFileType 1
#define TGLocalDocumentFileType 2
#define TGAudioFileType 3
#define TGLocalAudioFileType 4
#define TGImageFileType 5
#define TGLocalImageFileType 6

#define TGCustomPeerSettingsKey ((int)0x374BF349)

static const char *databaseQueueSpecific = "com.actionstage.databasequeue";
static const char *databaseIndexQueueSpecific = "com.actionstage.databaseindexqueue";

static dispatch_queue_t databaseDispatchQueue = nil;
static dispatch_queue_t databaseIndexDispatchQueue = nil;

static TGDatabase *TGDatabaseSingleton = nil;

static NSString *databaseName = nil;
static TGDatabasePasswordCheckResultBlock (^passwordRequiredBlock)(void (^)(NSString *), bool) = nil;
static TGDatabaseUpgradeCompletedBlock (^upgradeCompletedBlock)() = nil;

static NSString *_liveMessagesDispatchPath = nil;
static NSString *_liveBroadcastMessagesDispatchPath = nil;
static NSString *_liveUnreadCountDispatchPath = nil;

static NSString *md5String(NSString *string)
{
    const char *ptr = [string UTF8String];
    unsigned char md5Buffer[16];
    CC_MD5(ptr, (CC_LONG)[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding], md5Buffer);
    NSString *output = [[NSString alloc] initWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", md5Buffer[0], md5Buffer[1], md5Buffer[2], md5Buffer[3], md5Buffer[4], md5Buffer[5], md5Buffer[6], md5Buffer[7], md5Buffer[8], md5Buffer[9], md5Buffer[10], md5Buffer[11], md5Buffer[12], md5Buffer[13], md5Buffer[14], md5Buffer[15]];
    return output;
}

@interface TGCacheFileDesc : NSObject

@property (nonatomic, strong) NSString *filePath;
@property (nonatomic) int32_t date;

@end

@implementation TGCacheFileDesc

- (instancetype)initWithFilePath:(NSString *)filePath date:(int32_t)date
{
    self = [super init];
    if (self != nil)
    {
        _filePath = filePath;
        _date = date;
    }
    return self;
}

@end

@interface TGDeleteFileDesc : NSObject

@property (nonatomic) int64_t hash0;
@property (nonatomic) int64_t hash1;
@property (nonatomic, strong) NSString *filePath;

@end

@implementation TGDeleteFileDesc

- (instancetype)initWithHash0:(int64_t)hash0 hash1:(int64_t)hash1 filePath:(NSString *)filePath
{
    self = [super init];
    if (self != nil)
    {
        _hash0 = hash0;
        _hash1 = hash1;
        _filePath = filePath;
    }
    return self;
}

@end

@interface TGMediaDataDesc : NSObject

@property (nonatomic) int32_t messageId;
@property (nonatomic, strong) NSData *mediaData;
@property (nonatomic) int64_t peerId;

@end

@implementation TGMediaDataDesc

- (instancetype)initWithMessageId:(int32_t)messageId mediaData:(NSData *)mediaData peerId:(int64_t)peerId
{
    self = [super init];
    if (self != nil)
    {
        _messageId = messageId;
        _mediaData = mediaData;
        _peerId = peerId;
    }
    return self;
}

@end

@interface TGEncryptionKeyData : NSObject <NSCoding>

@property (nonatomic, readonly) int64_t keyId;
@property (nonatomic, strong, readonly) NSData *key;
@property (nonatomic, readonly) int32_t firstSeqOut;

@end

@implementation TGEncryptionKeyData

- (instancetype)initWithKeyId:(int64_t)keyId key:(NSData *)key firstSeqOut:(int32_t)firstSeqOut
{
    self = [super init];
    if (self != nil)
    {
        _keyId = keyId;
        _key = key;
        _firstSeqOut = firstSeqOut;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithKeyId:[aDecoder decodeInt64ForKey:@"keyId"] key:[aDecoder decodeObjectForKey:@"key"] firstSeqOut:[aDecoder decodeInt32ForKey:@"firstSeqOut"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt64:_keyId forKey:@"keyId"];
    if (_key != nil)
        [aCoder encodeObject:_key forKey:@"key"];
    [aCoder encodeInt32:_firstSeqOut forKey:@"firstSeqOut"];
}

@end

static TGFutureAction *futureActionDeserializer(int type)
{
    static TGChangeNotificationSettingsFutureAction *TGChangeNotificationSettingsFutureActionDeserializer = nil;
    static TGClearNotificationsFutureAction *TGClearNotificationsFutureActionDeserializer = nil;
    static TGChangePrivacySettingsFutureAction *TGChangePrivacySettingsFutureActionDeserializer = nil;
    static TGChangePeerBlockStatusFutureAction *TGChangePeerBlockStatusFutureActionDeserializer = nil;
    static TGUploadAvatarFutureAction *TGUploadAvatarFutureActionDeserializer = nil;
    static TGDeleteProfilePhotoFutureAction *TGDeleteProfilePhotoFutureActionDeserializer = nil;
    static TGRemoveContactFutureAction *TGRemoveContactFutureActionDeserializer = nil;
    static TGExportContactFutureAction *TGExportContactFutureActionDeserializer = nil;
    static TGSynchronizeEncryptedChatSettingsFutureAction *TGSynchronizeEncryptedChatSettingsFutureActionDeserializer = nil;
    static TGChangePasslockSettingsFutureAction *TGChangePasslockSettingsFutureActionDeserializer = nil;
    static TGUpdatePeerLayerFutureAction *TGUpdatePeerLayerFutureActionDeserializer = nil;
    static TGAcceptEncryptionFutureAction *TGAcceptEncryptionFutureActionDeserializer = nil;
    static TGEncryptedChatServiceAction *TGEncryptedChatServiceActionDeserializer = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        TGChangeNotificationSettingsFutureActionDeserializer = [[TGChangeNotificationSettingsFutureAction alloc] init];
        TGClearNotificationsFutureActionDeserializer = [[TGClearNotificationsFutureAction alloc] init];
        TGChangePrivacySettingsFutureActionDeserializer = [[TGChangePrivacySettingsFutureAction alloc] init];
        TGChangePeerBlockStatusFutureActionDeserializer = [[TGChangePeerBlockStatusFutureAction alloc] init];
        TGUploadAvatarFutureActionDeserializer = [[TGUploadAvatarFutureAction alloc] init];
        TGDeleteProfilePhotoFutureActionDeserializer = [[TGDeleteProfilePhotoFutureAction alloc] init];
        TGRemoveContactFutureActionDeserializer = [[TGRemoveContactFutureAction alloc] init];
        TGExportContactFutureActionDeserializer = [[TGExportContactFutureAction alloc] init];
        TGSynchronizeEncryptedChatSettingsFutureActionDeserializer = [[TGSynchronizeEncryptedChatSettingsFutureAction alloc] init];
        TGChangePasslockSettingsFutureActionDeserializer = [[TGChangePasslockSettingsFutureAction alloc] init];
        TGUpdatePeerLayerFutureActionDeserializer = [[TGUpdatePeerLayerFutureAction alloc] init];
        TGAcceptEncryptionFutureActionDeserializer = [[TGAcceptEncryptionFutureAction alloc] init];
        TGEncryptedChatServiceActionDeserializer = [[TGEncryptedChatServiceAction alloc] init];
    });
    
    switch (type)
    {
        case TGChangeNotificationSettingsFutureActionType:
            return TGChangeNotificationSettingsFutureActionDeserializer;
        case TGClearNotificationsFutureActionType:
            return TGClearNotificationsFutureActionDeserializer;
        case TGChangePrivacySettingsFutureActionType:
            return TGChangePrivacySettingsFutureActionDeserializer;
        case TGChangePeerBlockStatusFutureActionType:
            return TGChangePeerBlockStatusFutureActionDeserializer;
        case TGUploadAvatarFutureActionType:
            return TGUploadAvatarFutureActionDeserializer;
        case TGDeleteProfilePhotoFutureActionType:
            return TGDeleteProfilePhotoFutureActionDeserializer;
        case TGRemoveContactFutureActionType:
            return TGRemoveContactFutureActionDeserializer;
        case TGExportContactFutureActionType:
            return TGExportContactFutureActionDeserializer;
        case TGSynchronizeEncryptedChatSettingsFutureActionType:
            return TGSynchronizeEncryptedChatSettingsFutureActionDeserializer;
        case TGChangePasslockSettingsFutureActionType:
            return TGChangePasslockSettingsFutureActionDeserializer;
        case TGUpdatePeerLayerFutureActionType:
            return TGUpdatePeerLayerFutureActionDeserializer;
        case TGAcceptEncryptionFutureActionType:
            return TGAcceptEncryptionFutureActionDeserializer;
        case TGEncryptedChatServiceActionType:
            return TGEncryptedChatServiceActionDeserializer;
        default:
            break;
    }
    
    return nil;
}

@interface TGDatabase ()
{
    ATQueue *_fileDeletionQueue;
    ATQueue *_backgroundFileIndexingQueue;
    
    TG_SYNCHRONIZED_DEFINE(_userByUid);
    TG_SYNCHRONIZED_DEFINE(_contactsByPhoneId);
    TG_SYNCHRONIZED_DEFINE(_phonebookContacts);
    TG_SYNCHRONIZED_DEFINE(_mutedPeers);
    TG_SYNCHRONIZED_DEFINE(_nextLocalMid);
    TG_SYNCHRONIZED_DEFINE(_userLinks);
    TG_SYNCHRONIZED_DEFINE(_cachedUnreadCount);
    TG_SYNCHRONIZED_DEFINE(_unreadCountByConversation);
    TG_SYNCHRONIZED_DEFINE(_minAutosaveMessageIdForConversations);
    TG_SYNCHRONIZED_DEFINE(_containsConversation);
    TG_SYNCHRONIZED_DEFINE(_remoteContactUids);
    TG_SYNCHRONIZED_DEFINE(_peerCustomSettings);
    TG_SYNCHRONIZED_DEFINE(_encryptedConversationIds);
    TG_SYNCHRONIZED_DEFINE(_conversationEncryptionKeys);
    TG_SYNCHRONIZED_DEFINE(_encryptedParticipantIds);
    TG_SYNCHRONIZED_DEFINE(_encryptedConversationIsCreator);
    TG_SYNCHRONIZED_DEFINE(_encryptedConversationAccessHash);
    TG_SYNCHRONIZED_DEFINE(_messageLifetimeByPeerId);
    TG_SYNCHRONIZED_DEFINE(_cachedConversations);
    TG_SYNCHRONIZED_DEFINE(_conversationInputStates);
    
    std::tr1::unordered_map<int, TGUser *> _userByUid;
    std::map<int, TGContactBinding *> _contactsByPhoneId;
    std::map<int, int> _phoneIdByUid;
    std::set<int> _remoteContactUids;
    
    std::map<int, TGPhonebookContact *> _phonebookContacts;
    std::map<int, int> _phoneIdToNativeId;
    
    std::map<int64_t, int> _mutedPeers;
    
    std::map<int64_t, int> _minAutosaveMessageIdForConversations;
    
    std::map<int, std::pair<int, int> > _userLinks;
    
    std::map<int64_t, int> _unreadCountByConversation;
    std::set<int64_t> _containsConversation;
    int _cachedUnreadCount;
    
    std::map<int64_t, TGConversation *> _cachedConversations;
    
    std::map<int64_t, bool> _isConversationBroadcast;
    
    std::map<int64_t, TGPeerCustomSettings> _peerCustomSettings;
    
    std::map<int64_t, int64_t> _encryptedConversationIds;
    std::map<int64_t, int64_t> _peerIdsForEncryptedConversationIds;
    std::map<int64_t, std::vector<TGEncryptionKeyData *> > _conversationEncryptionKeys;
    std::map<int64_t, int32_t> _encryptedParticipantIds;
    std::map<int64_t, bool> _encryptedConversationIsCreator;
    std::map<int64_t, int64_t> _encryptedConversationAccessHash;
    std::map<int64_t, int32_t> _messageLifetimeByPeerId;
    
    std::map<int64_t, NSDictionary *> _conversationInputStates;
    
    std::map<int64_t, NSUInteger> _peerLayers;
    TG_SYNCHRONIZED_DEFINE(_peerLayers);
    std::map<int64_t, NSUInteger> _lastReportedToPeerLayers;
    TG_SYNCHRONIZED_DEFINE(_lastReportedToPeerLayers);
    
    NSString *_password;
    
    TG_SYNCHRONIZED_DEFINE(_ptsWatchers);
    SBag *_ptsWatchers;
    
    SMulticastSignalManager *_multicastManager;
    
    SPipe *_channelListPipe;
    TGChannelList *_storedChannelList;
    NSMutableDictionary *_existingChannelPipes;
    
    SPipe *_queuedDeleteChannelMessages;
    SPipe *_queuedReadChannelMessages;
    SPipe *_queuedLeaveChannels;
    
    NSMutableDictionary *_cachedChannelDataPipes;
}

@property (nonatomic, strong) NSString *databasePath;
@property (nonatomic, strong) NSString *indexDatabasePath;

@property (nonatomic, strong) FMDatabase *database;
@property (nonatomic, strong) FMDatabase *indexDatabase;
@property (nonatomic, strong) FMDatabase *filesDatabase;

@property (nonatomic) TGDatabaseState cachedDatabaseState;

@property (nonatomic) int schemaVersion;
@property (nonatomic, strong) NSString *serviceTableName;
@property (nonatomic, strong) NSString *usersTableName;
@property (nonatomic, strong) NSString *conversationListTableName;
@property (nonatomic, strong) NSString *broadcastConversationListTableName;
@property (nonatomic, strong) NSString *channelListTableName;
@property (nonatomic, strong) NSString *channelCachedDataTableName;
@property (nonatomic, strong) NSString *channelMessagesTableName;
@property (nonatomic, strong) NSString *channelMessageTagsTableName;
@property (nonatomic, strong) NSString *channelMessagesRandomIdTableName;
@property (nonatomic, strong) NSString *channelMessageHolesTableName;
@property (nonatomic, strong) NSString *channelMessageUnimportantHolesTableName;
@property (nonatomic, strong) NSString *channelMessageUnimportantGroupsTableName;
@property (nonatomic, strong) NSString *channelDeleteMessagesTableName;
@property (nonatomic, strong) NSString *channelLeaveTableName;
@property (nonatomic, strong) NSString *channelReadHistoryTableName;
@property (nonatomic, strong) NSString *messagesTableName;
@property (nonatomic, strong) NSString *conversationMediaTableName;
@property (nonatomic, strong) NSString *contactListTableName;
@property (nonatomic, strong) NSString *actionQueueTableName;
@property (nonatomic, strong) NSString *peerPropertiesTableName;
@property (nonatomic, strong) NSString *peerProfilePhotosTableName;
@property (nonatomic, strong) NSString *outgoingMessagesTableName;
@property (nonatomic, strong) NSString *futureActionsTableName;
@property (nonatomic, strong) NSString *peerHistoryHolesTableName;

@property (nonatomic, strong) NSString *assetsTableName;
@property (nonatomic, strong) NSString *videosTableName;
@property (nonatomic, strong) NSString *storedFilesTableName;
@property (nonatomic, strong) NSString *localFilesTableName;

@property (nonatomic, strong) NSString *serverAssetsTableName;

@property (nonatomic, strong) NSString *blockedUsersTableName;
@property (nonatomic, strong) NSString *userLinksTableName;

@property (nonatomic, strong) NSString *temporaryMessageIdsTableName;
@property (nonatomic, strong) NSString *randomIdsTableName;
@property (nonatomic, strong) NSString *selfDestructTableName;

@property (nonatomic, strong) NSString *encryptedConversationIdsTableName;

@property (nonatomic, strong) NSString *messageIndexTableName;

@property (nonatomic, strong) NSString *secretMediaAttributesTableName;

@property (nonatomic, strong) NSString *mediaCacheInvalidationTableName;
@property (nonatomic, strong) NSString *fileDeletionTableName;

@property (nonatomic, strong) NSString *secretPeerOutgoingTableName;
@property (nonatomic, strong) NSString *secretPeerOutgoingResendTableName;
@property (nonatomic, strong) NSString *secretPeerIncomingTableName;
@property (nonatomic, strong) NSString *secretPeerIncomingEncryptedTableName;

@property (nonatomic, strong) NSString *sharedMediaCacheTableName;
@property (nonatomic, strong) NSString *sharedMediaIndexBuiltTableName;
@property (nonatomic, strong) NSString *sharedMediaIndexDownloadedTableName;

@property (nonatomic, strong) NSString *botInfoTableName;

@property (nonatomic) int serviceLastCleanTimeKey;
@property (nonatomic) int serviceLastMidKey;
@property (nonatomic) int servicePtsKey;
@property (nonatomic) int serviceContactListStateKey;
@property (nonatomic) int serviceLatestSynchronizedMidKey;
@property (nonatomic) int serviceLatestSynchronizedQtsKey;
@property (nonatomic) int serviceEncryptedConversationCount;

@property (nonatomic) int nextLocalMid;

@property (nonatomic) int localUserId;
@property (nonatomic, strong) TGNotificationPrivacyAccountSetting *privacySettings;
@property (nonatomic) bool contactListPreloaded;

@property (nonatomic) int userLinksVersion;

@property (nonatomic, strong) TGTimer *selfDestructTimer;
@property (nonatomic, strong) TGTimer *mediaCleanupTimer;
@property (nonatomic, strong) TGTimer *deletionTickTimer;
@property (nonatomic, strong) TGTimer *updateMuteTimer;
@property (nonatomic) bool deletionInProgress;

- (void)initDatabase;

@end

TGDatabase *TGDatabaseInstance()
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        TGDatabaseSingleton = [[TGDatabase alloc] init];
        
        [TGDatabaseSingleton dispatchOnDatabaseThread:^
        {
            [TGDatabaseSingleton initDatabase];
        } synchronous:false];
    });
    
    return TGDatabaseSingleton;
}

@implementation TGDatabase

+ (void)setDatabaseName:(NSString *)name
{
    databaseName = name;
}

+ (void)setPasswordRequiredBlock:(TGDatabasePasswordCheckResultBlock (^)(void (^)(NSString *), bool))block
{
    passwordRequiredBlock = [block copy];
}

+ (void)setUpgradingBlock:(TGDatabaseUpgradeCompletedBlock (^)())block
{
    upgradeCompletedBlock = [block copy];
}

+ (void)setLiveMessagesDispatchPath:(NSString *)path
{
    _liveMessagesDispatchPath = path;
}

+ (void)setLiveBroadcastMessagesDispatchPath:(NSString *)path
{
    _liveBroadcastMessagesDispatchPath = path;
}

+ (void)setLiveUnreadCountDispatchPath:(NSString *)path
{
    _liveUnreadCountDispatchPath = path;
}

+ (TGDatabase *)instance
{
    return TGDatabaseInstance();
}

- (dispatch_queue_t)databaseQueue
{
    if (databaseDispatchQueue == NULL)
    {
        databaseDispatchQueue = dispatch_queue_create("com.actionstage.databasequeue", 0);
        
        dispatch_queue_set_specific(databaseDispatchQueue, databaseQueueSpecific, (void *)databaseQueueSpecific, NULL);
    }
    return databaseDispatchQueue;
}

- (SSignal *)appliedPts
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        TG_SYNCHRONIZED_BEGIN(_ptsWatchers);
        NSUInteger index = [_ptsWatchers addItem:[^(int32_t pts)
        {
            [subscriber putNext:@(pts)];
        } copy]];
        TG_SYNCHRONIZED_END(_ptsWatchers);
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            TG_SYNCHRONIZED_BEGIN(_ptsWatchers);
            [_ptsWatchers removeItem:index];
            TG_SYNCHRONIZED_END(_ptsWatchers);
        }];
    }];
}

- (bool)isCurrentQueueDatabaseQueue
{
    return dispatch_get_specific(databaseQueueSpecific) != NULL;
}

- (dispatch_queue_t)databaseIndexQueue
{
    if (databaseIndexDispatchQueue == NULL)
    {
        databaseIndexDispatchQueue = dispatch_queue_create("com.actionstage.databaseindexqueue", 0);
        
        dispatch_queue_set_specific(databaseIndexDispatchQueue, databaseIndexQueueSpecific, (void *)databaseIndexQueueSpecific, NULL);
    }
    return databaseIndexDispatchQueue;
}

- (bool)isCurrentQueueDatabaseIndexQueue
{
    return dispatch_get_specific(databaseIndexQueueSpecific) != NULL;
}

#ifdef DEBUG_DATABASE_INVOKATIONS
- (void)dispatchOnDatabaseThreadDebug:(const char *)file line:(int)line block:(dispatch_block_t)block synchronous:(bool)synchronous
#else
- (void)dispatchOnDatabaseThread:(dispatch_block_t)block synchronous:(bool)synchronous
#endif
{
    if ([self isCurrentQueueDatabaseQueue])
    {
        @autoreleasepool
        {
#ifdef DEBUG_DATABASE_INVOKATIONS
            CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
#endif
            block();
#ifdef DEBUG_DATABASE_INVOKATIONS
            CFAbsoluteTime executionTime = (CFAbsoluteTimeGetCurrent() - startTime);
            if (executionTime > 0.3)
                TGLog(@"***** DB Dispatch from %s:%d took %f s", file, line, executionTime);
#endif
        }
    }
    else
    {
        if (synchronous)
        {
            dispatch_sync([self databaseQueue], ^
            {
                @autoreleasepool
                {
#ifdef DEBUG_DATABASE_INVOKATIONS
                    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
#endif
                    block();
#ifdef DEBUG_DATABASE_INVOKATIONS
                    CFAbsoluteTime executionTime = (CFAbsoluteTimeGetCurrent() - startTime);
                    if (executionTime > 0.3)
                        TGLog(@"***** DB Dispatch from %s:%d took %f s", file, line, executionTime);
#endif
                }
            });
        }
        else
        {
            dispatch_async([self databaseQueue], ^
            {
                @autoreleasepool
                {
#ifdef DEBUG_DATABASE_INVOKATIONS
                    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
#endif
                    block();
#ifdef DEBUG_DATABASE_INVOKATIONS
                    CFAbsoluteTime executionTime = (CFAbsoluteTimeGetCurrent() - startTime);
                    if (executionTime > 0.3)
                        TGLog(@"***** DB Dispatch from %s:%d took %f s", file, line, executionTime);
#endif
                }
            });
        }
    }
}

- (void)dispatchOnIndexThread:(dispatch_block_t)block synchronous:(bool)synchronous
{
    if ([self isCurrentQueueDatabaseIndexQueue])
    {
        @autoreleasepool
        {
            block();
        }
    }
    else
    {
        if (synchronous)
        {
            dispatch_sync([self databaseIndexQueue], ^
            {
                @autoreleasepool
                {
                    block();
                }
            });
        }
        else
        {
            dispatch_async([self databaseIndexQueue], ^
            {
                @autoreleasepool
                {
                    block();
                }
            });
        }
    }
}

static NSMutableData *upgradedFileMidMap(NSData *data) {
    int32_t expectedMagic = 0x7ceaea64;
    if (data.length < 4) {
        return [[NSMutableData alloc] initWithBytes:&expectedMagic length:4];
    } else {
        int32_t magic = 0;
        [data getBytes:&magic length:4];
        if (magic == expectedMagic) {
            return [[NSMutableData alloc] initWithData:data];
        } else {
            NSMutableData *updatedData = [[NSMutableData alloc] init];
            [updatedData appendBytes:&expectedMagic length:4];
            
            int32_t *legacyMessageIds = (int32_t *)[data bytes];
            int32_t count = (int)data.length / 4;
            for (int32_t i = 0; i < count; i++)
            {
                int64_t peerId = 0;
                [updatedData appendBytes:&peerId length:8];
                int32_t messageId = legacyMessageIds[i];
                [updatedData appendBytes:&messageId length:4];
            }
            
            return updatedData;
        }
    }
}

static bool addMidToFileMap(NSMutableData *data, int64_t peerId, int32_t mid) {
    bool found = false;
    int32_t count = ((int32_t)data.length - 4) / (8 + 4);
    uint8_t *bytes = ((uint8_t *)data.bytes);
    for (int32_t i = 0; i < count; i++) {
        int64_t currentPeerId = 0;
        memcpy(&currentPeerId, bytes + 4 + i * (8 + 4), 8);
        int32_t currentMid = 0;
        memcpy(&currentMid, bytes + 4 + i * (8 + 4) + 8, 4);
        if (currentPeerId == peerId && currentMid == mid) {
            found = true;
            break;
        }
    }
    
    if (!found) {
        [data appendBytes:&peerId length:8];
        [data appendBytes:&mid length:4];
        return true;
    } else {
        return false;
    }
}

static void removeMidFromFileMap(NSMutableData *data, int64_t peerId, int32_t mid) {
    int32_t count = ((int32_t)data.length - 4) / (8 + 4);
    uint8_t *bytes = ((uint8_t *)data.bytes);
    for (int32_t i = 0; i < count; i++) {
        int64_t currentPeerId = 0;
        memcpy(&currentPeerId, bytes + 4 + i * (8 + 4), 8);
        int32_t currentMid = 0;
        memcpy(&currentMid, bytes + 4 + i * (8 + 4) + 8, 4);
        if (currentPeerId == peerId && currentMid == mid) {
            [data replaceBytesInRange:NSMakeRange(4 + i * (8 + 4), 8 + 4) withBytes:NULL length:0];
            count--;
            i--;
        }
    }
}

static NSData *singleMidFileMap(int64_t peerId, int32_t mid) {
    NSMutableData *midsData = [[NSMutableData alloc] init];
    int32_t expectedMagic = 0x7ceaea64;
    [midsData appendBytes:&expectedMagic length:4];
    [midsData appendBytes:&peerId length:8];
    [midsData appendBytes:&mid length:4];
    
    return midsData;
}

static void addVideoMid(TGDatabase *database, int64_t peerId, int32_t mid, int64_t videoId, bool isLocal)
{
    NSString *tableName = isLocal ? database.localFilesTableName : database.videosTableName;
    
    FMResultSet *result = [database.database executeQuery:[[NSString alloc] initWithFormat:@"SELECT mids FROM %@ WHERE vid=?", tableName], [[NSNumber alloc] initWithLongLong:videoId]];
    if ([result next])
    {
        NSMutableData *midsData = upgradedFileMidMap([result dataForColumn:@"mids"]);
        
        if (addMidToFileMap(midsData, peerId, mid)) {
            [database.database executeUpdate:[[NSString alloc] initWithFormat:@"UPDATE %@ SET mids=? WHERE vid=?", tableName], midsData, [[NSNumber alloc] initWithLongLong:videoId]];
        }
    }
    else
    {
        [database.database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT INTO %@ (vid, mids) VALUES(?, ?)", tableName], [[NSNumber alloc] initWithLongLong:videoId], singleMidFileMap(peerId, mid)];
    }
}

static void removeVideoMid(TGDatabase *database, int64_t peerId, int32_t mid, int64_t videoId, bool isLocal)
{
    NSString *tableName = isLocal ? database.localFilesTableName : database.videosTableName;
    
    FMResultSet *result = [database.database executeQuery:[[NSString alloc] initWithFormat:@"SELECT mids FROM %@ WHERE vid=?", tableName], [[NSNumber alloc] initWithLongLong:videoId]];
    if ([result next])
    {
        NSMutableData *midsData = upgradedFileMidMap([result dataForColumn:@"mids"]);
        
        removeMidFromFileMap(midsData, peerId, mid);
        
        if (midsData.length <= 4)
        {
            [database.database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE vid=?", tableName], [[NSNumber alloc] initWithLongLong:videoId]];
            
            dispatch_async([TGCache diskCacheQueue], ^
            {
                static NSString *videosPath = nil;
                if (videosPath == nil)
                {
                    videosPath = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"video"];
                }
                
                if (isLocal)
                {
                    [[TGCache diskFileManager] removeItemAtPath:[videosPath stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"local%llx.mov", videoId]] error:nil];
                }
                else
                {
                    [[TGCache diskFileManager] removeItemAtPath:[videosPath stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"remote%llx.mov", videoId]] error:nil];
                    [[TGCache diskFileManager] removeItemAtPath:[videosPath stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"remote%llx.mp4", videoId]] error:nil];
                    [[TGCache diskFileManager] removeItemAtPath:[videosPath stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"remote%llx.part", videoId]] error:nil];
                }
            });
        }
        else
        {
            [database.database executeUpdate:[[NSString alloc] initWithFormat:@"UPDATE %@ SET mids=? WHERE vid=?", tableName], midsData, [[NSNumber alloc] initWithLongLong:videoId]];
        }
    }
}

static void addFileMid(TGDatabase *database, int64_t peerId, int32_t mid, int type, int64_t fileId)
{
    FMResultSet *result = [database.database executeQuery:[[NSString alloc] initWithFormat:@"SELECT mids FROM %@ WHERE type=? AND file_id=?", database.storedFilesTableName], [[NSNumber alloc] initWithInteger:type], [[NSNumber alloc] initWithLongLong:fileId]];
    if ([result next]) {
        NSMutableData *midsData = upgradedFileMidMap([result dataForColumn:@"mids"]);
        
        if (addMidToFileMap(midsData, peerId, mid)) {
            [database.database executeUpdate:[[NSString alloc] initWithFormat:@"UPDATE %@ SET mids=? WHERE type=? AND file_id=?", database.storedFilesTableName], midsData, [[NSNumber alloc] initWithInteger:type], [[NSNumber alloc] initWithLongLong:fileId]];
        }
    } else {
        
        [database.database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT INTO %@ (type, file_id, mids) VALUES(?, ?, ?)", database.storedFilesTableName], [[NSNumber alloc] initWithInteger:type], [[NSNumber alloc] initWithLongLong:fileId], singleMidFileMap(peerId, mid)];
    }
}

static void removeFileMid(TGDatabase *database, int64_t peerId, int32_t mid, int type, int64_t fileId)
{
    NSString *tableName = database.storedFilesTableName;
    
    FMResultSet *result = [database.database executeQuery:[[NSString alloc] initWithFormat:@"SELECT mids FROM %@ WHERE type=? AND file_id=?", tableName], [[NSNumber alloc] initWithInt:type], [[NSNumber alloc] initWithLongLong:fileId]];
    if ([result next])
    {
        NSMutableData *midsData = upgradedFileMidMap([result dataForColumn:@"mids"]);
        removeMidFromFileMap(midsData, peerId, mid);
        
        if (midsData.length <= 4)
        {
            [database.database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE type=? AND file_id=?", tableName], [[NSNumber alloc] initWithInt:type], [[NSNumber alloc] initWithLongLong:fileId]];
            
            dispatch_async([TGCache diskCacheQueue], ^
            {
                if (type == TGDocumentFileType || type == TGLocalDocumentFileType)
                {
                    static NSString *filesPath = nil;
                    if (filesPath == nil)
                    {
                        filesPath = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"files"];
                    }
                    
                    [[NSFileManager defaultManager] removeItemAtPath:[filesPath stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%@%" PRIx64 "", type == TGLocalDocumentFileType ? @"local" : @"", fileId]] error:nil];
                }
                else if (type == TGAudioFileType || type == TGLocalAudioFileType)
                {
                    static NSString *audioPath = nil;
                    if (audioPath == nil)
                    {
                        audioPath = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"audio"];
                    }
                    
                    [[NSFileManager defaultManager] removeItemAtPath:[audioPath stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%@%" PRIx64 "", type == TGLocalAudioFileType ? @"local" : @"", fileId]] error:nil];
                }
                else if (type == TGImageFileType || type == TGLocalImageFileType)
                {
                    static NSString *filesDirectory = nil;
                    static dispatch_once_t onceToken;
                    dispatch_once(&onceToken, ^
                    {
                        filesDirectory = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"files"];
                    });
                    
                    NSString *photoDirectoryName = nil;
                    if (type == TGImageFileType) {
                        photoDirectoryName = [[NSString alloc] initWithFormat:@"image-remote-%" PRIx64 "", fileId];
                    } else {
                        photoDirectoryName = [[NSString alloc] initWithFormat:@"image-local-%" PRIx64 "", fileId];
                    }
                    
                    [[NSFileManager defaultManager] removeItemAtPath:[filesDirectory stringByAppendingPathComponent: photoDirectoryName] error:nil];
                }
            });
        }
        else
        {
            [database.database executeUpdate:[[NSString alloc] initWithFormat:@"UPDATE %@ SET mids=? WHERE type=? AND file_id=?", tableName], midsData, [[NSNumber alloc] initWithInt:type], [[NSNumber alloc] initWithLongLong:fileId]];
        }
    }
}

static void cleanupMessage(TGDatabase *database, int mid, NSArray *attachments, TGDatabaseMessageCleanupBlock cleanupBlock)
{
    for (TGMediaAttachment *attachment in attachments)
    {
        if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
        {
            TGVideoMediaAttachment *videoAttachment = (TGVideoMediaAttachment *)attachment;
            
            if (videoAttachment.videoId != 0)
                removeVideoMid(database, 0, mid, videoAttachment.videoId, false);
            else if (videoAttachment.localVideoId != 0)
            {
                removeVideoMid(database, 0, mid, videoAttachment.localVideoId, true);
                
                [[videoAttachment.thumbnailInfo allSizes] enumerateKeysAndObjectsUsingBlock:^(NSString *url, __unused NSValue *size, __unused BOOL *stop)
                {
                    NSString *fileUrl = nil;
                    if ([url hasPrefix:@"file://"])
                        fileUrl = [url substringFromIndex:@"file://".length];
                    if (fileUrl != nil)
                        [[TGCache diskFileManager] removeItemAtPath:fileUrl error:nil];
                    else
                        [[TGRemoteImageView sharedCache] removeFromDiskCache:url];
                }];
            }
        }
        else if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
        {
            TGImageMediaAttachment *imageAttachment = (TGImageMediaAttachment *)attachment;
            if (imageAttachment.imageId == 0)
            {
                TGImageInfo *imageInfo = imageAttachment.imageInfo;
                
                dispatch_async([TGCache diskCacheQueue], ^
                {
                    [[imageInfo allSizes] enumerateKeysAndObjectsUsingBlock:^(NSString *url, __unused NSValue *size, __unused BOOL *stop)
                    {
                        NSString *fileUrl = nil;
                        if ([url hasPrefix:@"file://"])
                            fileUrl = [url substringFromIndex:@"file://".length];
                        if (fileUrl != nil)
                            [[TGCache diskFileManager] removeItemAtPath:fileUrl error:nil];
                        else
                            [[TGRemoteImageView sharedCache] removeFromDiskCache:url];
                    }];
                });
            }
        }
        else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
        {
            TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)attachment;
            if (documentAttachment.localDocumentId != 0)
                removeFileMid(database, 0, mid, TGLocalDocumentFileType, documentAttachment.localDocumentId);
            else if (documentAttachment.documentId != 0)
                removeFileMid(database, 0, mid, TGDocumentFileType, documentAttachment.documentId);
        }
        else if ([attachment isKindOfClass:[TGAudioMediaAttachment class]])
        {
            TGAudioMediaAttachment *audioAttachment = (TGAudioMediaAttachment *)attachment;
            if (audioAttachment.localAudioId != 0)
                removeFileMid(database, 0, mid, TGLocalAudioFileType, audioAttachment.localAudioId);
            else if (audioAttachment.audioId != 0)
                removeFileMid(database, 0, mid, TGAudioFileType, audioAttachment.audioId);
        }
        
        if (cleanupBlock)
            cleanupBlock((TGMediaAttachment *)attachment);
    }
}

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        /*TGLog(@"static const int32 minReadIncomingMid_hash = %d;", @"minReadIncomingMid".hash);
        TGLog(@"static const int32 lastCleanTime_hash = %d;", @"lastCleanTime".hash);
        TGLog(@"static const int32 pts_hash = %d;", @"pts".hash);
        TGLog(@"static const int32 lastMid_hash = %d;", @"lastMid".hash);
        TGLog(@"static const int32 contactListState_hash = %d;", @"contactListState".hash);
        TGLog(@"static const int32 latestSynchronizedMid_hash = %d;", @"latestSynchronizedMid".hash);
        TGLog(@"static const int32 latestSynchronizedQts_hash = %d;", @"latestSynchronizedQts".hash);
        TGLog(@"static const int32 serviceEncryptedConversationCount_hash = %d;", @"serviceEncryptedConversationCount".hash);
        TGLog(@"static const int32 reportedLayer_hash = %d;", @"reportedLayer".hash);
        
        TGLog(@"static const int32 layer_hash = %d;", @"layer".hash);
        TGLog(@"static const int32 seq_out_hash = %d;", @"seq_out".hash);
        TGLog(@"static const int32 seq_in_hash = %d;", @"seq_in".hash);
        TGLog(@"static const int32 sent_seq_out_hash = %d;", @"sent_seq_out".hash);
        TGLog(@"static const int32 resend_seq_in_hash = %d;", @"resend_seq_in".hash);*/
        
        _fileDeletionQueue = [[ATQueue alloc] init];
        _backgroundFileIndexingQueue = [[ATQueue alloc] init];
        
        TG_SYNCHRONIZED_INIT(_userByUid);
        TG_SYNCHRONIZED_INIT(_contactsByPhoneId);
        TG_SYNCHRONIZED_INIT(_phonebookContacts);
        TG_SYNCHRONIZED_INIT(_mutedPeers);
        TG_SYNCHRONIZED_INIT(_minAutosaveMessageIdForConversations);
        TG_SYNCHRONIZED_INIT(_nextLocalMid);
        TG_SYNCHRONIZED_INIT(_userLinks);
        TG_SYNCHRONIZED_INIT(_cachedUnreadCount);
        TG_SYNCHRONIZED_INIT(_unreadCountByConversation);
        TG_SYNCHRONIZED_INIT(_containsConversation);
        TG_SYNCHRONIZED_INIT(_remoteContactUids);
        TG_SYNCHRONIZED_INIT(_peerCustomSettings);
        TG_SYNCHRONIZED_INIT(_encryptedConversationIds);
        TG_SYNCHRONIZED_INIT(_conversationEncryptionKeys);
        TG_SYNCHRONIZED_INIT(_encryptedParticipantIds);
        TG_SYNCHRONIZED_INIT(_encryptedConversationIsCreator);
        TG_SYNCHRONIZED_INIT(_encryptedConversationAccessHash);
        TG_SYNCHRONIZED_INIT(_messageLifetimeByPeerId);
        TG_SYNCHRONIZED_INIT(_cachedConversations);
        TG_SYNCHRONIZED_INIT(_conversationInputStates);
        
        TG_SYNCHRONIZED_INIT(_peerLayers);
        TG_SYNCHRONIZED_INIT(_lastReportedToPeerLayers);
        
        TG_SYNCHRONIZED_INIT(_ptsWatchers);
        _ptsWatchers = [[SBag alloc] init];
        
        _userLinksVersion = 1;
        
        _schemaVersion = 29;
        
        _cachedUnreadCount = INT_MIN;
        
        NSString *baseDatabasePath = [[self documentsPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db", (databaseName == nil ? @"tgdata" : databaseName)]];
        NSString *baseIndexDatabasePath = [[self documentsPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_index.db", (databaseName == nil ? @"tgdata" : databaseName)]];
        
        NSString *encryptedDatabasePath = [baseDatabasePath stringByAppendingString:@".y"];
        NSString *encryptedIndexDatabasePath = [baseIndexDatabasePath stringByAppendingString:@".y"];
        
#if defined(DEBUG ) && false
        [[NSFileManager defaultManager] removeItemAtPath:encryptedDatabasePath error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:[encryptedDatabasePath stringByAppendingString:@"-shm"] error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:[encryptedDatabasePath stringByAppendingString:@"-wal"] error:nil];
        
        [[NSFileManager defaultManager] removeItemAtPath:encryptedIndexDatabasePath error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:[encryptedIndexDatabasePath stringByAppendingString:@"-shm"] error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:[encryptedIndexDatabasePath stringByAppendingString:@"-wal"] error:nil];
        
        [[NSFileManager defaultManager] removeItemAtPath:[[self documentsPath] stringByAppendingPathComponent:@"x.y"] error:nil];
#endif
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:encryptedDatabasePath])
            _databasePath = encryptedDatabasePath;
        else
            _databasePath = baseDatabasePath;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:encryptedIndexDatabasePath])
            _indexDatabasePath = encryptedIndexDatabasePath;
        else
            _indexDatabasePath = baseIndexDatabasePath;
        
        _serviceLastCleanTimeKey = lastCleanTime_hash;
        _servicePtsKey = pts_hash;
        _serviceLastMidKey = lastMid_hash;
        _serviceContactListStateKey = contactListState_hash;
        _serviceLatestSynchronizedMidKey = latestSynchronizedMid_hash;
        _serviceLatestSynchronizedQtsKey = latestSynchronizedQts_hash;
        _serviceEncryptedConversationCount = serviceEncryptedConversationCount_hash;
        
        _serviceTableName = [NSString stringWithFormat:@"service_v%d", _schemaVersion];
        _usersTableName = [NSString stringWithFormat:@"users_v%d", _schemaVersion];
        _conversationListTableName = [NSString stringWithFormat:@"convesations_v%d", _schemaVersion];
        _broadcastConversationListTableName = [NSString stringWithFormat:@"broadcast_conversations_v%d", _schemaVersion];
        _channelListTableName = [NSString stringWithFormat:@"channel_conversations_v%d", _schemaVersion];
        _channelCachedDataTableName = [NSString stringWithFormat:@"channel_cached_v%d", _schemaVersion];
        _channelMessagesTableName = [NSString stringWithFormat:@"channel_messages_v%d", _schemaVersion];
        _channelMessageTagsTableName = [NSString stringWithFormat:@"channel_message_tags_v%d", _schemaVersion];
        _channelMessagesRandomIdTableName = [NSString stringWithFormat:@"channel_messages_randomid_v%d", _schemaVersion];
        _channelMessageHolesTableName = [NSString stringWithFormat:@"channel_message_holes_v%d", _schemaVersion];
        _channelMessageUnimportantHolesTableName = [NSString stringWithFormat:@"channel_message_unimportant_holes_v%d", _schemaVersion];
        _channelMessageUnimportantGroupsTableName = [NSString stringWithFormat:@"channel_message_unimportant_groups_v%d", _schemaVersion];
        _channelDeleteMessagesTableName = [NSString stringWithFormat:@"channel_delete_messages_v%d", _schemaVersion];
        _channelReadHistoryTableName = [NSString stringWithFormat:@"channel_read_history2_v%d", _schemaVersion];
        _channelLeaveTableName = [NSString stringWithFormat:@"channel_leave_v%d", _schemaVersion];
        _messagesTableName = [NSString stringWithFormat:@"messages_v%d", _schemaVersion];
        _conversationMediaTableName = [NSString stringWithFormat:@"media_v%d", _schemaVersion];
        _contactListTableName = [NSString stringWithFormat:@"contacts_v%d", _schemaVersion];
        _actionQueueTableName = [NSString stringWithFormat:@"actions_v%d", _schemaVersion];
        _peerPropertiesTableName = [NSString stringWithFormat:@"peers_v%d", _schemaVersion];
        _peerProfilePhotosTableName = [NSString stringWithFormat:@"peer_photos_v%d", _schemaVersion];
        _outgoingMessagesTableName = [NSString stringWithFormat:@"outbox_v%d", _schemaVersion];
        _futureActionsTableName = [NSString stringWithFormat:@"future_v%d", _schemaVersion];
        _messageIndexTableName = [NSString stringWithFormat:@"messageIndex_v%d", _schemaVersion];
        
        _assetsTableName = [NSString stringWithFormat:@"assets_v%d", _schemaVersion];
        _videosTableName = [[NSString alloc] initWithFormat:@"files_v%d", _schemaVersion];
        _storedFilesTableName = [[NSString alloc] initWithFormat:@"storedFiles_v%d", _schemaVersion];
        _localFilesTableName = [[NSString alloc] initWithFormat:@"local_files_v%d", _schemaVersion];
        
        _serverAssetsTableName = [[NSString alloc] initWithFormat:@"server_assets_v%d", _schemaVersion];
        
        _blockedUsersTableName = [NSString stringWithFormat:@"blacklist_v%d", _schemaVersion];
        _userLinksTableName = [NSString stringWithFormat:@"links_v%d", _schemaVersion];
        
        _temporaryMessageIdsTableName = [NSString stringWithFormat:@"tempMessages_v%d", _schemaVersion];
        _randomIdsTableName = [[NSString alloc] initWithFormat:@"random_ids_v%d", _schemaVersion];
        _selfDestructTableName = [[NSString alloc] initWithFormat:@"selfdestruct_v%d", _schemaVersion];
        
        _encryptedConversationIdsTableName = [NSString stringWithFormat:@"encrypted_cids_v%d", _schemaVersion];
        
        _secretMediaAttributesTableName = [NSString stringWithFormat:@"secret_media_v%d", _schemaVersion];
        
        _mediaCacheInvalidationTableName = [NSString stringWithFormat:@"media_cache_v%d", _schemaVersion];
        _fileDeletionTableName = [NSString stringWithFormat:@"file_deletion_v%d", _schemaVersion];
        
        _peerHistoryHolesTableName = [NSString stringWithFormat:@"history_holes_%d", _schemaVersion];
        
        _secretPeerIncomingTableName = [NSString stringWithFormat:@"peer_incoming_actions_%d", _schemaVersion];
        _secretPeerIncomingEncryptedTableName = [NSString stringWithFormat:@"peer_incoming_encrypted_actions_%d", _schemaVersion];
        _secretPeerOutgoingTableName = [NSString stringWithFormat:@"peer_outgoing_actions_%d", _schemaVersion];
        _secretPeerOutgoingResendTableName = [NSString stringWithFormat:@"peer_outgoing_actions_resend_%d", _schemaVersion];
        
        _sharedMediaCacheTableName = [NSString stringWithFormat:@"shared_media_index_%d", _schemaVersion];
        _sharedMediaIndexBuiltTableName = [NSString stringWithFormat:@"shared_media_index_built_%d", _schemaVersion];
        _sharedMediaIndexDownloadedTableName = [NSString stringWithFormat:@"shared_media_index_downloaded2_%d", _schemaVersion];
        
        _botInfoTableName = [NSString stringWithFormat:@"botinfo_%d", _schemaVersion];
        
        _multicastManager = [[SMulticastSignalManager alloc] init];
        _channelListPipe = [[SPipe alloc] init];
        _existingChannelPipes = [[NSMutableDictionary alloc] init];
        _cachedChannelDataPipes = [[NSMutableDictionary alloc] init];
        _queuedDeleteChannelMessages = [[SPipe alloc] init];
        _queuedReadChannelMessages = [[SPipe alloc] init];
        _queuedLeaveChannels = [[SPipe alloc] init];
    }
    return self;
}

- (void)explainQuery:(NSString *)query
{
    FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"EXPLAIN QUERY PLAN %@", query]];
    while ([result next])
    {
        TGLog(@"%d %d %d :: %@", [result intForColumnIndex:0], [result intForColumnIndex:1], [result intForColumnIndex:2],
              [result stringForColumnIndex:3]);
    }
}

- (NSString *)documentsPath
{
    return [TGAppDelegate documentsPath];
}

- (NSString *)currentPassword
{
    if (_password == nil)
    {
        NSData *data = [NSData dataWithContentsOfFile:[[self documentsPath] stringByAppendingPathComponent:@"x.y"]];
        if (data.length == 0)
            return @"";
        else
        {
            uint8_t mode = 0;
            [data getBytes:&mode length:1];
            
            if (mode == 0)
                return nil;
            else if (mode == 3 || mode == 4)
            {
                uint32_t passwordLength = 0;
                [data getBytes:&passwordLength range:NSMakeRange(1, 4)];
                NSData *passwordBytes = [data subdataWithRange:NSMakeRange(5, passwordLength)];
                NSString *candidatePassword = [[NSString alloc] initWithData:passwordBytes encoding:NSUTF8StringEncoding];
                return candidatePassword;
            }
        }
        
        return nil;
    }
    else
        return _password;
}

- (void)setPassword:(NSString *)password isStrong:(bool)isStrong completion:(void (^)())completion
{
    [self dispatchOnDatabaseThread:^
    {
        _password = password;
        
        if (_password.length == 0)
        {
            uint8_t mode = 0;
            NSData *passwordData = [NSData dataWithBytes:&mode length:1];
            [passwordData writeToFile:[[self documentsPath] stringByAppendingPathComponent:@"x.y"] atomically:true];
            if ([self isCurrentDatabaseEncrypted])
            {
                [self migrateDatabasePlaintext:^
                {
                    [ActionStageInstance() dispatchResource:@"/databasePasswordChanged" resource:nil];
                    if (completion)
                        completion();
                }];
            }
            else
            {
                [ActionStageInstance() dispatchResource:@"/databasePasswordChanged" resource:nil];
                if (completion)
                    completion();
            }
        }
        else
        {
            NSMutableData *passwordData = [[NSMutableData alloc] init];
            uint8_t mode = 0;
            
            if ([self isEncryptionEnabled])
                mode = isStrong ? 2 : 1;
            else
                mode = isStrong ? 4 : 3;
            
            [passwordData appendBytes:&mode length:1];
            if (![self isEncryptionEnabled])
            {
                NSData *passwordBytes = [_password dataUsingEncoding:NSUTF8StringEncoding];
                uint32_t passwordLength = (uint32_t)passwordBytes.length;
                [passwordData appendBytes:&passwordLength length:4];
                [passwordData appendData:passwordBytes];
            }
            
            if ([self isCurrentDatabaseEncrypted])
                [self rekeyDatabase:[[_password dataUsingEncoding:NSUTF8StringEncoding] stringByEncodingInHex]];
            
            [passwordData writeToFile:[[self documentsPath] stringByAppendingPathComponent:@"x.y"] atomically:true];
            [ActionStageInstance() dispatchResource:@"/databasePasswordChanged" resource:nil];
            if (completion)
                completion();
        }
    } synchronous:false];
}

- (bool)isPasswordSet:(bool *)isStrong
{
    NSData *passwordData = [NSData dataWithContentsOfFile:[[self documentsPath] stringByAppendingPathComponent:@"x.y"]];
    if (passwordData.length == 0)
        return false;
    
    uint8_t mode = 0;
    [passwordData getBytes:&mode length:1];
    if (isStrong)
        *isStrong = (mode == 2 || mode == 4);
    
    return mode != 0;
}

- (bool)table:(NSString *)table containsField:(NSString *)field
{
    FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"PRAGMA table_info(%@)", table]];
    while ([result next])
    {
        if ([[result stringForColumnIndex:1] isEqualToString:field])
            return true;
    }
    
    return false;
}

- (void)upgradeTables
{
    TGDatabaseUpgradeCompletedBlock completion = nil;
    
    for (int i = _schemaVersion - 2; i < _schemaVersion + 2; i++)
    {
        if (i != _schemaVersion)
        {
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [NSString stringWithFormat:@"service_v%d", i]]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [NSString stringWithFormat:@"users_v%d", i]]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [NSString stringWithFormat:@"convesations_v%d", i]]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [NSString stringWithFormat:@"broadcast_conversations_v%d", i]]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [NSString stringWithFormat:@"messages_v%d", i]]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [NSString stringWithFormat:@"media_v%d", i]]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [NSString stringWithFormat:@"cstates_v%d", i]]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [NSString stringWithFormat:@"contacts_v%d", i]]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [NSString stringWithFormat:@"actions_v%d", i]]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [NSString stringWithFormat:@"peers_v%d", i]]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [NSString stringWithFormat:@"peer_photos_v%d", i]]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [NSString stringWithFormat:@"outbox_v%d", i]]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [NSString stringWithFormat:@"future_v%d", i]]];
            
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [NSString stringWithFormat:@"assets_v%d", i]]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [NSString stringWithFormat:@"files_v%d", i]]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [NSString stringWithFormat:@"local_files_v%d", i]]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [NSString stringWithFormat:@"storedFiles_v%d", i]]];
            
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [NSString stringWithFormat:@"server_assets_v%d", i]]];
            
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [NSString stringWithFormat:@"blacklist_v%d", i]]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [NSString stringWithFormat:@"links_v%d", i]]];
            
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [NSString stringWithFormat:@"tempMessages_v%d", i]]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [NSString stringWithFormat:@"random_ids_v%d", i]]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [NSString stringWithFormat:@"selfdestruct_v%d", i]]];
            
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [NSString stringWithFormat:@"encrypted_cids_%d", i]]];
            
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [NSString stringWithFormat:@"secret_media_%d", i]]];
            
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [NSString stringWithFormat:@"history_holes_%d", i]]];
            
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [NSString stringWithFormat:@"media_cache_v%d", i]]];
            
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [NSString stringWithFormat:@"peer_incoming_actions_%d", i]]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [NSString stringWithFormat:@"peer_outgoing_actions_%d", i]]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [NSString stringWithFormat:@"peer_outgoing_actions_resend_%d", i]]];
            
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [NSString stringWithFormat:@"shared_media_%d", i]]];
            
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [NSString stringWithFormat:@"botinfo_%d", i]]];
        }
    }
    
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (key INTEGER PRIMARY KEY, value BLOB)", _serviceTableName]];
    
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (uid INTEGER PRIMARY KEY, first_name TEXT, last_name TEXT, local_first_name TEXT, local_last_name TEXT, phone_number TEXT, access_hash INTEGER, sex INTEGER, photo_small TEXT, photo_medium TEXT, photo_big TEXT, last_seen INTEGER, username STRING, data BLOB)", _usersTableName]];
    
    FMResultSet *usersHaveUsernameResult = [_database executeQuery:[[NSString alloc] initWithFormat:@"PRAGMA table_info(%@)", _usersTableName]];
    bool usersHaveUsername = false;
    bool usersHaveData = false;
    while ([usersHaveUsernameResult next])
    {
        if ([[usersHaveUsernameResult stringForColumn:@"name"] isEqualToString:@"username"])
            usersHaveUsername = true;
        else if ([[usersHaveUsernameResult stringForColumn:@"name"] isEqualToString:@"data"])
            usersHaveData = true;
    }
    if (!usersHaveUsername)
    {
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"ALTER TABLE %@ ADD COLUMN username STRING", _usersTableName]];
    }
    if (!usersHaveData)
    {
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"ALTER TABLE %@ ADD COLUMN data BLOB", _usersTableName]];
    }
    
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (cid INTEGER PRIMARY KEY, date INTEGER, from_uid INTEGER, message TEXT, media BLOB, unread_count INTEGER, flags INTEGER, chat_title TEXT, chat_photo BLOB, participants BLOB, participants_count INTEGER, chat_version INTEGER, service_unread INTEGER)", _conversationListTableName]];
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS date ON %@ (date DESC)", _conversationListTableName]];
    
    FMResultSet *serviceUnreadResult = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT service_unread FROM %@ LIMIT 1", _conversationListTableName]];
    if (![serviceUnreadResult next])
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"ALTER TABLE %@ ADD COLUMN service_unread INTEGER", _conversationListTableName]];
    
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (cid INTEGER PRIMARY KEY, date INTEGER, from_uid INTEGER, message TEXT, media BLOB, unread_count INTEGER, flags INTEGER, chat_title TEXT, chat_photo BLOB, participants BLOB, participants_count INTEGER, chat_version INTEGER, service_unread INTEGER)", _broadcastConversationListTableName]];
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS broadcast_conversations_date ON %@ (date DESC)", _broadcastConversationListTableName]];
    
    int32_t expectedChannelSchemaVersion = 2;
    
    NSData *dataChannelSchemaVersion = [self customProperty:@"channelSchemaVersion"];
    int32_t channelSchemaVersion = 0;
    if (dataChannelSchemaVersion.length >= 4) {
        [dataChannelSchemaVersion getBytes:&channelSchemaVersion length:4];
    }
    
    if (channelSchemaVersion != expectedChannelSchemaVersion) {
        int32_t randomId = 0;
        arc4random_buf(&randomId, 4);
        randomId = ABS(randomId);
        [self setCustomProperty:@"channelSchemaVersion" value:[NSData dataWithBytes:&expectedChannelSchemaVersion length:4]];
        [self setCustomProperty:@"channelListSynchronized" value:[NSData data]];

        [_database executeUpdate:[NSString stringWithFormat:@"ALTER TABLE %@ RENAME TO %@_%x", _channelListTableName, _channelListTableName, randomId]];
        [_database executeUpdate:[NSString stringWithFormat:@"ALTER TABLE %@ RENAME TO %@_%x", _channelCachedDataTableName, _channelCachedDataTableName, randomId]];
        [_database executeUpdate:[NSString stringWithFormat:@"ALTER TABLE %@ RENAME TO %@_%x", _channelMessagesRandomIdTableName, _channelMessagesRandomIdTableName, randomId]];
        [_database executeUpdate:[NSString stringWithFormat:@"ALTER TABLE %@ RENAME TO %@_%x", _channelMessagesTableName, _channelMessagesTableName, randomId]];
        [_database executeUpdate:[NSString stringWithFormat:@"ALTER TABLE %@ RENAME TO %@_%x", _channelMessageTagsTableName, _channelMessageTagsTableName, randomId]];
        [_database executeUpdate:[NSString stringWithFormat:@"ALTER TABLE %@ RENAME TO %@_%x", _channelMessageHolesTableName, _channelMessageHolesTableName, randomId]];
        [_database executeUpdate:[NSString stringWithFormat:@"ALTER TABLE %@ RENAME TO %@_%x", _channelMessageUnimportantHolesTableName, _channelMessageUnimportantHolesTableName, randomId]];
        [_database executeUpdate:[NSString stringWithFormat:@"ALTER TABLE %@ RENAME TO %@_%x", _channelMessageUnimportantGroupsTableName, _channelMessageUnimportantGroupsTableName, randomId]];
        [_database executeUpdate:[NSString stringWithFormat:@"ALTER TABLE %@ RENAME TO %@_%x", _channelDeleteMessagesTableName, _channelDeleteMessagesTableName, randomId]];
        [_database executeUpdate:[NSString stringWithFormat:@"ALTER TABLE %@ RENAME TO %@_%x", _channelReadHistoryTableName, _channelReadHistoryTableName, randomId]];
        [_database executeUpdate:[NSString stringWithFormat:@"ALTER TABLE %@ RENAME TO %@_%x", _channelLeaveTableName, _channelLeaveTableName, randomId]];
    }
    
#ifdef DEBUG
    if (false) {
        [self setCustomProperty:@"channelListSynchronized" value:[NSData data]];
        [_database executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@", _channelListTableName]];
        [_database executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@", _channelCachedDataTableName]];
        [_database executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@", _channelMessagesRandomIdTableName]];
        [_database executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@", _channelMessagesTableName]];
        [_database executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@", _channelMessageTagsTableName]];
        [_database executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@", _channelMessageHolesTableName]];
        [_database executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@", _channelMessageUnimportantHolesTableName]];
        [_database executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@", _channelMessageUnimportantGroupsTableName]];
        [_database executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@", _channelDeleteMessagesTableName]];
        [_database executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@", _channelReadHistoryTableName]];
        [_database executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@", _channelLeaveTableName]];
    }
#endif
    
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (cid INTEGER PRIMARY KEY, variant_sort_key BLOB, data BLOB)", _channelListTableName]];
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS channel_conversations_variant_sort ON %@ (variant_sort_key)", _channelListTableName]];

    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (cid INTEGER PRIMARY KEY, data BLOB)", _channelCachedDataTableName]];
    
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (cid INTEGER, mid INTEGER, sort_key BLOB, data BLOB, transparent_sort_key BLOB, PRIMARY KEY(cid, mid))", _channelMessagesTableName]];
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS channel_messagessort_key ON %@ (sort_key)", _channelMessagesTableName]];
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS channel_messagestransparent_sort_key ON %@ (transparent_sort_key)", _channelMessagesTableName]];
    
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (cid INTEGER, mid INTEGER, tag INTEGER, tag_sort_key BLOB, PRIMARY KEY(cid, mid, tag))", _channelMessageTagsTableName]];
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS %@_tag_sort_key ON %@ (tag_sort_key)", _channelMessageTagsTableName, _channelMessageTagsTableName]];
    
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (cid INTEGER, mid INTEGER, random_id INTEGER, PRIMARY KEY(cid, mid))", _channelMessagesRandomIdTableName]];
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS channel_messages_random_id_random_id ON %@ (random_id)", _channelMessagesRandomIdTableName]];
    
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (cid INTEGER, max_id INTEGER, max_timestamp, min_id INTEGER, min_timestamp INTEGER, max_sort_key BLOB, PRIMARY KEY(cid, max_id))", _channelMessageHolesTableName]];
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS %@_max_sort_key ON %@ (max_sort_key)", _channelMessageHolesTableName, _channelMessageHolesTableName]];
    
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (cid INTEGER, max_id INTEGER, max_timestamp, min_id INTEGER, min_timestamp INTEGER, max_sort_key BLOB, PRIMARY KEY(cid, max_id))", _channelMessageUnimportantHolesTableName]];
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS %@_max_sort_key ON %@ (max_sort_key)", _channelMessageUnimportantHolesTableName, _channelMessageUnimportantHolesTableName]];
    
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (cid INTEGER, max_id INTEGER, max_timestamp, min_id INTEGER, min_timestamp INTEGER, max_sort_key BLOB, count INTEGER, PRIMARY KEY(cid, max_id))", _channelMessageUnimportantGroupsTableName]];
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS %@_max_sort_key ON %@ (max_sort_key)", _channelMessageUnimportantGroupsTableName, _channelMessageUnimportantGroupsTableName]];

    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (cid INTEGER, mid INTEGER, access_hash INTEGER, PRIMARY KEY(cid, mid))", _channelDeleteMessagesTableName]];
    
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (cid INTEGER PRIMARY KEY, mid INTEGER)", _channelReadHistoryTableName]];
    
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (cid INTEGER PRIMARY KEY, access_hash INTEGER)", _channelLeaveTableName]];
    
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (mid INTEGER PRIMARY KEY, cid INTEGER, localMid INTEGER, message TEXT, media BLOB, from_id INTEGER, to_id INTEGER, outgoing INTEGER, unread INTEGER, dstate INTEGER, date INTEGER, flags INTEGER, seq_in INTEGER, seq_out INTEGER)", _messagesTableName]];
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS cid ON %@ (cid)", _messagesTableName]];
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS cid_date ON %@ (cid, date)", _messagesTableName]];
    
    if (![self table:_messagesTableName containsField:@"flags"])
    {
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"ALTER TABLE %@ ADD COLUMN flags INTEGER", _messagesTableName]];
    }
    
    if (![self table:_messagesTableName containsField:@"content_properties"])
    {
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"ALTER TABLE %@ ADD COLUMN content_properties BLOB", _messagesTableName]];
    }
    
    if ([self customProperty:@"hasPartialIndexOnUnread"].length == 0)
    {
        TGLog(@"===== Upgrading database (unread partial index)");
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT mid, cid, outgoing FROM %@ WHERE unread!=0 AND unread IS NOT NULL", _messagesTableName]];
        int cidIndex = [result columnIndexForName:@"cid"];
        int midIndex = [result columnIndexForName:@"mid"];
        int outgoingIndex = [result columnIndexForName:@"outgoing"];
        
        int messageCount = 0;
        
        std::map<int64_t, std::vector<std::pair<int32_t, bool> > > cidAndMids;
        while ([result next])
        {
            int64_t cid = [result longLongIntForColumnIndex:cidIndex];
            int32_t mid = [result intForColumnIndex:midIndex];
            bool outgoing = [result intForColumnIndex:outgoingIndex];
            
            cidAndMids[cid].push_back(std::pair<int32_t, bool>(mid, outgoing));
            messageCount++;
        }
        result = nil;
        
        [_database setSoftShouldCacheStatements:false];
        for (int pass = 0; pass < 2; pass++)
        {
            for (auto cidIt = cidAndMids.begin(); cidIt != cidAndMids.end(); cidIt++)
            {
                NSMutableString *midsString = [[NSMutableString alloc] init];
                
                int count = (int)cidIt->second.size();
                for (int j = 0; j < count; )
                {
                    [midsString deleteCharactersInRange:NSMakeRange(0, midsString.length)];
                    
                    for (int i = 0; i < 256 && j < count; i++, j++)
                    {
                        if (pass == 0)
                        {
                            if (cidIt->second[j].second)
                                continue;
                        }
                        else
                        {
                            if (!cidIt->second[j].second)
                                continue;
                        }
                        if (midsString.length != 0)
                            [midsString appendString:@","];
                        [midsString appendFormat:@"%d", cidIt->second[j].first];
                    }
                    
                    [_database executeUpdate:[[NSString alloc] initWithFormat:@"UPDATE %@ SET unread=%lld WHERE mid IN (%@)", _messagesTableName, pass == 0 ? cidIt->first : (int64_t)INT_MAX, midsString]];
                }
            }
        }
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"UPDATE %@ SET unread=NULL WHERE unread=0", _messagesTableName]];
        [_database setSoftShouldCacheStatements:true];
        
        TGLog(@"===== Done (%d messages)", messageCount);
        
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"CREATE INDEX unread_by_cid_with_date ON %@(unread, date ASC) WHERE unread IS NOT NULL", _messagesTableName]];
        
        uint8_t one = 1;
        [self setCustomProperty:@"hasPartialIndexOnUnread" value:[NSData dataWithBytes:&one length:1]];
    }
    
    if ([self customProperty:@"hasPartialIndexOnIncomingOutgoingUnread"].length == 0)
    {
        if (completion == nil && upgradeCompletedBlock)
            completion = [upgradeCompletedBlock() copy];
        
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"CREATE INDEX unread_by_cid_with_mid ON %@(cid, outgoing) WHERE unread IS NOT NULL", _messagesTableName]];
        
        uint8_t one = 1;
        [self setCustomProperty:@"hasPartialIndexOnIncomingOutgoingUnread" value:[NSData dataWithBytes:&one length:1]];
    }
    
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (uid INTEGER PRIMARY KEY)", _contactListTableName]];
    
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (action_type INTEGER, action_subject INTEGER, arg0 INTEGER, arg1 INTEGER, PRIMARY KEY(action_type, action_subject))", _actionQueueTableName]];
    
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (mid INTEGER PRIMARY KEY, cid INTEGER, date INTEGER, from_id INTEGER, type INTEGER, media BLOB)", _conversationMediaTableName]];
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS cid_date_idx ON %@ (cid, date DESC)", _conversationMediaTableName]];
    
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (pid INTEGER PRIMARY KEY, last_mid INTEGER, last_media INTEGER, notification_type INTEGER, mute INTEGER, preview_text INTEGER, custom_properties BLOB)", _peerPropertiesTableName]];
    
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (photo_id INTEGER PRIMARY KEY, peer_id INTEGER, date INTEGER, data BLOB)", _peerProfilePhotosTableName]];
    
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (mid INTEGER PRIMARY KEY, cid INTEGER, dstate INTEGER, local_media_id INTEGER)", _outgoingMessagesTableName]];
    
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER, type INTEGER, data BLOB, random_id INTEGER, sort_key INTEGER AUTO_INCREMENT, PRIMARY KEY(id, type))", _futureActionsTableName]];
    
    FMResultSet *futureActionsHasSortingKeyResult = [_database executeQuery:[[NSString alloc] initWithFormat:@"PRAGMA table_info(%@)", _futureActionsTableName]];
    bool futureActionsHasSortingKey = false;
    while ([futureActionsHasSortingKeyResult next])
    {
        if ([[futureActionsHasSortingKeyResult stringForColumn:@"name"] isEqualToString:@"sort_key"])
        {
            futureActionsHasSortingKey = true;
            break;
        }
    }
    if (!futureActionsHasSortingKey)
    {
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT * FROM %@ ORDER BY insert_date ASC", _futureActionsTableName]];
        
        NSMutableArray *actions = [[NSMutableArray alloc] init];
        while ([result next])
        {
            id action = loadFutureActionFromQueryResult(result);
            if (action != nil)
                [actions addObject:action];
        }
        result = nil;
        
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"ALTER TABLE %@ RENAME TO %@_old", _futureActionsTableName, _futureActionsTableName]];
        
        [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE %@ (id INTEGER, type INTEGER, data BLOB, random_id INTEGER, sort_key INTEGER AUTO_INCREMENT, PRIMARY KEY(id, type))", _futureActionsTableName]];
        
        [self storeFutureActions:actions];
    }
    
    FMResultSet *messagesHaveSeqInOutResult = [_database executeQuery:[[NSString alloc] initWithFormat:@"PRAGMA table_info(%@)", _messagesTableName]];
    bool messagesHaveSeqInOut = false;
    while ([messagesHaveSeqInOutResult next])
    {
        if ([[messagesHaveSeqInOutResult stringForColumn:@"name"] isEqualToString:@"seq_in"])
        {
            messagesHaveSeqInOut = true;
            break;
        }
    }
    if (!messagesHaveSeqInOut)
    {
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"ALTER TABLE %@ ADD COLUMN seq_in INTEGER", _messagesTableName]];
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"ALTER TABLE %@ ADD COLUMN seq_out INTEGER", _messagesTableName]];
    }
    
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (hash_high INTEGER, hash_low INTEGER, PRIMARY KEY(hash_high, hash_low))", _assetsTableName]];
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (vid INTEGER PRIMARY KEY, mids BLOB)", _videosTableName]];
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (vid INTEGER PRIMARY KEY, mids BLOB, remote_data BLOB)", _localFilesTableName]];

    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (type INTEGER, file_id INTEGER, mids BLOB, PRIMARY KEY(type, file_id))", _storedFilesTableName]];
    
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (hash_high INTEGER, hash_low INTEGER, data BLOB, PRIMARY KEY(hash_high, hash_low))", _serverAssetsTableName]];
    
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (pid INTEGER, date INTEGER)", _blockedUsersTableName]];
    
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (pid INTEGER PRIMARY KEY, link INTEGER)", _userLinksTableName]];
    
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (tmp_id INTEGER PRIMARY KEY, mid INTEGER)", _temporaryMessageIdsTableName]];
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (random_id INTEGER PRIMARY KEY, mid INTEGER)", _randomIdsTableName]];
    
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (mid INTEGER PRIMARY KEY, date INTEGER)", _selfDestructTableName]];
    [_database executeUpdate:[[NSString alloc] initWithFormat:@"CREATE INDEX IF NOT EXISTS selfdestruct_date ON %@ (date)", _selfDestructTableName]];
    
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (encrypted_id INTEGER PRIMARY KEY, cid INTEGER)", _encryptedConversationIdsTableName]];
    
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (mid INTEGER PRIMARY KEY, flags INTEGER)", _secretMediaAttributesTableName]];
    
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (date INTEGER, media_type INTEGER, media_id INTEGER, mids BLOB, PRIMARY KEY(media_type, media_id))", _mediaCacheInvalidationTableName]];
    [_database executeUpdate:[[NSString alloc] initWithFormat:@"CREATE INDEX IF NOT EXISTS media_cache_invalidation_date ON %@ (date)", _mediaCacheInvalidationTableName]];
    
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (hash0 INTEGER, hash1 INTEGER, path STRING, PRIMARY KEY(hash0, hash1))", _fileDeletionTableName]];
    
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (peer_id INTEGER PRIMARY KEY, holes BLOB)", _peerHistoryHolesTableName]];
    
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (action_id INTEGER PRIMARY KEY AUTOINCREMENT, peer_id INTEGER, seq_in INTEGER, seq_out INTEGER, data BLOB)", _secretPeerIncomingTableName]];
    [_database executeUpdate:[[NSString alloc] initWithFormat:@"CREATE INDEX IF NOT EXISTS %@_peer_id_action_id ON %@ (peer_id, action_id)", _secretPeerIncomingTableName, _secretPeerIncomingTableName]];

    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (action_id INTEGER PRIMARY KEY AUTOINCREMENT, peer_id INTEGER, data BLOB)", _secretPeerIncomingEncryptedTableName]];
    
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (action_id INTEGER PRIMARY KEY AUTOINCREMENT, peer_id INTEGER, seq_out INTEGER, seq_in INTEGER, data BLOB)", _secretPeerOutgoingTableName]];
    [_database executeUpdate:[[NSString alloc] initWithFormat:@"CREATE INDEX IF NOT EXISTS %@_peer_id_action_id ON %@ (peer_id, action_id)", _secretPeerOutgoingTableName, _secretPeerOutgoingTableName]];
    [_database executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (action_id INTEGER PRIMARY KEY AUTOINCREMENT, peer_id INTEGER, seq_out INTEGER, seq_in INTEGER, data BLOB)", _secretPeerOutgoingResendTableName]];
    [_database executeUpdate:[[NSString alloc] initWithFormat:@"CREATE INDEX IF NOT EXISTS %@_peer_id ON %@ (peer_id)", _secretPeerOutgoingResendTableName, _secretPeerOutgoingResendTableName]];
    
    [_database executeUpdate:[[NSString alloc] initWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (peer_id INTEGER, date INTEGER, type INTEGER, message_id INTEGER, message BLOB, PRIMARY KEY (peer_id, message_id, type))", _sharedMediaCacheTableName]];
    [_database executeUpdate:[[NSString alloc] initWithFormat:@"CREATE INDEX IF NOT EXISTS %@_peer_id_type_date ON %@ (peer_id, type, date)", _sharedMediaCacheTableName, _sharedMediaCacheTableName]];
    [_database executeUpdate:[[NSString alloc] initWithFormat:@"CREATE INDEX IF NOT EXISTS %@_peer_id_message_id ON %@ (peer_id, message_id)", _sharedMediaCacheTableName, _sharedMediaCacheTableName]];
    
    CFAbsoluteTime createMidIndexTime = CFAbsoluteTimeGetCurrent();
    [_database executeUpdate:[[NSString alloc] initWithFormat:@"CREATE INDEX IF NOT EXISTS %@_message_id ON %@ (message_id)", _sharedMediaCacheTableName, _sharedMediaCacheTableName]];
    TGLog(@"create index on media by message id: %f s", CFAbsoluteTimeGetCurrent() - createMidIndexTime);
    
    [_database executeUpdate:[[NSString alloc] initWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (peer_id INTEGER PRIMARY KEY, cache_built INTEGER)", _sharedMediaIndexBuiltTableName]];
    [_database executeUpdate:[[NSString alloc] initWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (peer_id INTEGER, type INTEGER, index_downloaded INTEGER, PRIMARY KEY (peer_id, type))", _sharedMediaIndexDownloadedTableName]];
    
    [_database executeUpdate:[[NSString alloc] initWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (user_id INTEGER PRIMARY KEY, data BLOB)", _botInfoTableName]];
    
    if (completion)
        completion();
    
//#if !TARGET_IPHONE_SIMULATOR
    if ([self customProperty:@"backgroundMediaIndexingCompleted"].length == 0)
//#endif
    {
        [self _beginBackgroundIndexing];
    }
    
    [self dispatchOnIndexThread:^
    {
        for (int i = _schemaVersion - 2; i < _schemaVersion + 2; i++)
        {
            if (i != _schemaVersion)
            {
                [_indexDatabase executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [NSString stringWithFormat:@"messageIndex_v%d", i]]];
            }
        }
        
        [_indexDatabase executeUpdate:[NSString stringWithFormat:@"CREATE VIRTUAL TABLE IF NOT EXISTS %@ USING fts4(text TEXT, matchinfo=fts3)", _messageIndexTableName]];
    } synchronous:false];
}

- (bool)isCurrentDatabaseEncrypted
{
    return [_databasePath hasSuffix:@".y"];
}

- (bool)isCurrentIndexDatabaseEncrypted
{
    return [_indexDatabasePath hasSuffix:@".y"];
}

- (NSString *)databasePath
{
    return _databasePath;
}

- (NSString *)indexDatabasePath
{
    return _indexDatabasePath;
}

- (bool)verifyPassword:(NSString *)password
{
    NSData *passwordData = [NSData dataWithContentsOfFile:[[self documentsPath] stringByAppendingPathComponent:@"x.y"]];
    if (passwordData.length != 0)
    {
        uint8_t mode = 0;
        [passwordData getBytes:&mode length:1];
        if (mode == 3 || mode == 4)
        {
            uint32_t passwordLength = 0;
            [passwordData getBytes:&passwordLength range:NSMakeRange(1, 4)];
            NSData *passwordBytes = [passwordData subdataWithRange:NSMakeRange(5, passwordLength)];
            NSString *plaintextPassword = [[NSString alloc] initWithData:passwordBytes encoding:NSUTF8StringEncoding];
            if ([plaintextPassword isEqualToString:password])
                return true;
        }
    }
    
    return [_password isEqualToString:password];
}

- (bool)checkPassword:(NSString *)password isLegacy:(bool *)isLegacy
{
    NSData *data = [password dataUsingEncoding:NSUTF8StringEncoding];
    NSString *hexKey = [data stringByEncodingInHex];

    for (int i = 0; i < 2; i++)
    {
        FMDatabase *database = [FMDatabase databaseWithPath:self.databasePath];
        [database open];
        database.logsErrors = true;
        NSString *keyString = nil;
        if (i == 0)
            keyString = [[NSString alloc] initWithFormat:@"PRAGMA key=\"%@\"", hexKey];
        else
            keyString = [[NSString alloc] initWithFormat:@"PRAGMA key=\"x'%@\"", hexKey];
        sqlite3_exec([database sqliteHandle], keyString.UTF8String, NULL, NULL, NULL);
        FMResultSet *result = [database executeQuery:@"SELECT count(*) FROM sqlite_master;"];
        bool success = [result next];
        [database close];
        if (success)
        {
            if (i == 1 && isLegacy)
                *isLegacy = true;
            return true;
        }
    }
    
    return false;
}

- (bool)checkIndexPassword:(NSString *)password isLegacy:(bool *)isLegacy
{
    NSData *data = [password dataUsingEncoding:NSUTF8StringEncoding];
    NSString *hexKey = [data stringByEncodingInHex];
    
    for (int i = 0; i < 2; i++)
    {
        FMDatabase *database = [FMDatabase databaseWithPath:self.indexDatabasePath];
        [database open];
        database.logsErrors = true;
        NSString *keyString = nil;
        if (i == 0)
            keyString = [[NSString alloc] initWithFormat:@"PRAGMA key=\"%@\"", hexKey];
        else
            keyString = [[NSString alloc] initWithFormat:@"PRAGMA key=\"x'%@\"", hexKey];
        sqlite3_exec([database sqliteHandle], keyString.UTF8String, NULL, NULL, NULL);
        FMResultSet *result = [database executeQuery:@"SELECT count(*) FROM sqlite_master;"];
        bool success = [result next];
        [database close];
        if (success)
        {
            if (i == 1 && isLegacy)
                *isLegacy = true;
            return true;
        }
    }
    
    return false;
}

- (void)setEncryptionEnabled:(bool)encryptionEnabled completion:(void (^)())completion
{
    NSData *passwordData = [NSData dataWithContentsOfFile:[[self documentsPath] stringByAppendingPathComponent:@"x.y"]];
    if (passwordData.length != 0)
    {
        uint8_t mode = 0;
        [passwordData getBytes:&mode length:1];
        if (mode == 3 || mode == 4)
        {
            uint32_t passwordLength = 0;
            [passwordData getBytes:&passwordLength range:NSMakeRange(1, 4)];
            NSData *passwordBytes = [passwordData subdataWithRange:NSMakeRange(5, passwordLength)];
            _password = [[NSString alloc] initWithData:passwordBytes encoding:NSUTF8StringEncoding];
        }
        
        if (encryptionEnabled)
        {
            if (_password.length != 0)
            {
                NSMutableData *updatedPasswordData = [[NSMutableData alloc] init];
                uint8_t updatedMode = mode;
                if (mode == 3)
                    updatedMode = 1;
                else if (mode == 4)
                    updatedMode = 2;
                [updatedPasswordData appendBytes:&updatedMode length:1];
                
                if (![self isCurrentDatabaseEncrypted])
                {
                    [self migrateDatabaseEncrypted:^
                    {
                        [updatedPasswordData writeToFile:[[self documentsPath] stringByAppendingPathComponent:@"x.y"] atomically:true];
                        if (completion)
                            completion();
                    }];
                }
                else
                {
                    [updatedPasswordData writeToFile:[[self documentsPath] stringByAppendingPathComponent:@"x.y"] atomically:true];
                    if (completion)
                        completion();
                }
            }
            else
            {
                if (completion)
                    completion();
            }
        }
        else
        {
            if (_password.length != 0)
            {
                NSMutableData *updatedPasswordData = [[NSMutableData alloc] init];
                uint8_t updatedMode = mode;
                if (mode == 1)
                    updatedMode = 3;
                else if (mode == 2)
                    updatedMode = 4;
                [updatedPasswordData appendBytes:&updatedMode length:1];
                NSData *passwordBytes = [_password dataUsingEncoding:NSUTF8StringEncoding];
                uint32_t passwordLength = (uint32_t)passwordBytes.length;
                [updatedPasswordData appendBytes:&passwordLength length:4];
                [updatedPasswordData appendData:passwordBytes];
                
                if ([self isCurrentDatabaseEncrypted])
                {
                    [self migrateDatabasePlaintext:^
                    {
                        [updatedPasswordData writeToFile:[[self documentsPath] stringByAppendingPathComponent:@"x.y"] atomically:true];
                        if (completion)
                            completion();
                    }];
                }
                else
                {
                    [updatedPasswordData writeToFile:[[self documentsPath] stringByAppendingPathComponent:@"x.y"] atomically:true];
                    if (completion)
                        completion();
                }
            }
            else
            {
                if (completion)
                    completion();
            }
        }
    }
    else
    {
        if (completion)
            completion();
    }
}

- (bool)isEncryptionEnabled
{
    NSData *passwordData = [NSData dataWithContentsOfFile:[[self documentsPath] stringByAppendingPathComponent:@"x.y"]];
    if (passwordData.length != 0)
    {
        uint8_t mode = 0;
        [passwordData getBytes:&mode length:1];
        if (mode == 1 || mode == 2)
            return true;
    }
    return false;
}

- (NSString *)_hexKey:(bool *)isLegacy
{
    if (_password != nil)
    {
        NSData *data = [_password dataUsingEncoding:NSUTF8StringEncoding];
        return [data stringByEncodingInHex];
    }
    else
    {
        NSData *data = [NSData dataWithContentsOfFile:[[self documentsPath] stringByAppendingPathComponent:@"x.y"]];
        if (data.length == 0)
            return @"";
        else
        {
            uint8_t mode = 0;
            [data getBytes:&mode length:1];
            
            if (mode == 0)
                return @"";
            else if (mode == 3 || mode == 4)
            {
                uint32_t passwordLength = 0;
                [data getBytes:&passwordLength range:NSMakeRange(1, 4)];
                NSData *passwordBytes = [data subdataWithRange:NSMakeRange(5, passwordLength)];
                NSString *candidatePassword = [[NSString alloc] initWithData:passwordBytes encoding:NSUTF8StringEncoding];
                if ([self checkPassword:candidatePassword isLegacy:isLegacy])
                {
                    _password = candidatePassword;
                    return [passwordBytes stringByEncodingInHex];
                }
            }
            
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            while (_password == nil)
            {
                TGDatabasePasswordCheckResultBlock resultCheckBlock = [passwordRequiredBlock(^(NSString *password)
                {
                    if ([self checkPassword:password isLegacy:isLegacy])
                        _password = password;
                    dispatch_semaphore_signal(semaphore);
                }, mode == 1) copy];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                
                if (resultCheckBlock)
                    resultCheckBlock(_password != nil);
            }
            
            data = [_password dataUsingEncoding:NSUTF8StringEncoding];
            return [data stringByEncodingInHex];
        }
    }
}

- (NSArray *)backedUpDatabasePaths
{
    NSString *baseDatabasePath = [[self documentsPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db", (databaseName == nil ? @"tgdata" : databaseName)]];
    
    NSMutableArray *paths = [[NSMutableArray alloc] init];
    
    int maxCount = 50;
    for (int i = 0; i <= maxCount; i++)
    {
        NSString *fromPath = [baseDatabasePath stringByAppendingFormat:@".%d", i];
        NSString *fromJournalPath = [baseDatabasePath stringByAppendingFormat:@"-journal.%d", i];
        if ([[NSFileManager defaultManager] fileExistsAtPath:fromPath])
            [paths addObject:fromPath];
        if ([[NSFileManager defaultManager] fileExistsAtPath:fromJournalPath])
            [paths addObject:fromJournalPath];
        
    }
    
    return paths;
}

- (void)_reopenDatabase
{
#if defined(DEBUG) || defined(INTERNAL_RELEASE)
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        NSString *baseDatabasePath = [[self documentsPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db", (databaseName == nil ? @"tgdata" : databaseName)]];
        int maxCount = 50;
        for (int i = maxCount; i >= 0; i--)
        {
            NSString *fromPath = [baseDatabasePath stringByAppendingFormat:@".%d", i];
            NSString *fromJournalPath = [baseDatabasePath stringByAppendingFormat:@"-journal.%d", i];
            if (true || i == maxCount)
            {
                [[NSFileManager defaultManager] removeItemAtPath:fromPath error:nil];
                [[NSFileManager defaultManager] removeItemAtPath:fromJournalPath error:nil];
            }
            else
            {
                NSString *toPath = [baseDatabasePath stringByAppendingFormat:@".%d", i + 1];
                NSString *toJournalPath = [baseDatabasePath stringByAppendingFormat:@"-journal.%d", i + 1];
                [[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:nil];
                [[NSFileManager defaultManager] moveItemAtPath:fromJournalPath toPath:toJournalPath error:nil];
            }
        }
        
        /*NSString *toPath = [baseDatabasePath stringByAppendingFormat:@".%d", 0];
        NSString *toJournalPath = [baseDatabasePath stringByAppendingFormat:@"-journal.%d", 0];
        [[NSFileManager defaultManager] copyItemAtPath:baseDatabasePath toPath:toPath error:nil];
        [[NSFileManager defaultManager] copyItemAtPath:[baseDatabasePath stringByAppendingString:@"-journal"] toPath:toJournalPath error:nil];*/
    });
#endif
    
    _database = [FMDatabase databaseWithPath:self.databasePath];
    
    if (![_database open])
    {
        TGLog(@"***** Error: couldn't open database! *****");
        [[[NSFileManager alloc] init] removeItemAtPath:self.databasePath error:nil];
        
        [self initDatabase];
        
        return;
    }
    
    [[NSURL fileURLWithPath:self.databasePath] setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:nil];
    
    [_database setShouldCacheStatements:true];
    [_database setLogsErrors:true];
    
    if ([self isCurrentDatabaseEncrypted])
    {
        bool isLegacy = false;
        NSString *hexKey = [self _hexKey:&isLegacy];
        if (isLegacy)
        {
            sqlite3_exec([_database sqliteHandle], [[NSString alloc] initWithFormat:@"PRAGMA key=\"x'%@\"", hexKey].UTF8String, NULL, NULL, NULL);
        }
        else
        {
            sqlite3_exec([_database sqliteHandle], [[NSString alloc] initWithFormat:@"PRAGMA key=\"%@\"", hexKey].UTF8String, NULL, NULL, NULL);
        }
    }
    
    sqlite3_exec([_database sqliteHandle], "PRAGMA encoding=\"UTF-8\"", NULL, NULL, NULL);
    sqlite3_exec([_database sqliteHandle], "PRAGMA synchronous=NORMAL", NULL, NULL, NULL);
    sqlite3_exec([_database sqliteHandle], "PRAGMA journal_mode=TRUNCATE", NULL, NULL, NULL);
    
    FMResultSet *result = [_database executeQuery:@"PRAGMA journal_mode"];
    if ([result next])
    {
        TGLog(@"journal_mode = %@", [result stringForColumnIndex:0]);
    }
}

- (void)_reopenIndexDatabase
{
    _indexDatabase = [FMDatabase databaseWithPath:self.indexDatabasePath];
    if (![_indexDatabase open])
    {
        TGLog(@"***** Error: couldn't open index database! *****");
        [[[NSFileManager alloc] init] removeItemAtPath:self.indexDatabasePath error:nil];
    }
    else
    {
        [_indexDatabase setShouldCacheStatements:true];
        [_indexDatabase setLogsErrors:true];
        
        if ([self isCurrentIndexDatabaseEncrypted])
        {
            bool isLegacy = false;
            NSString *hexKey = [self _hexKey:NULL];
            [self checkIndexPassword:[[NSString alloc] initWithData:[hexKey dataByDecodingHexString] encoding:NSUTF8StringEncoding] isLegacy:&isLegacy];
            if (isLegacy)
            {
                sqlite3_exec([_indexDatabase sqliteHandle], [[NSString alloc] initWithFormat:@"PRAGMA key=\"x'%@\"", hexKey].UTF8String, NULL, NULL, NULL);
            }
            else
            {
                sqlite3_exec([_indexDatabase sqliteHandle], [[NSString alloc] initWithFormat:@"PRAGMA key=\"%@\"", hexKey].UTF8String, NULL, NULL, NULL);
            }
        }
        
        sqlite3_exec([_indexDatabase sqliteHandle], "PRAGMA encoding=\"UTF-8\"", NULL, NULL, NULL);
        sqlite3_exec([_indexDatabase sqliteHandle], "PRAGMA synchronous=NORMAL", NULL, NULL, NULL);
        sqlite3_exec([_indexDatabase sqliteHandle], "PRAGMA journal_mode=TRUNCATE", NULL, NULL, NULL);
        //sqlite3_exec([_indexDatabase sqliteHandle], "PRAGMA temp_store=NORMAL", NULL, NULL, NULL);
    }
}

- (void)initDatabase
{
    [self _reopenDatabase];
    
    [self dispatchOnIndexThread:^
    {
        [self _reopenIndexDatabase];
    } synchronous:false];
    
    [self upgradeTables];
}

- (void)rekeyDatabase:(NSString *)hexKey
{
    [self dispatchOnDatabaseThread:^
    {
        TG_TIMESTAMP_DEFINE(rekeyDatabase)
        sqlite3_exec([_database sqliteHandle], [[NSString alloc] initWithFormat:@"PRAGMA rekey=\"%@\"", hexKey].UTF8String, NULL, NULL, NULL);
        TG_TIMESTAMP_MEASURE(rekeyDatabase)
    } synchronous:false];
    
    [self dispatchOnIndexThread:^
    {
        TG_TIMESTAMP_DEFINE(rekeyIndex)
        sqlite3_exec([_indexDatabase sqliteHandle], [[NSString alloc] initWithFormat:@"PRAGMA rekey=\"%@\"", hexKey].UTF8String, NULL, NULL, NULL);
        TG_TIMESTAMP_MEASURE(rekeyIndex)
    } synchronous:false];
}

- (void)migrateDatabaseEncrypted:(void (^)())completion
{
    [self dispatchOnDatabaseThread:^
    {
        if (![self isCurrentDatabaseEncrypted])
        {
            NSString *baseDatabasePath = [[self documentsPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db", (databaseName == nil ? @"tgdata" : databaseName)]];
            NSString *encryptedDatabasePath = [baseDatabasePath stringByAppendingString:@".y"];
            
            TG_TIMESTAMP_DEFINE(exportDatabase)
            sqlite3_exec([_database sqliteHandle], [[NSString alloc] initWithFormat:@"ATTACH DATABASE '%@' AS encrypted KEY \"%@\"", encryptedDatabasePath, [self _hexKey:NULL]].UTF8String, NULL, NULL, NULL);
            sqlite3_exec([_database sqliteHandle], "SELECT sqlcipher_export('encrypted')", NULL, NULL, NULL);
            sqlite3_exec([_database sqliteHandle], "DETACH DATABASE encrypted", NULL, NULL, NULL);
            TG_TIMESTAMP_MEASURE(exportDatabase)
            
            [_database close];
            
            _databasePath = encryptedDatabasePath;
            
            [self _reopenDatabase];

            [[NSFileManager defaultManager] removeItemAtPath:baseDatabasePath error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:[baseDatabasePath stringByAppendingString:@"-wal"] error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:[baseDatabasePath stringByAppendingString:@"-shm"] error:nil];
        }
        
        [self dispatchOnIndexThread:^
        {
            if (![self isCurrentIndexDatabaseEncrypted])
            {
                NSString *baseIndexDatabasePath = [[self documentsPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_index.db", (databaseName == nil ? @"tgdata" : databaseName)]];
                NSString *encryptedIndexDatabasePath = [baseIndexDatabasePath stringByAppendingString:@".y"];
                
                TG_TIMESTAMP_DEFINE(exportIndex)
                sqlite3_exec([_indexDatabase sqliteHandle], [[NSString alloc] initWithFormat:@"ATTACH DATABASE '%@' AS encrypted_index KEY \"%@\"", encryptedIndexDatabasePath, [self _hexKey:NULL]].UTF8String, NULL, NULL, NULL);
                sqlite3_exec([_indexDatabase sqliteHandle], "SELECT sqlcipher_export('encrypted_index')", NULL, NULL, NULL);
                sqlite3_exec([_indexDatabase sqliteHandle], "DETACH DATABASE encrypted_index", NULL, NULL, NULL);
                TG_TIMESTAMP_MEASURE(exportIndex)
                
                [_indexDatabase close];
                
                _indexDatabasePath = encryptedIndexDatabasePath;
                
                [self _reopenIndexDatabase];
                
                [[NSFileManager defaultManager] removeItemAtPath:baseIndexDatabasePath error:nil];
                [[NSFileManager defaultManager] removeItemAtPath:[baseIndexDatabasePath stringByAppendingString:@"-wal"] error:nil];
                [[NSFileManager defaultManager] removeItemAtPath:[baseIndexDatabasePath stringByAppendingString:@"-shm"] error:nil];
            }
            
            if (completion)
                completion();
        } synchronous:false];
    } synchronous:false];
}

- (void)migrateDatabasePlaintext:(void (^)())completion
{
    [self dispatchOnDatabaseThread:^
    {
        if ([self isCurrentDatabaseEncrypted])
        {
            NSString *baseDatabasePath = [[self documentsPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db", (databaseName == nil ? @"tgdata" : databaseName)]];
            NSString *encryptedDatabasePath = [baseDatabasePath stringByAppendingString:@".y"];
            
            TG_TIMESTAMP_DEFINE(exportDatabase)
            sqlite3_exec([_database sqliteHandle], [[NSString alloc] initWithFormat:@"ATTACH DATABASE '%@' AS plaintext KEY ''", baseDatabasePath].UTF8String, NULL, NULL, NULL);
            sqlite3_exec([_database sqliteHandle], "SELECT sqlcipher_export('plaintext')", NULL, NULL, NULL);
            sqlite3_exec([_database sqliteHandle], "DETACH DATABASE plaintext", NULL, NULL, NULL);
            TG_TIMESTAMP_MEASURE(exportDatabase)
            
            [_database close];
            
            _databasePath = baseDatabasePath;
            
            [self _reopenDatabase];
            
            [[NSFileManager defaultManager] removeItemAtPath:encryptedDatabasePath error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:[encryptedDatabasePath stringByAppendingString:@"-wal"] error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:[encryptedDatabasePath stringByAppendingString:@"-shm"] error:nil];
        }
        
        [self dispatchOnIndexThread:^
        {
            if ([self isCurrentIndexDatabaseEncrypted])
            {
                NSString *baseIndexDatabasePath = [[self documentsPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_index.db", (databaseName == nil ? @"tgdata" : databaseName)]];
                NSString *encryptedIndexDatabasePath = [baseIndexDatabasePath stringByAppendingString:@".y"];
                
                TG_TIMESTAMP_DEFINE(exportIndex)
                sqlite3_exec([_indexDatabase sqliteHandle], [[NSString alloc] initWithFormat:@"ATTACH DATABASE '%@' AS plaintext KEY ''", baseIndexDatabasePath].UTF8String, NULL, NULL, NULL);
                sqlite3_exec([_indexDatabase sqliteHandle], "SELECT sqlcipher_export('plaintext')", NULL, NULL, NULL);
                sqlite3_exec([_indexDatabase sqliteHandle], "DETACH DATABASE plaintext", NULL, NULL, NULL);
                TG_TIMESTAMP_MEASURE(exportIndex)
                
                [_indexDatabase close];
                
                _indexDatabasePath = baseIndexDatabasePath;
                
                [self _reopenIndexDatabase];
                
                [[NSFileManager defaultManager] removeItemAtPath:encryptedIndexDatabasePath error:nil];
                [[NSFileManager defaultManager] removeItemAtPath:[encryptedIndexDatabasePath stringByAppendingString:@"-wal"] error:nil];
                [[NSFileManager defaultManager] removeItemAtPath:[encryptedIndexDatabasePath stringByAppendingString:@"-shm"] error:nil];
            }
            
            if (completion)
                completion();
        } synchronous:false];
    } synchronous:false];
}

- (void)closeDatabase
{
    [self dispatchOnDatabaseThread:^
    {
        [_database close];
    } synchronous:true];
    
    [self dispatchOnIndexThread:^
    {
        [_indexDatabase close];
    } synchronous:true];
}

- (void)dropDatabase
{
    [self dropDatabase:true];
}

- (void)dropDatabase:(bool)fullDrop
{
    [self dispatchOnDatabaseThread:^
    {
        if (fullDrop)
        {
            [[NSFileManager defaultManager] removeItemAtPath:self.databasePath error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:[self.databasePath stringByAppendingString:@"-shm"] error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:[self.databasePath stringByAppendingString:@"-wal"] error:nil];
            
            [[NSFileManager defaultManager] removeItemAtPath:[[self documentsPath] stringByAppendingPathComponent:@"x.y"] error:nil];
            
            NSString *baseDatabasePath = [[self documentsPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db", (databaseName == nil ? @"tgdata" : databaseName)]];
            _databasePath = baseDatabasePath;
            
            [[NSFileManager defaultManager] removeItemAtPath:self.databasePath error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:[self.databasePath stringByAppendingString:@"-shm"] error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:[self.databasePath stringByAppendingString:@"-wal"] error:nil];
            
            NSString *baseIndexDatabasePath = [[self documentsPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_index.db", (databaseName == nil ? @"tgdata" : databaseName)]];
            
            [self dispatchOnIndexThread:^
            {
                [[NSFileManager defaultManager] removeItemAtPath:self.indexDatabasePath error:nil];
                [[NSFileManager defaultManager] removeItemAtPath:[self.indexDatabasePath stringByAppendingString:@"-shm"] error:nil];
                [[NSFileManager defaultManager] removeItemAtPath:[self.indexDatabasePath stringByAppendingString:@"-wal"] error:nil];
                _indexDatabasePath = baseIndexDatabasePath;
                
                [[NSFileManager defaultManager] removeItemAtPath:self.indexDatabasePath error:nil];
                [[NSFileManager defaultManager] removeItemAtPath:[self.indexDatabasePath stringByAppendingString:@"-shm"] error:nil];
                [[NSFileManager defaultManager] removeItemAtPath:[self.indexDatabasePath stringByAppendingString:@"-wal"] error:nil];
            } synchronous:false];
            
            [self initDatabase];
        }
        else
        {
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", _serviceTableName]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", _usersTableName]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", _conversationListTableName]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", _broadcastConversationListTableName]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", _messagesTableName]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", _conversationMediaTableName]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", _contactListTableName]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", _actionQueueTableName]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", _peerPropertiesTableName]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", _peerProfilePhotosTableName]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", _outgoingMessagesTableName]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", _futureActionsTableName]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", _peerHistoryHolesTableName]];
            
            //[_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", _assetsTableName]];
            
            [_database executeUpdate:[[NSString alloc] initWithFormat:@"DROP TABLE IF EXISTS %@", _serverAssetsTableName]];
            
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", _videosTableName]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", _storedFilesTableName]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", _localFilesTableName]];
            
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", _blockedUsersTableName]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", _userLinksTableName]];
            
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", _temporaryMessageIdsTableName]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", _randomIdsTableName]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", _selfDestructTableName]];

            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", _encryptedConversationIdsTableName]];
            [_database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", _secretMediaAttributesTableName]];
            
            [self dispatchOnIndexThread:^
            {
                [_indexDatabase executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", _messageIndexTableName]];
            } synchronous:false];
        }
        
        if (_cleanupEverythingBlock)
            _cleanupEverythingBlock();

        TG_SYNCHRONIZED_BEGIN(_cachedUnreadCount);
        _cachedUnreadCount = 0;
        TG_SYNCHRONIZED_END(_cachedUnreadCount);

        _cachedDatabaseState.pts = 0;
        _cachedDatabaseState.date = 0;
        _cachedDatabaseState.seq = 0;
        _cachedDatabaseState.unreadCount = 0;
        
        if (_liveUnreadCountDispatchPath != nil)
        {
            [ActionStageInstance() dispatchOnStageQueue:^
            {
                [ActionStageInstance() dispatchResource:_liveUnreadCountDispatchPath resource:[[SGraphObjectNode alloc] initWithObject:[[NSNumber alloc] initWithInt:0]]];
            }];
        }
        
        TG_SYNCHRONIZED_BEGIN(_mutedPeers);
        _mutedPeers.clear();
        TG_SYNCHRONIZED_END(_mutedPeers);
        
        TG_SYNCHRONIZED_BEGIN(_userByUid);
        _userByUid.clear();
        TG_SYNCHRONIZED_END(_userByUid);

        TG_SYNCHRONIZED_BEGIN(_contactsByPhoneId);
        _contactsByPhoneId.clear();
        TG_SYNCHRONIZED_END(_contactsByPhoneId);
        
        TG_SYNCHRONIZED_BEGIN(_phonebookContacts);
        _phonebookContacts.clear();
        TG_SYNCHRONIZED_END(_phonebookContacts);
        
        TG_SYNCHRONIZED_BEGIN(_unreadCountByConversation);
        _unreadCountByConversation.clear();
        TG_SYNCHRONIZED_END(_unreadCountByConversation);
        
        TG_SYNCHRONIZED_BEGIN(_cachedConversations);
        _cachedConversations.clear();
        TG_SYNCHRONIZED_END(_cachedConversations);
        
        TG_SYNCHRONIZED_BEGIN(_containsConversation);
        _containsConversation.clear();
        TG_SYNCHRONIZED_END(_containsConversation);
        
        TG_SYNCHRONIZED_BEGIN(_remoteContactUids);
        _remoteContactUids.clear();
        TG_SYNCHRONIZED_END(_remoteContactUids);
        
        TG_SYNCHRONIZED_BEGIN(_peerCustomSettings);
        _peerCustomSettings.clear();
        TG_SYNCHRONIZED_END(_peerCustomSettings);
        
        TG_SYNCHRONIZED_BEGIN(_encryptedConversationIds);
        _encryptedConversationIds.clear();
        _peerIdsForEncryptedConversationIds.clear();
        TG_SYNCHRONIZED_END(_encryptedConversationIds);
        
        TG_SYNCHRONIZED_BEGIN(_conversationEncryptionKeys);
        _conversationEncryptionKeys.clear();
        TG_SYNCHRONIZED_END(_conversationEncryptionKeys);
        
        TG_SYNCHRONIZED_BEGIN(_encryptedParticipantIds);
        _encryptedParticipantIds.clear();
        TG_SYNCHRONIZED_END(_encryptedParticipantIds);
        
        TG_SYNCHRONIZED_BEGIN(_encryptedConversationIsCreator);
        _encryptedConversationIsCreator.clear();
        TG_SYNCHRONIZED_END(_encryptedConversationIsCreator);
        
        TG_SYNCHRONIZED_BEGIN(_encryptedConversationAccessHash);
        _encryptedConversationAccessHash.clear();
        TG_SYNCHRONIZED_END(_encryptedConversationAccessHash);
        
        TG_SYNCHRONIZED_BEGIN(_messageLifetimeByPeerId);
        _messageLifetimeByPeerId.clear();
        TG_SYNCHRONIZED_END(_messageLifetimeByPeerId);
        
        TG_SYNCHRONIZED_BEGIN(_conversationInputStates);
        _conversationInputStates.clear();
        TG_SYNCHRONIZED_END(_conversationInputStates);
        
        TG_SYNCHRONIZED_BEGIN(_peerLayers);
        _peerLayers.clear();
        TG_SYNCHRONIZED_END(_peerLayers);
        
        TG_SYNCHRONIZED_BEGIN(_lastReportedToPeerLayers);
        _lastReportedToPeerLayers.clear();
        TG_SYNCHRONIZED_END(_lastReportedToPeerLayers);
        
        [self clearCachedUserLinks];
        
        _nextLocalMid = 0;
        
        _storedChannelList = [[TGChannelList alloc] initWithChannels:@[]];
        _channelListPipe = [[SPipe alloc] init];
        
        [_existingChannelPipes removeAllObjects];
        [_existingChannelPipes removeAllObjects];
        _queuedDeleteChannelMessages = [[SPipe alloc] init];
        _queuedReadChannelMessages = [[SPipe alloc] init];
        _queuedLeaveChannels = [[SPipe alloc] init];
        
        [self upgradeTables];
    } synchronous:false];
}

inline static void storeUserToDatabase(TGDatabase *instance, FMDatabase *database, TGUser *user, PSKeyValueEncoder *coder)
{
    static NSString *queryFormat = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (uid, first_name, last_name, local_first_name, local_last_name, phone_number, access_hash, sex, photo_small, photo_medium, photo_big, last_seen, username, data) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", instance.usersTableName];
    
    [coder reset];
    [user encodeWithKeyValueCoder:coder];
    
    [database executeUpdate:queryFormat, [[NSNumber alloc] initWithInt:user.uid], user.realFirstName, user.realLastName, user.phonebookFirstName, user.phonebookLastName, user.phoneNumber, [[NSNumber alloc] initWithLongLong:user.phoneNumberHash], [[NSNumber alloc] initWithInt:user.sex], user.photoUrlSmall, user.photoUrlMedium, user.photoUrlBig, [[NSNumber alloc] initWithInt:((int)user.presence.lastSeen)], user.userName == nil ? @"" : user.userName, coder.data];
}

inline static TGUser *loadUserFromDatabase(FMResultSet *result, PSKeyValueDecoder *coder)
{
    NSData *data = [result dataForColumn:@"data"];
    [coder resetData:data];
    
    TGUser *user = nil;
    if (data.length != 0)
        user = [[TGUser alloc] initWithKeyValueCoder:coder];
    else
        user = [[TGUser alloc] init];
    
    user.uid = [result intForColumn:@"uid"];
    user.firstName = [result stringForColumn:@"first_name"];
    user.lastName = [result stringForColumn:@"last_name"];
    user.phonebookFirstName = [result stringForColumn:@"local_first_name"];
    user.phonebookLastName = [result stringForColumn:@"local_last_name"];
    user.phoneNumber = [result stringForColumn:@"phone_number"];
    user.phoneNumberHash = [result longLongIntForColumn:@"access_hash"];
    user.sex = (TGUserSex)[result intForColumn:@"sex"];
    user.photoUrlSmall = [result stringForColumn:@"photo_small"];
    user.photoUrlMedium = [result stringForColumn:@"photo_medium"];
    user.photoUrlBig = [result stringForColumn:@"photo_big"];
    TGUserPresence presence;
    presence.online = false;
    presence.lastSeen = [result intForColumn:@"last_seen"];
    presence.temporaryLastSeen = 0;
    user.presence = presence;
    user.userName = [result stringForColumn:@"username"];
    
    return user;
}

- (void)storeUsers:(NSArray *)userList
{
    TG_SYNCHRONIZED_BEGIN(_userByUid);
    {
        for (TGUser *user in userList)
        {
            _userByUid[user.uid] = user;
            if (user.contactId != 0)
                _phoneIdByUid.insert(std::pair<int, int>(user.uid, user.contactId));
        }
    }
    TG_SYNCHRONIZED_END(_userByUid);
    
    PSKeyValueEncoder *encoder = [[PSKeyValueEncoder alloc] init];
    
    [self dispatchOnDatabaseThread:^
    {
        [_database beginTransaction];
        FMDatabase *database = _database;
        for (TGUser *user in userList)
        {
            storeUserToDatabase(self, database, user, encoder);
        }
        [_database commit];
    } synchronous:false];
}

- (void)storeUsersPresences:(std::map<int, TGUserPresence> *)presenceMap
{
    NSMutableArray *usersToStore = nil;
    std::tr1::shared_ptr<std::map<int, TGUserPresence> > unloadedUsersPresenceMap;
    
    TG_SYNCHRONIZED_BEGIN(_userByUid);
    {
        for (std::map<int, TGUserPresence>::iterator it = presenceMap->begin(); it != presenceMap->end(); it++)
        {
            std::tr1::unordered_map<int, TGUser *>::iterator userIt = _userByUid.find(it->first);
            if (userIt != _userByUid.end())
            {
                bool lastSeenChanged = userIt->second.presence.lastSeen != it->second.lastSeen;
                if (lastSeenChanged || userIt->second.presence.online != it->second.online)
                {
                    TGUser *newUser = [userIt->second copy];
                    newUser.presence = it->second;
                    _userByUid[newUser.uid] = newUser;
                    
                    if (lastSeenChanged)
                    {
                        if (usersToStore == nil)
                            usersToStore = [[NSMutableArray alloc] init];
                        [usersToStore addObject:newUser];
                    }
                }
            }
            else
            {
                if (unloadedUsersPresenceMap == NULL)
                    unloadedUsersPresenceMap = std::tr1::shared_ptr<std::map<int, TGUserPresence> >(new std::map<int, TGUserPresence>());
                
                unloadedUsersPresenceMap->insert(std::pair<int, TGUserPresence>(it->first, it->second));
            }
        }
    }
    TG_SYNCHRONIZED_END(_userByUid);
    
    if (unloadedUsersPresenceMap != NULL && !unloadedUsersPresenceMap->empty())
    {
        [self dispatchOnDatabaseThread:^
        {
            NSString *queryFormat = [NSString stringWithFormat:@"UPDATE OR IGNORE %@ SET last_seen=? WHERE uid=? LIMIT 1", _usersTableName];
            
            for (std::map<int, TGUserPresence>::iterator it = unloadedUsersPresenceMap->begin(); it != unloadedUsersPresenceMap->end(); it++)
            {
                [_database executeQuery:queryFormat, [[NSNumber alloc] initWithInt:it->second.lastSeen], [[NSNumber alloc] initWithInt:it->first]];
            }
        } synchronous:false];
    }
    
    if (usersToStore != nil && usersToStore.count != 0)
    {
        [self dispatchOnDatabaseThread:^
        {
            PSKeyValueEncoder *encoder = [[PSKeyValueEncoder alloc] init];
            
            [_database beginTransaction];
            FMDatabase *database = _database;
            for (TGUser *user in usersToStore)
            {
                storeUserToDatabase(self, database, user, encoder);
            }
            [_database commit];
        } synchronous:false];
    }
}

- (void)setLocalUserId:(int)localUserId
{
    [self dispatchOnDatabaseThread:^
    {
        _localUserId = localUserId;
    } synchronous:false];
}

- (void)setLocalUserStatusPrivacyRules:(TGNotificationPrivacyAccountSetting *)privacyRules changedLoadedUsers:(void (^)(NSArray *))changedLoadedUsers
{
    [self dispatchOnDatabaseThread:^
    {
        _privacySettings = privacyRules;
    } synchronous:false];
    
    NSMutableArray *users = [[NSMutableArray alloc] init];
    TG_SYNCHRONIZED_BEGIN(_userByUid);
    {
        NSTimeInterval currentTime = (CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970 + _timeDifferenceFromUTC);
        for (auto it : _userByUid)
        {
            TGUser *user = [it.second applyPrivacyRules:privacyRules currentTime:currentTime];
            if (![user isEqualToUser:it.second])
                [users addObject:user];
        }
    }
    TG_SYNCHRONIZED_END(_userByUid);
    
    if (changedLoadedUsers)
        changedLoadedUsers(users);
}

- (TGUser *)loadUser:(int)uid
{
    __block TGUser *user = nil;
    
    TG_SYNCHRONIZED_BEGIN(_userByUid);
    {
        //NSTimeInterval currentTime = (CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970 + _timeDifferenceFromUTC);
        
        std::tr1::unordered_map<int, TGUser *>::iterator it = _userByUid.find(uid);
        if (it != _userByUid.end())
        {
            user = [it->second copy];//[[it->second copy] applyPrivacyRules:_privacySettings currentTime:currentTime];
        }
    }
    TG_SYNCHRONIZED_END(_userByUid);
    
    if (user == nil)
    {
        [self dispatchOnDatabaseThread:^
        {
            PSKeyValueDecoder *decoder = [[PSKeyValueDecoder alloc] init];
             FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE uid=?", _usersTableName], [[NSNumber alloc] initWithInt:uid]];
             if ([result next])
             {
                 user = loadUserFromDatabase(result, decoder);
             }
        } synchronous:true];
        
        if (user != nil)
        {
            NSTimeInterval currentTime = (CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970 + _timeDifferenceFromUTC);
            user = [user applyPrivacyRules:_privacySettings currentTime:currentTime];
            
            TG_SYNCHRONIZED_BEGIN(_userByUid);
            {
                _userByUid[user.uid] = user;
                if (user.contactId != 0)
                    _phoneIdByUid.insert(std::pair<int, int>(uid, user.contactId));
            }
            TG_SYNCHRONIZED_END(_userByUid);
            
            if (uid == _localUserId)
            {
                user.phonebookFirstName = nil;
                user.phonebookLastName = nil;
            }
            else if (user.contactId != 0)
            {
                TGContactBinding *binding = [self contactBindingWithId:user.contactId];
                if (binding != nil)
                {
                    user.phonebookFirstName = binding.firstName;
                    user.phonebookLastName = binding.lastName;
                }
                else if (_contactListPreloaded)
                {
                    user.phonebookFirstName = nil;
                    user.phonebookLastName = nil;
                }
            }
            else if (_contactListPreloaded)
            {
                user.phonebookFirstName = nil;
                user.phonebookLastName = nil;
            }
        }
    }
    
    return user;
}

- (int)loadCachedPhoneIdByUid:(int)uid
{
    int contactId = 0;
    
    TG_SYNCHRONIZED_BEGIN(_userByUid);
    {
        std::map<int, int>::iterator it = _phoneIdByUid.find(uid);
        if (it != _phoneIdByUid.end())
            contactId = it->second;
    }
    TG_SYNCHRONIZED_END(_userByUid);
    
    return contactId;
}

- (void)loadCachedUsersWithContactIds:(std::set<int> const &)contactIds resultMap:(std::map<int, TGUser *> &)resultMap
{   
    TG_SYNCHRONIZED_BEGIN(_userByUid);
    {
        for (std::tr1::unordered_map<int, TGUser *>::iterator it = _userByUid.begin(); it != _userByUid.end(); it++)
        {
            if (it->second.phoneNumber.length != 0)
            {
                std::set<int>::iterator contactIdIt = contactIds.find(it->second.contactId);
                if (contactIdIt != contactIds.end())
                {
                    resultMap.insert(std::pair<int, TGUser *>(*contactIdIt, it->second));
                }
            }
        }
    }
    TG_SYNCHRONIZED_END(_userByUid);
}

- (int)loadUsersOnlineCount:(NSArray *)uids alwaysOnlineUid:(int)alwaysOnlineUid
{
    int count = 0;
    
    std::vector<int> unknownUsers;
    
    TG_SYNCHRONIZED_BEGIN(_userByUid);
    for (NSNumber *nUid in uids)
    {
        int uid = [nUid intValue];
        if (uid == alwaysOnlineUid)
        {
            count++;
        }
        else
        {
            std::tr1::unordered_map<int, TGUser *>::iterator userIt = _userByUid.find(uid);
            if (userIt != _userByUid.end())
            {
                if (userIt->second.presence.online)
                    count++;
            }
            else
                unknownUsers.push_back(uid);
        }
    }
    TG_SYNCHRONIZED_END(_userByUid);
    
    if (!unknownUsers.empty())
    {
        __block int blockCount = 0;
        [self dispatchOnDatabaseThread:^
        {
            NSString *queryFormat = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE uid=? LIMIT 1", _usersTableName];
            
            NSMutableArray *foundUsers = [[NSMutableArray alloc] init];
            
            PSKeyValueDecoder *decoder = [[PSKeyValueDecoder alloc] init];
            
            for (std::vector<int>::const_iterator it = unknownUsers.begin(); it != unknownUsers.end(); it++)
            {
                FMResultSet *result = [_database executeQuery:queryFormat, [[NSNumber alloc] initWithInt:*it]];
                if ([result next])
                {
                    TGUser *user = loadUserFromDatabase(result, decoder);
                    if (user.uid == _localUserId)
                    {
                        user.phonebookFirstName = nil;
                        user.phonebookLastName = nil;
                    }
                    else if (user.phoneNumber.length != 0)
                    {
                        TGContactBinding *binding = [self contactBindingWithId:user.contactId];
                        if (binding != nil)
                        {
                            user.phonebookFirstName = binding.firstName;
                            user.phonebookLastName = binding.lastName;
                        }
                        else if (_contactListPreloaded)
                        {
                            user.phonebookFirstName = nil;
                            user.phonebookLastName = nil;
                        }
                    }
                    
                    [foundUsers addObject:user];
                }
            }
            
            TG_SYNCHRONIZED_BEGIN(_userByUid);
            for (TGUser *user in foundUsers)
            {
                if (user.presence.online)
                    blockCount++;
                
                _userByUid[user.uid] = user;
                
                if (user.contactId != 0)
                    _phoneIdByUid.insert(std::pair<int, int>(user.uid, user.contactId));
            }
            TG_SYNCHRONIZED_END(_userByUid);
         } synchronous:true];
        
        count += blockCount;
    }
    
    return count;
}

- (std::tr1::shared_ptr<std::map<int, TGUser *> >)loadUsers:(std::vector<int> const &)uidList
{
    std::tr1::shared_ptr<std::map<int, TGUser *> > users(new std::map<int, TGUser *>());
    
    std::vector<int> unknownUsers;
    
    TG_SYNCHRONIZED_BEGIN(_userByUid);
    for (std::vector<int>::const_iterator it = uidList.begin(); it != uidList.end(); it++)
    {
        std::tr1::unordered_map<int, TGUser *>::iterator userIt = _userByUid.find(*it);
        if (userIt != _userByUid.end())
        {
            users->insert(std::pair<int, TGUser *>(*it, userIt->second));
        }
        else
            unknownUsers.push_back(*it);
    }
    TG_SYNCHRONIZED_END(_userByUid);
    
    if (!unknownUsers.empty())
    {
        [self dispatchOnDatabaseThread:^
        {
            NSString *queryFormat = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE uid=? LIMIT 1", _usersTableName];
            
            NSMutableArray *foundUsers = [[NSMutableArray alloc] init];
            
            PSKeyValueDecoder *decoder = [[PSKeyValueDecoder alloc] init];
            
            for (std::vector<int>::const_iterator it = unknownUsers.begin(); it != unknownUsers.end(); it++)
            {   
                FMResultSet *result = [_database executeQuery:queryFormat, [[NSNumber alloc] initWithInt:*it]];
                if ([result next])
                {
                    TGUser *user = loadUserFromDatabase(result, decoder);
                    if (user.uid == _localUserId)
                    {
                        user.phonebookFirstName = nil;
                        user.phonebookLastName = nil;
                    }
                    else if (user.phoneNumber.length != 0)
                    {
                        TGContactBinding *binding = [self contactBindingWithId:user.contactId];
                        if (binding != nil)
                        {
                            user.phonebookFirstName = binding.firstName;
                            user.phonebookLastName = binding.lastName;
                        }
                        else if (_contactListPreloaded)
                        {
                            user.phonebookFirstName = nil;
                            user.phonebookLastName = nil;
                        }
                    }
                    
                    [foundUsers addObject:user];
                }
            }
            
            TG_SYNCHRONIZED_BEGIN(_userByUid);
            for (TGUser *user in foundUsers)
            {
                (*users)[user.uid] = user;
                _userByUid[user.uid] = user;
                
                if (user.contactId != 0)
                    _phoneIdByUid.insert(std::pair<int, int>(user.uid, user.contactId));
            }
            TG_SYNCHRONIZED_END(_userByUid);
        } synchronous:true];
    }
    
    return users;
}

- (int)loadUserLink:(int)uid outdated:(bool *)outdated
{
    int link = 0;
    bool foundCached = false;
    bool valueOutdated = false;
    
    TG_SYNCHRONIZED_BEGIN(_userLinks);
    std::map<int, std::pair<int, int> >::iterator it = _userLinks.find(uid);
    if (it != _userLinks.end())
    {
        link = it->second.first;
        valueOutdated = it->second.second != _userLinksVersion;
        foundCached = true;
    }
    TG_SYNCHRONIZED_END(_userLinks);
    
    if (!foundCached)
    {
        valueOutdated = true;
        
        __block int blockLink = 0;
        
        [self dispatchOnDatabaseThread:^
        {
            FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT link FROM %@ WHERE pid=?", _userLinksTableName], [[NSNumber alloc] initWithInt:uid]];
            if ([result next])
            {
                blockLink = [result intForColumn:@"link"];
            }
        } synchronous:true];
        
        link = blockLink;
        
        if (link != 0)
        {
            TG_SYNCHRONIZED_BEGIN(_userLinks);
            _userLinks[uid] = std::pair<int, int>(link, -1);
            TG_SYNCHRONIZED_END(_userLinks);
        }
    }
    
    if (outdated != NULL)
        *outdated = valueOutdated;
    
    return link;
}

- (void)storeUserLink:(int)uid link:(int)link
{
    TG_SYNCHRONIZED_BEGIN(_userLinks);
    _userLinks[uid] = std::pair<int, int>(link, _userLinksVersion);
    TG_SYNCHRONIZED_END(_userLinks);
    
    [self dispatchOnDatabaseThread:^
    {
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO %@ (pid, link) VALUES (?, ?)", _userLinksTableName], [[NSNumber alloc] initWithInt:uid], [[NSNumber alloc] initWithInt:link]];
    } synchronous:false];
}

- (void)clearCachedUserLinks
{
    TG_SYNCHRONIZED_BEGIN(_userLinks);
    _userLinks.clear();
    TG_SYNCHRONIZED_END(_userLinks);
}

- (void)upgradeUserLinks
{
    TG_SYNCHRONIZED_BEGIN(_userLinks);
    _userLinksVersion++;
    TG_SYNCHRONIZED_END(_userLinks);
}

static inline void storeConversationToDatabase(TGDatabase *database, TGConversation *conversation)
{
    NSString *queryFormat = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (cid, date, from_uid, message, media, unread_count, flags, chat_title, chat_photo, participants, participants_count, chat_version, service_unread) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", [database _listTableNameForConversationId:conversation.conversationId]];
    
    int flags = 0;
    if (conversation.outgoing)
        flags |= 1;
    if (conversation.isChat)
        flags |= 2;
    if (conversation.leftChat)
        flags |= 4;
    if (conversation.kickedFromChat)
        flags |= 8;
    if (conversation.unread)
        flags |= 16;
    if (conversation.deliveryError)
        flags |= 32;
    if (conversation.deliveryState == TGMessageDeliveryStatePending)
        flags |= 64;
    else if (conversation.deliveryState == TGMessageDeliveryStateFailed)
        flags |= 128;
    
    [database.database executeUpdate:queryFormat, [[NSNumber alloc] initWithLongLong:conversation.conversationId], [[NSNumber alloc] initWithInt:conversation.date], [[NSNumber alloc] initWithInt:conversation.fromUid], conversation.text, conversation.media == nil ? nil :  [TGMessage serializeMediaAttachments:false attachments:conversation.media], [[NSNumber alloc] initWithInt:conversation.unreadCount], [[NSNumber alloc] initWithInt:flags], conversation.chatTitle, !conversation.isChat ? nil : [conversation serializeChatPhoto], !conversation.isChat ? nil : [conversation.chatParticipants serializedData], [[NSNumber alloc] initWithInt:conversation.chatParticipantCount], [[NSNumber alloc] initWithInt:conversation.chatVersion], [[NSNumber alloc] initWithInt:conversation.serviceUnreadCount]];
}

static inline void storeConversationToDatabaseIfNotExists(TGDatabase *database, TGConversation *conversation)
{
    NSString *queryFormat = [NSString stringWithFormat:@"INSERT OR IGNORE INTO %@ (cid, date, from_uid, message, media, unread_count, flags, chat_title, chat_photo, participants, participants_count, chat_version) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", [database _listTableNameForConversationId:conversation.conversationId]];
    
    int flags = 0;
    if (conversation.outgoing)
        flags |= 1;
    if (conversation.isChat)
        flags |= 2;
    if (conversation.leftChat)
        flags |= 4;
    if (conversation.kickedFromChat)
        flags |= 8;
    if (conversation.unread)
        flags |= 16;
    if (conversation.deliveryError)
        flags |= 32;
    if (conversation.deliveryState == TGMessageDeliveryStatePending)
        flags |= 64;
    else if (conversation.deliveryState == TGMessageDeliveryStateFailed)
        flags |= 128;
    
    [database.database executeUpdate:queryFormat, [[NSNumber alloc] initWithLongLong:conversation.conversationId], [[NSNumber alloc] initWithInt:conversation.date], [[NSNumber alloc] initWithInt:conversation.fromUid], conversation.text, conversation.media == nil ? nil :  [TGMessage serializeMediaAttachments:false attachments:conversation.media], [[NSNumber alloc] initWithInt:conversation.unreadCount], [[NSNumber alloc] initWithInt:flags], conversation.chatTitle, !conversation.isChat ? nil : [conversation serializeChatPhoto], !conversation.isChat ? nil : [conversation.chatParticipants serializedData], [[NSNumber alloc] initWithInt:conversation.chatParticipantCount], [[NSNumber alloc] initWithInt:conversation.chatVersion]];
}

static inline TGConversation *loadConversationFromDatabase(FMResultSet *result)
{
    TGConversation *conversation = [[TGConversation alloc] init];
    
    conversation.conversationId = [result longLongIntForColumn:@"cid"];
    conversation.date = [result intForColumn:@"date"];
    conversation.fromUid = [result intForColumn:@"from_uid"];
    conversation.text = [result stringForColumn:@"message"];
    NSData *media = [result dataForColumn:@"media"];
    if (media != nil)
        conversation.media = [TGMessage parseMediaAttachments:media];
    conversation.unreadCount = [result intForColumn:@"unread_count"];
    conversation.serviceUnreadCount = [result intForColumn:@"service_unread"];
    
    int flags = [result intForColumn:@"flags"];
    
    conversation.outgoing = flags & 1;
    conversation.isChat = flags & 2;
    conversation.leftChat = flags & 4;
    conversation.kickedFromChat = flags & 8;
    conversation.unread = flags & 16;
    conversation.deliveryError = flags & 32;
    conversation.deliveryState = ((flags & 64) ? TGMessageDeliveryStatePending : ((flags & 128) ? TGMessageDeliveryStateFailed : TGMessageDeliveryStateDelivered));
    
    if (flags & 2)
    {
        conversation.chatTitle = [result stringForColumn:@"chat_title"];
        conversation.chatParticipantCount = [result intForColumn:@"participants_count"];
        conversation.chatVersion = [result intForColumn:@"chat_version"];
        conversation.chatParticipants = [TGConversationParticipantsData deserializeData:[result dataForColumn:@"participants"]];
        [conversation deserializeChatPhoto:[result dataForColumn:@"chat_photo"]];
    }
    
    return conversation;
}

- (void)storeConversationList:(NSArray *)conversations replace:(bool)replace
{
    [self dispatchOnDatabaseThread:^
    {
        [_database beginTransaction];
        
        if (replace)
        {
            [_database executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@", _conversationListTableName]];
        
            for (TGConversation *conversation in conversations)
            {
                storeConversationToDatabase(self, conversation);
            }
        }
        else
        {
            for (TGConversation *conversation in conversations)
            {
                storeConversationToDatabaseIfNotExists(self, conversation);
            }
        }
        
        TG_SYNCHRONIZED_BEGIN(_cachedConversations);
        for (TGConversation *conversation in conversations)
        {
            _cachedConversations[conversation.conversationId] = conversation;
        }
        TG_SYNCHRONIZED_END(_cachedConversations);
        
        [_database commit];
    } synchronous:false];
}

- (void)loadConversationListFromDate:(int)date limit:(int)limit excludeConversationIds:(NSArray *)excludeConversationIds completion:(void (^)(NSArray *))completion
{
    [self dispatchOnDatabaseThread:^
    {
        std::set<int64_t> excludeConversationIdsSet;
        for (NSNumber *nCid in excludeConversationIds)
        {
            excludeConversationIdsSet.insert([nCid longLongValue]);
        }
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE date<=? ORDER BY date DESC LIMIT ?", _conversationListTableName], [[NSNumber alloc] initWithInt:date], [[NSNumber alloc] initWithInt:limit]];
        while ([result next])
        {
            TGConversation *conversation = loadConversationFromDatabase(result);
            if (conversation != nil)
            {
                TG_SYNCHRONIZED_BEGIN(_unreadCountByConversation);
                _unreadCountByConversation[conversation.conversationId] = conversation.unreadCount;
                TG_SYNCHRONIZED_END(_unreadCountByConversation);
                
                TG_SYNCHRONIZED_BEGIN(_cachedConversations);
                _cachedConversations[conversation.conversationId] = conversation;
                TG_SYNCHRONIZED_END(_cachedConversations);
                
                if (excludeConversationIdsSet.find(conversation.conversationId) == excludeConversationIdsSet.end())
                    [array addObject:conversation];
            }
        }
        
        [array addObjectsFromArray:[self _loadChannelsWithLowerBound:TGConversationSortKeyLowerBound(TGConversationKindPersistentChannel) upperBound:TGConversationSortKeyMake(TGConversationKindPersistentChannel, date, INT32_MAX) count:limit]];
        
        [TGDatabaseInstance() loadBroadcastConversationListFromDate:INT_MAX limit:INT_MAX excludeConversationIds:excludeConversationIds completion:^(NSArray *broadcastConversations)
        {
            [array addObjectsFromArray:broadcastConversations];
            
            if (completion)
                completion(array);
}];
    } synchronous:false];
}

- (void)loadBroadcastConversationListFromDate:(int)date limit:(int)limit excludeConversationIds:(NSArray *)excludeConversationIds completion:(void (^)(NSArray *))completion
{
    [self dispatchOnDatabaseThread:^
     {
         std::set<int64_t> excludeConversationIdsSet;
         for (NSNumber *nCid in excludeConversationIds)
         {
             excludeConversationIdsSet.insert([nCid longLongValue]);
         }
         
         NSMutableArray *array = [[NSMutableArray alloc] init];
         
         FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE date<=? ORDER BY date DESC LIMIT ?", _broadcastConversationListTableName], [[NSNumber alloc] initWithInt:date], [[NSNumber alloc] initWithInt:limit]];
         while ([result next])
         {
             TGConversation *conversation = loadConversationFromDatabase(result);
             if (conversation != nil)
             {
                 conversation.isBroadcast = true;
                 
                 TG_SYNCHRONIZED_BEGIN(_unreadCountByConversation);
                 _unreadCountByConversation[conversation.conversationId] = conversation.unreadCount;
                 TG_SYNCHRONIZED_END(_unreadCountByConversation);
                 
                 TG_SYNCHRONIZED_BEGIN(_cachedConversations);
                 _cachedConversations[conversation.conversationId] = conversation;
                 TG_SYNCHRONIZED_END(_cachedConversations);
                 
                 if (excludeConversationIdsSet.find(conversation.conversationId) == excludeConversationIdsSet.end())
                     [array addObject:conversation];
             }
         }
         
         if (completion)
             completion(array);
     } synchronous:false];
}

- (int)loadConversationListRemoteOffset
{
    __block int offset = 0;
    
    [self dispatchOnDatabaseThread:^
    {
        FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT cid FROM %@ ORDER BY date ASC", _conversationListTableName]];
        
        NSString *messageQuery = [[NSString alloc] initWithFormat:@"SELECT mid FROM %@ WHERE cid=? AND mid<%d LIMIT 1", _messagesTableName, TGMessageLocalMidBaseline];
        
        int cidIndex = [result columnIndexForName:@"cid"];
        
        while ([result next])
        {
            int64_t conversationId = [result intForColumnIndex:cidIndex];
            FMResultSet *messageResult = [_database executeQuery:messageQuery, [[NSNumber alloc] initWithLongLong:conversationId]];
            if ([messageResult next])
            {
                offset++;
            }
        }
    } synchronous:true];
    
    return offset;
}

- (NSInteger)secretUnreadCount
{
    __block NSInteger totalUnreadCount = 0;
    
    [self dispatchOnDatabaseThread:^
    {
        FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT cid, unread_count FROM %@ WHERE cid <= ?", _conversationListTableName], @(INT_MIN)];
        
        int unreadCountIndex = [result columnIndexForName:@"unread_count"];
        
        while ([result next])
        {
            //__unused int64_t peerId = [result intForColumnIndex:cidIndex];
            totalUnreadCount += [result intForColumnIndex:unreadCountIndex];
        }
    } synchronous:true];
    
    return totalUnreadCount;
}

- (bool)isConversationBroadcast:(int64_t)conversationId
{
    __block bool value = false;
    
    [self dispatchOnDatabaseThread:^
    {
        auto it = _isConversationBroadcast.find(conversationId);
        if (it != _isConversationBroadcast.end())
            value = it->second;
        else
        {
            FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT cid FROM %@ WHERE cid=?", _broadcastConversationListTableName], @(conversationId)];
            if ([result next])
                value = true;
            
            _isConversationBroadcast.insert(std::pair<int64_t, bool>(conversationId, value));
        }
    } synchronous:true];
    
    return value;
}

- (NSString *)_listTableNameForConversationId:(int64_t)conversationId
{
    if (TGPeerIdIsChannel(conversationId)) {
        return _channelListTableName;
    } else if ([self isConversationBroadcast:conversationId]) {
        return _broadcastConversationListTableName;
    }
    return _conversationListTableName;
}

- (TGConversation *)loadConversationWithId:(int64_t)conversationId
{
    __block TGConversation *conversation = nil;
    
    [self dispatchOnDatabaseThread:^
    {
        if (TGPeerIdIsChannel(conversationId)) {
            conversation = [self _loadChannelConversation:conversationId];
        } else {
            FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE cid=?", [self _listTableNameForConversationId:conversationId]], [[NSNumber alloc] initWithLongLong:conversationId]];
            
            if ([result next])
            {
                conversation = loadConversationFromDatabase(result);
                if (conversation != nil)
                {
                    TG_SYNCHRONIZED_BEGIN(_unreadCountByConversation);
                    _unreadCountByConversation[conversation.conversationId] = conversation.unreadCount;
                    TG_SYNCHRONIZED_END(_unreadCountByConversation);
                    
                    TG_SYNCHRONIZED_BEGIN(_cachedConversations);
                    _cachedConversations[conversation.conversationId] = conversation;
                    TG_SYNCHRONIZED_END(_cachedConversations);
                }
            }
        }
    } synchronous:true];
    
    if (conversation == nil)
    {
        TG_SYNCHRONIZED_BEGIN(_unreadCountByConversation);
        _unreadCountByConversation[conversationId] = 0;
        TG_SYNCHRONIZED_END(_unreadCountByConversation);
    }
    
    return conversation;
}

- (TGConversation *)loadConversationWithIdCached:(int64_t)conversationId
{
    TGConversation *conversation = nil;
    
    TG_SYNCHRONIZED_BEGIN(_cachedConversations);
    auto it = _cachedConversations.find(conversationId);
    if (it != _cachedConversations.end())
        conversation = it->second;
    TG_SYNCHRONIZED_END(_cachedConversations);
    
    if (conversation == nil)
        conversation = [self loadConversationWithId:conversationId];
    
    return conversation;
}

- (BOOL)containsConversationWithId:(int64_t)conversationId
{
    __block bool contains = false;
    
    TG_SYNCHRONIZED_BEGIN(_unreadCountByConversation);
    contains = _unreadCountByConversation.find(conversationId) != _unreadCountByConversation.end();
    TG_SYNCHRONIZED_END(_unreadCountByConversation);
    
    if (!contains)
    {
        TG_SYNCHRONIZED_BEGIN(_containsConversation);
        contains = _containsConversation.find(conversationId) != _containsConversation.end();
        TG_SYNCHRONIZED_END(_containsConversation);
        
        [self dispatchOnDatabaseThread:^
        {
            FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT cid FROM %@ WHERE cid=?", [self _listTableNameForConversationId:conversationId]], [[NSNumber alloc] initWithLongLong:conversationId]];
            
            if ([result next])
            {
                contains = true;
                
                TG_SYNCHRONIZED_BEGIN(_containsConversation);
                _containsConversation.insert(conversationId);
                TG_SYNCHRONIZED_END(_containsConversation);
            }
        } synchronous:true];
    }
    
    return contains;
}

- (void)storeConversationParticipantData:(int64_t)conversationId participantData:(TGConversationParticipantsData *)participantData
{
    [self dispatchOnDatabaseThread:^
    {
        TGConversation *listConversation = [self loadConversationWithId:conversationId];
        if (listConversation == nil)
        {
            TGLog(@"***** Conversation %lld not found", conversationId);
            return;
        }
        
        TGConversation *newConversation = [listConversation copy];
        
        if (participantData != nil)
        {
            newConversation.chatVersion = participantData.version;
            newConversation.chatParticipants = participantData;
            newConversation.chatParticipantCount = (int)participantData.chatParticipantUids.count;
            
            TGBotReplyMarkup *replyMarkup = [self botReplyMarkupForPeerId:conversationId];
            if (replyMarkup != nil && ![participantData.chatParticipantUids containsObject:@(replyMarkup.userId)])
            {
                [self storeBotReplyMarkup:nil hideMarkupAuthorId:0 forPeerId:conversationId messageId:-1];
            }
        }
        else
        {
            newConversation.chatVersion = -1;
        }
        
        if (![newConversation isEqualToConversation:listConversation])
        {
            storeConversationToDatabase(self, newConversation);
            
            TG_SYNCHRONIZED_BEGIN(_cachedConversations);
            _cachedConversations[conversationId] = newConversation;
            TG_SYNCHRONIZED_END(_cachedConversations);
            
            [ActionStageInstance() dispatchResource:[NSString stringWithFormat:@"/tg/conversation/(%lld)/conversation", conversationId] resource:[[SGraphObjectNode alloc] initWithObject:newConversation]];
        }
    } synchronous:false];
}

- (void)actualizeConversation:(int64_t)conversationId dispatch:(bool)dispatch
{
    [self actualizeConversation:conversationId dispatch:dispatch conversation:nil forceUpdate:false addUnreadCount:0 addServiceUnreadCount:0 keepDate:false];
}

- (void)actualizeConversation:(int64_t)conversationId dispatch:(bool)dispatch conversation:(TGConversation *)conversation forceUpdate:(bool)forceUpdate addUnreadCount:(int)addUnreadCount addServiceUnreadCount:(int)addServiceUnreadCount keepDate:(bool)keepDate
{
    [self dispatchOnDatabaseThread:^
    {
        if (TGPeerIdIsChannel(conversationId)) {
            
        } else {
            bool isBroadcast = [self isConversationBroadcast:conversationId];
            
            TGConversation *listConversation = [self loadConversationWithId:conversationId];
            
            if (listConversation == nil && conversation == nil && conversationId < 0)
            {
                TGLog(@"New message from chat, but chat wasn't found");
                return;
            }
            
            TGConversation *newConversation = nil;
            if (conversation != nil)
                newConversation = [conversation copy];
            else if (listConversation != nil)
            {
                newConversation = [listConversation copy];
            }
            else
            {
                newConversation = [[TGConversation alloc] initWithConversationId:conversationId unreadCount:0 serviceUnreadCount:0];
            }
            
            newConversation.isBroadcast = isBroadcast;
            
            if (listConversation != nil)
            {
                newConversation.unreadCount = listConversation.unreadCount;
                newConversation.serviceUnreadCount = listConversation.serviceUnreadCount;
                if (newConversation.chatVersion < listConversation.chatVersion || newConversation.chatParticipants == nil)
                {
                    newConversation.chatVersion = listConversation.chatVersion;
                    newConversation.chatParticipants = listConversation.chatParticipants;
                }
            }
            
            newConversation.unreadCount += addUnreadCount;
            if (newConversation.unreadCount < 0)
                newConversation.unreadCount = 0;
            
            newConversation.serviceUnreadCount += addServiceUnreadCount;
            if (newConversation.serviceUnreadCount < 0)
                newConversation.serviceUnreadCount = 0;
            
            NSNumber *nConversationId = [[NSNumber alloc] initWithLongLong:conversationId];
            
            FMResultSet *deliveryErrorResult = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE cid=? AND dstate=? LIMIT 1", _outgoingMessagesTableName], nConversationId, [[NSNumber alloc] initWithInt:TGMessageDeliveryStateFailed]];
            bool hasFailed = [deliveryErrorResult next];
            deliveryErrorResult = nil;
            
            FMResultSet *messageResult = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE cid=? ORDER BY date DESC LIMIT ?", _messagesTableName], nConversationId, [[NSNumber alloc] initWithInt:hasFailed ? 4 : 1]];
            
            if ([messageResult next])
            {
                NSString *text = [messageResult stringForColumn:@"message"];
                NSData *media = [messageResult dataForColumn:@"media"];
                bool unread = [messageResult longLongIntForColumn:@"unread"] ? 1 : 0;
                int64_t fromUid = [messageResult longLongIntForColumn:@"from_id"];
                bool outgoing = [messageResult intForColumn:@"outgoing"];
                int date = [messageResult intForColumn:@"date"];
                int flags = [messageResult intForColumn:@"flags"];
                NSData *contentProperties = [messageResult dataForColumn:@"content_properties"];
                TGMessageDeliveryState deliveryState = (TGMessageDeliveryState)[messageResult intForColumn:@"dstate"];
                
                int oldDate = newConversation.date;
                
                TGMessage *message = [[TGMessage alloc] init];
                message.text = text;
                message.mediaAttachments = [TGMessage parseMediaAttachments:media];
                message.outgoing = outgoing;
                message.date = date;
                message.fromUid = fromUid;
                message.unread = unread;
                message.deliveryState = deliveryState;
                message.flags = flags;
                message.contentProperties = [TGMessage parseContentProperties:contentProperties];
                [newConversation mergeMessage:message];
                
                if ((keepDate || message.isBroadcast))// && oldDate > newConversation.date)
                    newConversation.date = oldDate;
                
                if (hasFailed)
                {
                    bool anyFailed = false;

                    int dstateIndex = [messageResult columnIndexForName:@"dstate"];
                    
                    while ([messageResult next])
                    {
                        if ([messageResult intForColumnIndex:dstateIndex] == TGMessageDeliveryStateFailed)
                        {
                            anyFailed = true;
                            break;
                        }
                    }
                    
                    if (!anyFailed)
                        hasFailed = false;
                }
                
                newConversation.deliveryError = hasFailed;
                
                if (forceUpdate || listConversation == nil || ![newConversation isEqualToConversation:listConversation])
                {
                    TG_SYNCHRONIZED_BEGIN(_unreadCountByConversation);
                    _unreadCountByConversation[conversationId] = newConversation.unreadCount;
                    TG_SYNCHRONIZED_END(_unreadCountByConversation);
                    
                    TG_SYNCHRONIZED_BEGIN(_cachedConversations);
                    _cachedConversations[conversationId] = newConversation;
                    TG_SYNCHRONIZED_END(_cachedConversations);
                    
                    storeConversationToDatabase(self, newConversation);
                    
                    if (dispatch)
                    {
                        [ActionStageInstance() dispatchResource:isBroadcast ? _liveBroadcastMessagesDispatchPath : _liveMessagesDispatchPath resource:[[SGraphObjectNode alloc] initWithObject:[NSArray arrayWithObject:newConversation]]];
                        [ActionStageInstance() dispatchResource:[NSString stringWithFormat:@"/tg/conversation/(%lld)/conversation", conversationId] resource:[[SGraphObjectNode alloc] initWithObject:newConversation]];
                    }
                }
            }
            else
            {
                newConversation.outgoing = false;
                newConversation.text = nil;
                newConversation.media = nil;
                newConversation.unread = false;
                newConversation.unreadCount = 0;
                newConversation.serviceUnreadCount = 0;
                newConversation.fromUid = 0;
                newConversation.deliveryError = false;
                newConversation.deliveryState = TGMessageDeliveryStateDelivered;
                newConversation.date = listConversation == nil ? conversation.date : listConversation.date;
                
                if (forceUpdate || listConversation == nil || ![newConversation isEqualToConversation:listConversation])
                {
                    TG_SYNCHRONIZED_BEGIN(_unreadCountByConversation);
                    _unreadCountByConversation[conversationId] = newConversation.unreadCount;
                    TG_SYNCHRONIZED_END(_unreadCountByConversation);
                    
                    TG_SYNCHRONIZED_BEGIN(_cachedConversations);
                    _cachedConversations[conversationId] = newConversation;
                    TG_SYNCHRONIZED_END(_cachedConversations);
                    
                    storeConversationToDatabase(self, newConversation);
                }
                
                if (dispatch)
                {
                    [ActionStageInstance() dispatchResource:isBroadcast ? _liveBroadcastMessagesDispatchPath : _liveMessagesDispatchPath resource:[[SGraphObjectNode alloc] initWithObject:[NSArray arrayWithObject:newConversation]]];
                    [ActionStageInstance() dispatchResource:[NSString stringWithFormat:@"/tg/conversation/(%lld)/conversation", conversationId] resource:[[SGraphObjectNode alloc] initWithObject:newConversation]];
                }
            }
        }
    } synchronous:false];
}

bool searchDialogsResultComparator(const std::pair<id, int> &obj1, const std::pair<id, int> &obj2)
{
    return obj1.second > obj2.second;
}

- (void)searchDialogs:(NSString *)query ignoreUid:(int)ignoreUid partial:(bool)partial completion:(void (^)(NSDictionary *, bool))completion isCancelled:(bool (^)())isCancelled
{
    [self dispatchOnDatabaseThread:^
    {
        if (isCancelled && isCancelled())
            return;
        
        NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
        
        std::vector<std::pair<id, int> > searchResults;
        
        std::set<int> foundUids;
        
        static NSMutableCharacterSet *characterSet = nil;
        static NSCharacterSet *whitespaceCharacterSet = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            characterSet = [[NSMutableCharacterSet alloc] init];
            [characterSet formUnionWithCharacterSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
            [characterSet formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            whitespaceCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        });
        
        NSString *cleanQuery1 = [[query stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
        
        NSArray *queryParts = breakStringIntoParts(cleanQuery1, characterSet, whitespaceCharacterSet);
        
        {
            FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT data FROM %@ where variant_sort_key>? AND variant_sort_key<? ORDER BY variant_sort_key DESC LIMIT 128", _channelListTableName], TGConversationSortKeyData(TGConversationSortKeyLowerBound(TGConversationKindPersistentChannel)), TGConversationSortKeyData(TGConversationSortKeyUpperBound(TGConversationKindPersistentChannel))];
            PSKeyValueDecoder *decoder = [[PSKeyValueDecoder alloc] init];
            while ([result next]) {
                [decoder resetData:[result dataForColumnIndex:0]];
                NSString *chatTitle = [TGConversation chatTitleForDecoder:decoder];
                
                NSArray *titleParts = breakStringIntoParts([chatTitle lowercaseString], characterSet, whitespaceCharacterSet);
                
                bool everyPartMatches = true;
                for (NSString *queryPart in queryParts)
                {
                    bool found = false;
                    for (NSString *string in titleParts)
                    {
                        if ([string rangeOfString:queryPart options:NSDiacriticInsensitiveSearch].location == 0)
                        {
                            found = true;
                            break;
                        }
                    }
                    
                    if (!found)
                    {
                        everyPartMatches = false;
                        break;
                    }
                }
                
                if (everyPartMatches)
                {
                    [decoder rewind];
                    TGConversation *conversation = [[TGConversation alloc] initWithKeyValueCoder:decoder];
                    searchResults.push_back(std::pair<id, int>(conversation, TGConversationSortKeyTimestamp(conversation.variantSortKey)));
                }
            }
        }
        
        {
            
            FMResultSet *listResult = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT * FROM %@ ORDER BY DATE DESC LIMIT 512", _conversationListTableName]];
            
            int cidIndex = [listResult columnIndexForName:@"cid"];
            int dateIndex = [listResult columnIndexForName:@"date"];
            int titleIndex = [listResult columnIndexForName:@"chat_title"];
            int participantsIndex = [listResult columnIndexForName:@"participants"];
            
            std::map<int, std::vector<std::pair<int, TGConversation *> > > userToDateAndConversations;
            std::vector<int> usersToLoad;
            
            int counter = 0;
            
            while ([listResult next])
            {
                if (counter++ % 10 == 0)
                {
                    if (isCancelled && isCancelled())
                        return;
                }
                
                int64_t cid = [listResult longLongIntForColumnIndex:cidIndex];
                int date = [listResult intForColumnIndex:dateIndex];
                
                if (cid <= INT_MIN)
                {
                    NSData *participantsData = [listResult dataForColumnIndex:participantsIndex];
                    
                    TGConversationParticipantsData *participants = [TGConversationParticipantsData deserializeData:participantsData];
                    if (participants.chatParticipantUids.count != 0)
                    {
                        int uid = [participants.chatParticipantUids[0] intValue];
                        TGConversation *conversation = loadConversationFromDatabase(listResult);
                        
                        userToDateAndConversations[uid].push_back(std::pair<int, TGConversation *>(date, conversation));
                        usersToLoad.push_back(uid);
                    }
                }
                else if (cid < 0)
                {
                    NSString *chatTitle = [listResult stringForColumnIndex:titleIndex];
                    NSArray *titleParts = breakStringIntoParts([chatTitle lowercaseString], characterSet, whitespaceCharacterSet);
                    
                    bool everyPartMatches = true;
                    for (NSString *queryPart in queryParts)
                    {
                        bool found = false;
                        for (NSString *string in titleParts)
                        {
                            if ([string rangeOfString:queryPart options:NSDiacriticInsensitiveSearch].location == 0)
                            {
                                found = true;
                                break;
                            }
                        }
                        
                        if (!found)
                        {
                            everyPartMatches = false;
                            break;
                        }
                    }
                    
                    if (everyPartMatches)
                    {
                        TGConversation *conversation = loadConversationFromDatabase(listResult);
                        searchResults.push_back(std::pair<id, int>(conversation, date));
                    }
                }
                else
                {
                    userToDateAndConversations[(int)cid].push_back(std::pair<int, TGConversation *>(date, nil));
                    usersToLoad.push_back((int)cid);
                }
            }
            
            NSMutableString *testString = [[NSMutableString alloc] initWithCapacity:128];
            NSMutableDictionary *cache = transliterationPartsCache();
            
            NSMutableString *mutableQuery = [[NSMutableString alloc] initWithString:cleanQuery1];
            CFStringTransform((CFMutableStringRef)mutableQuery, NULL, kCFStringTransformToLatin, false);
            CFStringTransform((CFMutableStringRef)mutableQuery, NULL, kCFStringTransformStripCombiningMarks, false);
            
            NSArray *latinQueryParts = breakStringIntoParts(mutableQuery, characterSet, whitespaceCharacterSet);
            
            if (latinQueryParts.count != 0)
            {
                std::tr1::shared_ptr<std::map<int, TGUser *> > pUsers = [self loadUsers:usersToLoad];
                bool useCache = pUsers->size() < 1500;
                
                for (auto it : *pUsers)
                {
                    if (counter++ % 10 == 0)
                    {
                        if (isCancelled && isCancelled())
                            return;
                    }
                    
                    bool failed = true;
                    
                    NSString *firstName = it.second.firstName;
                    NSString *lastName = it.second.lastName;
                    
                    if (firstName.length != 0 || lastName.length != 0)
                    {
                        [testString deleteCharactersInRange:NSMakeRange(0, testString.length)];
                        if (firstName.length != 0)
                        {
                            [testString appendString:firstName];
                            [testString appendString:@" "];
                        }
                        if (lastName.length != 0)
                            [testString appendString:lastName];
                        
                        NSArray *testParts = nil;
                        
                        if (useCache)
                        {
                            testParts = [cache objectForKey:testString];
                            if (testParts == nil)
                            {
                                NSString *originalString = [testString copy];
                                
                                CFStringTransform((CFMutableStringRef)testString, NULL, kCFStringTransformToLatin, false);
                                CFStringTransform((CFMutableStringRef)testString, NULL, kCFStringTransformStripCombiningMarks, false);
                                
                                testParts = breakStringIntoParts([testString lowercaseString], characterSet, whitespaceCharacterSet);
                                if (testParts != nil)
                                    [cache setObject:testParts forKey:originalString];
                            }
                        }
                        else
                        {
                            testParts = breakStringIntoParts([testString lowercaseString], characterSet, whitespaceCharacterSet);
                        }
                        
                        bool everyPartMatches = true;
                        for (NSString *queryPart in latinQueryParts)
                        {
                            bool hasMatches = false;
                            for (NSString *testPart in testParts)
                            {
                                if ([testPart hasPrefix:queryPart])
                                {
                                    hasMatches = true;
                                    break;
                                }
                            }
                            
                            if (!hasMatches)
                            {
                                everyPartMatches = false;
                                break;
                            }
                        }
                        if (everyPartMatches)
                            failed = false;
                    }
                    else
                        failed = true;
                    
                    if (!failed)
                    {
                        auto conversationsIt = userToDateAndConversations.find(it.first);
                        if (conversationsIt != userToDateAndConversations.end())
                        {
                            for (auto itemIt : conversationsIt->second)
                            {
                                searchResults.push_back(std::pair<id, int>(itemIt.second == nil ? it.second : itemIt.second, itemIt.first));
                                if (itemIt.second == nil)
                                    foundUids.insert(it.first);
                            }
                        }
                    }
                }
            }
        }
        
        NSMutableArray *chatList = [[NSMutableArray alloc] init];
        
        std::sort(searchResults.begin(), searchResults.end(), &searchDialogsResultComparator);
        for (std::vector<std::pair<id, int> >::iterator it = searchResults.begin(); it != searchResults.end(); it++)
        {
            [chatList addObject:it->first];
        }
        
        if (isCancelled && isCancelled())
            return;
        
        if (partial)
        {
            if (completion)
                completion(@{@"chatList": [[NSArray alloc] initWithArray:chatList]}, false);
        }
        
        std::set<int> *pFoundUids = &foundUids;
        [self searchContacts:query ignoreUid:ignoreUid searchPhonebook:false completion:^(NSDictionary *result)
        {
            if ([result objectForKey:@"users"] != nil)
            {   
                for (TGUser *user in [result objectForKey:@"users"])
                {
                    if (pFoundUids->find(user.uid) == pFoundUids->end())
                    {
                        [chatList addObject:user];
                    }
                }
            }
        } internalIsCancelled:isCancelled];
        
        [resultDict setObject:chatList forKey:@"chats"];
        
        if (completion)
            completion(resultDict, true);
    } synchronous:false];
}

static NSArray *breakStringIntoParts(NSString *string, NSCharacterSet *characterSet, NSCharacterSet *whitespaceCharacterSet)
{
    NSMutableArray *parts = [[NSMutableArray alloc] initWithCapacity:2];
    
    NSScanner *scanner = [[NSScanner alloc] initWithString:string];
    NSString *token = nil;
    
    if ([scanner scanCharactersFromSet:characterSet intoString:&token])
    {
        token = [token stringByTrimmingCharactersInSet:whitespaceCharacterSet];
        if (token.length != 0)
            [parts addObject:token];
    }
    
    while ([scanner scanUpToCharactersFromSet:characterSet intoString:&token])
    {
        [parts addObject:token];
        if ([scanner scanCharactersFromSet:characterSet intoString:&token])
        {
            token = [token stringByTrimmingCharactersInSet:whitespaceCharacterSet];
            if (token.length != 0)
                [parts addObject:token];
        }
    }
    
    return parts;
}

static NSMutableDictionary *transliterationPartsCache()
{
    static NSMutableDictionary *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        dict = [[NSMutableDictionary alloc] init];
    });
    return dict;
}

- (dispatch_block_t)searchContacts:(NSString *)query ignoreUid:(int)ignoreUid searchPhonebook:(bool)searchPhonebook completion:(void (^)(NSDictionary *))completion
{
    return [self searchContacts:query ignoreUid:ignoreUid searchPhonebook:searchPhonebook completion:completion internalIsCancelled:NULL];
}

- (dispatch_block_t)searchContacts:(NSString *)query ignoreUid:(int)ignoreUid searchPhonebook:(bool)searchPhonebook completion:(void (^)(NSDictionary *))completion internalIsCancelled:(bool (^)())internalIsCancelled
{
    __block bool isCancelled = false;
    
    [self dispatchOnDatabaseThread:^
    {
        [self buildTransliterationCache];
        
        __unused CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        
        NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
        
        NSMutableArray *usersArray = [[NSMutableArray alloc] init];
        
        static NSMutableCharacterSet *characterSet = nil;
        static NSCharacterSet *whitespaceCharacterSet = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            characterSet = [[NSMutableCharacterSet alloc] init];
            [characterSet formUnionWithCharacterSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
            [characterSet formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            whitespaceCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        });
     
        NSMutableString *mutableQuery = [[NSMutableString alloc] initWithString:query];
        CFStringTransform((CFMutableStringRef)mutableQuery, NULL, kCFStringTransformToLatin, false);
        CFStringTransform((CFMutableStringRef)mutableQuery, NULL, kCFStringTransformStripCombiningMarks, false);
        
        NSArray *latinQueryParts = breakStringIntoParts([mutableQuery lowercaseString], characterSet, whitespaceCharacterSet);
        
        NSMutableString *testString = [[NSMutableString alloc] initWithCapacity:128];
        NSString *nameQuery = [[query lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        NSMutableDictionary *cache = transliterationPartsCache();
        
        NSArray *contactUsers = [self loadContactUsers];
        bool useCache = contactUsers.count < 1500;
        TGLog(@"searchContacts useCache = %d", (int)useCache);
        int counter = 0;
        for (TGUser *user in contactUsers)
        {
            if (user.uid == ignoreUid)
                continue;
            
            if (isCancelled)
                return;
            if (((counter++) % 32 == 0) && internalIsCancelled && internalIsCancelled())
                return;
            
            bool failed = true;
            
            NSString *firstName = user.firstName;
            NSString *lastName = user.lastName;
            
            if (user.userName.length != 0 && [[user.userName lowercaseString] hasPrefix:nameQuery])
            {
                [usersArray addObject:user];
                continue;
            }
            
            if (firstName.length != 0 || lastName.length != 0)
            {
                [testString deleteCharactersInRange:NSMakeRange(0, testString.length)];
                if (firstName.length != 0)
                {
                    [testString appendString:firstName];
                    [testString appendString:@" "];
                }
                if (lastName.length != 0)
                    [testString appendString:lastName];
                
                NSArray *testParts = [cache objectForKey:testString];
                if (testParts == nil)
                {
                    NSString *originalString = [testString copy];
                    
                    if (useCache)
                    {
                        CFStringTransform((CFMutableStringRef)testString, NULL, kCFStringTransformToLatin, false);
                        CFStringTransform((CFMutableStringRef)testString, NULL, kCFStringTransformStripCombiningMarks, false);
                        
                        testParts = breakStringIntoParts([testString lowercaseString], characterSet, whitespaceCharacterSet);
                        if (testParts != nil)
                            [cache setObject:testParts forKey:originalString];
                    }
                    else
                    {
                        testParts = breakStringIntoParts([testString lowercaseString], characterSet, whitespaceCharacterSet);
                    }
                }
                
                bool everyPartMatches = true;
                for (NSString *queryPart in latinQueryParts)
                {
                    bool hasMatches = false;
                    for (NSString *testPart in testParts)
                    {
                        if ([testPart hasPrefix:queryPart])
                        {
                            hasMatches = true;
                            break;
                        }
                    }
                    
                    if (!hasMatches)
                    {
                        everyPartMatches = false;
                        break;
                    }
                }
                if (everyPartMatches)
                    failed = false;
            }
            else
                failed = true;
            
            if (!failed)
                [usersArray addObject:user];
        }
        TGLog(@"Search time: %f ms", (CFAbsoluteTimeGetCurrent() - startTime) * 1000.0);
        
        if (searchPhonebook)
        {
            startTime = CFAbsoluteTimeGetCurrent();
            NSArray *contactResults = [TGDatabaseInstance() searchPhonebookContacts:query contacts:[self loadPhonebookContacts]];
            
            std::set<int> remoteContactIds;
            
            for (TGUser *user in [TGDatabaseInstance() loadContactUsers])
            {
                if (user.contactId)
                    remoteContactIds.insert(user.contactId);
            }
            
            for (TGPhonebookContact *phonebookContact in contactResults)
            {
                if (isCancelled)
                    return;
                if (((counter++) % 32 == 0) && internalIsCancelled && internalIsCancelled())
                    return;
                
                //int phonesCount = phonebookContact.phoneNumbers.count;
                for (TGPhoneNumber *phoneNumber in phonebookContact.phoneNumbers)
                {
                    if (remoteContactIds.find(phoneNumber.phoneId) != remoteContactIds.end())
                        continue;
                    
                    TGUser *phonebookUser = [[TGUser alloc] init];
                    phonebookUser.firstName = phonebookContact.firstName;
                    phonebookUser.lastName = phonebookContact.lastName;
                    phonebookUser.uid = -phonebookContact.nativeId;
                    phonebookUser.phoneNumber = phoneNumber.number;
                    //if (phonesCount != 0)
                    //    phonebookUser.customProperties = [[NSDictionary alloc] initWithObjectsAndKeys:phoneNumber.label, @"label", nil];
                    [usersArray addObject:phonebookUser];
                    
                    break;
                }
            }
            
            TGLog(@"Phonebook time: +%f ms", (CFAbsoluteTimeGetCurrent() - startTime) * 1000.0);
        }
        
        [resultDict setObject:usersArray forKey:@"users"];
        
        if (completion)
            completion(resultDict);
    } synchronous:false];
    
    return ^
    {
        isCancelled = true;
    };
}

- (void)buildTransliterationCache
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        [self dispatchOnDatabaseThread:^
        {
            NSArray *users = [self loadContactUsers];
            NSArray *contacts = [self loadPhonebookContacts];
            
            if (users.count + contacts.count > 2000)
                return;
            
            NSString *cacheFilename = [[TGAppDelegate cachePath] stringByAppendingPathComponent:@"translit.cache"];
            NSData *transliterationData = [[NSData alloc] initWithContentsOfFile:cacheFilename];
            if (transliterationData != nil)
            {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                
                NSInputStream *is = [[NSInputStream alloc] initWithData:transliterationData];
                [is open];
                int count = 0;
                [is read:(uint8_t *)&count maxLength:4];
                for (int i = 0; i < count; i++)
                {
                    int length = 0;
                    [is read:(uint8_t *)&length maxLength:4];
                    
                    uint8_t keyBytes[length];
                    [is read:keyBytes maxLength:length];
                    
                    NSString *key = [[NSString alloc] initWithBytes:keyBytes length:length encoding:NSUTF8StringEncoding];
                    
                    int valueCount = 0;
                    [is read:(uint8_t *)&valueCount maxLength:4];
                    NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:valueCount];
                    for (int j = 0; j < valueCount; j++)
                    {
                        length = 0;
                        [is read:(uint8_t *)&length maxLength:4];
                        uint8_t valueBytes[length];
                        [is read:valueBytes maxLength:length];
                        
                        NSString *value = [[NSString alloc] initWithBytes:valueBytes length:length encoding:NSUTF8StringEncoding];
                        if (value.length != 0)
                            [values addObject:value];
                    }
                    
                    if (key != nil && values.count != 0)
                        [dict setObject:values forKey:key];
                }
                [is close];
                
                [self dispatchOnDatabaseThread:^
                {
                    [transliterationPartsCache() addEntriesFromDictionary:dict];
                } synchronous:false];
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
            {
                CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
                
                static NSMutableCharacterSet *characterSet = nil;
                static NSCharacterSet *whitespaceCharacterSet = nil;
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^
                {
                    characterSet = [[NSMutableCharacterSet alloc] init];
                    [characterSet formUnionWithCharacterSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
                    [characterSet formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    whitespaceCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
                });
                
                NSMutableString *testString = [[NSMutableString alloc] initWithCapacity:128];
                
                NSMutableDictionary *cache = [[NSMutableDictionary alloc] init];
                
                for (TGUser *user in users)
                {            
                    NSString *firstName = user.firstName;
                    NSString *lastName = user.lastName;
                    
                    if (firstName.length != 0 || lastName.length != 0)
                    {
                        [testString deleteCharactersInRange:NSMakeRange(0, testString.length)];
                        if (firstName.length != 0)
                        {
                            [testString appendString:firstName];
                            [testString appendString:@" "];
                        }
                        if (lastName.length != 0)
                            [testString appendString:lastName];
                        
                        NSArray *testParts = [cache objectForKey:testString];
                        if (testParts == nil)
                        {
                            NSString *originalString = [testString copy];
                            
                            CFStringTransform((CFMutableStringRef)testString, NULL, kCFStringTransformToLatin, false);
                            CFStringTransform((CFMutableStringRef)testString, NULL, kCFStringTransformStripCombiningMarks, false);
                            
                            testParts = breakStringIntoParts([testString lowercaseString], characterSet, whitespaceCharacterSet);
                            if (testParts != nil)
                                [cache setObject:testParts forKey:originalString];
                        }
                    }
                }
                
                for (TGPhonebookContact *user in contacts)
                {
                    NSString *firstName = user.firstName;
                    NSString *lastName = user.lastName;
                    
                    if (firstName.length != 0 || lastName.length != 0)
                    {
                        [testString deleteCharactersInRange:NSMakeRange(0, testString.length)];
                        if (firstName.length != 0)
                        {
                            [testString appendString:firstName];
                            [testString appendString:@" "];
                        }
                        if (lastName.length != 0)
                            [testString appendString:lastName];
                        
                        NSArray *testParts = [cache objectForKey:testString];
                        if (testParts == nil)
                        {
                            NSString *originalString = [testString copy];
                            
                            CFStringTransform((CFMutableStringRef)testString, NULL, kCFStringTransformToLatin, false);
                            CFStringTransform((CFMutableStringRef)testString, NULL, kCFStringTransformStripCombiningMarks, false);
                            
                            testParts = breakStringIntoParts([testString lowercaseString], characterSet, whitespaceCharacterSet);
                            if (testParts != nil)
                                [cache setObject:testParts forKey:originalString];
                        }
                    }
                }
                
                TGLog(@"Contacts cache built in %fs", CFAbsoluteTimeGetCurrent() - startTime);
                
                [self dispatchOnDatabaseThread:^
                {
                    [transliterationPartsCache() addEntriesFromDictionary:cache];
                } synchronous:false];
                
                NSMutableData *data = [[NSMutableData alloc] init];
                int32_t count = (int32_t)cache.count;
                [data appendBytes:&count length:4];
                
                [cache enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *values, __unused BOOL *stop)
                {
                    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
                    int32_t length = (int32_t)keyData.length;
                    [data appendBytes:&length length:4];
                    [data appendData:keyData];
                    
                    int32_t valueCount = (int32_t)values.count;
                    [data appendBytes:&valueCount length:4];
                    for (NSString *value in values)
                    {
                        NSData *valueData = [value dataUsingEncoding:NSUTF8StringEncoding];
                        length = (int32_t)valueData.length;
                        [data appendBytes:&length length:4];
                        [data appendData:valueData];
                    }
                }];
                
                [data writeToFile:cacheFilename atomically:false];
            });
        } synchronous:false];
    });
}

- (NSArray *)searchPhonebookContacts:(NSString *)query contacts:(NSArray *)contacts
{    
    NSMutableArray *usersArray = [[NSMutableArray alloc] init];
    
    static NSMutableCharacterSet *characterSet = nil;
    static NSCharacterSet *whitespaceCharacterSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        characterSet = [[NSMutableCharacterSet alloc] init];
        [characterSet formUnionWithCharacterSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
        [characterSet formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        whitespaceCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    });
    
    NSMutableString *mutableQuery = [[NSMutableString alloc] initWithString:query];
    CFStringTransform((CFMutableStringRef)mutableQuery, NULL, kCFStringTransformToLatin, false);
    CFStringTransform((CFMutableStringRef)mutableQuery, NULL, kCFStringTransformStripCombiningMarks, false);
    
    NSArray *latinQueryParts = breakStringIntoParts([mutableQuery lowercaseString], characterSet, whitespaceCharacterSet);
    
    NSMutableString *testString = [[NSMutableString alloc] initWithCapacity:128];
    
    NSMutableDictionary *cache = transliterationPartsCache();
    
    bool useCache = contacts.count < 1500;
    
    for (TGPhonebookContact *user in contacts)
    {
        bool failed = true;
        
        NSString *firstName = user.firstName;
        NSString *lastName = user.lastName;
        
        if (firstName.length != 0 || lastName.length != 0)
        {
            [testString deleteCharactersInRange:NSMakeRange(0, testString.length)];
            if (firstName.length != 0)
            {
                [testString appendString:firstName];
                [testString appendString:@" "];
            }
            if (lastName.length != 0)
                [testString appendString:lastName];
            
            NSArray *testParts = nil;
            if (useCache)
            {
                testParts = [cache objectForKey:testString];
                if (testParts == nil)
                {
                    NSString *originalString = [testString copy];
                    
                    CFStringTransform((CFMutableStringRef)testString, NULL, kCFStringTransformToLatin, false);
                    CFStringTransform((CFMutableStringRef)testString, NULL, kCFStringTransformStripCombiningMarks, false);
                    
                    testParts = breakStringIntoParts([testString lowercaseString], characterSet, whitespaceCharacterSet);
                    if (testParts != nil)
                        [cache setObject:testParts forKey:originalString];
                }
            }
            else
            {
                testParts = breakStringIntoParts([testString lowercaseString], characterSet, whitespaceCharacterSet);
            }
            
            bool everyPartMatches = true;
            for (NSString *queryPart in latinQueryParts)
            {
                bool hasMatches = false;
                for (NSString *testPart in testParts)
                {
                    if ([testPart hasPrefix:queryPart])
                    {
                        hasMatches = true;
                        break;
                    }
                }
                
                if (!hasMatches)
                {
                    everyPartMatches = false;
                    break;
                }
            }
            if (everyPartMatches)
                failed = false;
        }
        else
            failed = true;
        
        if (!failed)
        {
            [usersArray addObject:user];
        }
    }
    
    return usersArray;
}

- (dispatch_block_t)searchMessages:(NSString *)query peerId:(int64_t)peerId completion:(void (^)(NSArray *, NSSet *))completion
{
    static int32_t nextToken = 1;
    static int32_t currentToken = 0;
    int32_t queryToken = nextToken++;
    __block bool queryCancelled = false;
    
    [self dispatchOnIndexThread:^
    {
        bool containsHashtag = [query rangeOfString:@"#"].location != NSNotFound;
        
        currentToken = queryToken;
        
        NSString *lowercaseQuery = [query lowercaseString];
        NSString *cleanQuery = [NSString stringWithFormat:@"\"%@*\"", [lowercaseQuery stringByReplacingOccurrencesOfString:@"*" withString:@""]];
        
        NSMutableArray *mids = [[NSMutableArray alloc] init];
        
        /*int32_t testId = 1;
        FMResultSet *testResult = [_indexDatabase executeQuery:[[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE rowid=?", _messageIndexTableName], @(testId)];
        if ([testResult next])
        {
            TGLog(@"%@", testResult.resultDictionary);
        }*/
        
        CFAbsoluteTime searchStartTime = CFAbsoluteTimeGetCurrent();
        [_indexDatabase setSoftShouldCacheStatements:false];
        FMResultSet *result = nil;
        if (peerId == 0)
        {
            result = [_indexDatabase executeQuery:[NSString stringWithFormat:@"SELECT docid FROM %@ WHERE text MATCH '%@' ORDER BY docid DESC", _messageIndexTableName, cleanQuery]];
        }
        else
        {
            NSString *peerIdTag = [[NSString alloc] initWithFormat:@"z0z9p%lld%s", (long long)ABS(peerId), peerId < 0 ? "c" : "p"];
            NSString *query = [NSString stringWithFormat:@"SELECT docid FROM %@ WHERE text MATCH '%@' INTERSECT SELECT docid FROM %@ WHERE text MATCH '%@'", _messageIndexTableName, cleanQuery, _messageIndexTableName, peerIdTag];
            result = [_indexDatabase executeQuery:query];
        }
        
        [_indexDatabase setSoftShouldCacheStatements:true];
        int docidIndex = [result columnIndexForName:@"docid"];
        while ([result next])
        {
            [mids addObject:[[NSNumber alloc] initWithInt:[result intForColumnIndex:docidIndex]]];
        }
        TGLog(@"Search time: %f s", CFAbsoluteTimeGetCurrent() - searchStartTime);
        
        currentToken = 0;
        
        if (mids.count == 0)
        {
            if (completion)
                completion(@[], [NSSet set]);
        }
        else
        {
            NSMutableArray *messages = [[NSMutableArray alloc] init];
            
            [self dispatchOnDatabaseThread:^
            {
                CFAbsoluteTime extractionStartTime = CFAbsoluteTimeGetCurrent();
                std::set<int64_t> conversationsToLoad;
                
                int midsCount = (int)mids.count;
                
                NSMutableString *rangeString = [[NSMutableString alloc] init];
                for (int i = 0; i < midsCount; i++)
                {
                    if (i % 64 == 0)
                    {
                        if (queryCancelled)
                            return;
                    }
                    
                    if (rangeString.length != 0)
                        [rangeString deleteCharactersInRange:NSMakeRange(0, rangeString.length)];
                    
                    std::set<int> midsInRange;
                    
                    bool first = true;
                    int count = 0;
                    for (; count < 200 && i < midsCount; i++, count++)
                    {
                        if (first)
                            first = false;
                        else
                            [rangeString appendString:@","];
                        
                        int mid = [[mids objectAtIndex:i] intValue];
                        [rangeString appendFormat:@"%d", mid];
                        midsInRange.insert(mid);
                    }
                    
                    NSString *messagesQueryFormat = [[NSString alloc] initWithFormat:@"SELECT mid, cid, message, media, date, from_id, to_id, outgoing, dstate, unread FROM %@ WHERE mid IN (%@)", _messagesTableName, rangeString];
                    FMResultSet *result = [_database executeQuery:messagesQueryFormat];
                    
                    int midIndex = [result columnIndexForName:@"mid"];
                    int cidIndex = [result columnIndexForName:@"cid"];
                    int messageIndex = [result columnIndexForName:@"message"];
                    int mediaIndex = [result columnIndexForName:@"media"];
                    int dateIndex = [result columnIndexForName:@"date"];
                    int fromIdIndex = [result columnIndexForName:@"from_id"];
                    int toIdIndex = [result columnIndexForName:@"to_id"];
                    int outgoingIndex = [result columnIndexForName:@"outgoing"];
                    int dstateIndex = [result columnIndexForName:@"dstate"];
                    int unreadIndex = [result columnIndexForName:@"unread"];
                    
                    while ([result next])
                    {
                        if (queryCancelled)
                            return;
                        
                        NSArray *mediaAttachments = [TGMessage parseMediaAttachments:[result dataForColumnIndex:mediaIndex]];
                        
                        NSString *text = [result stringForColumnIndex:messageIndex];
                        if (text.length == 0)
                        {
                            for (TGMediaAttachment *attachment in mediaAttachments)
                            {
                                if (attachment.type == TGImageMediaAttachmentType)
                                    text = ((TGImageMediaAttachment *)attachment).caption;
                                else if (attachment.type == TGVideoMediaAttachmentType)
                                    text = ((TGVideoMediaAttachment *)attachment).caption;
                            }
                        }
                        
                        if (containsHashtag)
                        {
                            if ([[text lowercaseString] rangeOfString:lowercaseQuery].location == NSNotFound)
                                continue;
                        }
                        
                        int mid = [result intForColumnIndex:midIndex];
                        midsInRange.erase(mid);
                        
                        TGMessage *message = [[TGMessage alloc] init];
                        message.mid = mid;
                        
                        message.cid = [result longLongIntForColumnIndex:cidIndex];
                        message.date = [result intForColumnIndex:dateIndex];
                        message.text = text;
                        
                        message.fromUid = [result longLongIntForColumnIndex:fromIdIndex];
                        message.toUid = [result longLongIntForColumnIndex:toIdIndex];
                        message.outgoing = [result intForColumnIndex:outgoingIndex] != 0;
                        message.deliveryState = (TGMessageDeliveryState)[result intForColumnIndex:dstateIndex];
                        message.unread = [result longLongIntForColumnIndex:unreadIndex];
                        message.mediaAttachments = mediaAttachments;
                        
                        conversationsToLoad.insert(message.cid);
                        
                        [messages addObject:message];
                    }
                    
                    if (!midsInRange.empty())
                    {
                        TGLog(@"***** Message index contains %ld non-existing rows, removing", midsInRange.size());
                        
                        NSMutableArray *deleteMids = [[NSMutableArray alloc] initWithCapacity:midsInRange.size()];
                        for (std::set<int>::iterator it = midsInRange.begin(); it != midsInRange.end(); it++)
                        {
                            [deleteMids addObject:[[NSNumber alloc] initWithInt:*it]];
                        }
                        
                        [self deleteMessagesFromIndex:deleteMids];
                    }
                }
                
                TGLog(@"Extraction time: %f s", CFAbsoluteTimeGetCurrent() - extractionStartTime);
                
                CFAbsoluteTime sortStartTime = CFAbsoluteTimeGetCurrent();
                
                [messages sortUsingComparator:^NSComparisonResult(TGMessage *message1, TGMessage *message2)
                {
                    if (message1.date > message2.date)
                        return NSOrderedAscending;
                    return NSOrderedDescending;
                }];
                
                TGLog(@"Sort time: %f s", CFAbsoluteTimeGetCurrent() - sortStartTime);
                
                const int maxMessages = 200;
                if (messages.count > maxMessages)
                    [messages removeObjectsInRange:NSMakeRange(maxMessages, messages.count - maxMessages)];
                
                CFAbsoluteTime conversationStartTime = CFAbsoluteTimeGetCurrent();
                std::map<int64_t, TGConversation *> loadedConversations;
                for (std::set<int64_t>::iterator it = conversationsToLoad.begin(); it != conversationsToLoad.end(); it++)
                {
                    if (queryCancelled)
                        return;
                    
                    TGConversation *conversation = [self loadConversationWithId:*it];
                    if (*it < 0 && [self isConversationBroadcast:*it])
                    {
                        conversation.isBroadcast = true;
                    }
                    
                    if (conversation != nil)
                        loadedConversations.insert(std::pair<int64_t, TGConversation *>(*it, conversation));
                    else
                        TGLog(@"***** Couldn't find conversation %lld", *it);
                }
                
                TGLog(@"Conversation parsing time: %f s", CFAbsoluteTimeGetCurrent() - conversationStartTime);
                
                NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:messages.count];
                
                CFAbsoluteTime conversationMergingTime = CFAbsoluteTimeGetCurrent();
                for (TGMessage *message in messages)
                {
                    std::map<int64_t, TGConversation *>::iterator it = loadedConversations.find(message.cid);
                    if (it == loadedConversations.end())
                        continue;
                    
                    TGConversation *conversation = [it->second copy];
                    [conversation mergeMessage:message];
                    conversation.additionalProperties = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithInt:message.mid], @"searchMessageId", nil];
                    [result addObject:conversation];
                }
                
                TGLog(@"Conversation merging time: %f s", CFAbsoluteTimeGetCurrent() - conversationMergingTime);
                
                NSMutableSet *midsSet = [[NSMutableSet alloc] initWithArray:mids];
                
                if (completion)
                    completion(result, midsSet);
            } synchronous:false];
        }
    } synchronous:false];
    
    return ^
    {
        queryCancelled = true;
        
        if (currentToken == queryToken)
        {
            TGLog(@"interrupted running search");
            sqlite3_interrupt([_indexDatabase sqliteHandle]);
        }
    };
}

- (void)deleteMessagesFromIndex:(NSArray *)mids
{
    [self dispatchOnIndexThread:^
    {
        int midsCount = (int)mids.count;
        
        NSMutableString *rangeString = [[NSMutableString alloc] init];
        for (int i = 0; i < midsCount; i++)
        {
            if (rangeString.length != 0)
                [rangeString deleteCharactersInRange:NSMakeRange(0, rangeString.length)];
            
            std::set<int> midsInRange;
            
            bool first = true;
            int count = 0;
            for (; count < 100 && i < midsCount; i++, count++)
            {
                if (first)
                    first = false;
                else
                    [rangeString appendString:@","];
                
                int mid = [[mids objectAtIndex:i] intValue];
                [rangeString appendFormat:@"%d", mid];
                midsInRange.insert(mid);
            }
            
            NSString *messagesQueryFormat = [[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE docid IN (%@)", _messageIndexTableName, rangeString];
#if TARGET_IPHONE_SIMULATOR
            TGLog(@"index: delete %@", rangeString);
#endif
            [_indexDatabase executeUpdate:messagesQueryFormat];
        }
    } synchronous:false];
}

- (void)markAllPendingMessagesAsFailed
{
    [self dispatchOnDatabaseThread:^
    {
        NSString *updateDeliveryStateFormat = [[NSString alloc] initWithFormat:@"UPDATE OR IGNORE %@ SET dstate=%d WHERE mid=?", _messagesTableName, TGMessageDeliveryStateFailed];
        
        FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE dstate=%d", _outgoingMessagesTableName, TGMessageDeliveryStatePending]];
        int midIndex = [result columnIndexForName:@"mid"];
        int cidIndex = [result columnIndexForName:@"cid"];
        
        std::set<int64_t> conversations;
        
        [_database beginTransaction];
        
        while ([result next])
        {
            int mid = [result intForColumnIndex:midIndex];
            int64_t conversationId = [result longLongIntForColumnIndex:cidIndex];
            conversations.insert(conversationId);
            
            if (TGPeerIdIsChannel(conversationId)) {
                FMResultSet *dataResult = [_database executeQuery:[NSString stringWithFormat:@"SELECT data FROM %@ WHERE cid=? AND mid=?", _channelMessagesTableName], @(conversationId), @(mid)];
                if ([dataResult next]) {
                    TGMessage *message = [[TGMessage alloc] initWithKeyValueCoder:[[PSKeyValueDecoder alloc] initWithData:[dataResult dataForColumnIndex:0]]];
                    if (message.cid == conversationId && message.mid != 0) {
                        message.deliveryState = TGMessageDeliveryStateFailed;
                        PSKeyValueEncoder *encoder = [[PSKeyValueEncoder alloc] init];
                        [message encodeWithKeyValueCoder:encoder];
                        [_database executeQuery:[NSString stringWithFormat:@"UPDATE %@ SET data=? WHERE cid=? AND mid=?", _channelMessagesTableName], encoder.data, @(conversationId), @(mid)];
                    }
                }
            } else {
                [_database executeUpdate:updateDeliveryStateFormat, [[NSNumber alloc] initWithInt:mid]];
            }
        }
        
        if (!conversations.empty())
            [_database executeUpdate:[[NSString alloc] initWithFormat:@"UPDATE %@ SET dstate=%d", _outgoingMessagesTableName, TGMessageDeliveryStateFailed]];
        
        [_database commit];
        
        for (std::set<int64_t>::iterator it = conversations.begin(); it != conversations.end(); it++)
        {
            [self actualizeConversation:*it dispatch:false];
        }
    } synchronous:false];
}

- (void)applyPts:(int)pts date:(int)date seq:(int)seq qts:(int)qts unreadCount:(int)unreadCount
{
    [self dispatchOnDatabaseThread:^
    {
        TGDatabaseState currentState = [self databaseState];
        
        if (seq > 0)
            currentState.seq = seq;
        if (pts > 0)
            currentState.pts = pts;
        if (date > 0 && date > currentState.date)
            currentState.date = date;
        if (unreadCount >= 0)
            currentState.unreadCount = unreadCount;
        if (qts > 0)
            currentState.qts = qts;
        
        [self setPts:currentState.pts date:currentState.date seq:currentState.seq qts:currentState.qts unreadCount:currentState.unreadCount];
    } synchronous:false];
}

- (void)setPts:(int)_ptsValue date:(int)_dateValue seq:(int)_seqValue qts:(int)_qtsValue unreadCount:(int)_unreadCountValue
{
    [self dispatchOnDatabaseThread:^
    {
        int pts = _ptsValue;
        int date = _dateValue;
        int seq = _seqValue;
        int qts = _qtsValue;
        int unreadCount = _unreadCountValue;
        
        int lastUnreadCount = 0;
        
        _cachedDatabaseState.pts = pts;
        _cachedDatabaseState.date = date;
        _cachedDatabaseState.seq = seq;
        _cachedDatabaseState.qts = qts;
        lastUnreadCount = _cachedDatabaseState.unreadCount;
        _cachedDatabaseState.unreadCount = unreadCount;
        
        TG_SYNCHRONIZED_BEGIN(_cachedUnreadCount);
        _cachedUnreadCount = unreadCount;
        TG_SYNCHRONIZED_END(_cachedUnreadCount);
        
        if (lastUnreadCount != unreadCount && _liveUnreadCountDispatchPath != nil)
        {
            [ActionStageInstance() dispatchOnStageQueue:^
            {
                [ActionStageInstance() dispatchResource:_liveUnreadCountDispatchPath resource:[[SGraphObjectNode alloc] initWithObject:[[NSNumber alloc] initWithInt:unreadCount]]];
            }];
        }
        
        NSMutableData *data = [[NSMutableData alloc] initWithCapacity:4 * 4];
        [data appendBytes:&pts length:4];
        [data appendBytes:&date length:4];
        [data appendBytes:&seq length:4];
        [data appendBytes:&unreadCount length:4];
        [data appendBytes:&qts length:4];
        
        if (pts == 0)
        {
            TGLog(@"****pts = 0!");
        }
        
        TGLog(@"(TGDatabase apply pts: %d, date: %d, qts: %d, seq: %d)", pts, date, qts, seq);
        
        [_database executeUpdate:[NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (key, value) VALUES (?, ?)", _serviceTableName], [[NSNumber alloc] initWithInt:_servicePtsKey], data];
        
        TG_SYNCHRONIZED_BEGIN(_ptsWatchers);
        NSArray *ptsWatchers = [_ptsWatchers copyItems];
        TG_SYNCHRONIZED_END(_ptsWatchers);
        for (void (^ptsWatcher)(int32_t) in ptsWatchers)
        {
            ptsWatcher((int32_t)pts);
        }
    } synchronous:false];
}

- (void)setUnreadCount:(int)unreadCount
{
    [self dispatchOnDatabaseThread:^
    {
        TGDatabaseState state = [self databaseState];
        state.unreadCount = unreadCount;
        [self setPts:state.pts date:state.date seq:state.seq qts:state.qts unreadCount:state.unreadCount];
    } synchronous:false];
}

- (TGDatabaseState)databaseState
{   
    __block TGDatabaseState state;
    
    [self dispatchOnDatabaseThread:^
    {
        bool validState = false;
        
        TGDatabaseState resultState;
        if (_cachedDatabaseState.pts != 0)
        {
            validState = true;
            resultState = _cachedDatabaseState;
        }
        
        if (validState)
        {
            state = resultState;
            return;
        }
        
        NSData *value = nil;
        
        FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE key=%d", _serviceTableName, _servicePtsKey]];
        if ([result next])
        {
            value = [result dataForColumn:@"value"];
        }
        
        if (value == nil || value.length < 4 * 4)
        {
            state.pts = 0;
            state.seq = 0;
            state.date = 0;
            state.unreadCount = 0;
            state.qts = 0;
        }
        else
        {
            int ptr = 0;
            
            int pts = 0;
            [value getBytes:&pts range:NSMakeRange(ptr, 4)];
            ptr += 4;
            
            int date = 0;
            [value getBytes:&date range:NSMakeRange(ptr, 4)];
            ptr += 4;
            
            int seq = 0;
            [value getBytes:&seq range:NSMakeRange(ptr, 4)];
            ptr += 4;
            
            int unreadCount = 0;
            [value getBytes:&unreadCount range:NSMakeRange(ptr, 4)];
            ptr += 4;
            
            int qts = 0;
            if ((int)value.length >= ptr + 4)
            {
                [value getBytes:&qts range:NSMakeRange(ptr, 4)];
                ptr += 4;
            }
            
            state.pts = pts;
            state.date = date;
            state.seq = seq;
            state.unreadCount = unreadCount;
            state.qts = qts;
        }
        
        _cachedDatabaseState = state;
    } synchronous:true];
    
    return state;
}

- (int)cachedUnreadCount
{
    int value = 0;
    TG_SYNCHRONIZED_BEGIN(_cachedUnreadCount);
    value = _cachedUnreadCount;
    TG_SYNCHRONIZED_END(_cachedUnreadCount);
    
    if (value != INT_MIN)
        return value;
    
    value = [self databaseState].unreadCount;
    TG_SYNCHRONIZED_BEGIN(_cachedUnreadCount);
    _cachedUnreadCount = value;
    TG_SYNCHRONIZED_END(_cachedUnreadCount);
    
    return value;
}

- (int)unreadCountForConversation:(int64_t)conversationId
{
    int unreadCount = 0;
    bool found = false;
    
    TG_SYNCHRONIZED_BEGIN(_unreadCountByConversation);
    std::map<int64_t, int>::iterator it = _unreadCountByConversation.find(conversationId);
    if (it != _unreadCountByConversation.end())
    {
        found = true;
        unreadCount = it->second;
    }
    TG_SYNCHRONIZED_END(_unreadCountByConversation);
    
    if (found)
        return unreadCount;
    
    TGLog(@"***** Suboptimal conversation unread count retrieval");
    unreadCount = [self loadConversationWithId:conversationId].unreadCount;
    return unreadCount;
}

- (void)setCustomProperty:(NSString *)key value:(NSData *)value
{
    [self dispatchOnDatabaseThread:^
    {
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO %@ (key, value) VALUES (?, ?)", _serviceTableName], [[NSNumber alloc] initWithInt:murMurHash32(key)], value];
    } synchronous:false];
}

- (void)customProperty:(NSString *)key completion:(void (^)(NSData *value))completion
{
    [self dispatchOnDatabaseThread:^
    {
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT value FROM %@ WHERE key=?", _serviceTableName], [[NSNumber alloc] initWithInt:murMurHash32(key)]];
        if ([result next])
        {
            NSData *value = [result dataForColumn:@"value"];
            result = nil;
            
            if (completion)
                completion(value);
        }
        else
        {
            if (completion)
                completion(nil);
        }
    } synchronous:false];
}

- (NSData *)customProperty:(NSString *)key
{
    __block NSData *blockResult = nil;
    
    [self dispatchOnDatabaseThread:^
    {
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT value FROM %@ WHERE key=?", _serviceTableName], [[NSNumber alloc] initWithInt:murMurHash32(key)]];
        if ([result next])
        {
            blockResult = [result dataForColumn:@"value"];
            result = nil;
        }
    } synchronous:true];
    
    return blockResult;
}

- (NSArray *)loadContactUsers
{
    NSMutableArray *users = [[NSMutableArray alloc] init];
    
    [self dispatchOnDatabaseThread:^
    {
        std::vector<int> uids;
        [self loadRemoteContactUids:uids];
        
        std::tr1::shared_ptr<std::map<int, TGUser *> > userMap = [self loadUsers:uids];
        for (std::map<int, TGUser *>::iterator it = userMap->begin(); it != userMap->end(); it++)
        {
            [users addObject:it->second];
        }
    } synchronous:true];
    
    return users;
}

- (void)loadRemoteContactUids:(std::vector<int> &)contactUids
{
    [self dispatchOnDatabaseThread:^
    {
        std::vector<int> uids;
        
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT uid FROM %@", _contactListTableName]];
        int uidIndex = [result columnIndexForName:@"uid"];
        while ([result next])
        {
            int uid = [result intForColumnIndex:uidIndex];
            contactUids.push_back(uid);
            uids.push_back(uid);
        }
        
        TG_SYNCHRONIZED_BEGIN(_remoteContactUids);
         _remoteContactUids.clear();
         _remoteContactUids.insert(uids.begin(), uids.end());
        TG_SYNCHRONIZED_END(_remoteContactUids);
    } synchronous:true];
}

- (void)loadRemoteContactUidsContactIds:(std::map<int, int> &)contactUidsAndIds
{
    [self dispatchOnDatabaseThread:^
    {
        std::vector<int> uids;
        [self loadRemoteContactUids:uids];
        
        std::tr1::shared_ptr<std::map<int, TGUser *> > userMap = [self loadUsers:uids];
        for (std::map<int, TGUser *>::iterator it = userMap->begin(); it != userMap->end(); it++)
        {
            int contactId = it->second.contactId;
            if (contactId != 0)
                contactUidsAndIds.insert(std::pair<int, int>(contactId, it->first));
        }
    } synchronous:true];
}

- (bool)haveRemoteContactUids
{
    bool haveCachedContacts = false;
    
    TG_SYNCHRONIZED_BEGIN(_remoteContactUids);
    haveCachedContacts = !_remoteContactUids.empty();
    TG_SYNCHRONIZED_END(_remoteContactUids);
    
    if (haveCachedContacts)
        return true;
    
    __block bool haveContacts = false;
    
    [self dispatchOnDatabaseThread:^
    {
        std::vector<int> uids;
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT uid FROM %@ LIMIT 1", _contactListTableName]];
        if ([result next])
        {
            haveContacts = true;
        }
        
        std::vector<int> v;
        [self loadRemoteContactUids:v];
    } synchronous:true];
    
    return haveContacts;
}

- (bool)uidIsRemoteContact:(int)uid
{
    bool haveCachedResults = false;
    bool cachedResult = false;
    
    TG_SYNCHRONIZED_BEGIN(_remoteContactUids);
    haveCachedResults = !_remoteContactUids.empty();
    if (haveCachedResults)
        cachedResult = _remoteContactUids.find(uid) != _remoteContactUids.end();
    TG_SYNCHRONIZED_END(_remoteContactUids);
    
    if (haveCachedResults)
        return cachedResult;
    
    __block bool isRemoteContact = false;
    [self dispatchOnDatabaseThread:^
    {
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT uid FROM %@ WHERE uid=?", _contactListTableName], [[NSNumber alloc] initWithInt:uid]];
        if ([result next])
        {
            isRemoteContact = true;
        }
        
        std::vector<int> v;
        [self loadRemoteContactUids:v];
    } synchronous:true];
    
    return isRemoteContact;
}

- (void)replaceRemoteContactUids:(NSArray *)uids
{
    TG_SYNCHRONIZED_BEGIN(_remoteContactUids);
    _remoteContactUids.clear();
    for (NSNumber *nUid in uids)
    {
        _remoteContactUids.insert([nUid intValue]);
    }
    TG_SYNCHRONIZED_END(_remoteContactUids);
    
    [self dispatchOnDatabaseThread:^
    {
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@", _contactListTableName]];
        [_database beginTransaction];
        NSString *queryFormat = [[NSString alloc] initWithFormat:@"INSERT INTO %@ (uid) VALUES (?)", _contactListTableName];
        for (NSNumber *nUid in uids)
        {
            [_database executeUpdate:queryFormat, nUid];
        }
        [_database commit];
    } synchronous:false];
}

- (void)addRemoteContactUids:(NSArray *)uids
{
    TG_SYNCHRONIZED_BEGIN(_remoteContactUids);
    for (NSNumber *nUid in uids)
    {
        _remoteContactUids.insert([nUid intValue]);
    }
    TG_SYNCHRONIZED_END(_remoteContactUids);
    
    [self dispatchOnDatabaseThread:^
    {
        [_database beginTransaction];
        NSString *queryFormat = [[NSString alloc] initWithFormat:@"INSERT OR IGNORE INTO %@ (uid) VALUES (?)", _contactListTableName];
        for (NSNumber *nUid in uids)
        {
            [_database executeUpdate:queryFormat, nUid];
        }
        [_database commit];
    } synchronous:false];
}

- (void)deleteRemoteContactUids:(NSArray *)uids
{
    TG_SYNCHRONIZED_BEGIN(_remoteContactUids);
    _remoteContactUids.clear();
    for (NSNumber *nUid in uids)
    {
        _remoteContactUids.erase([nUid intValue]);
    }
    TG_SYNCHRONIZED_END(_remoteContactUids);
    
    [self dispatchOnDatabaseThread:^
    {
        [_database beginTransaction];
        NSString *queryFormat = [[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE uid=?", _contactListTableName];
        for (NSNumber *nUid in uids)
        {
            [_database executeUpdate:queryFormat, nUid];
        }
        [_database commit];
    } synchronous:false];
}

- (void)addContactBindings:(NSArray *)contactBindings
{
    TG_SYNCHRONIZED_BEGIN(_contactsByPhoneId);
    for (TGContactBinding *binding in contactBindings)
    {
        _contactsByPhoneId[binding.phoneId] = binding;
    }
    TG_SYNCHRONIZED_END(_contactsByPhoneId);
}

- (void)deleteContactBinding:(int)phoneId
{
    TG_SYNCHRONIZED_BEGIN(_contactsByPhoneId);
    _contactsByPhoneId.erase(phoneId);
    TG_SYNCHRONIZED_END(_contactsByPhoneId);
}

- (void)replaceContactBindings:(NSArray *)contactBindings
{
    TG_SYNCHRONIZED_BEGIN(_contactsByPhoneId);
    _contactsByPhoneId.clear();
    for (TGContactBinding *binding in contactBindings)
    {
        _contactsByPhoneId.insert(std::pair<int, TGContactBinding *>(binding.phoneId, binding));
    }
    TG_SYNCHRONIZED_END(_contactsByPhoneId);
}

- (TGContactBinding *)contactBindingWithId:(int)phoneId
{
    TGContactBinding *result = nil;
    
    TG_SYNCHRONIZED_BEGIN(_contactsByPhoneId);
    std::map<int, TGContactBinding *>::iterator it = _contactsByPhoneId.find(phoneId);
    if (it != _contactsByPhoneId.end())
        result = it->second;
    TG_SYNCHRONIZED_END(_contactsByPhoneId);
    
    return result;
}

- (NSArray *)contactBindings
{
    NSMutableArray *array = nil;
    
    TG_SYNCHRONIZED_BEGIN(_contactsByPhoneId);
    array = [[NSMutableArray alloc] initWithCapacity:_contactsByPhoneId.size()];
    for (std::map<int, TGContactBinding *>::iterator it = _contactsByPhoneId.begin(); it != _contactsByPhoneId.end(); it++)
    {
        [array addObject:it->second];
    }
    TG_SYNCHRONIZED_END(_contactsByPhoneId);
    
    return array;
}

- (void)replacePhonebookContacts:(NSArray *)phonebookContacts
{
    TG_SYNCHRONIZED_BEGIN(_phonebookContacts);
    _phonebookContacts.clear();
    _phoneIdToNativeId.clear();
    
    for (TGPhonebookContact *contact in phonebookContacts)
    {
        _phonebookContacts.insert(std::pair<int, TGPhonebookContact *>(contact.nativeId, contact));
        [contact fillPhoneHashToNativeMap:&_phoneIdToNativeId replace:false];
    }
    TG_SYNCHRONIZED_END(_phonebookContacts);
}

- (TGPhonebookContact *)phonebookContactByNativeId:(int)nativeId
{
    TGPhonebookContact *result = nil;
    
    TG_SYNCHRONIZED_BEGIN(_phonebookContacts);
    std::map<int, TGPhonebookContact *>::iterator it = _phonebookContacts.find(nativeId);
    if (it != _phonebookContacts.end())
        result = it->second;
    TG_SYNCHRONIZED_END(_phonebookContacts);
    
    return result;
}

- (void)replacePhonebookContact:(int)nativeId phonebookContact:(TGPhonebookContact *)phonebookContact generateContactBindings:(bool)generateContactBindings
{
    std::vector<int> erasedPhoneIds;
    
    TG_SYNCHRONIZED_BEGIN(_phonebookContacts);
    if (nativeId != 0)
    {
        std::map<int, TGPhonebookContact *>::iterator it = _phonebookContacts.find(nativeId);
        if (it != _phonebookContacts.end())
        {
            for (TGPhoneNumber *numberDesc in it->second.phoneNumbers)
            {
                int phoneId = [numberDesc phoneId];
                _phoneIdToNativeId.erase(phoneId);
                erasedPhoneIds.push_back(phoneId);
            }
        }
        
        _phonebookContacts.erase(nativeId);
    }
    
    if (phonebookContact != nil)
    {
        _phonebookContacts[phonebookContact.nativeId] = phonebookContact;
        [phonebookContact fillPhoneHashToNativeMap:&_phoneIdToNativeId replace:true];
    }
    
    TG_SYNCHRONIZED_END(_phonebookContacts);
    
    if (generateContactBindings)
    {
        TG_SYNCHRONIZED_BEGIN(_contactsByPhoneId);
        for (std::vector<int>::iterator it = erasedPhoneIds.begin(); it != erasedPhoneIds.end(); it++)
        {
            _contactsByPhoneId.erase(*it);
        }
        
        if (phonebookContact != nil)
        {
            for (TGPhoneNumber *numberDesc in phonebookContact.phoneNumbers)
            {
                TGContactBinding *binding = [[TGContactBinding alloc] init];
                int phoneId = numberDesc.phoneId;
                if (phoneId != 0)
                {
                    binding.phoneId = numberDesc.phoneId;
                    binding.phoneNumber = numberDesc.number;
                    binding.firstName = phonebookContact.firstName;
                    binding.lastName = phonebookContact.lastName;
                    
                    _contactsByPhoneId[binding.phoneId] = binding;
                }
            }
        }
        TG_SYNCHRONIZED_END(_contactsByPhoneId);
    }
}

- (TGPhonebookContact *)phonebookContactByPhoneId:(int)phoneId
{
    TGPhonebookContact *result = nil;
    
    TG_SYNCHRONIZED_BEGIN(_phonebookContacts);
    std::map<int, int>::iterator it = _phoneIdToNativeId.find(phoneId);
    if (it != _phoneIdToNativeId.end())
    {
        if (it->second != -1)
        {
            std::map<int, TGPhonebookContact *>::iterator contactIt = _phonebookContacts.find(it->second);
            if (contactIt != _phonebookContacts.end())
                result = contactIt->second;
        }
    }
    TG_SYNCHRONIZED_END(_phonebookContacts);
    
    return result;
}

- (NSArray *)loadPhonebookContacts
{
    NSMutableArray *array = nil;
    
    TG_SYNCHRONIZED_BEGIN(_phonebookContacts);
    if (_phonebookContacts.size() < 2000)
    {
        array = [[NSMutableArray alloc] initWithCapacity:_phonebookContacts.size()];
        for (std::map<int, TGPhonebookContact *>::iterator it = _phonebookContacts.begin(); it != _phonebookContacts.end(); it++)
        {
            [array addObject:it->second];
        }
    }
    TG_SYNCHRONIZED_END(_phonebookContacts);
    
    return array;
}

static inline TGMessage *loadMessageFromQueryResult(FMResultSet *result, int64_t conversationId, int indexMid, int indexMessage, int indexMedia, int indexFromId, int indexToId, int indexOutgoing, int indexUnread, int indexDeliveryState, int indexDate, int indexLifetime, int indexFlags, int indexSeqIn, int indexSeqOut, int indexContentProperties)
{
    TGMessage *message = [[TGMessage alloc] init];
    
    message.mid = [result intForColumnIndex:indexMid];
    message.cid = conversationId;
    message.text = [result stringForColumnIndex:indexMessage];
    NSData *mediaData = [result dataForColumnIndex:indexMedia];
    if (mediaData != nil)
        message.mediaAttachments = [TGMessage parseMediaAttachments:mediaData];
    message.contentProperties = [TGMessage parseContentProperties:[result dataForColumnIndex:indexContentProperties]];
    message.fromUid = [result longLongIntForColumnIndex:indexFromId];
    message.toUid = [result longLongIntForColumnIndex:indexToId];
    message.outgoing = [result intForColumnIndex:indexOutgoing];
    message.unread = [result longLongIntForColumnIndex:indexUnread];
    message.deliveryState = (TGMessageDeliveryState)[result intForColumnIndex:indexDeliveryState];
    message.date = [result intForColumnIndex:indexDate];
    
    message.messageLifetime = [result intForColumnIndex:indexLifetime];
    
    message.flags = (int64_t)[result longLongIntForColumnIndex:indexFlags];
    
    message.seqIn = [result intForColumnIndex:indexSeqIn];
    message.seqOut = [result intForColumnIndex:indexSeqOut];
    
    return message;
}

static inline TGMessage *loadMessageFromQueryResult(FMResultSet *result)
{
    TGMessage *message = [[TGMessage alloc] init];
    
    message.mid = [result intForColumn:@"mid"];
    message.cid = [result longLongIntForColumn:@"cid"];
    message.text = [result stringForColumn:@"message"];
    message.mediaAttachments = [TGMessage parseMediaAttachments:[result dataForColumn:@"media"]];
    message.contentProperties = [TGMessage parseContentProperties:[result dataForColumn:@"content_properties"]];
    message.fromUid = [result longLongIntForColumn:@"from_id"];
    message.toUid = [result longLongIntForColumn:@"to_id"];
    message.outgoing = [result intForColumn:@"outgoing"];
    message.unread = [result longLongIntForColumn:@"unread"];
    message.deliveryState = (TGMessageDeliveryState)[result intForColumn:@"dstate"];
    message.date = [result intForColumn:@"date"];
    
    message.messageLifetime = [result intForColumn:@"localMid"];
    
    message.flags = (int64_t)[result longLongIntForColumn:@"flags"];
    message.seqIn = [result intForColumn:@"seq_in"];
    message.seqOut = [result intForColumn:@"seq_out"];
    
    return message;
}

- (TGMessage *)loadMediaMessageWithMid:(int)mid
{
    __block TGMessage *message = nil;
    
    [self dispatchOnDatabaseThread:^
    {
        FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE mid=?", _conversationMediaTableName], [[NSNumber alloc] initWithInt:mid]];
        
        int dateIndex = [result columnIndexForName:@"date"];
        int midIndex = [result columnIndexForName:@"mid"];
        int mediaIndex = [result columnIndexForName:@"media"];
        int fromIdIndex = [result columnIndexForName:@"from_id"];
        
        if ([result next])
        {
            message = loadMessageMediaFromQueryResult(result, dateIndex, fromIdIndex, midIndex, mediaIndex);
        }
        
        if (message == nil)
            message = [self _cachedMediaMessageForId:mid];
    } synchronous:true];
    
    return message;
}

- (TGMessage *)loadMessageWithMid:(int)mid peerId:(int64_t)peerId
{
    __block TGMessage *message = nil;
    
    [self dispatchOnDatabaseThread:^
    {
        if (TGPeerIdIsChannel(peerId)) {
            message = [self _loadChannelMessage:peerId messageId:mid];
        } else {
            FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE mid=?", _messagesTableName], [[NSNumber alloc] initWithInt:mid]];
            if ([result next])
                message = loadMessageFromQueryResult(result);
        }
    } synchronous:true];
    
    return message;
}

- (void)loadUnreadMessagesHeadFromConversation:(int64_t)conversationId limit:(int)limit completion:(void (^)(NSArray *messages, bool isAtBottom))completion
{
    [self dispatchOnDatabaseThread:^
    {
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        
        //[self explainQuery:[[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE unread=%lld ORDER BY date ASC LIMIT 1", _messagesTableName, conversationId]];
        
        NSMutableArray *messages = [[NSMutableArray alloc] init];
        
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE unread=? ORDER BY date ASC LIMIT 1", _messagesTableName], [[NSNumber alloc] initWithLongLong:conversationId]];
        
        int indexMid = [result columnIndexForName:@"mid"];
        int indexMessage = [result columnIndexForName:@"message"];
        int indexMedia = [result columnIndexForName:@"media"];
        int indexFromId = [result columnIndexForName:@"from_id"];
        int indexToId = [result columnIndexForName:@"to_id"];
        int indexOutgoing = [result columnIndexForName:@"outgoing"];
        int indexUnread = [result columnIndexForName:@"unread"];
        int indexDeliveryState = [result columnIndexForName:@"dstate"];
        int indexDate = [result columnIndexForName:@"date"];
        int indexLifetime = [result columnIndexForName:@"localMid"];
        int indexFlags = [result columnIndexForName:@"flags"];
        int indexSeqIn = [result columnIndexForName:@"seq_in"];
        int indexSeqOut = [result columnIndexForName:@"seq_out"];
        int indexContentProperties = [result columnIndexForName:@"content_properties"];
        
        int minDate = INT_MAX;
        int minMid = INT_MAX;
        int minLocalMid = INT_MAX;
        
        int maxDate = INT_MIN;
        int maxMid = INT_MIN;
        int maxLocalMid = INT_MIN;
        
        if ([result next])
        {
            TGMessage *message = loadMessageFromQueryResult(result, conversationId, indexMid, indexMessage, indexMedia, indexFromId, indexToId, indexOutgoing, indexUnread, indexDeliveryState, indexDate, indexLifetime, indexFlags, indexSeqIn, indexSeqOut, indexContentProperties);
            if (message != nil)
            {
                minDate = (int)message.date;
                maxDate = minDate;
                
                if (message.mid < TGMessageLocalMidBaseline)
                {
                    minMid = message.mid;
                    maxMid = minMid;
                }
                else
                {
                    minLocalMid = message.mid;
                    maxLocalMid = minLocalMid;
                }
            }
            
            [messages addObject:message];
        }
        
        if (minDate != INT_MAX)
        {
            result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE cid=? AND date>=? ORDER BY DATE ASC LIMIT %d", _messagesTableName, limit], [[NSNumber alloc] initWithLongLong:conversationId], [[NSNumber alloc] initWithInt:maxDate]];
            
            indexMid = [result columnIndexForName:@"mid"];
            indexMessage = [result columnIndexForName:@"message"];
            indexMedia = [result columnIndexForName:@"media"];
            indexFromId = [result columnIndexForName:@"from_id"];
            indexToId = [result columnIndexForName:@"to_id"];
            indexOutgoing = [result columnIndexForName:@"outgoing"];
            indexUnread = [result columnIndexForName:@"unread"];
            indexDeliveryState = [result columnIndexForName:@"dstate"];
            indexDate = [result columnIndexForName:@"date"];
            indexLifetime = [result columnIndexForName:@"localMid"];
            indexFlags = [result columnIndexForName:@"flags"];
            indexSeqIn = [result columnIndexForName:@"seq_in"];
            indexSeqOut = [result columnIndexForName:@"seq_out"];
            int indexContentProperties = [result columnIndexForName:@"content_properties"];
            
            while ([result next])
            {
                TGMessage *message = loadMessageFromQueryResult(result, conversationId, indexMid, indexMessage, indexMedia, indexFromId, indexToId, indexOutgoing, indexUnread, indexDeliveryState, indexDate, indexLifetime, indexFlags, indexSeqIn, indexSeqOut, indexContentProperties);
                if (message != nil)
                {
                    if (message.mid < TGMessageLocalMidBaseline)
                    {
                        if (message.mid <= maxMid)
                            continue;
                    }
                    else
                    {
                        if (message.mid <= maxLocalMid)
                            continue;
                    }
                    [messages addObject:message];
                }
            }
        }
        
        result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE cid=? AND date<=? ORDER BY date DESC LIMIT %d", _messagesTableName, limit], [[NSNumber alloc] initWithLongLong:conversationId], [[NSNumber alloc] initWithInt:minDate]];
        
        indexMid = [result columnIndexForName:@"mid"];
        indexMessage = [result columnIndexForName:@"message"];
        indexMedia = [result columnIndexForName:@"media"];
        indexFromId = [result columnIndexForName:@"from_id"];
        indexToId = [result columnIndexForName:@"to_id"];
        indexOutgoing = [result columnIndexForName:@"outgoing"];
        indexUnread = [result columnIndexForName:@"unread"];
        indexDeliveryState = [result columnIndexForName:@"dstate"];
        indexDate = [result columnIndexForName:@"date"];
        indexLifetime = [result columnIndexForName:@"localMid"];
        indexFlags = [result columnIndexForName:@"flags"];
        indexSeqIn = [result columnIndexForName:@"seq_in"];
        indexSeqOut = [result columnIndexForName:@"seq_out"];
        indexContentProperties = [result columnIndexForName:@"content_properties"];
        
        while ([result next])
        {
            TGMessage *message = loadMessageFromQueryResult(result, conversationId, indexMid, indexMessage, indexMedia, indexFromId, indexToId, indexOutgoing, indexUnread, indexDeliveryState, indexDate, indexLifetime, indexFlags, indexSeqIn, indexSeqOut, indexContentProperties);
            if (message != nil)
            {
                if (message.mid < TGMessageLocalMidBaseline)
                {
                    if (message.mid >= minMid)
                        continue;
                }
                else
                {
                    if (message.mid >= minLocalMid)
                        continue;
                }
                [messages addObject:message];
            }
        }
        
        bool isAtBottom = false;
        
        result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT mid FROM %@ WHERE cid=? ORDER BY date DESC LIMIT 1", _messagesTableName], [[NSNumber alloc] initWithLongLong:conversationId]];
        if ([result next])
        {
            int mid = [result intForColumn:@"mid"];
            for (TGMessage *message in messages)
            {
                if (mid == message.mid)
                {
                    isAtBottom = true;
                    break;
                }
            }
        }
        else
            isAtBottom = true;
        
        TGLog(@"Loaded head in %f ms", (CFAbsoluteTimeGetCurrent() - startTime) * 1000.0);
        
        if (completion != nil)
            completion(messages, isAtBottom);
    } synchronous:false];
}

- (void)loadMessagesFromConversation:(int64_t)conversationId maxMid:(int)argMaxMid maxDate:(int)argMaxDate maxLocalMid:(int)argMaxLocalMid atMessageId:(int)argAtMessageId limit:(int)argLimit extraUnread:(bool)extraUnread completion:(void (^)(NSArray *messages, bool historyExistsBelow))completion
{
    CFAbsoluteTime requestTime = CFAbsoluteTimeGetCurrent();
    
    [self dispatchOnDatabaseThread:^
    {
        int maxMid = argMaxMid;
        int maxDate = argMaxDate;
        int maxLocalMid = argMaxLocalMid;
        int atMessageId = argAtMessageId;
        int limit = argLimit;
        
        CFAbsoluteTime dbStartTime = CFAbsoluteTimeGetCurrent();
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        int extraLimit = 0;
        int extraOffset = 0;
        
        int downLimit = 0;
        int extraDownLimit = 0;
        int extraDownOffset = 0;
        
        NSNumber *nConversationId = [[NSNumber alloc] initWithLongLong:conversationId];
        
        if (atMessageId != 0)
        {
            FMResultSet *selectedMessageDateResult = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT date FROM %@ WHERE mid=?", _messagesTableName], [[NSNumber alloc] initWithInt:atMessageId]];
            if ([selectedMessageDateResult next])
            {
                downLimit = 10;
                limit = 18;
                maxDate = [selectedMessageDateResult intForColumn:@"date"];
            }
        }
        
        if (extraUnread)
        {
            int lastIncomingMid = 0;
            FMResultSet *lastIncomingResult = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT mid FROM %@ WHERE cid=? AND outgoing=0 ORDER BY date DESC LIMIT 1", _messagesTableName], nConversationId];
            if ([lastIncomingResult next])
                lastIncomingMid = [lastIncomingResult intForColumn:@"mid"];
            
            int lastUnreadMid = 0;
            FMResultSet *lastUnreadResult = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT mid FROM %@ WHERE cid=? AND unread!=0 AND outgoing=0 ORDER BY date DESC LIMIT 1", _messagesTableName], nConversationId];
            if ([lastUnreadResult next])
                lastUnreadMid = [lastUnreadResult intForColumn:@"mid"];
            
            if (lastUnreadMid != 0 && lastIncomingMid != 0 && lastIncomingMid == lastUnreadMid)
            {   
                FMResultSet *dateResult = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT MIN(date) FROM %@ WHERE cid=? AND unread!=0 AND outgoing=0", _messagesTableName], nConversationId];
                
                int minUnreadDate = INT_MAX;
                
                if ([dateResult next])
                    minUnreadDate = [dateResult intForColumn:@"MIN(date)"];
                
                if (minUnreadDate != INT_MAX)
                {
                    FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE cid=? AND date>=?", _messagesTableName], nConversationId, [[NSNumber alloc] initWithInt:minUnreadDate]];
                    int indexMid = [result columnIndexForName:@"mid"];
                    int indexMessage = [result columnIndexForName:@"message"];
                    int indexMedia = [result columnIndexForName:@"media"];
                    int indexFromId = [result columnIndexForName:@"from_id"];
                    int indexToId = [result columnIndexForName:@"to_id"];
                    int indexOutgoing = [result columnIndexForName:@"outgoing"];
                    int indexUnread = [result columnIndexForName:@"unread"];
                    int indexDeliveryState = [result columnIndexForName:@"dstate"];
                    int indexDate = [result columnIndexForName:@"date"];
                    int indexLifetime = [result columnIndexForName:@"localMid"];
                    int indexFlags = [result columnIndexForName:@"flags"];
                    int indexSeqIn = [result columnIndexForName:@"seq_in"];
                    int indexSeqOut = [result columnIndexForName:@"seq_out"];
                    int indexContentProperties = [result columnIndexForName:@"content_properties"];
                    
                    int loadedUnreadMessages = 0;
                    
                    while ([result next])
                    {
                        TGMessage *message = loadMessageFromQueryResult(result, conversationId, indexMid, indexMessage, indexMedia, indexFromId, indexToId, indexOutgoing, indexUnread, indexDeliveryState, indexDate, indexLifetime, indexFlags, indexSeqIn, indexSeqOut, indexContentProperties);
                        
                        [array addObject:message];
                        
                        maxDate = MIN(maxDate, (int)message.date);
                        int mid = message.mid;
                        if (mid < TGMessageLocalMidBaseline)
                            maxMid = MIN(maxMid, mid);
                        else
                            maxLocalMid = MIN(maxLocalMid, mid);
                        
                        loadedUnreadMessages++;
                    }
                    
                    TGLog(@"Loaded %d unread messages", loadedUnreadMessages);
                }
            }
        }
        
        FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE cid=? AND date<=? ORDER BY date DESC LIMIT ?", _messagesTableName], nConversationId, [[NSNumber alloc] initWithInt:maxDate], [[NSNumber alloc] initWithInt:limit + 1]];
        
        int indexMid = [result columnIndexForName:@"mid"];
        int indexMessage = [result columnIndexForName:@"message"];
        int indexMedia = [result columnIndexForName:@"media"];
        int indexFromId = [result columnIndexForName:@"from_id"];
        int indexToId = [result columnIndexForName:@"to_id"];
        int indexOutgoing = [result columnIndexForName:@"outgoing"];
        int indexUnread = [result columnIndexForName:@"unread"];
        int indexDeliveryState = [result columnIndexForName:@"dstate"];
        int indexDate = [result columnIndexForName:@"date"];
        int indexLifetime = [result columnIndexForName:@"localMid"];
        int indexFlags = [result columnIndexForName:@"flags"];
        int indexSeqIn = [result columnIndexForName:@"seq_in"];
        int indexSeqOut = [result columnIndexForName:@"seq_out"];
        int indexContentProperties = [result columnIndexForName:@"content_properties"];
        
        while ([result next])
        {
            extraOffset++;
            
            int mid = [result intForColumnIndex:indexMid];
            if (mid >= TGMessageLocalMidBaseline)
            {
                if (mid >= maxLocalMid)
                {
                    extraLimit++;
                    continue;
                }
            }
            else if (mid >= maxMid)
            {
                extraLimit++;
                continue;
            }
            
            TGMessage *message = loadMessageFromQueryResult(result, conversationId, indexMid, indexMessage, indexMedia, indexFromId, indexToId, indexOutgoing, indexUnread, indexDeliveryState, indexDate, indexLifetime, indexFlags, indexSeqIn, indexSeqOut, indexContentProperties);
            [array addObject:message];
        }
        
        
        if (extraLimit > 1)
        {
            TGLog(@"Loading %d extra messages", extraLimit);
            result = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE cid=? AND date<=? ORDER BY date DESC LIMIT ?, ?", _messagesTableName], [[NSNumber alloc] initWithLongLong:conversationId], [[NSNumber alloc] initWithInt:maxDate], [[NSNumber alloc] initWithInt:extraOffset], [[NSNumber alloc] initWithInt:extraLimit]];
            
            indexMid = [result columnIndexForName:@"mid"];
            indexMessage = [result columnIndexForName:@"message"];
            indexMedia = [result columnIndexForName:@"media"];
            indexFromId = [result columnIndexForName:@"from_id"];
            indexToId = [result columnIndexForName:@"to_id"];
            indexOutgoing = [result columnIndexForName:@"outgoing"];
            indexUnread = [result columnIndexForName:@"unread"];
            indexDeliveryState = [result columnIndexForName:@"dstate"];
            indexDate = [result columnIndexForName:@"date"];
            indexLifetime = [result columnIndexForName:@"localMid"];
            int indexFlags = [result columnIndexForName:@"flags"];
            int indexSeqIn = [result columnIndexForName:@"seq_in"];
            int indexSeqOut = [result columnIndexForName:@"seq_out"];
            int indexContentProperties = [result columnIndexForName:@"content_properties"];
            
            while ([result next])
            {
                int mid = [result intForColumnIndex:indexMid];
                if (mid >= TGMessageLocalMidBaseline)
                {
                    if (mid >= maxLocalMid)
                        continue;
                }
                else if (mid >= maxMid)
                    continue;
                
                TGMessage *message = loadMessageFromQueryResult(result, conversationId, indexMid, indexMessage, indexMedia, indexFromId, indexToId, indexOutgoing, indexUnread, indexDeliveryState, indexDate, indexLifetime, indexFlags, indexSeqIn, indexSeqOut, indexContentProperties);
                [array addObject:message];
            }
        }
        
        int loadedDownMessages = 0;
        
        if (downLimit > 0)
        {
            if (array.count < 18)
                downLimit = 30;
            
            int loadedMaxDate = INT_MIN;
            int loadedMaxMid = INT_MIN;
            int loadedMaxLocalMid = INT_MIN;
            
            for (TGMessage *message in array)
            {
                loadedMaxDate = MAX(loadedMaxDate, (int)message.date);
                int mid = message.mid;
                if (mid >= TGMessageLocalMidBaseline)
                    loadedMaxLocalMid = MAX(loadedMaxLocalMid, mid);
                else
                    loadedMaxMid = MAX(loadedMaxMid, mid);
            }
            
            if (loadedMaxDate != INT_MIN)
            {
                result = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE cid=? AND date>=? ORDER BY date ASC LIMIT ?", _messagesTableName], [[NSNumber alloc] initWithLongLong:conversationId], [[NSNumber alloc] initWithInt:loadedMaxDate], [[NSNumber alloc] initWithInt:downLimit]];
                
                indexMid = [result columnIndexForName:@"mid"];
                indexMessage = [result columnIndexForName:@"message"];
                indexMedia = [result columnIndexForName:@"media"];
                indexFromId = [result columnIndexForName:@"from_id"];
                indexToId = [result columnIndexForName:@"to_id"];
                indexOutgoing = [result columnIndexForName:@"outgoing"];
                indexUnread = [result columnIndexForName:@"unread"];
                indexDeliveryState = [result columnIndexForName:@"dstate"];
                indexDate = [result columnIndexForName:@"date"];
                indexLifetime = [result columnIndexForName:@"localMid"];
                indexFlags = [result columnIndexForName:@"flags"];
                indexSeqIn = [result columnIndexForName:@"seq_in"];
                indexSeqOut = [result columnIndexForName:@"seq_out"];
                indexContentProperties = [result columnIndexForName:@"content_properties"];
                
                while ([result next])
                {
                    extraDownOffset++;
                    
                    int mid = [result intForColumnIndex:indexMid];
                    if (mid >= TGMessageLocalMidBaseline)
                    {
                        if (mid <= loadedMaxLocalMid)
                        {
                            extraDownLimit++;
                            continue;
                        }
                    }
                    else if (mid <= loadedMaxMid)
                    {
                        extraDownLimit++;
                        continue;
                    }
                    
                    loadedDownMessages++;
                    TGMessage *message = loadMessageFromQueryResult(result, conversationId, indexMid, indexMessage, indexMedia, indexFromId, indexToId, indexOutgoing, indexUnread, indexDeliveryState, indexDate, indexLifetime, indexFlags, indexSeqIn, indexSeqOut, indexContentProperties);
                    [array addObject:message];
                }
            }
            
            if (extraDownLimit != 0)
            {
                result = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE cid=? AND date>=? ORDER BY date ASC LIMIT ?, ?", _messagesTableName], [[NSNumber alloc] initWithLongLong:conversationId], [[NSNumber alloc] initWithInt:loadedMaxDate], [[NSNumber alloc] initWithInt:extraDownOffset], [[NSNumber alloc] initWithInt:extraDownLimit]];
                
                indexMid = [result columnIndexForName:@"mid"];
                indexMessage = [result columnIndexForName:@"message"];
                indexMedia = [result columnIndexForName:@"media"];
                indexFromId = [result columnIndexForName:@"from_id"];
                indexToId = [result columnIndexForName:@"to_id"];
                indexOutgoing = [result columnIndexForName:@"outgoing"];
                indexUnread = [result columnIndexForName:@"unread"];
                indexDeliveryState = [result columnIndexForName:@"dstate"];
                indexDate = [result columnIndexForName:@"date"];
                indexLifetime = [result columnIndexForName:@"localMid"];
                indexFlags = [result columnIndexForName:@"flags"];
                indexSeqIn = [result columnIndexForName:@"seq_in"];
                indexSeqOut = [result columnIndexForName:@"seq_out"];
                indexContentProperties = [result columnIndexForName:@"content_properties"];
                
                while ([result next])
                {
                    int mid = [result intForColumnIndex:indexMid];
                    if (mid >= TGMessageLocalMidBaseline)
                    {
                        if (mid <= loadedMaxLocalMid)
                            continue;
                    }
                    else if (mid <= loadedMaxMid)
                        continue;
                    
                    loadedDownMessages++;
                    TGMessage *message = loadMessageFromQueryResult(result, conversationId, indexMid, indexMessage, indexMedia, indexFromId, indexToId, indexOutgoing, indexUnread, indexDeliveryState, indexDate, indexLifetime, indexFlags, indexSeqIn, indexSeqOut, indexContentProperties);
                    [array addObject:message];
                }
            }
        }
        
        TGLog(@"===== Parse time: %f ms (%f ms)", (CFAbsoluteTimeGetCurrent() - dbStartTime) * 1000.0, (CFAbsoluteTimeGetCurrent() - requestTime) * 1000.0);
        
        if (completion)
            completion(array, downLimit != 0 && loadedDownMessages != 0);
    } synchronous:false];
}

- (void)loadMessagesFromConversationDownwards:(int64_t)conversationId minMid:(int)argMinMid minLocalMid:(int)argMinLocalMid minDate:(int)argMinDate limit:(int)argLimit completion:(void (^)(NSArray *messages))completion
{
    [self dispatchOnDatabaseThread:^
    {
        int minMid = argMinMid;
        int minLocalMid = argMinLocalMid;
        int minDate = argMinDate;
        int limit = argLimit;
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        int extraLimit = 0;
        int extraOffset = 0;

        NSNumber *nConversationId = [[NSNumber alloc] initWithLongLong:conversationId];
        
        FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE cid=? AND date>=? ORDER BY date ASC LIMIT ?", _messagesTableName], nConversationId, [[NSNumber alloc] initWithInt:minDate], [[NSNumber alloc] initWithInt:limit + 1]];
        
        int indexMid = [result columnIndexForName:@"mid"];
        int indexMessage = [result columnIndexForName:@"message"];
        int indexMedia = [result columnIndexForName:@"media"];
        int indexFromId = [result columnIndexForName:@"from_id"];
        int indexToId = [result columnIndexForName:@"to_id"];
        int indexOutgoing = [result columnIndexForName:@"outgoing"];
        int indexUnread = [result columnIndexForName:@"unread"];
        int indexDeliveryState = [result columnIndexForName:@"dstate"];
        int indexDate = [result columnIndexForName:@"date"];
        int indexLifetime = [result columnIndexForName:@"localMid"];
        int indexFlags = [result columnIndexForName:@"flags"];
        int indexSeqIn = [result columnIndexForName:@"seq_in"];
        int indexSeqOut = [result columnIndexForName:@"seq_out"];
        int indexContentProperties = [result columnIndexForName:@"content_properties"];
        
        while ([result next])
        {
            extraOffset++;
            
            int mid = [result intForColumnIndex:indexMid];
            if (mid >= TGMessageLocalMidBaseline)
            {
                if (mid <= minLocalMid)
                {
                    extraLimit++;
                    continue;
                }
            }
            else if (mid <= minMid)
            {
                extraLimit++;
                continue;
            }
            
            TGMessage *message = loadMessageFromQueryResult(result, conversationId, indexMid, indexMessage, indexMedia, indexFromId, indexToId, indexOutgoing, indexUnread, indexDeliveryState, indexDate, indexLifetime, indexFlags, indexSeqIn, indexSeqOut, indexContentProperties);
            [array addObject:message];
        }
        
        
        if (extraLimit > 1)
        {
            TGLog(@"Loading %d extra messages", extraLimit);
            result = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE cid=? AND date>=? ORDER BY date ASC LIMIT ?, ?", _messagesTableName], [[NSNumber alloc] initWithLongLong:conversationId], [[NSNumber alloc] initWithInt:minDate], [[NSNumber alloc] initWithInt:extraOffset], [[NSNumber alloc] initWithInt:extraLimit]];
            
            indexMid = [result columnIndexForName:@"mid"];
            indexMessage = [result columnIndexForName:@"message"];
            indexMedia = [result columnIndexForName:@"media"];
            indexFromId = [result columnIndexForName:@"from_id"];
            indexToId = [result columnIndexForName:@"to_id"];
            indexOutgoing = [result columnIndexForName:@"outgoing"];
            indexUnread = [result columnIndexForName:@"unread"];
            indexDeliveryState = [result columnIndexForName:@"dstate"];
            indexDate = [result columnIndexForName:@"date"];
            indexLifetime = [result columnIndexForName:@"localMid"];
            indexFlags = [result columnIndexForName:@"flags"];
            indexSeqIn = [result columnIndexForName:@"seq_in"];
            indexSeqOut = [result columnIndexForName:@"seq_out"];
            indexContentProperties = [result columnIndexForName:@"content_properties"];
            
            while ([result next])
            {
                int mid = [result intForColumnIndex:indexMid];
                if (mid >= TGMessageLocalMidBaseline)
                {
                    if (mid <= minLocalMid)
                        continue;
                }
                else if (mid <= minMid)
                    continue;
                
                TGMessage *message = loadMessageFromQueryResult(result, conversationId, indexMid, indexMessage, indexMedia, indexFromId, indexToId, indexOutgoing, indexUnread, indexDeliveryState, indexDate, indexLifetime, indexFlags, indexSeqIn, indexSeqOut, indexContentProperties);
                [array addObject:message];
            }
        }
        
        if (completion)
            completion(array);
    } synchronous:false];
}

- (void)replaceMediaInMessagesWithLocalMediaId:(int)localMediaId media:(NSData *)media
{
    [self dispatchOnDatabaseThread:^
    {
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT mid FROM %@ WHERE local_media_id=?", _outgoingMessagesTableName], [[NSNumber alloc] initWithInt:localMediaId]];
        while ([result next])
        {
            int mid = [result intForColumn:@"mid"];
            
            [_database executeUpdate:[[NSString alloc] initWithFormat:@"UPDATE %@ SET media=? WHERE mid=?", _messagesTableName], media, [[NSNumber alloc] initWithInt:mid]];
        }
    } synchronous:false];
}

- (void)replaceContentPropertiesInMessageWithId:(int32_t)messageId contentProperties:(NSDictionary *)contentProperties
{
    [self dispatchOnDatabaseThread:^
    {
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"UPDATE %@ SET content_properties=? WHERE mid=?", _messagesTableName], [TGMessage serializeContentProperties:contentProperties], [[NSNumber alloc] initWithInt:messageId]];
    } synchronous:false];
}

- (NSArray *)generateLocalMids:(int)count
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    TG_SYNCHRONIZED_BEGIN(_nextLocalMid);
    
    if (_nextLocalMid == 0)
    {
        __block int databaseResult = 0;
        [self dispatchOnDatabaseThread:^
        {
            FMResultSet *nextLocalMidResult = [_database executeQuery:[NSString stringWithFormat:@"SELECT * from %@ WHERE key=%d", _serviceTableName, _serviceLastMidKey]];
            if ([nextLocalMidResult next])
            {
                NSData *value = [nextLocalMidResult dataForColumn:@"value"];
                int intValue = 0;
                [value getBytes:&intValue range:NSMakeRange(0, 4)];
                databaseResult = intValue;
            }
            else
                databaseResult = 800000000;
        } synchronous:true];
        
        _nextLocalMid = databaseResult;
    }
    
    for (int i = 0; i < count; i++)
    {
        [result addObject:[[NSNumber alloc] initWithInt:_nextLocalMid++]];
    }
    
    int storeLocalMid = _nextLocalMid;
    NSData *storeData = [[NSData alloc] initWithBytes:&storeLocalMid length:4];
    [self dispatchOnDatabaseThread:^
    {
        [_database executeUpdate:[NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (key, value) VALUES (?, ?)", _serviceTableName], [[NSNumber alloc] initWithInt:_serviceLastMidKey], storeData];
    } synchronous:false];
    
    TG_SYNCHRONIZED_END(_nextLocalMid);
    
    return result;
}

- (void)addMessagesToConversation:(NSArray *)argMessages conversationId:(int64_t)conversationId updateConversation:(TGConversation *)conversation dispatch:(bool)dispatch countUnread:(bool)countUnread
{
    [self addMessagesToConversation:argMessages conversationId:conversationId updateConversation:conversation dispatch:dispatch countUnread:countUnread updateDates:true];
}

- (void)addMessagesToConversation:(NSArray *)argMessages conversationId:(int64_t)conversationId updateConversation:(TGConversation *)conversation dispatch:(bool)dispatch countUnread:(bool)countUnread updateDates:(bool)updateDates
{
    int localIdCount = 0;
    for (TGMessage *message in argMessages)
    {
        if (message.mid == 0 || message.mid == INT_MIN)
        {
            localIdCount++;
        }
    }
    if (localIdCount != 0)
    {
        NSArray *localMids = [self generateLocalMids:localIdCount];
        int localMidIndex = 0;
        for (TGMessage *message in argMessages)
        {
            if (message.mid == 0)
            {
                message.mid = [[localMids objectAtIndex:localMidIndex++] intValue];
            }
            else if (message.mid == INT_MIN)
            {
                message.mid = INT_MIN + 1 + ([[localMids objectAtIndex:localMidIndex++] intValue] - 800000000);
            }
        }
    }
    
    if (TGPeerIdIsChannel(conversationId)) {
        if (conversation != nil) {
            [self updateChannels:@[conversation]];
        }
        NSAssert(false, @"");
        return;
    }
    
    [self dispatchOnDatabaseThread:^
    {
        NSArray *messages = argMessages;
        
        std::map<int64_t, int> randomIdToPosition;
        
        int positionIndex = -1;
        for (TGMessage *message in argMessages)
        {
            positionIndex++;
            if (message.randomId != 0)
                randomIdToPosition.insert(std::pair<int64_t, int>(message.randomId, positionIndex));
        }
        
        if (!randomIdToPosition.empty())
        {
            NSMutableArray *modifiedMessages = [[NSMutableArray alloc] initWithArray:argMessages];
            messages = modifiedMessages;
            
            [_database setSoftShouldCacheStatements:false];
            NSMutableString *rangeString = [[NSMutableString alloc] init];
            
            NSMutableIndexSet *removeIndices = [[NSMutableIndexSet alloc] init];
            
            const int batchSize = 256;
            for (auto it = randomIdToPosition.begin(); it != randomIdToPosition.end(); )
            {
                [rangeString deleteCharactersInRange:NSMakeRange(0, rangeString.length)];
                bool first = true;
                
                for (int i = 0; i < batchSize && it != randomIdToPosition.end(); i++, it++)
                {
                    if (first)
                    {
                        first = false;
                        [rangeString appendFormat:@"%lld", it->first];
                    }
                    else
                        [rangeString appendFormat:@",%lld", it->first];
                }
                
                FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT random_id FROM %@ WHERE random_id IN (%@)", _randomIdsTableName, rangeString]];
                int randomIdIndex = [result columnIndexForName:@"random_id"];
                while ([result next])
                {
                    int64_t randomId = [result longLongIntForColumnIndex:randomIdIndex];
                    
                    auto indexIt = randomIdToPosition.find(randomId);
                    if (indexIt != randomIdToPosition.end())
                        [removeIndices addIndex:indexIt->second];
                }
            }
            [_database setSoftShouldCacheStatements:true];
            
            if (removeIndices.count != 0)
            {
                TGLog(@"(not adding %d duplicate messages by random id)", removeIndices.count);
                [modifiedMessages removeObjectsAtIndexes:removeIndices];
            }
        }
        
        int legacyMessageLifetime = 0;
        if (conversationId <= INT_MIN)
            legacyMessageLifetime = [self messageLifetimeForPeerId:conversationId];
        
        NSString *queryFormat = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (mid, cid, localMid, message, media, from_id, to_id, outgoing, unread, dstate, date, flags, seq_in, seq_out, content_properties) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", _messagesTableName];
        
        NSString *mediaInsertQueryFormat = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (mid, cid, date, from_id, type, media) VALUES (?, ?, ?, ?, ?, ?)", _conversationMediaTableName];
        
        NSString *outboxInsertQueryFormat = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (mid, cid, dstate, local_media_id) VALUES (?, ?, ?, ?)", _outgoingMessagesTableName];
        
        NSString *randomIdInsertFormat = [[NSString alloc] initWithFormat:@"INSERT OR IGNORE INTO %@ (random_id, mid) VALUES (?, ?)", _randomIdsTableName];
        
        TGMessage *lastMesage = nil;
        TGMessage *lastIncomingMesage = nil;
        TGMessage *lastIncomingMesageWithMarkup = nil;
        struct { int32_t messageId, botId; } lastKickedBot = {0, 0};
        
        std::map<int32_t, bool> userIsBot;
        
        int unreadCount = 0;
        int localUnreadCount = 0;
        
        int messagesCount = (int)messages.count;
        NSMutableString *rangeString = [[NSMutableString alloc] init];
        [_database setSoftShouldCacheStatements:false];
        for (int i = 0; i < messagesCount; )
        {
            if (rangeString.length != 0)
                [rangeString deleteCharactersInRange:NSMakeRange(0, rangeString.length)];
            
            int maybeUnreadCount = 0;
            int maybeLocalUnreadCount = 0;
            
            std::vector<int> checkingMids;
            
            bool first = true;
            for (int lastI = i + 64; i < messagesCount && i < lastI; i++)
            {
                TGMessage *message = [messages objectAtIndex:i];
                int mid = message.mid;
                if (message.outgoing || !message.unread)
                    continue;
                
                if (first)
                    first = false;
                else
                    [rangeString appendString:@","];
                
                [rangeString appendFormat:@"%d", mid];
                checkingMids.push_back(mid);
                
                if (mid >= TGMessageLocalMidBaseline)
                    maybeLocalUnreadCount++;
                else
                    maybeUnreadCount++;
            }
            
            if (maybeUnreadCount != 0 || maybeLocalUnreadCount != 0)
            {
                if (maybeLocalUnreadCount != 0)
                {
                    FMResultSet *alreadyThereResult = [_database executeQuery:[NSString stringWithFormat:@"SELECT mid FROM %@ WHERE mid IN (%@)", _messagesTableName, rangeString]];
                    int midIndex = [alreadyThereResult columnIndexForName:@"mid"];
                    
                    std::set<int> alreadyThereSet;
                    
                    while ([alreadyThereResult next])
                    {
                        int mid = [alreadyThereResult intForColumnIndex:midIndex];
                        alreadyThereSet.insert(mid);
                    }
                    
                    if (alreadyThereSet.empty())
                    {
                        unreadCount += maybeUnreadCount;
                        localUnreadCount += maybeLocalUnreadCount;
                    }
                    else
                    {
                        for (auto it = checkingMids.begin(); it != checkingMids.end(); it++)
                        {
                            if (*it < TGMessageLocalMidBaseline)
                            {
                                if (alreadyThereSet.find(*it) == alreadyThereSet.end())
                                    unreadCount++;
                            }
                            else
                            {
                                if (alreadyThereSet.find(*it) == alreadyThereSet.end())
                                    localUnreadCount++;
                            }
                        }
                    }
                }
                else
                {
                    FMResultSet *countResult = [_database executeQuery:[NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE mid IN (%@)", _messagesTableName, rangeString]];
                    if ([countResult next])
                    {
                        int alreadyThere = [countResult intForColumn:@"COUNT(*)"];
                        maybeUnreadCount -= alreadyThere;
                    }
                    
                    unreadCount += maybeUnreadCount;
                }
            }
        }
        [_database setSoftShouldCacheStatements:true];
        
        [_database beginTransaction];
        for (TGMessage *message in messages)
        {   
            if (message.mid == 0)
            {
                TGLog(@"***** Error: message mid = 0");
                continue;
            }
            
            if (!message.outgoing)
            {
                bool isBot = false;
                if (conversationId > INT_MIN && conversationId < 0)
                {
                    auto isBotIt = userIsBot.find((int32_t)message.fromUid);
                    if (isBotIt == userIsBot.end())
                    {
                        TGUser *user = [self loadUser:(int)message.fromUid];
                        isBot = user.kind == TGUserKindBot || user.kind == TGUserKindSmartBot;
                        userIsBot.insert(std::pair<int32_t, bool>((int32_t)message.fromUid, isBot));
                    }
                    else
                        isBot = isBotIt->second;
                }
                
                if (isBot && (message.replyMarkup != nil || message.hideReplyMarkup))
                {
                    if (lastIncomingMesageWithMarkup == nil || message.mid > lastIncomingMesageWithMarkup.mid)
                        lastIncomingMesageWithMarkup = message;
                }
            }
            
            if (message.actionInfo != nil)
            {
                if (message.actionInfo.actionType == TGMessageActionChatDeleteMember)
                {
                    int32_t deletedUserId = [message.actionInfo.actionData[@"uid"] intValue];
                    bool isBot = false;
                    if (conversationId > INT_MIN && conversationId < 0)
                    {
                        auto isBotIt = userIsBot.find((int32_t)deletedUserId);
                        if (isBotIt == userIsBot.end())
                        {
                            TGUser *user = [self loadUser:(int)deletedUserId];
                            isBot = user.kind == TGUserKindBot || user.kind == TGUserKindSmartBot;
                            userIsBot.insert(std::pair<int32_t, bool>((int32_t)deletedUserId, isBot));
                        }
                        else
                            isBot = isBotIt->second;
                    }
                    
                    if (isBot && (lastKickedBot.messageId == 0 || message.mid > lastKickedBot.messageId))
                    {
                        lastKickedBot.messageId = message.mid;
                        lastKickedBot.botId = deletedUserId;
                    }
                }
            }
            
            if (lastMesage == nil || message.date > lastMesage.date || (message.date == lastMesage.date && message.mid > lastMesage.mid))
            {
                lastMesage = message;
            }
            
            if (!message.outgoing)
            {
                if (lastIncomingMesage == nil || message.mid > lastIncomingMesage.mid)
                    lastIncomingMesage = message;
                
                if ((message.replyMarkup != nil || message.hideReplyMarkup) && (lastIncomingMesageWithMarkup == nil || message.mid > lastIncomingMesageWithMarkup.mid))
                    lastIncomingMesageWithMarkup = message;
            }
            
            NSData *mediaData = nil;
            int mediaType = 0;
            if (message.mediaAttachments != nil && message.mediaAttachments.count != 0)
            {
                for (TGMediaAttachment *attachment in message.mediaAttachments)
                {
                    if (attachment.type == TGImageMediaAttachmentType)
                    {
                        mediaData = [TGMessage serializeAttachment:attachment];
                        mediaType = 0;
                    }
                    else if (attachment.type == TGVideoMediaAttachmentType)
                    {
                        mediaData = [TGMessage serializeAttachment:attachment];
                        mediaType = 1;
                        
                        TGVideoMediaAttachment *videoAttachment = (TGVideoMediaAttachment *)attachment;
                        if (videoAttachment.videoId != 0)
                            addVideoMid(self, 0, message.mid, videoAttachment.videoId, false);
                        else if (videoAttachment.localVideoId != 0)
                            addVideoMid(self, 0, message.mid, videoAttachment.localVideoId, true);
                    }
                    else if (attachment.type == TGDocumentMediaAttachmentType)
                    {
                        TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)attachment;
                        if (documentAttachment.documentId != 0)
                            addFileMid(self, 0, message.mid, TGDocumentFileType, documentAttachment.documentId);
                        else if (documentAttachment.localDocumentId != 0)
                            addFileMid(self, 0, message.mid, TGLocalDocumentFileType, documentAttachment.localDocumentId);
                    }
                    else if (attachment.type == TGAudioMediaAttachmentType)
                    {
                        TGAudioMediaAttachment *audioAttachment = (TGAudioMediaAttachment *)attachment;
                        if (audioAttachment.audioId != 0)
                            addFileMid(self, 0, message.mid, TGAudioFileType, audioAttachment.audioId);
                        else if (audioAttachment.localAudioId != 0)
                            addFileMid(self, 0, message.mid, TGLocalAudioFileType, audioAttachment.localAudioId);
                    }
                }
            }
            
            int currentLifetime = 0;
            if (message.layer >= 17)
                currentLifetime = message.messageLifetime;
            else if (message.messageLifetime != 0)
                currentLifetime = (int)message.messageLifetime;
            else if (message.actionInfo.actionType != TGMessageActionEncryptedChatMessageLifetime)
                currentLifetime = legacyMessageLifetime;
            
            [_database executeUpdate:queryFormat, [[NSNumber alloc] initWithInt:message.mid], [[NSNumber alloc] initWithLongLong:conversationId], [[NSNumber alloc] initWithInt:currentLifetime], message.text, [message serializeMediaAttachments:false], [[NSNumber alloc] initWithLongLong:message.fromUid], [[NSNumber alloc] initWithLongLong:message.toUid], [[NSNumber alloc] initWithInt:message.outgoing ? 1 : 0], message.unread ? [[NSNumber alloc] initWithLongLong:message.outgoing ? INT_MAX : conversationId] : nil, [[NSNumber alloc] initWithInt:message.deliveryState], [[NSNumber alloc] initWithInt:(int)(message.date)], [[NSNumber alloc] initWithLongLong:message.flags], [[NSNumber alloc] initWithInt:message.seqIn], [[NSNumber alloc] initWithInt:message.seqOut], [message serializeContentProperties]];
            
            if (mediaData != nil && mediaData.length != 0)
                [_database executeUpdate:mediaInsertQueryFormat, [[NSNumber alloc] initWithInt:message.mid], [[NSNumber alloc] initWithLongLong:conversationId], [[NSNumber alloc] initWithInt:(int)message.date], [[NSNumber alloc] initWithInt:(int)message.fromUid], [[NSNumber alloc] initWithInt:mediaType], mediaData];
            
            if (message.local && message.deliveryState == TGMessageDeliveryStatePending)
            {
                int localMediaId = 0;
                
                for (TGMediaAttachment *attachment in message.mediaAttachments)
                {
                    if (attachment.type == (int)TGLocalMessageMetaMediaAttachmentType)
                    {
                        localMediaId = ((TGLocalMessageMetaMediaAttachment *)attachment).localMediaId;
                        break;
                    }
                }
                
                [_database executeUpdate:outboxInsertQueryFormat, [[NSNumber alloc] initWithInt:message.mid], [[NSNumber alloc] initWithLongLong:conversationId], [[NSNumber alloc] initWithInt:message.deliveryState], [[NSNumber alloc] initWithInt:localMediaId]];
            }
            
            if (message.randomId != 0)
            {
                [_database executeUpdate:randomIdInsertFormat, [[NSNumber alloc] initWithLongLong:message.randomId], [[NSNumber alloc] initWithInt:message.mid]];
            }
        }
        
        [self cacheMediaForPeerId:conversationId messages:messages];
        
        [_database commit];
        
        if (!countUnread)
        {
            unreadCount = 0;
            localUnreadCount = 0;
        }
        else if (conversationId < 0 && conversation == nil)
        {
            FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT cid FROM %@ WHERE cid=?", [self _listTableNameForConversationId:conversationId]], [[NSNumber alloc] initWithLongLong:conversationId]];
            if (![result next])
            {
                unreadCount = 0;
                localUnreadCount = 0;
            }
        }
        
        if (dispatch)
        {
            if (lastMesage != nil)
            {
                [self actualizeConversation:conversationId dispatch:true conversation:conversation forceUpdate:(unreadCount != 0 || localUnreadCount != 0) addUnreadCount:unreadCount addServiceUnreadCount:localUnreadCount keepDate:!updateDates];
            }
            else if (conversation != nil)
            {
                [self actualizeConversation:conversationId dispatch:true conversation:conversation forceUpdate:true addUnreadCount:unreadCount addServiceUnreadCount:localUnreadCount keepDate:!updateDates];
            }
            
            if (unreadCount != 0)
            {
                int newUnreadCount = [self databaseState].unreadCount + unreadCount;
                if (newUnreadCount < 0)
                    TGLog(@"***** Warning: wrong unread_count");
                [self setUnreadCount:MAX(newUnreadCount, 0)];
            }
        }
        
        if (conversationId > 0)
        {
            if (lastIncomingMesageWithMarkup != nil)
            {
                TGUser *user = [self loadUser:(int)conversationId];
                if (user.kind == TGUserKindBot || user.kind == TGUserKindSmartBot)
                {
                    [self storeBotReplyMarkup:lastIncomingMesage.replyMarkup hideMarkupAuthorId:user.uid forPeerId:conversationId messageId:lastIncomingMesage.mid];
                }
            }
        }
        else if (conversationId > INT_MIN)
        {
            if (lastKickedBot.messageId > lastIncomingMesageWithMarkup.mid)
            {
                [self storeBotReplyMarkup:nil hideMarkupAuthorId:(int32_t)lastKickedBot.botId forPeerId:conversationId messageId:lastKickedBot.messageId];
            }
            else if (lastIncomingMesageWithMarkup != nil)
            {
                [self storeBotReplyMarkup:lastIncomingMesageWithMarkup.replyMarkup hideMarkupAuthorId:(int32_t)lastIncomingMesageWithMarkup.fromUid forPeerId:conversationId messageId:lastIncomingMesageWithMarkup.mid];
            }
        }
        
        [self dispatchOnIndexThread:^
        {
            NSString *indexInsertQueryFormat = [NSString stringWithFormat:@"INSERT INTO %@ (docid, text) VALUES (?, ?)", _messageIndexTableName];
            
            [_indexDatabase beginTransaction];
            
            [_indexDatabase setSoftShouldCacheStatements:false];
            NSMutableString *midsString = [[NSMutableString alloc] init];
            for (TGMessage *message in messages)
            {
                if (midsString.length != 0)
                    [midsString appendString:@","];
                [midsString appendFormat:@"%d", (int)message.mid];
            }
            NSString *indexSelectQueryFormat = [NSString stringWithFormat:@"SELECT docid FROM %@ WHERE docid IN (%@)", _messageIndexTableName, midsString];
            FMResultSet *existingResult = [_indexDatabase executeQuery:indexSelectQueryFormat];
            int docidIndex = [existingResult columnIndexForName:@"docid"];
            std::set<int32_t> existingMids;

            while ([existingResult next])
            {
                existingMids.insert([existingResult intForColumnIndex:docidIndex]);
            }
            [_indexDatabase setSoftShouldCacheStatements:true];
            
            for (TGMessage *message in messages)
            {
                if (existingMids.find(message.mid) == existingMids.end())
                {
                    NSString *text = nil;
                    for (id attachment in message.mediaAttachments)
                    {
                        if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
                            text = ((TGDocumentMediaAttachment *)attachment).fileName;
                        else if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
                            text = ((TGImageMediaAttachment *)attachment).caption;
                        else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
                            text = ((TGVideoMediaAttachment *)attachment).caption;
                    }
                    
                    if (text.length == 0)
                        text = message.text;
                    
                    if (text.length != 0)
                    {
                        text = [text stringByAppendingFormat:@" z0z9p%lld%s", (long long)ABS(conversationId), conversationId < 0 ? "c" : "p"];
                        
#if TARGET_IPHONE_SIMULATOR
                        TGLog(@"index: insert %@ with %@", @(message.mid), text);
#endif
                        [_indexDatabase executeUpdate:indexInsertQueryFormat, [[NSNumber alloc] initWithInt:message.mid], [text lowercaseString]];
                    }
                }
            }
            [_indexDatabase commit];
        } synchronous:false];
    } synchronous:false];
}

- (void)setTempIdForMessageId:(int)messageId peerId:(int64_t)peerId tempId:(int64_t)tempId
{
    [self dispatchOnDatabaseThread:^
    {
        if (TGPeerIdIsChannel(peerId)) {
            [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO %@ (cid, mid, random_id) VALUES (?, ?, ?)", _channelMessagesRandomIdTableName], @(peerId), @(messageId), @(tempId)];
        } else {
            [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO %@ (tmp_id, mid) VALUES (?, ?)", _temporaryMessageIdsTableName], [[NSNumber alloc] initWithLongLong:tempId], [[NSNumber alloc] initWithInt:messageId]];
        }
    } synchronous:false];
}

- (void)tempIdsForLocalMessages:(void (^)(std::vector<std::pair<int64_t, int> >))completion
{
    [self dispatchOnDatabaseThread:^
    {
        std::vector<std::pair<int64_t, int> > result;
        
        FMResultSet *resultSet = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT tmp_id, mid FROM %@ where mid >= %d", _temporaryMessageIdsTableName, TGMessageLocalMidBaseline]];
        int tmpIdIndex = [resultSet columnIndexForName:@"tmp_id"];
        int midIndex = [resultSet columnIndexForName:@"mid"];
        
        while ([resultSet next])
        {
            int64_t tempId = [resultSet longLongIntForColumnIndex:tmpIdIndex];
            int mid = [resultSet intForColumnIndex:midIndex];
            
            result.push_back(std::make_pair(tempId, mid));
        }
        
        if (completion)
            completion(result);
    } synchronous:false];
}

- (void)removeTempIds:(NSArray *)tempIds
{
    [self dispatchOnDatabaseThread:^
    {
        [_database setSoftShouldCacheStatements:false];
        
        NSMutableString *tempIdsString = [[NSMutableString alloc] init];
        
        int count = (int)tempIds.count;
        for (int i = 0; i < count; i += 128)
        {
            [tempIdsString deleteCharactersInRange:NSMakeRange(0, tempIdsString.length)];
            
            for (int j = i; j < count && j < 128; j++)
            {
                int64_t tempId = [[tempIds objectAtIndex:j] longLongValue];
                
                if (j != i)
                    [tempIdsString appendFormat:@",%lld", tempId];
                else
                    [tempIdsString appendFormat:@"%lld", tempId];
            }
            
            [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE tmp_id IN (%@)", _temporaryMessageIdsTableName, tempIdsString]];
        }
        
        [_database setSoftShouldCacheStatements:true];
    } synchronous:false];
}

- (void)messageIdsForTempIds:(NSArray *)tempIds mapping:(std::map<int64_t, int> *)mapping
{
    [self dispatchOnDatabaseThread:^
    {
        [_database setSoftShouldCacheStatements:false];
        
        NSMutableString *tempIdsString = [[NSMutableString alloc] init];
        
        int count = (int)tempIds.count;
        for (int i = 0; i < count; i += 128)
        {
            [tempIdsString deleteCharactersInRange:NSMakeRange(0, tempIdsString.length)];
            
            for (int j = i; j < count && j < 128; j++)
            {
                int64_t tempId = [[tempIds objectAtIndex:j] longLongValue];
                
                if (j != i)
                    [tempIdsString appendFormat:@",%lld", tempId];
                else
                    [tempIdsString appendFormat:@"%lld", tempId];
            }
            
            FMResultSet *resultSet = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT tmp_id, mid FROM %@ where tmp_id IN (%@)", _temporaryMessageIdsTableName, tempIdsString]];
            
            int tmpIdIndex = [resultSet columnIndexForName:@"tmp_id"];
            int midIndex = [resultSet columnIndexForName:@"mid"];
            
            while ([resultSet next])
            {
                mapping->insert(std::pair<int64_t, int>([resultSet longLongIntForColumnIndex:tmpIdIndex], [resultSet intForColumnIndex:midIndex]));
            }
        }
        
        [_database setSoftShouldCacheStatements:true];
    } synchronous:true];
}

- (int32_t)messageIdForRandomId:(int64_t)randomId
{
    __block int32_t messageId = 0;
    
    [self dispatchOnDatabaseThread:^
    {
        FMResultSet *resultSet = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT mid FROM %@ where random_id=?", _randomIdsTableName], [[NSNumber alloc] initWithLongLong:randomId]];
        if ([resultSet next])
        {
            messageId = (int32_t)[resultSet intForColumn:@"mid"];
        }
    } synchronous:true];
    
    return messageId;
}

- (int64_t)randomIdForMessageId:(int32_t)messageId
{
    __block int64_t randomId = 0;
    
    [self dispatchOnDatabaseThread:^
    {
        FMResultSet *resultSet = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT random_id FROM %@ where mid=?", _randomIdsTableName], [[NSNumber alloc] initWithInt:messageId]];
        if ([resultSet next])
        {
            randomId = (int64_t)[resultSet longLongIntForColumn:@"random_id"];
        }
    } synchronous:true];
    
    return randomId;
}

- (void)messageIdsForRandomIds:(NSArray *)randomIds mapping:(std::map<int64_t, int32_t> *)mapping
{
    [self dispatchOnDatabaseThread:^
    {
        [_database setSoftShouldCacheStatements:false];
        
        NSMutableString *randomIdsString = [[NSMutableString alloc] init];
        
        int count = (int)randomIds.count;
        for (int i = 0; i < count; i += 128)
        {
            [randomIdsString deleteCharactersInRange:NSMakeRange(0, randomIdsString.length)];
            
            for (int j = i; j < count && j < 128; j++)
            {
                int64_t randomId = [[randomIds objectAtIndex:j] longLongValue];
                
                if (j != i)
                    [randomIdsString appendFormat:@",%" PRId64 "", randomId];
                else
                    [randomIdsString appendFormat:@"%" PRId64 "", randomId];
            }
            
            FMResultSet *resultSet = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT random_id, mid FROM %@ where random_id IN (%@)", _randomIdsTableName, randomIdsString]];
            
            int midIndex = [resultSet columnIndexForName:@"mid"];
            int randomIdIndex = [resultSet columnIndexForName:@"random_id"];
            
            while ([resultSet next])
            {
                mapping->insert(std::pair<int64_t, int32_t>([resultSet longLongIntForColumnIndex:randomIdIndex], [resultSet intForColumnIndex:midIndex]));
            }
        }
        
        [_database setSoftShouldCacheStatements:true];
    } synchronous:true];
}

- (void)randomIdsForMessageIds:(NSArray *)messageIds mapping:(std::map<int32_t, int64_t> *)mapping
{
    [self dispatchOnDatabaseThread:^
    {
        [_database setSoftShouldCacheStatements:false];
        
        NSMutableString *midsString = [[NSMutableString alloc] init];
        
        int count = (int)messageIds.count;
        for (int i = 0; i < count; i += 128)
        {
            [midsString deleteCharactersInRange:NSMakeRange(0, midsString.length)];
            
            for (int j = i; j < count && j < 128; j++)
            {
                int32_t mid = [[messageIds objectAtIndex:j] intValue];
                
                if (j != i)
                    [midsString appendFormat:@",%d", mid];
                else
                    [midsString appendFormat:@"%d", mid];
            }
            
            FMResultSet *resultSet = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT random_id, mid FROM %@ where mid IN (%@)", _randomIdsTableName, midsString]];
            
            int midIndex = [resultSet columnIndexForName:@"mid"];
            int randomIdIndex = [resultSet columnIndexForName:@"random_id"];
            
            while ([resultSet next])
            {
                mapping->insert(std::pair<int32_t, int64_t>([resultSet intForColumnIndex:midIndex], [resultSet longLongIntForColumnIndex:randomIdIndex]));
            }
        }
        
        [_database setSoftShouldCacheStatements:true];
    } synchronous:true];
}

- (NSArray *)messageIdsInConversation:(int64_t)conversationId
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    [self dispatchOnDatabaseThread:^
    {
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT mid FROM %@ WHERE cid=?", _messagesTableName], @(conversationId)];
        int midIndex = [result columnIndexForName:@"mid"];
        while ([result next])
        {
            [array addObject:[[NSNumber alloc] initWithInt:[result intForColumnIndex:midIndex]]];
        }
    } synchronous:true];
    
    return array;
}

- (void)updateMessage:(int)mid peerId:(int64_t)peerId flags:(std::vector<TGDatabaseMessageFlagValue> const &)flags1 media:(NSArray *)media dispatch:(bool)dispatch
{
    std::vector<TGDatabaseMessageFlagValue> flags = flags1;
    [self dispatchOnDatabaseThread:^
    {
        if (TGPeerIdIsChannel(peerId)) {
            TGMessage *message = [[self _loadChannelMessage:peerId messageId:mid] copy];
            if (message != nil) {
                int32_t previousMid = message.mid;
                TGMessageSortKey previousSortKey = message.sortKey;
                
                for (std::vector<TGDatabaseMessageFlagValue>::const_iterator it = flags.begin(); it != flags.end(); it++)
                {
                    switch (it->flag)
                    {
                        case TGDatabaseMessageFlagDeliveryState:
                            message.deliveryState = (TGMessageDeliveryState)it->value;
                            break;
                        case TGDatabaseMessageFlagUnread:
                            message.unread = it->value;
                            break;
                        case TGDatabaseMessageFlagMid:
                            message.mid = it->value;
                            break;
                        case TGDatabaseMessageFlagDate:
                            message.date = it->value;
                            break;
                        default:
                            break;
                    }
                }
                
                int32_t updatedMid = message.mid;

                int64_t previousLocalImageId = 0;
                int64_t previousRemoteImageId = 0;
                
                int64_t previousLocalVideoId = 0;
                int64_t previousRemoteVideoId = 0;
                
                int64_t previousLocalDocumentId = 0;
                int64_t previousRemoteDocumentId = 0;
                
                int64_t previousLocalAudioId = 0;
                int64_t previousRemoteAudioId = 0;
                
                for (TGMediaAttachment *attachment in message.mediaAttachments)
                {
                    if (attachment.type == TGImageMediaAttachmentType)
                    {
                        TGImageMediaAttachment *imageAttachment = (TGImageMediaAttachment *)attachment;
                        if (imageAttachment.imageId != 0)
                            previousRemoteImageId = imageAttachment.imageId;
                        else
                            previousLocalImageId = imageAttachment.localImageId;
                    }
                    else if (attachment.type == TGVideoMediaAttachmentType)
                    {
                        TGVideoMediaAttachment *videoAttachment = (TGVideoMediaAttachment *)attachment;
                        if (videoAttachment.localVideoId != 0)
                            previousLocalVideoId = videoAttachment.localVideoId;
                        else if (videoAttachment.videoId != 0)
                            previousRemoteVideoId = videoAttachment.videoId;
                    }
                    else if (attachment.type == TGDocumentMediaAttachmentType)
                    {
                        TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)attachment;
                        if (documentAttachment.localDocumentId != 0)
                            previousLocalDocumentId = documentAttachment.localDocumentId;
                        else if (documentAttachment.documentId != 0)
                            previousRemoteDocumentId = documentAttachment.documentId;
                    }
                    else if (attachment.type == TGAudioMediaAttachmentType)
                    {
                        TGAudioMediaAttachment *audioAttachment = (TGAudioMediaAttachment *)attachment;
                        if (audioAttachment.localAudioId != 0)
                            previousLocalAudioId = audioAttachment.localAudioId;
                        else if (audioAttachment.audioId != 0)
                            previousRemoteAudioId = audioAttachment.audioId;
                    }
                }
                
                int64_t currentLocalImageId = 0;
                int64_t currentRemoteImageId = 0;
                
                int64_t currentLocalVideoId = 0;
                int64_t currentRemoteVideoId = 0;
                
                int64_t currentLocalDocumentId = 0;
                int64_t currentRemoteDocumentId = 0;
                
                int64_t currentLocalAudioId = 0;
                int64_t currentRemoteAudioId = 0;
                
                for (TGMediaAttachment *attachment in media)
                {
                    if (attachment.type == TGImageMediaAttachmentType)
                    {
                        TGImageMediaAttachment *imageAttachment = (TGImageMediaAttachment *)attachment;
                        if (imageAttachment.imageId != 0)
                            currentRemoteImageId = imageAttachment.imageId;
                        else
                            currentLocalImageId = imageAttachment.localImageId;
                    }
                    else if (attachment.type == TGVideoMediaAttachmentType)
                    {
                        TGVideoMediaAttachment *videoAttachment = (TGVideoMediaAttachment *)attachment;
                        if (videoAttachment.localVideoId != 0)
                            currentLocalVideoId = videoAttachment.localVideoId;
                        else if (videoAttachment.videoId != 0)
                            currentRemoteVideoId = videoAttachment.videoId;
                    }
                    else if (attachment.type == TGDocumentMediaAttachmentType)
                    {
                        TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)attachment;
                        if (documentAttachment.localDocumentId != 0)
                            currentLocalDocumentId = documentAttachment.localDocumentId;
                        else if (documentAttachment.documentId != 0)
                            currentRemoteDocumentId = documentAttachment.documentId;
                    }
                    else if (attachment.type == TGAudioMediaAttachmentType)
                    {
                        TGAudioMediaAttachment *audioAttachment = (TGAudioMediaAttachment *)attachment;
                        if (audioAttachment.localAudioId != 0)
                            currentLocalAudioId = audioAttachment.localAudioId;
                        else if (audioAttachment.audioId != 0)
                            currentRemoteAudioId = audioAttachment.audioId;
                    }
                }
                
                if (currentLocalImageId != 0)
                    addFileMid(self, peerId, updatedMid, TGLocalImageFileType, currentLocalImageId);
                else if (currentRemoteImageId != 0)
                    addFileMid(self, peerId, updatedMid, TGImageFileType, currentRemoteImageId);
                
                if (currentLocalVideoId != 0)
                    addVideoMid(self, peerId, updatedMid, currentLocalVideoId, true);
                else if (currentRemoteVideoId != 0)
                    addVideoMid(self, peerId, updatedMid, currentRemoteVideoId, false);
                
                if (currentLocalDocumentId != 0)
                    addFileMid(self, peerId, updatedMid, TGLocalDocumentFileType, currentLocalDocumentId);
                else if (currentRemoteDocumentId != 0)
                    addFileMid(self, peerId, updatedMid, TGDocumentFileType, currentRemoteDocumentId);
                
                if (currentLocalAudioId != 0)
                    addFileMid(self, peerId, updatedMid, TGLocalAudioFileType, currentLocalAudioId);
                else if (currentRemoteAudioId != 0)
                    addFileMid(self, peerId, updatedMid, TGAudioFileType, currentRemoteAudioId);
                
                if (previousRemoteImageId != 0) {
                    removeFileMid(self, peerId, previousMid, TGImageFileType, previousRemoteImageId);
                } else if (previousLocalImageId != 0) {
                    removeFileMid(self, peerId, previousMid, TGLocalImageFileType, previousLocalImageId);
                }
                
                if (previousLocalVideoId != 0)
                    removeVideoMid(self, peerId, previousMid, previousLocalVideoId, true);
                else if (previousRemoteVideoId != 0)
                    removeVideoMid(self, peerId, previousMid, previousRemoteVideoId, false);
                
                if (previousLocalDocumentId != 0)
                    removeFileMid(self, peerId, previousMid, TGLocalDocumentFileType, previousLocalDocumentId);
                else if (previousRemoteDocumentId != 0)
                    removeFileMid(self, peerId, previousMid, TGDocumentFileType, previousRemoteDocumentId);
                
                if (previousLocalAudioId != 0)
                    removeFileMid(self, peerId, previousMid, TGLocalAudioFileType, previousLocalAudioId);
                else if (previousRemoteAudioId != 0)
                    removeFileMid(self, peerId, previousMid, TGAudioFileType, previousRemoteAudioId);
                
                message.sortKey = TGMessageSortKeyMake(peerId, TGMessageSortKeySpace(message.sortKey), (int32_t)message.date, message.mid);
                message.mediaAttachments = media;
                PSKeyValueEncoder *encoder = [[PSKeyValueEncoder alloc] init];
                [message encodeWithKeyValueCoder:encoder];
                
                [_database executeUpdate:[[NSString alloc] initWithFormat:@"UPDATE %@ SET mid=?, data=?, sort_key=?, transparent_sort_key=? WHERE cid=? AND mid=?", _channelMessagesTableName], @(message.mid), encoder.data, TGMessageSortKeyData(message.sortKey), TGMessageTransparentSortKeyData(message.transparentSortKey), @(peerId), @(mid)];
                
                if (previousMid != message.mid) {
                    [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE cid=? AND mid=?", _channelMessageTagsTableName], @(peerId), @(previousMid)];
                    [self cacheMediaForPeerId:peerId messages:@[message]];
                }
                
                [self updateChannelMessageSortKeyAndDispatch:peerId previousSortKey:previousSortKey updatedSortKey:message.sortKey];
                
                [self _updateChannelConversation:peerId];
            }
        } else {
            NSMutableArray *changedMessageIds = [[NSMutableArray alloc] init];
            
             FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE mid=? LIMIT 1", _messagesTableName], [[NSNumber alloc] initWithInt:mid]];
             if ([result next])
             {
                 int64_t isUnread = [result longLongIntForColumn:@"unread"];
                 int deliveryState = [result intForColumn:@"dstate"];
                 int date = [result intForColumn:@"date"];
                 bool wasPending = deliveryState == TGMessageDeliveryStatePending || deliveryState == TGMessageDeliveryStateFailed;
                 bool wasDelivered = deliveryState == TGMessageDeliveryStateDelivered;
                 bool wasFailed = deliveryState == TGMessageDeliveryStateFailed;
                 int newMid = mid;
                 int newDate = date;
                 int64_t conversationId = [result longLongIntForColumn:@"cid"];
                 bool outgoing = [result intForColumn:@"outgoing"];
                 
                 bool changed = false;

                 int64_t previousLocalVideoId = 0;
                 int64_t previousRemoteVideoId = 0;
                 
                 int64_t previousLocalDocumentId = 0;
                 int64_t previousRemoteDocumentId = 0;
                 
                 int64_t previousLocalAudioId = 0;
                 int64_t previousRemoteAudioId = 0;
                 
                 for (TGMediaAttachment *attachment in [TGMessage parseMediaAttachments:[result dataForColumn:@"media"]])
                 {
                     if (attachment.type == TGVideoMediaAttachmentType)
                     {
                         TGVideoMediaAttachment *videoAttachment = (TGVideoMediaAttachment *)attachment;
                         if (videoAttachment.localVideoId != 0)
                             previousLocalVideoId = videoAttachment.localVideoId;
                         else if (videoAttachment.videoId != 0)
                             previousRemoteVideoId = videoAttachment.videoId;
                     }
                     else if (attachment.type == TGDocumentMediaAttachmentType)
                     {
                         TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)attachment;
                         if (documentAttachment.localDocumentId != 0)
                             previousLocalDocumentId = documentAttachment.localDocumentId;
                         else if (documentAttachment.documentId != 0)
                             previousRemoteDocumentId = documentAttachment.documentId;
                     }
                     else if (attachment.type == TGAudioMediaAttachmentType)
                     {
                         TGAudioMediaAttachment *audioAttachment = (TGAudioMediaAttachment *)attachment;
                         if (audioAttachment.localAudioId != 0)
                             previousLocalAudioId = audioAttachment.localAudioId;
                         else if (audioAttachment.audioId != 0)
                             previousRemoteAudioId = audioAttachment.audioId;
                     }
                 }
                 
                 for (TGMediaAttachment *attachment in media)
                 {
                     if (attachment.type == TGVideoMediaAttachmentType)
                     {
                         TGVideoMediaAttachment *videoAttachment = (TGVideoMediaAttachment *)attachment;
                         if (videoAttachment.localVideoId != 0)
                             previousLocalVideoId = videoAttachment.localVideoId;
                         else if (videoAttachment.videoId != 0)
                             previousRemoteVideoId = videoAttachment.videoId;
                     }
                     else if (attachment.type == TGDocumentMediaAttachmentType)
                     {
                         TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)attachment;
                         if (documentAttachment.localDocumentId != 0)
                             previousLocalDocumentId = documentAttachment.localDocumentId;
                         else if (documentAttachment.documentId != 0)
                             previousRemoteDocumentId = documentAttachment.documentId;
                     }
                     else if (attachment.type == TGAudioMediaAttachmentType)
                     {
                         TGAudioMediaAttachment *audioAttachment = (TGAudioMediaAttachment *)attachment;
                         if (audioAttachment.localAudioId != 0)
                             previousLocalAudioId = audioAttachment.localAudioId;
                         else if (audioAttachment.audioId != 0)
                             previousRemoteAudioId = audioAttachment.audioId;
                     }
                 }
                 
                 for (std::vector<TGDatabaseMessageFlagValue>::const_iterator it = flags.begin(); it != flags.end(); it++)
                 {
                     switch (it->flag)
                     {
                         case TGDatabaseMessageFlagDeliveryState:
                             deliveryState = it->value;
                             changed = true;
                             break;
                         case TGDatabaseMessageFlagUnread:
                             isUnread = it->value != 0 ? conversationId : 0;
                             changed = true;
                             break;
                         case TGDatabaseMessageFlagMid:
                             newMid = it->value;
                             changed = true;
                             break;
                         case TGDatabaseMessageFlagDate:
                             newDate = it->value;
                             changed = true;
                             break;
                         default:
                             break;
                     }
                 }
                 
                 if (media != nil && mid != newMid)
                 {
                     int64_t currentLocalVideoId = 0;
                     int64_t currentRemoteVideoId = 0;
                     
                     int64_t currentLocalDocumentId = 0;
                     int64_t currentRemoteDocumentId = 0;
                     
                     int64_t currentLocalAudioId = 0;
                     int64_t currentRemoteAudioId = 0;
                     
                     for (TGMediaAttachment *attachment in media)
                     {
                         if (attachment.type == TGVideoMediaAttachmentType)
                         {
                             TGVideoMediaAttachment *videoAttachment = (TGVideoMediaAttachment *)attachment;
                             if (videoAttachment.localVideoId != 0)
                                 currentLocalVideoId = videoAttachment.localVideoId;
                             else if (videoAttachment.videoId != 0)
                                 currentRemoteVideoId = videoAttachment.videoId;
                         }
                         else if (attachment.type == TGDocumentMediaAttachmentType)
                         {
                             TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)attachment;
                             if (documentAttachment.localDocumentId != 0)
                                 currentLocalDocumentId = documentAttachment.localDocumentId;
                             else if (documentAttachment.documentId != 0)
                                 currentRemoteDocumentId = documentAttachment.documentId;
                         }
                         else if (attachment.type == TGAudioMediaAttachmentType)
                         {
                             TGAudioMediaAttachment *audioAttachment = (TGAudioMediaAttachment *)attachment;
                             if (audioAttachment.localAudioId != 0)
                                 currentLocalAudioId = audioAttachment.localAudioId;
                             else if (audioAttachment.audioId != 0)
                                 currentRemoteAudioId = audioAttachment.audioId;
                         }
                     }
                     
                     if (currentLocalVideoId != 0)
                         addVideoMid(self, 0, newMid, currentLocalVideoId, true);
                     else if (currentRemoteVideoId != 0)
                         addVideoMid(self, 0, newMid, currentRemoteVideoId, false);
                     
                     if (currentLocalDocumentId != 0)
                         addFileMid(self, 0, newMid, TGLocalDocumentFileType, currentLocalDocumentId);
                     else if (currentRemoteDocumentId != 0)
                         addFileMid(self, 0, newMid, TGDocumentFileType, currentRemoteDocumentId);
                     
                     if (currentLocalAudioId != 0)
                         addFileMid(self, 0, newMid, TGLocalAudioFileType, currentLocalAudioId);
                     else if (currentRemoteAudioId != 0)
                         addFileMid(self, 0, newMid, TGAudioFileType, currentRemoteAudioId);
                     
                     if (previousLocalVideoId != 0)
                         removeVideoMid(self, 0, mid, previousLocalVideoId, true);
                     else if (previousRemoteVideoId != 0)
                         removeVideoMid(self, 0, mid, previousRemoteVideoId, false);
                     
                     if (previousLocalDocumentId != 0)
                         removeFileMid(self, 0, mid, TGLocalDocumentFileType, previousLocalDocumentId);
                     else if (previousRemoteDocumentId != 0)
                         removeFileMid(self, 0, mid, TGDocumentFileType, previousRemoteDocumentId);
                     
                     if (previousLocalAudioId != 0)
                         removeFileMid(self, 0, mid, TGLocalAudioFileType, previousLocalAudioId);
                     else if (previousRemoteAudioId != 0)
                         removeFileMid(self, 0, mid, TGAudioFileType, previousRemoteAudioId);
                 }
                 
                 if (changed)
                 {
                     if (wasPending && deliveryState == TGMessageDeliveryStateDelivered)
                         [_database executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE mid=?", _outgoingMessagesTableName], [[NSNumber alloc] initWithInt:mid]];
                     else if (wasDelivered && deliveryState == TGMessageDeliveryStateFailed)
                     {
                         NSString *outboxInsertQueryFormat = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (mid, cid, dstate, local_media_id) VALUES (?, ?, ?, ?)", _outgoingMessagesTableName];
                         [_database executeUpdate:outboxInsertQueryFormat, [[NSNumber alloc] initWithInt:newMid], [[NSNumber alloc] initWithLongLong:conversationId], [[NSNumber alloc] initWithInt:deliveryState], [[NSNumber alloc] initWithInt:0]];
                     }
                     else if (deliveryState == TGMessageDeliveryStatePending && wasFailed)
                     {
                         NSString *outboxInsertQueryFormat = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (mid, cid, dstate, local_media_id) VALUES (?, ?, ?, ?)", _outgoingMessagesTableName];
                         [_database executeUpdate:outboxInsertQueryFormat, [[NSNumber alloc] initWithInt:newMid], [[NSNumber alloc] initWithLongLong:conversationId], [[NSNumber alloc] initWithInt:deliveryState], [[NSNumber alloc] initWithInt:0]];
                     }
                     else
                     {
                         [_database executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET dstate=? WHERE mid=?", _outgoingMessagesTableName], [[NSNumber alloc] initWithInt:deliveryState], [[NSNumber alloc] initWithInt:mid]];
                     }
                     
                     if (newMid != mid)
                     {
                         [changedMessageIds addObject:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:mid], [[NSNumber alloc] initWithInt:newMid], nil]];
                         
                         [_database executeUpdate:[NSString stringWithFormat:@"UPDATE OR IGNORE %@ SET mid=?, unread=?, dstate=?, date=? WHERE mid=?", _messagesTableName], [[NSNumber alloc] initWithInt:newMid], isUnread ? [[NSNumber alloc] initWithLongLong:outgoing ? INT_MAX : conversationId] : nil, [[NSNumber alloc] initWithInt:deliveryState], [[NSNumber alloc] initWithInt:newDate], [[NSNumber alloc] initWithInt:mid]];
                         
                         [_database executeUpdate:[NSString stringWithFormat:@"UPDATE OR IGNORE %@ SET mid=?, date=? WHERE mid=?", _conversationMediaTableName], [[NSNumber alloc] initWithInt:newMid], [[NSNumber alloc] initWithInt:newDate], [[NSNumber alloc] initWithInt:mid]];
                         
                         [self actualizeConversation:conversationId dispatch:dispatch];
                     }
                     else
                     {
                         [_database executeUpdate:[NSString stringWithFormat:@"UPDATE OR IGNORE %@ SET unread=?, dstate=?, date=? WHERE mid=?", _messagesTableName], isUnread ? [[NSNumber alloc] initWithLongLong:outgoing ? INT_MAX : conversationId] : nil, [[NSNumber alloc] initWithInt:deliveryState], [[NSNumber alloc] initWithInt:newDate], [[NSNumber alloc] initWithInt:mid]];

                         [self actualizeConversation:conversationId dispatch:dispatch];
                     }
                 }
                 
                 if (media != nil)
                 {
                     [_database executeUpdate:[[NSString alloc] initWithFormat:@"UPDATE %@ SET media=? WHERE mid=?", _messagesTableName], [TGMessage serializeMediaAttachments:true attachments:media], @(newMid)];
                     [_database executeUpdate:[[NSString alloc] initWithFormat:@"UPDATE %@ SET media=? WHERE mid=?", _conversationMediaTableName], [TGMessage serializeMediaAttachments:true attachments:media], @(newMid)];
                 }
                 
                 TGMessage *newMessage = [self loadMessageWithMid:newMid peerId:peerId];
                 
                 [self removeMediaFromCacheForPeerId:conversationId messageIds:@[@(mid)]];
                 if (newMessage != nil)
                     [self cacheMediaForPeerId:conversationId messages:@[newMessage]];
             }
             else
             {
                 TGLog(@"***** Warning: message %d not found", mid);
             }
            
            if (changedMessageIds.count != 0)
            {
                [self dispatchOnIndexThread:^
                {
                    NSString *indexInsertFormat = [NSString stringWithFormat:@"UPDATE %@ SET docid=? WHERE docid=?", _messageIndexTableName];
                    
                    [_indexDatabase beginTransaction];
                    for (NSArray *mids in changedMessageIds)
                    {
    #if TARGET_IPHONE_SIMULATOR
                        TGLog(@"index: moving %@ to %@", mids[0], mids[1]);
    #endif
                        [_indexDatabase executeUpdate:indexInsertFormat, [mids objectAtIndex:1], [mids objectAtIndex:0]];
                    }
                    [_indexDatabase commit];
                } synchronous:false];
            }
        }
    } synchronous:false];
}

- (void)updateMessage:(int32_t)__unused mid peerId:(int64_t)peerId withMessage:(TGMessage *)message
{
    [self dispatchOnDatabaseThread:^
    {
        NSString *queryFormat = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (mid, cid, localMid, message, media, from_id, to_id, outgoing, unread, dstate, date, flags, seq_in, seq_out, content_properties) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", _messagesTableName];
        
        [_database executeUpdate:queryFormat, [[NSNumber alloc] initWithInt:message.mid], [[NSNumber alloc] initWithLongLong:peerId], [[NSNumber alloc] initWithInt:0], message.text, [message serializeMediaAttachments:false], [[NSNumber alloc] initWithLongLong:message.fromUid], [[NSNumber alloc] initWithLongLong:message.toUid], [[NSNumber alloc] initWithInt:message.outgoing ? 1 : 0], message.unread ? [[NSNumber alloc] initWithLongLong:message.outgoing ? INT_MAX : peerId] : nil, [[NSNumber alloc] initWithInt:message.deliveryState], [[NSNumber alloc] initWithInt:(int)(message.date)], [[NSNumber alloc] initWithLongLong:message.flags], [[NSNumber alloc] initWithInt:message.seqIn], [[NSNumber alloc] initWithInt:message.seqOut], [message serializeContentProperties]];
    } synchronous:false];
}

- (void)updateMessages:(NSArray *)messages
{
    [self dispatchOnDatabaseThread:^
     {
         NSString *queryFormat = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (mid, cid, localMid, message, media, from_id, to_id, outgoing, unread, dstate, date, flags, seq_in, seq_out, content_properties) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", _messagesTableName];
         
         [_database beginTransaction];
         for (TGMessage *message in messages)
         {
             [_database executeUpdate:queryFormat, [[NSNumber alloc] initWithInt:message.mid], [[NSNumber alloc] initWithLongLong:message.cid], [[NSNumber alloc] initWithInt:0], message.text, [message serializeMediaAttachments:false], [[NSNumber alloc] initWithLongLong:message.fromUid], [[NSNumber alloc] initWithLongLong:message.toUid], [[NSNumber alloc] initWithInt:message.outgoing ? 1 : 0], message.unread ? [[NSNumber alloc] initWithLongLong:message.outgoing ? INT_MAX : message.cid] : nil, [[NSNumber alloc] initWithInt:message.deliveryState], [[NSNumber alloc] initWithInt:(int)(message.date)], [[NSNumber alloc] initWithLongLong:message.flags], [[NSNumber alloc] initWithInt:message.seqIn], [[NSNumber alloc] initWithInt:message.seqOut], [message serializeContentProperties]];
         }
         [_database commit];
     } synchronous:false];
}

- (void)updateMessageViews:(int64_t)peerId messageIdToViews:(NSDictionary *)messageIdToViews {
    [self dispatchOnDatabaseThread:^{
        if (TGPeerIdIsChannel(peerId)) {
            PSKeyValueDecoder *decoder = [[PSKeyValueDecoder alloc] init];
            PSKeyValueEncoder *encoder = [[PSKeyValueEncoder alloc] init];
            
            for (NSNumber *nId in messageIdToViews.allKeys) {
                FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT data FROM %@ WHERE cid=? AND mid=?", _channelMessagesTableName], @(peerId), nId];
                if ([result next]) {
                    [decoder resetData:[result dataForColumnIndex:0]];
                    TGMessage *message = [[TGMessage alloc] initWithKeyValueCoder:decoder];
                    int32_t updatedCount = [messageIdToViews[nId] intValue];
                    if (message.viewCount.viewCount < updatedCount) {
                        message.viewCount = [[TGMessageViewCountContentProperty alloc] initWithViewCount:updatedCount];
                        
                        [encoder reset];
                        [message encodeWithKeyValueCoder:encoder];
                        
                        [_database executeUpdate:[[NSString alloc] initWithFormat:@"UPDATE %@ SET data=? WHERE cid=? AND mid=?", _channelMessagesTableName], encoder.data, @(peerId), nId];
                    }
                }
            }
        } else {
            for (NSNumber *nId in messageIdToViews.allKeys) {
                FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT content_properties FROM %@ WHERE mid=?", _messagesTableName], nId];
                if ([result next]) {
                    NSMutableDictionary *contentProperties = [[NSMutableDictionary alloc] initWithDictionary:[TGMessage parseContentProperties:[result dataForColumnIndex:0]]];
                    int32_t updatedCount = [messageIdToViews[nId] intValue];
                    if (((TGMessageViewCountContentProperty *)contentProperties[@"viewCount"]).viewCount != updatedCount) {
                        contentProperties[@"viewCount"] = [[TGMessageViewCountContentProperty alloc] initWithViewCount:updatedCount];
                        [_database executeUpdate:[[NSString alloc] initWithFormat:@"UPDATE %@ SET content_properties=? WHERE mid=?", _messagesTableName], [TGMessage serializeContentProperties:contentProperties], nId];
                    }
                }
            }
        }
    } synchronous:false];
}

- (void)deleteMessages:(NSArray *)mids populateActionQueue:(bool)populateActionQueue fillMessagesByConversationId:(NSMutableDictionary *)messagesByConversationId
{
    [self deleteMessages:mids populateActionQueue:populateActionQueue fillMessagesByConversationId:messagesByConversationId keepDate:false populateActionQueueIfIncoming:false];
}

- (void)deleteMessages:(NSArray *)mids populateActionQueue:(bool)populateActionQueue fillMessagesByConversationId:(NSMutableDictionary *)messagesByConversationId keepDate:(bool)keepDate populateActionQueueIfIncoming:(bool)populateActionQueueIfIncoming
{
    [self dispatchOnDatabaseThread:^
    {
        std::map<int64_t, int> conversationSet;
        
        NSMutableArray *actions = [[NSMutableArray alloc] init];
        
        NSString *messagesDeleteFormat = [NSString stringWithFormat:@"DELETE FROM %@ WHERE mid=?", _messagesTableName];
        NSString *mediaDeleteFormat = [NSString stringWithFormat:@"DELETE FROM %@ WHERE mid=?", _conversationMediaTableName];
        NSString *outboxDeleteFormat = [NSString stringWithFormat:@"DELETE FROM %@ WHERE mid=?", _outgoingMessagesTableName];
        
        sqlite3_exec([_database sqliteHandle], "PRAGMA secure_delete = 1", NULL, NULL, NULL);
        
        int deletedUnreadCount = 0;
        
        TGLog(@"Deleting %d messages", (int)mids.count);
        
        for (NSNumber *nMid in mids)
        {
            FMResultSet *messageResult = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE mid=? LIMIT 1", _messagesTableName], nMid];
            
            bool found = false;
            int64_t cid = 0;
            NSData *localMedia = nil;
            NSArray *parsedLocalMedia = nil;
            bool outgoing = false;
            
            if ([messageResult next])
            {
                found = true;
                
                int indexMedia = [messageResult columnIndexForName:@"media"];
                int indexCid = [messageResult columnIndexForName:@"cid"];
                
                cid = [messageResult longLongIntForColumnIndex:indexCid];
                
                outgoing = [messageResult intForColumn:@"outgoing"] != 0;
                
                if (messagesByConversationId != nil)
                {
                    NSNumber *conversationKey = [[NSNumber alloc] initWithLongLong:cid];
                    NSMutableArray *messagesInConversation = [messagesByConversationId objectForKey:conversationKey];
                    if (messagesInConversation == nil)
                    {
                        messagesInConversation = [[NSMutableArray alloc] init];
                        [messagesByConversationId setObject:messagesInConversation forKey:conversationKey];
                    }
                    [messagesInConversation addObject:nMid];
                }
                
                localMedia = [messageResult dataForColumnIndex:indexMedia];
                
                if ([nMid intValue] < TGMessageLocalMidBaseline && [messageResult intForColumn:@"outgoing"] == 0 && [messageResult intForColumn:@"unread"] != 0)
                {
                    conversationSet[cid]--;
                    deletedUnreadCount++;
                }
                else
                {
                    if (conversationSet.find(cid) == conversationSet.end())
                        conversationSet[cid] = 0;
                }
            }
            else
            {
                FMResultSet *mediaResult = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT cid, media FROM %@ WHERE mid=? LIMIT 1", _conversationMediaTableName], nMid];
                
                if ([mediaResult next])
                {
                    found = true;
                    
                    localMedia = [mediaResult dataForColumn:@"media"];
                    
                    cid = [mediaResult longLongIntForColumn:@"cid"];
                    if (conversationSet.find(cid) == conversationSet.end())
                        conversationSet[cid] = 0;
                    
                    if (messagesByConversationId != nil)
                    {
                        NSNumber *conversationKey = [[NSNumber alloc] initWithLongLong:cid];
                        NSMutableArray *messagesInConversation = [messagesByConversationId objectForKey:conversationKey];
                        if (messagesInConversation == nil)
                        {
                            messagesInConversation = [[NSMutableArray alloc] init];
                            [messagesByConversationId setObject:messagesInConversation forKey:conversationKey];
                        }
                        [messagesInConversation addObject:nMid];
                    }
                }
                else
                {
                    TGMessage *mediaMessage = [self _cachedMediaMessageForId:[nMid intValue]];
                    if (mediaMessage != nil)
                    {
                        found = true;
                        outgoing = mediaMessage.outgoing;
                        cid = mediaMessage.cid;
                        parsedLocalMedia = mediaMessage.mediaAttachments;
                    }
                }
            }
            
            if (found)
            {
                if (localMedia != nil && localMedia.length != 0)
                {
                    cleanupMessage(self, [nMid intValue], [TGMessage parseMediaAttachments:localMedia], _messageCleanupBlock);
                }
                if (parsedLocalMedia != nil)
                    cleanupMessage(self, [nMid intValue], parsedLocalMedia, _messageCleanupBlock);

                if (populateActionQueue || (populateActionQueueIfIncoming && !outgoing))
                {
                    if (cid <= INT_MIN)
                    {
                        int32_t conversationIdHigh = ((int32_t *)&cid)[0];
                        int32_t conversationIdLow = ((int32_t *)&cid)[1];
                        
                        TGDatabaseAction action = { .type = TGDatabaseActionDeleteSecretMessage, .subject = [nMid intValue], .arg0 = conversationIdHigh, .arg1 = conversationIdLow };
                        [actions addObject:[[NSValue alloc] initWithBytes:&action objCType:@encode(TGDatabaseAction)]];
                    }
                    else if ([nMid intValue] < TGMessageLocalMidBaseline)
                    {
                        TGDatabaseAction action = { .type = TGDatabaseActionDeleteMessage, .subject = [nMid intValue], .arg0 = 0, .arg1 = 0 };
                        [actions addObject:[[NSValue alloc] initWithBytes:&action objCType:@encode(TGDatabaseAction)]];
                    }
                }
                
                [_database executeUpdate:messagesDeleteFormat, nMid];
                [_database executeUpdate:mediaDeleteFormat, nMid];
            }
            
            [self removeMediaFromCacheForPeerId:cid messageIds:@[nMid]];
            
            if ([nMid intValue] >= 800000000)
                [_database executeUpdate:outboxDeleteFormat, nMid];
        }
        
        for (auto it = conversationSet.begin(); it != conversationSet.end(); it++)
        {
            [self actualizeConversation:it->first dispatch:true conversation:nil forceUpdate:false addUnreadCount:it->second addServiceUnreadCount:0 keepDate:keepDate];
        }
        
        if (deletedUnreadCount != 0)
        {
            int unreadCount = [self databaseState].unreadCount - deletedUnreadCount;
            if (unreadCount < 0)
                TGLog(@"***** Warning: wrong unread_count");
            [self setUnreadCount:MAX(unreadCount, 0)];
        }
        
        if (actions.count != 0)
            [self storeQueuedActions:actions];
        
        [_database setSoftShouldCacheStatements:false];
        NSMutableString *midsString = [[NSMutableString alloc] init];
        int count = (int)mids.count;
        for (int j = 0; j < count; )
        {
            [midsString deleteCharactersInRange:NSMakeRange(0, midsString.length)];
            
            for (int i = 0; i < 256 && j < count; i++, j++)
            {
                if (midsString.length != 0)
                    [midsString appendString:@","];
                [midsString appendFormat:@"%d", [mids[j] intValue]];
            }
            
            [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE mid IN (%@)", _selfDestructTableName, midsString]];
        }
        [_database setSoftShouldCacheStatements:true];
        
        sqlite3_exec([_database sqliteHandle], "PRAGMA secure_delete = 0", NULL, NULL, NULL);
        
        [self dispatchOnIndexThread:^
        {
            NSString *deleteQueryFormat = [NSString stringWithFormat:@"DELETE FROM %@ WHERE docid=?", _messageIndexTableName];
            [_indexDatabase beginTransaction];
            for (NSNumber *nMid in mids)
            {
#if TARGET_IPHONE_SIMULATOR
                TGLog(@"index: delete %@", nMid);
#endif
                [_indexDatabase executeUpdate:deleteQueryFormat, nMid];
            }
            [_indexDatabase commit];
        } synchronous:false];
    } synchronous:(populateActionQueue || messagesByConversationId != nil)];
}

- (void)deleteConversation:(int64_t)conversationId populateActionQueue:(bool)populateActionQueue
{
    [self clearConversation:conversationId populateActionQueue:populateActionQueue clearOnly:false];
}

- (void)clearConversation:(int64_t)conversationId populateActionQueue:(bool)populateActionQueue
{
    [self clearConversation:conversationId populateActionQueue:populateActionQueue clearOnly:true];
}

- (void)clearConversation:(int64_t)conversationId populateActionQueue:(bool)populateActionQueue clearOnly:(bool)clearOnly
{
    [self dispatchOnDatabaseThread:^
    {
        NSMutableSet *cleanedUpMessageIds = [[NSMutableSet alloc] init];
        
        FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT mid, media FROM %@ WHERE cid=? AND media NOT NULL", _messagesTableName], [[NSNumber alloc] initWithLongLong:conversationId]];
        int midIndex = [result columnIndexForName:@"mid"];
        int mediaIndex = [result columnIndexForName:@"media"];
        while ([result next])
        {
            int mid = [result intForColumnIndex:midIndex];
            NSData *media = [result dataForColumnIndex:mediaIndex];
            if (media != nil && media.length != 0)
            {
                [cleanedUpMessageIds addObject:@(mid)];
                cleanupMessage(self, mid, [TGMessage parseMediaAttachments:media], _messageCleanupBlock);
            }
        }
        
        result = [_database executeQuery:[NSString stringWithFormat:@"SELECT mid, media FROM %@ WHERE cid=?", _conversationMediaTableName], [[NSNumber alloc] initWithLongLong:conversationId]];
        midIndex = [result columnIndexForName:@"mid"];
        mediaIndex = [result columnIndexForName:@"media"];
        while ([result next])
        {
            int mid = [result intForColumnIndex:midIndex];
            NSNumber *nMid = @(mid);
            if (![cleanedUpMessageIds containsObject:nMid])
            {
                [cleanedUpMessageIds addObject:nMid];
                NSData *media = [result dataForColumnIndex:mediaIndex];
                if (media != nil && media.length != 0)
                {
                    cleanupMessage(self, mid, [TGMessage parseMediaAttachments:media], _messageCleanupBlock);
                }
            }
        }
        
        [self cachedMediaForPeerId:conversationId itemType:TGSharedMediaCacheItemTypePhotoVideoFile limit:0 important:false completion:^(NSArray *cachedMediaMessages, bool)
        {
            for (TGMessage *message in cachedMediaMessages)
            {
                NSNumber *nMid = @(message.mid);
                if (![cleanedUpMessageIds containsObject:nMid])
                {
                    cleanupMessage(self, message.mid, message.mediaAttachments, _messageCleanupBlock);
                }
            }
        } buildIndex:false isCancelled:nil];
        
        [self removeMediaFromCacheForPeerId:conversationId];
        
        NSMutableArray *midsInConversation = [[NSMutableArray alloc] init];
        FMResultSet *midsResult = [_database executeQuery:[NSString stringWithFormat:@"SELECT mid FROM %@ WHERE cid=?", _messagesTableName], [[NSNumber alloc] initWithLongLong:conversationId]];
        int midsResultMidIndex = [midsResult columnIndexForName:@"mid"];
        while ([midsResult next])
        {
            [midsInConversation addObject:[[NSNumber alloc] initWithInt:[midsResult intForColumnIndex:midsResultMidIndex]]];
        }
        
        [_database executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE cid=?", _messagesTableName], [[NSNumber alloc] initWithLongLong:conversationId]];
        [_database executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE cid=?", _conversationMediaTableName], [[NSNumber alloc] initWithLongLong:conversationId]];
        [_database executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE cid=?", _outgoingMessagesTableName], [[NSNumber alloc] initWithLongLong:conversationId]];
        
        TGConversation *conversation = [self loadConversationWithId:conversationId];
        if (conversation != nil)
        {
            int previousConversationUnreadCount = 0;
            
            if (conversation.unreadCount != 0)
            {
                previousConversationUnreadCount = conversation.unreadCount;
                int unreadCount = [self databaseState].unreadCount - conversation.unreadCount;
                if (unreadCount < 0)
                    TGLog(@"***** Warning: wrong unread_count");
                [self setUnreadCount:MAX(unreadCount, 0)];
            }
            
            if (clearOnly)
            {
                [self loadConversationWithId:conversationId];
                [self actualizeConversation:conversationId dispatch:true];
                
                if (populateActionQueue)
                {
                    if (conversationId <= INT_MIN)
                    {
                        NSMutableArray *actions = [[NSMutableArray alloc] init];
                        
                        TGDatabaseAction action = { .type = TGDatabaseActionClearSecretConversation, .subject = conversationId, .arg0 = 0, .arg1 = 0 };
                        [actions addObject:[[NSValue alloc] initWithBytes:&action objCType:@encode(TGDatabaseAction)]];
                        
                        [self storeQueuedActions:actions];
                    }
                    else
                    {
                        TGDatabaseAction action = { .type = TGDatabaseActionClearConversation, .subject = conversationId, .arg0 = 0, .arg1 = previousConversationUnreadCount };
                        [self storeQueuedActions:[NSArray arrayWithObject:[[NSValue alloc] initWithBytes:&action objCType:@encode(TGDatabaseAction)]]];
                    }
                }
            }
            else
            {
                [_database executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE cid=?", [self _listTableNameForConversationId:conversationId]], [[NSNumber alloc] initWithLongLong:conversationId]];
                
                [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE peer_id=?", _secretPeerIncomingTableName], @(conversationId)];
                [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE peer_id=?", _secretPeerIncomingEncryptedTableName], @(conversationId)];
                [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE peer_id=?", _secretPeerOutgoingTableName], @(conversationId)];
                [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE peer_id=?", _secretPeerOutgoingResendTableName], @(conversationId)];
                
                TG_SYNCHRONIZED_BEGIN(_cachedConversations);
                _cachedConversations.erase(conversationId);
                TG_SYNCHRONIZED_END(_cachedConversations);
            
                if (populateActionQueue)
                {
                    TGDatabaseAction action = { .type = TGDatabaseActionDeleteConversation, .subject = conversationId, .arg0 = 0, .arg1 = previousConversationUnreadCount };
                    [self storeQueuedActions:[NSArray arrayWithObject:[[NSValue alloc] initWithBytes:&action objCType:@encode(TGDatabaseAction)]]];
                }
            }
        }
        
        if (!clearOnly)
        {
            if (conversationId <= INT_MIN)
            {
                [self setConversationCustomProperty:conversationId name:murMurHash32(@"key") value:nil];
            }
        }
        
        [self dispatchOnIndexThread:^
        {
            int midsCount = (int)midsInConversation.count;
            
            [_indexDatabase setSoftShouldCacheStatements:false];
            [_indexDatabase beginTransaction];
            NSMutableString *rangeString = [[NSMutableString alloc] init];
            for (int i = 0; i < midsCount; i++)
            {
                if (rangeString.length != 0)
                    [rangeString deleteCharactersInRange:NSMakeRange(0, rangeString.length)];
                
                bool first = true;
                int count = 0;
                for (; count < 20 && i < midsCount; i++, count++)
                {
                    if (first)
                        first = false;
                    else
                        [rangeString appendString:@","];
                    
                    [rangeString appendFormat:@"%d", [[midsInConversation objectAtIndex:i] intValue]];
                }
                
                NSString *deleteQueryFormat = [[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE docid IN (%@)", _messageIndexTableName, rangeString];
#if TARGET_IPHONE_SIMULATOR
                TGLog(@"index: delete %@", rangeString);
#endif
                [_indexDatabase executeUpdate:deleteQueryFormat];
            }
            [_indexDatabase commit];
            [_indexDatabase setSoftShouldCacheStatements:true];
        } synchronous:false];
    } synchronous:false];
}

- (void)markMessagesAsRead:(NSArray *)mids
{
    if (mids.count == 0)
        return;
    
    [self dispatchOnDatabaseThread:^
    {
        const int batchCount = 256;
        
        std::map<int64_t, int> unreadByConversation;
        std::set<int64_t> outgoingUnreadConversations;
        
        NSMutableString *rangeString = [[NSMutableString alloc] init];
        int midsCount = (int)mids.count;
        for (int i = 0; i < midsCount; i++)
        {
            if (rangeString.length != 0)
                [rangeString deleteCharactersInRange:NSMakeRange(0, rangeString.length)];
            
            bool first = true;
            int count = 0;
            for (; count < batchCount && i < midsCount; i++, count++)
            {
                if (first)
                    first = false;
                else
                    [rangeString appendString:@","];
                
                [rangeString appendFormat:@"%d", [[mids objectAtIndex:i] intValue]];
            }
            
            FMResultSet *unreadResult = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT cid, outgoing FROM %@ WHERE mid IN (%@) AND unread IS NOT NULL", _messagesTableName, rangeString]];
            
            int cidIndex = [unreadResult columnIndexForName:@"cid"];
            int outgoingIndex = [unreadResult columnIndexForName:@"outgoing"];
            while ([unreadResult next])
            {
                int64_t cid = [unreadResult longLongIntForColumnIndex:cidIndex];
                if ([unreadResult intForColumnIndex:outgoingIndex] == 0)
                {
                    std::map<int64_t, int>::iterator it = unreadByConversation.find(cid);
                    if (it == unreadByConversation.end())
                        unreadByConversation.insert(std::pair<int64_t, int>(cid, 1));
                    else
                        it->second++;
                }
                else
                {
                    outgoingUnreadConversations.insert(cid);
                }
            }
            
            if (rangeString.length != 0)
            {
                NSString *readQueryFormat = [[NSString alloc] initWithFormat:@"UPDATE %@ SET unread=NULL WHERE mid IN (%@)", _messagesTableName, rangeString];
                [_database executeUpdate:readQueryFormat];
            }
            
            if (i >= midsCount)
                break;
        }
        
        int completeReadCount = 0;
        for (std::map<int64_t, int>::iterator it = unreadByConversation.begin(); it != unreadByConversation.end(); it++)
        {
            completeReadCount += it->second;
            outgoingUnreadConversations.erase(it->first);
            [self actualizeConversation:it->first dispatch:true conversation:nil forceUpdate:false addUnreadCount:(-it->second) addServiceUnreadCount:0 keepDate:false];
        }
        
        for (std::set<int64_t>::iterator it = outgoingUnreadConversations.begin(); it != outgoingUnreadConversations.end(); it++)
        {
            [self actualizeConversation:*it dispatch:true conversation:nil forceUpdate:false addUnreadCount:0 addServiceUnreadCount:0 keepDate:false];
        }
        
        [self setUnreadCount:MAX(0, [self databaseState].unreadCount - completeReadCount)];
    } synchronous:false];
}

- (void)markMessagesAsReadInConversation:(int64_t)conversationId outgoing:(bool)outgoing maxMessageId:(int32_t)maxMessageId
{
    [self dispatchOnDatabaseThread:^
    {
        std::vector<int32_t> markedMessageIds;
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT mid FROM %@ WHERE cid=? AND mid<=? AND outgoing=? AND unread IS NOT NULL", _messagesTableName], @(conversationId), @(maxMessageId), @(outgoing ? 1 : 0)];
        //[self explainQuery:[[NSString alloc] initWithFormat:@"SELECT mid FROM %@ WHERE cid=1 AND mid<=2 AND outgoing=3 AND unread IS NOT NULL", _messagesTableName]];
        
        int midIndex = [result columnIndexForName:@"mid"];
        
        while ([result next])
        {
            markedMessageIds.push_back([result intForColumnIndex:midIndex]);
        }
        
        if (!outgoing)
        {
            TGLog(@"Mark %d incoming messages as read in %lld", (int)markedMessageIds.size(), (long long)conversationId);
        }

        int32_t topIncomingId = 0;
        if (!outgoing)
        {
            //[self explainQuery:[[NSString alloc] initWithFormat:@"SELECT MAX(mid) FROM %@ WHERE cid=1", _messagesTableName]];
            FMResultSet *topResult = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT MAX(mid) FROM %@ WHERE cid=?", _messagesTableName], @(conversationId)];
            if ([topResult next])
            {
                int32_t topMid = [topResult intForColumn:@"MAX(mid)"];
                FMResultSet *topOutgoing = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT outgoing FROM %@ WHERE mid=?", _messagesTableName], @(topMid)];
                if ([topOutgoing intForColumn:@"outgoing"] == 0)
                {
                    topIncomingId = topMid;
                }
            }
        }
        
        if (!markedMessageIds.empty())
        {
            NSMutableString *midsString = [[NSMutableString alloc] init];
            for (int i = 0; i < (int)markedMessageIds.size(); )
            {
                [midsString deleteCharactersInRange:NSMakeRange(0, midsString.length)];
                for (int j = 0; j < 1024 && i < (int)markedMessageIds.size(); j++, i++)
                {
                    if (midsString.length != 0)
                        [midsString appendString:@","];
                    [midsString appendFormat:@"%d", (int)markedMessageIds[i]];
                }
                if (midsString.length != 0)
                {
                    [_database setSoftShouldCacheStatements:false];
                    [_database executeUpdate:[[NSString alloc] initWithFormat:@"UPDATE %@ SET unread=NULL WHERE mid IN (%@)", _messagesTableName, midsString]];
                    [_database setSoftShouldCacheStatements:true];
                }
            }
            
            if (!outgoing)
            {
                int32_t readCount = (int)markedMessageIds.size();
                if (topIncomingId != 0 && maxMessageId >= topIncomingId)
                {
                    TGConversation *conversation = [self loadConversationWithId:conversationId];
                    readCount = conversation.unreadCount;
                }
                
                [self actualizeConversation:conversationId dispatch:true conversation:nil forceUpdate:false addUnreadCount:-readCount addServiceUnreadCount:0 keepDate:false];
                
                [self setUnreadCount:MAX(0, [self databaseState].unreadCount - readCount)];
            }
            else
                [self actualizeConversation:conversationId dispatch:true];
        }
    } synchronous:false];
}

- (void)markMessagesAsReadInConversation:(int64_t)conversationId maxDate:(int32_t)maxDate referenceDate:(int32_t)referenceDate
{
    [self dispatchOnDatabaseThread:^
    {
        NSMutableString *midsString = [[NSMutableString alloc] init];
        bool firstLoop = true;
        int startingDate = maxDate;
        
        int startingDateLimit = 0;
        
        NSMutableArray *markedMids = [[NSMutableArray alloc] init];
        
        std::vector<std::pair<int, int> > midsWithLifetime;
        
        while (true)
        {
            [midsString deleteCharactersInRange:NSMakeRange(0, midsString.length)];
            
            FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE cid=? AND date<=? ORDER BY date DESC LIMIT ?, ?", _messagesTableName], [[NSNumber alloc] initWithLongLong:conversationId], [[NSNumber alloc] initWithInt:startingDate], [[NSNumber alloc] initWithInt:startingDateLimit], [[NSNumber alloc] initWithInt:firstLoop ? 8 : 64]];
            
            int midIndex = [result columnIndexForName:@"mid"];
            int messageIndex = [result columnIndexForName:@"message"];
            int dateIndex = [result columnIndexForName:@"date"];
            int fromIdIndex = [result columnIndexForName:@"from_id"];
            int toIdIndex = [result columnIndexForName:@"to_id"];
            int unreadIndex = [result columnIndexForName:@"unread"];
            int outgoingIndex = [result columnIndexForName:@"outgoing"];
            int messageLifetimeIndex = [result columnIndexForName:@"localMid"];
            int mediaIndex = [result columnIndexForName:@"media"];
            int deliveryStateIndex = [result columnIndexForName:@"dstate"];
            int flagsIndex = [result columnIndexForName:@"flags"];
            int indexSeqIn = [result columnIndexForName:@"seq_in"];
            int indexSeqOut = [result columnIndexForName:@"seq_out"];
            int indexContentProperties = [result columnIndexForName:@"content_properties"];
            
            firstLoop = false;
            
            bool anyMarked = false;
            bool anyFound = false;
            bool outgoingFound = false;
            
            while ([result next])
            {
                TGMessage *message = loadMessageFromQueryResult(result, conversationId, midIndex, messageIndex, mediaIndex, fromIdIndex, toIdIndex, outgoingIndex, unreadIndex, deliveryStateIndex, dateIndex, messageLifetimeIndex, flagsIndex, indexSeqIn, indexSeqOut, indexContentProperties);
                
                anyFound = true;
                
                if (message.outgoing && message.deliveryState == TGMessageDeliveryStateDelivered)
                {
                    outgoingFound = true;
                    
                    if (message.unread)
                    {
                        int mid = message.mid;
                        
                        if (midsString.length != 0)
                            [midsString appendString:@","];
                        [midsString appendFormat:@"%d", mid];
                        
                        anyMarked = true;
                        
                        [markedMids addObject:[[NSNumber alloc] initWithInt:mid]];
                        
                        bool hasSecretMedia = false;
                        if (message.messageLifetime != 0)
                        {
                            for (TGMediaAttachment *attachment in [TGMessage parseMediaAttachments:[result dataForColumnIndex:mediaIndex]])
                            {
                                switch (attachment.type)
                                {
                                    case TGImageMediaAttachmentType:
                                    case TGVideoMediaAttachmentType:
                                    case TGAudioMediaAttachmentType:
                                    {
                                        hasSecretMedia = true;
                                        break;
                                    }
                                    default:
                                        break;
                                }
                                
                                if (hasSecretMedia)
                                    break;
                            }
                            
                            if (hasSecretMedia)
                                hasSecretMedia = message.messageLifetime > 0 && message.messageLifetime <= 60 && message.layer >= 17;
                        }
                        
                        if (message.messageLifetime != 0 && !hasSecretMedia)
                            midsWithLifetime.push_back(std::pair<int, int>(mid, message.messageLifetime));
                    }
                }
                
                int date = [result intForColumnIndex:dateIndex];
                
                if (date < startingDate)
                {
                    startingDate = date;
                    startingDateLimit = 0;
                }
                
                startingDateLimit++;
            }
            
            if (midsString.length != 0)
            {
                //TGLog(@"%@", midsString);
                [_database setSoftShouldCacheStatements:false];
                [_database executeUpdate:[[NSString alloc] initWithFormat:@"UPDATE %@ SET unread=NULL WHERE mid IN (%@)", _messagesTableName, midsString]];
                [_database setSoftShouldCacheStatements:true];
            }
            
            if (!anyFound || (outgoingFound && !anyMarked))
                break;
        }
        
        if (markedMids.count != 0)
            [self _scheduleSelfDestruct:&midsWithLifetime referenceDate:referenceDate];
        
        [self actualizeConversation:conversationId dispatch:true];
    } synchronous:false];
}

/*- (void)preloadConversationStates:(NSArray *)conversationIds
{
    if (conversationIds.count == 0)
        return;
    
    [self dispatchOnDatabaseThread:^
    {
        NSMutableString *idsString = [[NSMutableString alloc] init];
        for (NSNumber *nConversationId in conversationIds)
        {
            if (idsString.length != 0)
                [idsString appendString:@","];
            [idsString appendFormat:@"%" PRId64 "", [nConversationId int64Value]];
        }
        
        std::map<int64_t, NSString *> stateMap;
        
        [_database setSoftShouldCacheStatements:false];
        FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE cid IN (%@)", _conversationsStatesTableName, idsString]];
        [_database setSoftShouldCacheStatements:true];
        while ([result next])
        {
            int64_t cid = [result longLongIntForColumn:@"cid"];
            NSString *messageText = [result stringForColumn:@"message_text"];
            stateMap[cid] = messageText;
        }
        
        TG_SYNCHRONIZED_BEGIN(_conversationInputStates);
        for (NSNumber *nConversationId in conversationIds)
        {
            auto it = stateMap.find([nConversationId int64Value]);
            if (it != stateMap.end())
                _conversationInputStates[[nConversationId int64Value]] = it->second;
            else
                _conversationInputStates[[nConversationId int64Value]] = nil;
        }
        TG_SYNCHRONIZED_END(_conversationInputStates);
    } synchronous:false];
}*/

- (NSString *)loadConversationState:(int64_t)conversationId replyMessageId:(int32_t *)replyMessageId forwardMessageDescs:(__autoreleasing NSArray **)forwardMessageDescs
{
    __block NSDictionary *state = nil;
    bool found = false;
    TG_SYNCHRONIZED_BEGIN(_conversationInputStates);
    auto it = _conversationInputStates.find(conversationId);
    if (it != _conversationInputStates.end())
    {
        found = true;
        state = it->second;
    }
    TG_SYNCHRONIZED_END(_conversationInputStates);
    
    if (found)
    {
        if (replyMessageId)
            *replyMessageId = [state[@"replyMessageId"] intValue];
        
        if (forwardMessageDescs)
            *forwardMessageDescs = state[@"forwardMessageDescs"];
        
        return state[@"text"];
    }
    
    [self dispatchOnDatabaseThread:^
    {
        TGLog(@"(loading conversation state sync)");
        NSData *inputState = [self conversationCustomPropertySync:conversationId name:murMurHash32(@"inputState")];
        PSKeyValueDecoder *decoder = [[PSKeyValueDecoder alloc] initWithData:inputState == nil ? [NSData data] : inputState];
        
        NSMutableDictionary *mutableState = [[NSMutableDictionary alloc] init];
        
        NSString *text = [decoder decodeStringForCKey:"text"];
        mutableState[@"text"] = text == nil ? @"" : text;
        mutableState[@"replyMessageId"] = @([decoder decodeInt32ForCKey:"replyMessageId"]);
        
        NSData *forwardMessageDescsData = [decoder decodeDataCorCKey:"forwardMessageDescs"];
        if (forwardMessageDescsData != nil) {
            NSMutableArray *messageDescs = [[NSMutableArray alloc] init];
            for (int i = 0; i < (int32_t)forwardMessageDescsData.length; i += 8 + 4)
            {
                int64_t peerId = 0;
                int32_t messageId = 0;
                [forwardMessageDescsData getBytes:&peerId range:NSMakeRange(i, 8)];
                [forwardMessageDescsData getBytes:&messageId range:NSMakeRange(i + 8, 4)];
                
                [messageDescs addObject:@{@"peerId": @(peerId), @"messageId": @(messageId)}];
            }
            mutableState[@"forwardMessageDescs"] = messageDescs;
        } else {
            NSData *forwardMessageIdsData = [decoder decodeDataCorCKey:"forwardMessageIds"];
            if (forwardMessageIdsData.length != 0)
            {
                NSMutableArray *messageIds = [[NSMutableArray alloc] init];
                for (int i = 0; i < (int32_t)forwardMessageIdsData.length; i+= 4)
                {
                    int32_t messageId = 0;
                    [forwardMessageIdsData getBytes:&messageId range:NSMakeRange(i, 4)];
                    [messageIds addObject:@(messageId)];
                }
                mutableState[@"forwardMessageIds"] = messageIds;
            }
        }
        
        state = mutableState;
        
        TG_SYNCHRONIZED_BEGIN(_conversationInputStates);
        _conversationInputStates[conversationId] = state;
        TG_SYNCHRONIZED_END(_conversationInputStates);
    } synchronous:true];
    
    if (replyMessageId)
        *replyMessageId = [state[@"replyMessageId"] intValue];
    
    if (forwardMessageDescs)
        *forwardMessageDescs = state[@"forwardMessageDescs"];
    
    return state[@"text"];
}

- (void)storeConversationState:(int64_t)conversationId state:(NSString *)text replyMessageId:(int32_t)replyMessageId forwardMessageDescs:(NSArray *)forwardMessageDescs
{
    bool changed = true;
    
    NSDictionary *state = @{@"text": text == nil ? @"" : text, @"replyMessageId": @(replyMessageId), @"forwardMessageDescs": forwardMessageDescs == nil ? @[] : forwardMessageDescs};
    
    TG_SYNCHRONIZED_BEGIN(_conversationInputStates);
    auto it = _conversationInputStates.find(conversationId);
    if (it != _conversationInputStates.end())
    {
        if (TGObjectCompare(it->second, state))
            changed = false;
    }
    _conversationInputStates[conversationId] = state;
    TG_SYNCHRONIZED_END(_conversationInputStates);
    
    if (changed)
    {
        [self dispatchOnDatabaseThread:^
        {
            PSKeyValueEncoder *encoder = [[PSKeyValueEncoder alloc] init];
            [encoder encodeString:state[@"text"] forCKey:"text"];
            [encoder encodeInt32:[state[@"replyMessageId"] intValue] forCKey:"replyMessageId"];
            
            NSMutableData *forwardMessageIdsData = [[NSMutableData alloc] init];
            for (NSDictionary *desc in forwardMessageDescs)
            {
                int64_t peerId = [desc[@"peerId"] longLongValue];
                int32_t messageId = [desc[@"messageId"] intValue];
                [forwardMessageIdsData appendBytes:&peerId length:8];
                [forwardMessageIdsData appendBytes:&messageId length:4];
            }
            [encoder encodeData:forwardMessageIdsData forCKey:"forwardMessageDescs"];
             
            [self setConversationCustomProperty:conversationId name:murMurHash32(@"inputState") value:[encoder data]];
        } synchronous:false];
    }
}

- (void)readHistoryOptimized:(int64_t)conversationId populateActionQueue:(bool)populateActionQueue completion:(void (^)(bool))completion
{
    [self dispatchOnDatabaseThread:^
    {
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        
        //[self explainQuery:[[NSString alloc] initWithFormat:@"SELECT date, mid, localMid FROM %@ WHERE unread=%lld", _messagesTableName, conversationId]];
        
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT date, mid, flags, localMid%s FROM %@ WHERE unread=?", conversationId <= INT_MIN ? ", media" : "", _messagesTableName], [[NSNumber alloc] initWithLongLong:conversationId]];
        
        std::set<int> unreadMids;
        std::vector<std::pair<int, int> > midWithLifetime;
        
        int midIndex = [result columnIndexForName:@"mid"];
        int lifetimeIndex = [result columnIndexForName:@"localMid"];
        int dateIndex = [result columnIndexForName:@"date"];
        int flagsIndex = [result columnIndexForName:@"flags"];
        
        int lastMid = 0;
        int actionQueueMid = 0;
        int actionQueueDate = 0;
        
        while ([result next])
        {
            int mid = [result intForColumnIndex:midIndex];
            int lifetime = [result intForColumnIndex:lifetimeIndex];
            int date = [result intForColumnIndex:dateIndex];
            int64_t flags = [result longLongIntForColumnIndex:flagsIndex];
            int layer = (int)[TGMessage layerFromFlags:flags];
            
            if (mid < TGMessageLocalMidBaseline)
            {
                if (mid < lastMid || lastMid == 0)
                    lastMid = mid;
                
                if (mid > actionQueueMid || actionQueueMid == 0)
                    actionQueueMid = mid;
            }
            
            if (date > actionQueueDate || actionQueueDate == 0)
                actionQueueDate = date;
            
            unreadMids.insert(mid);
            
            bool hasSecretMedia = false;
            if (lifetime != 0)
            {
                for (TGMediaAttachment *attachment in [TGMessage parseMediaAttachments:[result dataForColumn:@"media"]])
                {
                    switch (attachment.type)
                    {
                        case TGImageMediaAttachmentType:
                        case TGVideoMediaAttachmentType:
                        case TGAudioMediaAttachmentType:
                        {
                            hasSecretMedia = true;
                            break;
                        }
                        default:
                            break;
                    }
                    
                    if (hasSecretMedia)
                        break;
                }
                
                if (hasSecretMedia)
                    hasSecretMedia = lifetime > 0 && lifetime <= 60 && layer >= 17;
            }
            
            if (lifetime != 0 && !hasSecretMedia)
                midWithLifetime.push_back(std::pair<int, int>(mid, lifetime));
        }
        
        NSMutableString *rangeString = [[NSMutableString alloc] init];
        for (std::set<int>::iterator it = unreadMids.begin(); it != unreadMids.end(); it++)
        {
            const int batchCount = 256;
            
            if (rangeString.length != 0)
                [rangeString deleteCharactersInRange:NSMakeRange(0, rangeString.length)];
            
            bool first = true;
            int count = 0;
            for (; count < batchCount && it != unreadMids.end(); it++, count++)
            {
                if (first)
                    first = false;
                else
                    [rangeString appendString:@","];
                
                [rangeString appendFormat:@"%d", *it];
            }
            
            [_database setSoftShouldCacheStatements:false];
            NSString *readQueryFormat = [[NSString alloc] initWithFormat:@"UPDATE %@ SET unread=NULL WHERE mid IN (%@)", _messagesTableName, rangeString];
            [_database executeUpdate:readQueryFormat];
            [_database setSoftShouldCacheStatements:true];
            
            if (it == unreadMids.end())
                break;
        }
        
        if (lastMid != 0)
            [self storeMinAutosaveMessageIdForConversation:conversationId mid:lastMid];
        
        bool hasUnread = !unreadMids.empty();
        if (!hasUnread)
        {
            TGConversation *conversation = [self loadConversationWithId:conversationId];
            if (conversation.unreadCount != 0 || conversation.serviceUnreadCount != 0)
                hasUnread = true;
        }
        
        if (!hasUnread)
        {
            TGLog(@"No messages to read in %f ms", (CFAbsoluteTimeGetCurrent() - startTime) * 1000.0);
            return;
        }
        else
        {
#ifdef DEBUG
            TGLog(@"Read %d messages in %f ms", unreadMids.size(), (CFAbsoluteTimeGetCurrent() - startTime) * 1000.0);
#endif
        }
        
        int previousConversationUnreadCount = 0;
        
        TGConversation *conversationData = [self loadConversationWithId:conversationId];
        if (conversationData != nil && ((!conversationData.outgoing && conversationData.unread) || conversationData.unreadCount != 0 || conversationData.serviceUnreadCount != 0))
        {
            int flags = 0;
            if (conversationData.outgoing)
                flags |= 1;
            if (conversationData.isChat)
                flags |= 2;
            if (conversationData.leftChat)
                flags |= 4;
            if (conversationData.kickedFromChat)
                flags |= 8;
            if (conversationData.unread && conversationData.outgoing)
                flags |= 16;
            if (conversationData.deliveryError)
                flags |= 32;
            
            previousConversationUnreadCount = conversationData.unreadCount;
            
            int unreadCount = [self databaseState].unreadCount - (conversationData.unreadCount);
            if (unreadCount < 0)
                TGLog(@"***** Warning: wrong unread_count");
            [self setUnreadCount:MAX(unreadCount, 0)];
            
            [_database executeUpdate:[[NSString alloc] initWithFormat:@"UPDATE %@ SET unread_count=0, service_unread=0, flags=? WHERE cid=?", [self _listTableNameForConversationId:conversationId]], [[NSNumber alloc] initWithInt:flags], @(conversationId)];
            
            conversationData.unreadCount = 0;
            conversationData.serviceUnreadCount = 0;
            conversationData.unread = false;
            
            TG_SYNCHRONIZED_BEGIN(_cachedConversations);
            _cachedConversations[conversationId] = conversationData;
            TG_SYNCHRONIZED_END(_cachedConversations);
            
            TG_SYNCHRONIZED_BEGIN(_unreadCountByConversation);
            _unreadCountByConversation[conversationId] = 0;
            TG_SYNCHRONIZED_END(_unreadCountByConversation);
            
            [ActionStageInstance() dispatchResource:_liveMessagesDispatchPath resource:[[SGraphObjectNode alloc] initWithObject:[NSArray arrayWithObject:conversationData]]];
        }
        
        bool storedActions = false;
        
        if (populateActionQueue && (previousConversationUnreadCount != 0 || hasUnread))
        {
            if (actionQueueMid == 0)
            {
                FMResultSet *anyResult = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT mid FROM %@ WHERE cid=? ORDER BY date DESC LIMIT 1", _messagesTableName], @(conversationId)];
                if ([anyResult next])
                {
                    int mid = [anyResult intForColumn:@"mid"];
                    if (mid < TGMessageLocalMidBaseline)
                        actionQueueMid = mid;
                }
            }
            
            if (actionQueueMid != 0)
            {
                TGDatabaseAction action = { .type = TGDatabaseActionReadConversation, .subject = conversationId, .arg0 = (conversationId <= INT_MIN ? actionQueueDate : actionQueueMid), .arg1 = previousConversationUnreadCount};
                [self storeQueuedActions:[NSArray arrayWithObject:[[NSValue alloc] initWithBytes:&action objCType:@encode(TGDatabaseAction)]]];
                
                storedActions = true;
            }
        }
        
        if (completion)
            completion(storedActions);
        
        if (conversationId <= INT_MIN && !midWithLifetime.empty())
        {
            int currentDate = (int)(CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970 + _timeDifferenceFromUTC);
            NSString *selfDestructInsertQuery = [[NSString alloc] initWithFormat:@"INSERT OR IGNORE INTO %@ (mid, date) VALUES (?, ?)", _selfDestructTableName];
            
            [_database beginTransaction];
            for (auto it = midWithLifetime.begin(); it != midWithLifetime.end(); it++)
            {
                NSNumber *nDate = [[NSNumber alloc] initWithInt:currentDate + it->second];
                [_database executeUpdate:selfDestructInsertQuery, [[NSNumber alloc] initWithInt:it->first], nDate];
            }
            [_database commit];
            
            [self processAndScheduleSelfDestruct];
        }
    } synchronous:false];
}

- (void)readHistory:(int64_t)conversationId includeOutgoing:(bool)includeOutgoing populateActionQueue:(bool)populateActionQueue minRemoteMid:(int)minRemoteMid completion:(void (^)(bool hasItemsOnActionQueue))completion
{
    if (!includeOutgoing)
    {
        [self readHistoryOptimized:conversationId populateActionQueue:populateActionQueue completion:completion];
        return;
    }
    
    [self dispatchOnDatabaseThread:^
    {
        const int firstBatchCount = 32;
        const int batchCount = 256;
        
        NSNumber *nConversationId = [[NSNumber alloc] initWithLongLong:conversationId];
        
        NSString *firstQueryFormat = [[NSString alloc] initWithFormat:@"SELECT mid, unread, date, localMid FROM %@ WHERE cid=? %@ ORDER BY mid DESC LIMIT %d", _messagesTableName, !includeOutgoing ? @"AND outgoing=0" : [[NSString alloc] initWithFormat:@"AND mid < %d", TGMessageLocalMidBaseline], firstBatchCount];
        
        NSString *queryFormat = [[NSString alloc] initWithFormat:@"SELECT mid, unread, date, localMid FROM %@ WHERE cid=? AND mid < ? %@ ORDER BY mid DESC LIMIT %d", _messagesTableName, !includeOutgoing ? @"AND outgoing=0" : [[NSString alloc] initWithFormat:@"AND mid < %d", TGMessageLocalMidBaseline], batchCount];
        
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        
        std::set<int> unreadMids;
        int actionQueueMid = 0;
        int actionQueueDate = 0;
        
        int lastMid = 0;
        int lastProcessedMid = INT_MAX;
        
        int passCount = 0;
        
        std::vector<std::pair<int, int> > midWithLifetime;
        
        while (true)
        {
            passCount++;
            
            int recordCount = 0;
            
            FMResultSet *result = nil;
            if (lastProcessedMid == INT_MAX)
                result = [_database executeQuery:firstQueryFormat, nConversationId];
            else
                result = [_database executeQuery:queryFormat, nConversationId, [[NSNumber alloc] initWithInt:lastProcessedMid]];
            
            int midIndex = [result columnIndexForName:@"mid"];
            int unreadIndex = [result columnIndexForName:@"unread"];
            int dateIndex = [result columnIndexForName:@"date"];
            int messageLifetimeIndex = [result columnIndexForName:@"localMid"];
            
            bool loadedSomething = false;
            
            while ([result next])
            {
                loadedSomething = true;
                
                int mid = [result intForColumnIndex:midIndex];
                int messageLifetime = [result intForColumnIndex:messageLifetimeIndex];
                
                if (mid < lastProcessedMid)
                    lastProcessedMid = mid;
                
                if ([result intForColumnIndex:unreadIndex] != 0)
                {
                    recordCount++;

                    if (lastMid == 0)
                    {
                        actionQueueMid = mid;
                        actionQueueDate = [result intForColumnIndex:dateIndex];
                    }
                    
                    if (mid < lastMid || lastMid == 0)
                        lastMid = mid;
                    
                    unreadMids.insert(mid);
                    if (messageLifetime != 0)
                        midWithLifetime.push_back(std::pair<int, int>(mid, messageLifetime));
                }
            }
            
            if (!loadedSomething)
                break;
            
            if (recordCount > 0 || minRemoteMid == 0 || lastProcessedMid <= minRemoteMid)
            {
                if (recordCount < batchCount && (minRemoteMid == 0 || lastProcessedMid <= minRemoteMid))
                    break;
            }
        }
        
        TGLog(@"Read time: %f ms (%d loops)", (CFAbsoluteTimeGetCurrent() - startTime) * 1000.0, passCount);
        
        if (lastMid != 0)
            [self storeMinAutosaveMessageIdForConversation:conversationId mid:lastMid];
        
        bool hasUnread = !unreadMids.empty();
        
        int localUnreadCount = 0;
        
        NSMutableString *rangeString = [[NSMutableString alloc] init];
        for (std::set<int>::iterator it = unreadMids.begin(); it != unreadMids.end(); it++)
        {
            if (rangeString.length != 0)
                [rangeString deleteCharactersInRange:NSMakeRange(0, rangeString.length)];
            
            bool first = true;
            int count = 0;
            for (; count < batchCount && it != unreadMids.end(); it++, count++)
            {
                if (first)
                    first = false;
                else
                    [rangeString appendString:@","];
                
                [rangeString appendFormat:@"%d", *it];
                
                if (*it >= TGMessageLocalMidBaseline)
                    localUnreadCount++;
            }
            
            [_database setSoftShouldCacheStatements:false];
            NSString *readQueryFormat = [[NSString alloc] initWithFormat:@"UPDATE %@ SET unread=NULL WHERE mid IN (%@)", _messagesTableName, rangeString];
            [_database executeUpdate:readQueryFormat];
            [_database setSoftShouldCacheStatements:true];
            
            if (it == unreadMids.end())
                break;
        }
        
        if (actionQueueMid == 0)
        {
            FMResultSet *lastMidResult = [_database executeQuery:[NSString stringWithFormat:@"SELECT mid FROM %@ WHERE cid=? AND mid<%d ORDER BY mid DESC LIMIT 1", _messagesTableName, TGMessageLocalMidBaseline], nConversationId];
            if ([lastMidResult next])
            {
                actionQueueMid = [lastMidResult intForColumn:@"mid"];
            }
        }
        
        if (actionQueueMid == 0)
        {
            TGLog(@"No messages to read");
            return;
        }
        
        int previousConversationUnreadCount = 0;
        
        TGConversation *conversationData = [self loadConversationWithId:conversationId];
        if (conversationData != nil && ((!conversationData.outgoing && conversationData.unread) || conversationData.unreadCount != 0 || conversationData.serviceUnreadCount != 0))
        {
            int flags = 0;
            if (conversationData.outgoing)
                flags |= 1;
            if (conversationData.isChat)
                flags |= 2;
            if (conversationData.leftChat)
                flags |= 4;
            if (conversationData.kickedFromChat)
                flags |= 8;
            if (conversationData.unread && conversationData.outgoing)
                flags |= 16;
            if (conversationData.deliveryError)
                flags |= 32;
            
            previousConversationUnreadCount = conversationData.unreadCount;
            
            int unreadCount = [self databaseState].unreadCount - (conversationData.unreadCount);
            if (unreadCount < 0)
                TGLog(@"***** Warning: wrong unread_count");
            [self setUnreadCount:MAX(unreadCount, 0)];
            
            [_database executeUpdate:[[NSString alloc] initWithFormat:@"UPDATE %@ SET unread_count=0, service_unread=0, flags=? WHERE cid=?", [self _listTableNameForConversationId:conversationId]], [[NSNumber alloc] initWithInt:flags], nConversationId];
            
            conversationData.unreadCount = 0;
            conversationData.serviceUnreadCount = 0;
            conversationData.unread = false;
            
            TG_SYNCHRONIZED_BEGIN(_cachedConversations);
            _cachedConversations[conversationId] = conversationData;
            TG_SYNCHRONIZED_END(_cachedConversations);
            
            TG_SYNCHRONIZED_BEGIN(_unreadCountByConversation);
            _unreadCountByConversation[conversationId] = 0;
            TG_SYNCHRONIZED_END(_unreadCountByConversation);
            
            [ActionStageInstance() dispatchResource:_liveMessagesDispatchPath resource:[[SGraphObjectNode alloc] initWithObject:[NSArray arrayWithObject:conversationData]]];
        }
        
        bool storedActions = false;
        
        if (populateActionQueue && (previousConversationUnreadCount != 0 || hasUnread))
        {
            if (actionQueueMid != 0)
            {
#if TARGET_IPHONE_SIMULATOR
                TGLog(@"read date %d", actionQueueDate);
#endif
                TGDatabaseAction action = { .type = TGDatabaseActionReadConversation, .subject = conversationId, .arg0 = (conversationId <= INT_MIN ? actionQueueDate : actionQueueMid), .arg1 = previousConversationUnreadCount};
                [self storeQueuedActions:[NSArray arrayWithObject:[[NSValue alloc] initWithBytes:&action objCType:@encode(TGDatabaseAction)]]];
                
                storedActions = true;
            }
        }
        
        if (minRemoteMid != 0)
        {
            [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversationReadApplied/(%lld)", conversationId] resource:[[NSNumber alloc] initWithLongLong:minRemoteMid]];
        }
        
        if (completion)
            completion(storedActions);
        
        if (conversationId <= INT_MIN && !midWithLifetime.empty())
        {
            int currentDate = (int)(CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970 + _timeDifferenceFromUTC);
            NSString *selfDestructInsertQuery = [[NSString alloc] initWithFormat:@"INSERT OR IGNORE INTO %@ (mid, date) VALUES (?, ?)", _selfDestructTableName];
            
            [_database beginTransaction];
            for (auto it = midWithLifetime.begin(); it != midWithLifetime.end(); it++)
            {
                NSNumber *nDate = [[NSNumber alloc] initWithInt:currentDate + it->second];
                [_database executeUpdate:selfDestructInsertQuery, [[NSNumber alloc] initWithInt:it->first], nDate];
            }
            [_database commit];
            
            [self processAndScheduleSelfDestruct];
        }
    } synchronous:false];
}

inline TGMessage *loadMessageMediaFromQueryResult(FMResultSet *result, int const &dateIndex, int const &fromIdIndex, int const &midIndex, int const &mediaIndex)
{
    int mid = [result intForColumnIndex:midIndex];
    int date = [result intForColumnIndex:dateIndex];
    int fromId = [result intForColumnIndex:fromIdIndex];
    
    TGMessage *message = [[TGMessage alloc] init];
    
    NSData *mediaData = [result dataForColumnIndex:mediaIndex];
    NSArray *mediaAttachments = [TGMessage parseMediaAttachments:mediaData];
    message.mid = mid;
    message.fromUid = fromId;
    message.date = date;
    message.mediaAttachments = mediaAttachments;
    
    return message;
}

- (void)loadMediaPositionInConversation:(int64_t)conversationId messageId:(int)messageId completion:(void (^)(int position, int count))completion
{
    [self dispatchOnDatabaseThread:^
    {
        FMResultSet *dateResult = [_database executeQuery:[NSString stringWithFormat:@"SELECT date FROM %@ WHERE cid=? AND mid=?", _conversationMediaTableName], [[NSNumber alloc] initWithLongLong:conversationId], [[NSNumber alloc] initWithInt:messageId]];
        if ([dateResult next])
        {
            int maxDate = [dateResult intForColumn:@"date"];
            
            int positionInConversation = 0;
            int totalCount = 0;
            
            FMResultSet *uniqueDateResult = [_database executeQuery:[NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE cid=? AND date<?", _conversationMediaTableName], [[NSNumber alloc] initWithLongLong:conversationId], [[NSNumber alloc] initWithInt:maxDate]];
            
            if ([uniqueDateResult next])
            {
                positionInConversation = [uniqueDateResult intForColumn:@"COUNT(*)"];
                
                FMResultSet *equalDateResult = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT mid FROM %@ WHERE cid=? AND date=?", _conversationMediaTableName], [[NSNumber alloc] initWithLongLong:conversationId], [[NSNumber alloc] initWithInt:maxDate]];
                
                while ([equalDateResult next])
                {
                    int mid = [equalDateResult intForColumn:@"mid"];
                    if (mid != messageId)
                    {
                        if ((mid >= 800000000) != (messageId >= 800000000))
                        {
                            if (mid < 800000000)
                                positionInConversation++;
                        }
                        else
                        {
                            if (mid < messageId)
                                positionInConversation++;
                        }
                    }
                }
                
                FMResultSet *countResult = [_database executeQuery:[NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE cid=?", _conversationMediaTableName], [[NSNumber alloc] initWithLongLong:conversationId]];
                if ([countResult next])
                    totalCount = [countResult intForColumn:@"COUNT(*)"];
                
            }
            
            if (completion)
                completion(positionInConversation, totalCount);
        }
        else
        {
            if (completion)
                completion(0, 0);
        }
    } synchronous:false];
}

- (NSArray *)loadMediaInConversation:(int64_t)conversationId atMessageId:(int)atMessageId limitAfter:(int)limitAfter count:(int *)count important:(bool)important
{
    NSMutableArray *mediaArray = [[NSMutableArray alloc] init];
    
    [self dispatchOnDatabaseThread:^
    {
        if (conversationId == 0)
        {
            if (count != NULL)
                *count = 0;
            return;
        }
        
        if (TGPeerIdIsChannel(conversationId)) {
            __block NSArray *result = nil;
            [self cachedMediaForPeerId:conversationId itemType:TGSharedMediaCacheItemTypePhotoVideo limit:0 important:important completion:^(NSArray *media, __unused bool indexDownloaded) {
                result = media;
            } buildIndex:false isCancelled:nil];
            [mediaArray addObjectsFromArray:result];
            if (count) {
                *count = (int)result.count;
            }
        } else {
            FMResultSet *dateResult = [_database executeQuery:[NSString stringWithFormat:@"SELECT date FROM %@ WHERE cid=? AND mid=? LIMIT 1", _conversationMediaTableName], [[NSNumber alloc] initWithLongLong:conversationId], [[NSNumber alloc] initWithInt:atMessageId]];
            if ([dateResult next])
            {
                int maxDate = [dateResult intForColumn:@"date"];
                FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT date, from_id, mid, media FROM %@ WHERE cid=? AND date>=?", _conversationMediaTableName], [[NSNumber alloc] initWithLongLong:conversationId], [[NSNumber alloc] initWithInt:maxDate]];
                
                int dateIndex = [result columnIndexForName:@"date"];
                int midIndex = [result columnIndexForName:@"mid"];
                int mediaIndex = [result columnIndexForName:@"media"];
                int fromIdIndex = [result columnIndexForName:@"from_id"];
                
                while ([result next])
                {
                    TGMessage *message = loadMessageMediaFromQueryResult(result, dateIndex, fromIdIndex, midIndex, mediaIndex);
                    TGMessage *actualMessage = [self loadMessageWithMid:message.mid peerId:conversationId];
                    if (conversationId <= INT_MIN && (actualMessage.messageLifetime > 0 && actualMessage.messageLifetime <= 60 && actualMessage.layer >= 17))
                        continue;
                    //TGLog(@"mid %d", message.mid);
                    [mediaArray addObject:message];
                }
                
                result = [_database executeQuery:[NSString stringWithFormat:@"SELECT date, mid, from_id, media FROM %@ WHERE cid=? AND date<? ORDER BY date DESC LIMIT ?", _conversationMediaTableName], [[NSNumber alloc] initWithLongLong:conversationId], [[NSNumber alloc] initWithInt:maxDate], [[NSNumber alloc] initWithInt:limitAfter]];
                
                dateIndex = [result columnIndexForName:@"date"];
                midIndex = [result columnIndexForName:@"mid"];
                mediaIndex = [result columnIndexForName:@"media"];
                fromIdIndex = [result columnIndexForName:@"from_id"];
                
                while ([result next])
                {
                    TGMessage *message = loadMessageMediaFromQueryResult(result, dateIndex, fromIdIndex, midIndex, mediaIndex);
                    TGMessage *actualMessage = [self loadMessageWithMid:message.mid peerId:conversationId];
                    if (conversationId <= INT_MIN && (actualMessage.messageLifetime > 0 && actualMessage.messageLifetime <= 60 && actualMessage.layer >= 17))
                        continue;
                    //TGLog(@"add mid %d", message.mid);
                    [mediaArray addObject:message];
                }
                
                if (count != NULL)
                {
                    if (conversationId <= INT_MIN)
                    {
                        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT mid FROM %@ WHERE cid=?", _conversationMediaTableName], @(conversationId)];
                        int localCount = 0;
                        while ([result next])
                        {
                            TGMessage *message = [self loadMessageWithMid:[result intForColumn:@"mid"] peerId:conversationId];
                            if (message.messageLifetime == 0 || message.messageLifetime > 60 || message.layer < 17)
                                localCount++;
                        }
                        
                        *count = localCount;
                    }
                    else
                    {
                        FMResultSet *countResult = [_database executeQuery:[NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE cid=?", _conversationMediaTableName], [[NSNumber alloc] initWithLongLong:conversationId]];
                        if ([countResult next])
                            *count = [countResult intForColumn:@"COUNT(*)"];
                    }
                }
            }
        }
    } synchronous:true];
    
    return mediaArray;
}

- (NSArray *)loadMediaInConversation:(int64_t)conversationId maxMid:(int)maxMid maxLocalMid:(int)maxLocalMid maxDate:(int)maxDate limit:(int)limit count:(int *)count important:(bool)important
{
    NSMutableArray *mediaArray = [[NSMutableArray alloc] init];
    
    [self dispatchOnDatabaseThread:^
    {
        if (TGPeerIdIsChannel(conversationId)) {
            __block NSArray *result = nil;
            [self cachedMediaForPeerId:conversationId itemType:TGSharedMediaCacheItemTypePhotoVideo limit:limit important:important completion:^(NSArray *media, __unused bool indexDownloaded) {
                result = media;
            } buildIndex:false isCancelled:nil];
            [mediaArray addObjectsFromArray:result];
            if (count) {
                *count = (int)result.count;
            }
        } else {
            FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT date, mid, from_id, media FROM %@ WHERE cid=? AND date<=? ORDER BY date DESC LIMIT ?", _conversationMediaTableName], [[NSNumber alloc] initWithLongLong:conversationId], [[NSNumber alloc] initWithInt:maxDate], [[NSNumber alloc] initWithInt:limit]];
            
            int dateIndex = [result columnIndexForName:@"date"];
            int midIndex = [result columnIndexForName:@"mid"];
            int mediaIndex = [result columnIndexForName:@"media"];
            int fromIdIndex = [result columnIndexForName:@"from_id"];
            
            int extraLimit = 0;
            int extraOffset = 0;
            
            while ([result next])
            {
                extraOffset++;
                
                int mid = [result intForColumnIndex:midIndex];
                if (mid >= 800000000 && mid >= maxLocalMid)
                {
                    extraLimit++;
                    continue;
                }
                else if (mid >= maxMid)
                {
                    extraLimit++;
                    continue;
                }
                else if (conversationId <= INT_MIN)
                {
                    TGMessage *actualMessage = [self loadMessageWithMid:mid peerId:conversationId];
                    if (actualMessage.messageLifetime > 0 && actualMessage.messageLifetime <= 60 && actualMessage.layer >= 17)
                    {
                        extraLimit++;
                        continue;
                    }
                }
                
                TGMessage *message = loadMessageMediaFromQueryResult(result, dateIndex, fromIdIndex, midIndex, mediaIndex);
                
                [mediaArray addObject:message];
            }
            [result close];
            
            if (extraLimit != 0)
            {
                result = [_database executeQuery:[NSString stringWithFormat:@"SELECT date, mid, from_id, media FROM %@ WHERE cid=? AND date<=? ORDER BY date DESC LIMIT ?, ?", _conversationMediaTableName], [[NSNumber alloc] initWithLongLong:conversationId], [[NSNumber alloc] initWithInt:maxDate], [[NSNumber alloc] initWithInt:extraOffset], [[NSNumber alloc] initWithInt:extraLimit]];
                
                while ([result next])
                {
                    int mid = [result intForColumnIndex:midIndex];
                    if (mid >= 800000000)
                    {
                        if (mid >= maxLocalMid)
                        {
                            continue;
                        }
                    }
                    else if (mid >= maxMid)
                    {
                        continue;
                    }
                    else if (conversationId <= INT_MIN)
                    {
                        TGMessage *actualMessage = [self loadMessageWithMid:mid peerId:conversationId];
                        if (actualMessage.messageLifetime > 0 && actualMessage.messageLifetime <= 60 && actualMessage.layer >= 17)
                            continue;
                    }
                    
                    TGMessage *message = loadMessageMediaFromQueryResult(result, dateIndex, fromIdIndex, midIndex, mediaIndex);
                    
                    [mediaArray addObject:message];
                }
            }
            
            if (count != NULL)
            {
                if (conversationId <= INT_MIN)
                {
                    FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT mid FROM %@ WHERE cid=?", _conversationMediaTableName], @(conversationId)];
                    int localCount = 0;
                    while ([result next])
                    {
                        TGMessage *message = [self loadMessageWithMid:[result intForColumn:@"mid"] peerId:conversationId];
                        if ((message.messageLifetime == 0 || message.messageLifetime > 60) || message.layer < 17)
                            localCount++;
                    }
                    
                    *count = localCount;
                }
                else
                {
                    FMResultSet *countResult = [_database executeQuery:[NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE cid=?", _conversationMediaTableName], [[NSNumber alloc] initWithLongLong:conversationId]];
                    if ([countResult next])
                        *count = [countResult intForColumn:@"COUNT(*)"];
                }
            }
        }
    } synchronous:true];
    
    return mediaArray;
}

- (void)addMediaToConversation:(int64_t)conversationId messages:(NSArray *)messages completion:(void (^)(int count))completion
{
    [self dispatchOnDatabaseThread:^
    {
        NSString *queryFormat = [[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO %@ (mid, cid, date, from_id, type, media) VALUES (?, ?, ?, ?, ?, ?)", _conversationMediaTableName];
        
        NSNumber *nConversationId = [[NSNumber alloc] initWithLongLong:conversationId];
        
        [_database beginTransaction];
        
        for (TGMessage *message in messages)
        {
            NSData *mediaData = nil;
            int mediaType = 0;
            
            int64_t videoId = 0;
            
            if (message.mediaAttachments != nil && message.mediaAttachments.count != 0)
            {
                for (TGMediaAttachment *attachment in message.mediaAttachments)
                {
                    if (attachment.type == TGImageMediaAttachmentType)
                    {
                        mediaData = [TGMessage serializeAttachment:attachment];
                        mediaType = 0;
                    }
                    else if (attachment.type == TGVideoMediaAttachmentType)
                    {
                        mediaData = [TGMessage serializeAttachment:attachment];
                        mediaType = 1;
                        videoId = ((TGVideoMediaAttachment *)attachment).videoId;
                    }
                }
            }
            
            if (mediaData != nil && mediaData.length != 0)
            {
                [_database executeUpdate:queryFormat, [[NSNumber alloc] initWithInt:message.mid], nConversationId, [[NSNumber alloc] initWithInt:(int)message.date], [[NSNumber alloc] initWithInt:(int)message.fromUid], [[NSNumber alloc] initWithInt:mediaType], mediaData];
                
                if (mediaType == 1)
                    addVideoMid(self, 0, message.mid, videoId, false);
            }
        }
        
        [_database commit];
        
        if (completion)
        {
            int count = 0;
            FMResultSet *countResult = [_database executeQuery:[NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE cid=?", _conversationMediaTableName], nConversationId];
            if ([countResult next])
                count = [countResult intForColumn:@"COUNT(*)"];
            
            completion(count);
        }
    } synchronous:false];
}

- (void)loadLastRemoteMediaMessageIdInConversation:(int64_t)conversationId completion:(void (^)(int32_t messageId))completion
{
    [self dispatchOnDatabaseThread:^
    {
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT MIN(mid) FROM %@ WHERE cid=?", _conversationMediaTableName], @(conversationId)];
        if ([result next])
        {
            int32_t messageId = [result intForColumn:@"MIN(mid)"];
            if (messageId < TGMessageLocalMidBaseline)
            {
                if (completion)
                    completion(messageId);
            }
            else
            {
                if (completion)
                    completion(0);
            }
        }
        else
        {
            if (completion)
                completion(0);
        }
    } synchronous:false];
}

- (int32_t)mediaCountInConversation:(int64_t)conversationId
{
    __block int32_t mediaCount = 0;
    
    [self dispatchOnDatabaseThread:^
    {
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT COUNT(*) FROM %@ WHERE cid=?", _conversationMediaTableName], @(conversationId)];
        if ([result next])
            mediaCount = [result intForColumn:@"COUNT(*)"];
    } synchronous:true];
    
    return mediaCount;
}

- (void)storeQueuedActions:(NSArray *)actions
{
    [self dispatchOnDatabaseThread:^
    {
        [_database beginTransaction];
        for (NSValue *value in actions)
        {
            TGDatabaseAction action;
            [value getValue:&action];
            //TGLog(@"Enqueue action: %d, %lld, %d, %d", action.type, action.subject, action.arg0, action.arg1);
            [_database executeUpdate:[NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (action_type, action_subject, arg0, arg1) VALUES (?, ?, ?, ?)", _actionQueueTableName], [[NSNumber alloc] initWithInt:action.type], [[NSNumber alloc] initWithLongLong:action.subject], [[NSNumber alloc] initWithInt:action.arg0], [[NSNumber alloc] initWithInt:action.arg1]];
        }
        [_database commit];
    } synchronous:false];
}

- (void)confirmQueuedActions:(NSArray *)actions requireFullMatch:(bool)requireFullMatch
{
    [self dispatchOnDatabaseThread:^
    {
        NSString *queryFormat = nil;
        if (requireFullMatch)
            queryFormat = [NSString stringWithFormat:@"DELETE FROM %@ WHERE action_type=? AND action_subject=? AND arg0=?", _actionQueueTableName];
        else
            queryFormat = [NSString stringWithFormat:@"DELETE FROM %@ WHERE action_type=? AND action_subject=?", _actionQueueTableName];
        
        for (NSValue *value in actions)
        {
            TGDatabaseAction action;
            [value getValue:&action];
            
            if (requireFullMatch)
                [_database executeUpdate:queryFormat, [[NSNumber alloc] initWithInt:action.type], [[NSNumber alloc] initWithLongLong:action.subject], [[NSNumber alloc] initWithInt:action.arg0]];
            else
                [_database executeUpdate:queryFormat, [[NSNumber alloc] initWithInt:action.type], [[NSNumber alloc] initWithLongLong:action.subject]];
        }
    } synchronous:false];
}

- (void)loadQueuedActions:(NSArray *)actionTypes completion:(void (^)(NSMutableDictionary *actionSetsByType))completion
{
    [self dispatchOnDatabaseThread:^
    {
        NSMutableDictionary *actionSetsByType = [[NSMutableDictionary alloc] init];
        
        for (NSNumber *nActionType in actionTypes)
        {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            
            FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE action_type=%d", _actionQueueTableName, [nActionType intValue]]];
            int actionSubjectIndex = [result columnIndexForName:@"action_subject"];
            int arg0Index = [result columnIndexForName:@"arg0"];
            int arg1Index = [result columnIndexForName:@"arg1"];
            
            while ([result next])
            {
                TGDatabaseAction action;
                action.type = (TGDatabaseActionType)[nActionType intValue];
                action.subject = [result longLongIntForColumnIndex:actionSubjectIndex];
                action.arg0 = [result intForColumnIndex:arg0Index];
                action.arg1 = [result intForColumnIndex:arg1Index];
                NSValue *value = [[NSValue alloc] initWithBytes:&action objCType:@encode(TGDatabaseAction)];
                if (value != nil)
                    [array addObject:value];
            }
            
            if (array.count != 0)
                [actionSetsByType setObject:array forKey:nActionType];
        }
        
        if (completion)
            completion(actionSetsByType);
    } synchronous:false];
}

- (void)storeFutureActions:(NSArray *)actions
{
    [self dispatchOnDatabaseThread:^
    {
        NSString *queryFormat = [[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO %@ (id, type, data, random_id) VALUES (?, ?, ?, ?)", _futureActionsTableName];
        
        [_database beginTransaction];
        for (TGFutureAction *action in actions)
        {
            [_database executeUpdate:queryFormat, [[NSNumber alloc] initWithLongLong:action.uniqueId], [[NSNumber alloc] initWithInt:action.type], [action serialize], [[NSNumber alloc] initWithInt:action.randomId]];
        }
        [_database commit];
    } synchronous:false];
}

static inline TGFutureAction *loadFutureActionFromQueryResult(FMResultSet *result)
{
    int idIndex = [result columnIndexForName:@"id"];
    int typeIndex = [result columnIndexForName:@"type"];
    int dataIndex = [result columnIndexForName:@"data"];
    int randomIdIndex = [result columnIndexForName:@"random_id"];
    
    NSData *data = [result dataForColumnIndex:dataIndex];
    if (data == nil)
        return nil;
    
    int type = [result intForColumnIndex:typeIndex];
    
    TGFutureAction *deserializer = futureActionDeserializer(type);
    
    if (deserializer == nil)
    {
        TGLog(@"Warning: unknown future action type %d", type);
        return nil;
    }
    
    TGFutureAction *action = [deserializer deserialize:data];
    action.uniqueId = [result longLongIntForColumnIndex:idIndex];
    action.randomId = [result intForColumnIndex:randomIdIndex];
    
    return action;
}

- (void)removeFutureAction:(int64_t)uniqueId type:(int)type randomId:(int)randomId
{
    [self dispatchOnDatabaseThread:^
    {
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE id=? AND type=? AND random_id=?", _futureActionsTableName], [[NSNumber alloc] initWithLongLong:uniqueId], [[NSNumber alloc] initWithInt:type], [[NSNumber alloc] initWithInt:randomId]];
        if ([result next])
        {
            TGFutureAction *action = loadFutureActionFromQueryResult(result);
            [action prepareForDeletion];
            action = nil;
            
            NSString *queryFormat = [[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE id=? AND type=? AND random_id=?", _futureActionsTableName];
            [_database executeUpdate:queryFormat, [[NSNumber alloc] initWithLongLong:uniqueId], [[NSNumber alloc] initWithInt:type], [[NSNumber alloc] initWithInt:randomId]];
        }
    } synchronous:false];
}

- (void)removeFutureActionsWithType:(int)type uniqueIds:(NSArray *)uniqueIds
{
    [self dispatchOnDatabaseThread:^
    {
        NSString *queryFormat = [[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE id=? AND type=?", _futureActionsTableName];
        NSNumber *nType = [[NSNumber alloc] initWithInt:type];
        [_database beginTransaction];
        for (NSNumber *nUniqueId in uniqueIds)
        {
            [_database executeUpdate:queryFormat, nUniqueId, nType];
        }
        [_database commit];
    } synchronous:false];
}

- (NSArray *)loadOneFutureAction
{
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    
    [self dispatchOnDatabaseThread:^
    {   
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT id, type, data, random_id FROM %@ WHERE type NOT IN (%d, %d, %d, %d) ORDER BY sort_key ASC LIMIT 1", _futureActionsTableName, TGUploadAvatarFutureActionType, TGDeleteProfilePhotoFutureActionType, TGRemoveContactFutureActionType, TGExportContactFutureActionType]];
        
        if ([result next])
        {
            TGFutureAction *action = loadFutureActionFromQueryResult(result);
            
            if (action != nil)
                [actions addObject:action];
        }
    } synchronous:true];
    
    return actions;
}

- (NSArray *)loadFutureActionsWithType:(int)type
{
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    
    [self dispatchOnDatabaseThread:^
    {
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT id, type, data, random_id FROM %@ WHERE type=? ORDER BY sort_key ASC", _futureActionsTableName], [[NSNumber alloc] initWithInt:type]];
        
        while ([result next])
        {
            TGFutureAction *action = loadFutureActionFromQueryResult(result);
            
            if (action != nil)
                [actions addObject:action];
        }
    } synchronous:true];
    
    return actions;
}

- (TGFutureAction *)loadFutureAction:(int64_t)uniqueId type:(int)type
{
    __block TGFutureAction *action = nil;
    
    [self dispatchOnDatabaseThread:^
    {
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT id, type, data, random_id FROM %@ WHERE id=? AND type=?", _futureActionsTableName], [[NSNumber alloc] initWithLongLong:uniqueId], [[NSNumber alloc] initWithInt:type]];
        if ([result next])
        {
            action = loadFutureActionFromQueryResult(result);
        }
        
    } synchronous:true];
    
    return action;
}

- (int)loadPeerMinMid:(int64_t)peerId
{
    __block int minMid = 0;
    
    [self dispatchOnDatabaseThread:^
    {
        FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT last_mid FROM %@ WHERE pid=%lld", _peerPropertiesTableName, peerId]];
        if ([result next])
        {
            minMid = [result intForColumn:@"last_mid"];
        }
    } synchronous:true];
    
    return minMid;
}

- (int)loadPeerMinMediaMid:(int64_t)peerId
{
    __block int minMediaMid = 0;
    
    [self dispatchOnDatabaseThread:^
    {
        FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT last_media FROM %@ WHERE pid=%lld", _peerPropertiesTableName, peerId]];
        if ([result next])
        {
            minMediaMid = [result intForColumn:@"last_media"];
        }
    } synchronous:true];
    
    return minMediaMid;
}

- (void)loadPeerNotificationSettings:(int64_t)peerId soundId:(int *)soundId muteUntil:(int *)muteUntil previewText:(bool *)previewText photoNotificationsEnabled:(bool *)photoNotificationsEnabled notFound:(bool *)notFound
{
    __block bool found = false;
    __block int foundSoundId = 1;
    __block int foundMuteUntil = 0;
    __block int foundPreviewText = 1;
    __block bool foundPhotoNotificationsEnabled = true;
    
    [self dispatchOnDatabaseThread:^
    {
        FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT notification_type, mute, preview_text FROM %@ WHERE pid=%lld", _peerPropertiesTableName, peerId]];
        if ([result next])
        {
            foundSoundId = [result intForColumn:@"notification_type"];
            foundMuteUntil = [result intForColumn:@"mute"];
            foundPreviewText = [result intForColumn:@"preview_text"] != 0;
            found = true;
            
            if (foundMuteUntil - (CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970) <= 0)
            {
                foundMuteUntil = 0;
                [_database executeQuery:[NSString stringWithFormat:@"UPDATE OR IGNORE %@ SET mute=0 WHERE pid=%lld", _peerPropertiesTableName, peerId]];
            }
            
            TG_SYNCHRONIZED_BEGIN(_mutedPeers);
            _mutedPeers[peerId] = foundMuteUntil;
            TG_SYNCHRONIZED_END(_mutedPeers);
        }
        
        foundPhotoNotificationsEnabled = [self loadPeerPhotoNotificationsEnabled:peerId];
    } synchronous:true];
    
    if (found && notFound != NULL)
        *notFound = !found;
    
    if (soundId != NULL)
        *soundId = foundSoundId;
    if (muteUntil != NULL)
        *muteUntil = foundMuteUntil;
    if (previewText != NULL)
        *previewText = foundPreviewText;
    if (photoNotificationsEnabled != NULL)
        *photoNotificationsEnabled = foundPhotoNotificationsEnabled;
}

- (BOOL)isPeerMuted:(int64_t)peerId
{
    bool found = false;
    int muteDate = 0;
    
    TG_SYNCHRONIZED_BEGIN(_mutedPeers);
    std::map<int64_t, int>::iterator it = _mutedPeers.find(peerId);
    if (it != _mutedPeers.end())
    {
        found = true;
        muteDate = it->second;
        
        if (muteDate != 0 && muteDate - (CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970) <= 0)
        {
            muteDate = 0;
            _mutedPeers[peerId] = muteDate;
            
            [self dispatchOnDatabaseThread:^
            {
                [_database executeQuery:[NSString stringWithFormat:@"UPDATE OR IGNORE %@ SET mute=0 WHERE pid=%lld", _peerPropertiesTableName, peerId]];
            } synchronous:false];
        }
    }
    TG_SYNCHRONIZED_END(_mutedPeers);
    
    if (found)
        return muteDate > 0;
    
    __block bool blockIsMuted = false;
    
    [self dispatchOnDatabaseThread:^
    {
        int muteUntil = 0;
        [self loadPeerNotificationSettings:peerId soundId:NULL muteUntil:&muteUntil previewText:NULL photoNotificationsEnabled:NULL notFound:NULL];
        
        if (muteUntil != 0 && muteUntil - (CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970 + _timeDifferenceFromUTC) <= 0)
        {
            [_database executeQuery:[NSString stringWithFormat:@"UPDATE OR IGNORE %@ SET mute=0 WHERE pid=%lld", _peerPropertiesTableName, peerId]];
            muteUntil = 0;
        }
        
        TG_SYNCHRONIZED_BEGIN(_mutedPeers);
        _mutedPeers[peerId] = muteUntil;
        TG_SYNCHRONIZED_END(_mutedPeers);
        
        blockIsMuted = muteUntil != 0;
    } synchronous:true];
    
    return blockIsMuted;
}

- (TGPeerCustomSettings)loadPeerCustomSettings:(int64_t)peerId
{
    bool cacheFound = false;
    TGPeerCustomSettings value;
    
    TG_SYNCHRONIZED_BEGIN(_peerCustomSettings);
    auto it = _peerCustomSettings.find(peerId);
    if (it != _peerCustomSettings.end())
    {
        cacheFound = true;
        value = it->second;
    }
    TG_SYNCHRONIZED_END(_peerCustomSettings);
    
    if (cacheFound)
        return value;
    
    NSData *data = [self conversationCustomPropertySync:peerId name:TGCustomPeerSettingsKey];
    
    if (data.length != 0)
    {
        int ptr = 0;
        
        uint8_t version = 0;
        [data getBytes:&version range:NSMakeRange(ptr, 1)];
        ptr++;
        
        uint8_t photoNotificationsEnabled = 0;
        [data getBytes:&photoNotificationsEnabled length:1];
        ptr++;
        
        value.photoNotificationsEnabled = photoNotificationsEnabled;
    }
    else
    {
        value.photoNotificationsEnabled = true;
    }
    
    TG_SYNCHRONIZED_BEGIN(_peerCustomSettings);
    _peerCustomSettings[peerId] = value;
    TG_SYNCHRONIZED_END(_peerCustomSettings);
    
    return value;
}

- (void)storePeerCustomSettings:(int64_t)peerId customSettings:(TGPeerCustomSettings)customSettings
{
    bool commitToDatabase = true;
    
    TG_SYNCHRONIZED_BEGIN(_peerCustomSettings);
    auto it = _peerCustomSettings.find(peerId);
    if (it != _peerCustomSettings.end())
    {
        commitToDatabase = memcmp(&customSettings, &it->second, sizeof(TGPeerCustomSettings));
    }
    _peerCustomSettings[peerId] = customSettings;
    TG_SYNCHRONIZED_END(_peerCustomSettings);
    
    if (commitToDatabase)
    {
        NSMutableData *data = [[NSMutableData alloc] init];
        
        uint8_t version = 0;
        [data appendBytes:&version length:1];
        
        uint8_t photoNotificationsEnabled = customSettings.photoNotificationsEnabled;
        [data appendBytes:&photoNotificationsEnabled length:1];
        
        [self setConversationCustomProperty:peerId name:TGCustomPeerSettingsKey value:data];
    }
}

- (bool)loadPeerPhotoNotificationsEnabled:(int64_t)peerId
{
    return [self loadPeerCustomSettings:peerId].photoNotificationsEnabled;
}

- (void)setPeerPhotoNotificationsEnabled:(int64_t)peerId photoNotificationsEnabled:(bool)photoNotificationsEnabled
{
    TGPeerCustomSettings customSettings = [self loadPeerCustomSettings:peerId];
    if (customSettings.photoNotificationsEnabled != photoNotificationsEnabled)
    {
        customSettings.photoNotificationsEnabled = photoNotificationsEnabled;
        [self storePeerCustomSettings:peerId customSettings:customSettings];
    }
}

- (std::set<int>)filterPeerPhotoNotificationsEnabled:(std::vector<int> const &)uidList
{
    std::set<int> result;
    
    for (auto it : uidList)
    {
        if ([self loadPeerPhotoNotificationsEnabled:it] && [self uidIsRemoteContact:it])
            result.insert(it);
    }
    
    [self _filterPeersAreBlockedSync:&result];
    
    return result;
}

- (int)minAutosaveMessageIdForConversation:(int64_t)conversationId
{
    int result = 0;
    bool found = false;
    
    TG_SYNCHRONIZED_BEGIN(_minAutosaveMessageIdForConversations);
    auto it = _minAutosaveMessageIdForConversations.find(conversationId);
    if (it != _minAutosaveMessageIdForConversations.end())
    {
        result = it->second;
        found = true;
    }
    TG_SYNCHRONIZED_END(_minAutosaveMessageIdForConversations);
    
    if (!found)
    {
        NSData *value = [self conversationCustomPropertySync:conversationId name:minReadIncomingMid_hash];
        
        if (value == nil)
            result = INT_MAX;
        else
            [value getBytes:&result range:NSMakeRange(0, 4)];
        
        TG_SYNCHRONIZED_BEGIN(_minAutosaveMessageIdForConversations);
        _minAutosaveMessageIdForConversations[conversationId] = result;
        TG_SYNCHRONIZED_END(_minAutosaveMessageIdForConversations);
    }
    
    return result;
}

- (void)storeMinAutosaveMessageIdForConversation:(int64_t)conversationId mid:(int)mid
{
    bool loadFromDatabase = true;
    bool storeToDatabase = false;
    
    TG_SYNCHRONIZED_BEGIN(_minAutosaveMessageIdForConversations);
    auto it = _minAutosaveMessageIdForConversations.find(conversationId);
    if (it != _minAutosaveMessageIdForConversations.end())
    {
        if (it->second > mid)
        {
            it->second = mid;
            storeToDatabase = true;
        }
        
        loadFromDatabase = false;
    }
    TG_SYNCHRONIZED_END(_minAutosaveMessageIdForConversations);
    
    if (loadFromDatabase)
    {
        NSData *value = [self conversationCustomPropertySync:conversationId name:minReadIncomingMid_hash];
        
        int result = INT_MAX;
        if (value != nil)
            [value getBytes:&result range:NSMakeRange(0, 4)];
        
        TG_SYNCHRONIZED_BEGIN(_minAutosaveMessageIdForConversations);
        _minAutosaveMessageIdForConversations[conversationId] = result;
        
        if (result > mid)
            storeToDatabase = true;
        TG_SYNCHRONIZED_END(_minAutosaveMessageIdForConversations);
    }
    
    if (storeToDatabase)
    {
        [self setConversationCustomProperty:conversationId name:minReadIncomingMid_hash value:[[NSData alloc] initWithBytes:&mid length:4]];
    }
}

- (void)storePeerMinMid:(int64_t)peerId minMid:(int)minMid
{
    [self dispatchOnDatabaseThread:^
    {
        FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT pid FROM %@ WHERE pid=%lld", _peerPropertiesTableName, peerId]];
        if ([result next])
        {
            [_database executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET last_mid=%d WHERE pid=%lld", _peerPropertiesTableName, minMid, peerId]];
        }
        else
        {
            [_database executeUpdate:[NSString stringWithFormat:@"INSERT INTO %@ (pid, last_mid, last_media, notification_type, mute, preview_text, custom_properties) VALUES(%lld, %d, 0, 1, 0, 1, NULL)", _peerPropertiesTableName, peerId, minMid]];
        }
    } synchronous:false];
}

- (void)storePeerMinMediaMid:(int64_t)peerId minMediaMid:(int)minMediaMid
{
    [self dispatchOnDatabaseThread:^
    {
        FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT pid FROM %@ WHERE pid=%lld", _peerPropertiesTableName, peerId]];
        if ([result next])
        {
            [_database executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET last_media=%d WHERE pid=%lld", _peerPropertiesTableName, minMediaMid, peerId]];
        }
        else
        {
            [_database executeUpdate:[NSString stringWithFormat:@"INSERT INTO %@ (pid, last_mid, last_media, notification_type, mute, preview_text, custom_properties) VALUES(%lld, 0, %d, 1, 0, 1, NULL)", _peerPropertiesTableName, peerId, minMediaMid]];
        }
    } synchronous:false];
}

- (void)storePeerNotificationSettings:(int64_t)peerId soundId:(int)soundId muteUntil:(int)muteUntil previewText:(bool)previewText photoNotificationsEnabled:(bool)photoNotificationsEnabled writeToActionQueue:(bool)writeToActionQueue completion:(void (^)(bool))completion
{
    [self dispatchOnDatabaseThread:^
    {
        FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT pid, notification_type, mute, preview_text FROM %@ WHERE pid=%lld", _peerPropertiesTableName, peerId]];
        if ([result next])
        {
            int currentSoundId = [result intForColumn:@"notification_type"];
            int currentMuteUntil = [result intForColumn:@"mute"];
            bool currentPreviewText = [result intForColumn:@"preview_text"] != 0;
            
            [_database executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET notification_type=%d, mute=%d, preview_text=%d WHERE pid=%lld", _peerPropertiesTableName, soundId, muteUntil, previewText != 0, peerId]];
            
            if (completion)
                completion(soundId != currentSoundId || muteUntil != currentMuteUntil || previewText != currentPreviewText);
        }
        else
        {
            [_database executeUpdate:[NSString stringWithFormat:@"INSERT INTO %@ (pid, last_mid, last_media, notification_type, mute, preview_text, custom_properties) VALUES(%lld, 0, 0, %d, %d, %d, NULL)", _peerPropertiesTableName, peerId, soundId, muteUntil, previewText]];
            
            if (completion)
                completion(soundId != 0 || muteUntil != 0 || previewText != true);
        }
        
        TG_SYNCHRONIZED_BEGIN(_mutedPeers);
        _mutedPeers[peerId] = muteUntil;
        TG_SYNCHRONIZED_END(_mutedPeers);
        
        [self setPeerPhotoNotificationsEnabled:peerId photoNotificationsEnabled:photoNotificationsEnabled];
        
        if (writeToActionQueue)
        {
            [self storeFutureActions:[NSArray arrayWithObject:[[TGChangeNotificationSettingsFutureAction alloc] initWithPeerId:peerId muteUntil:muteUntil soundId:soundId previewText:previewText photoNotificationsEnabled:photoNotificationsEnabled]]];
        }
    } synchronous:false];
}

- (void)setConversationCustomProperty:(int64_t)conversationId name:(int)name value:(NSData *)value
{
    [self dispatchOnDatabaseThread:^
    {
        FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT custom_properties FROM %@ WHERE pid=?", _peerPropertiesTableName], [[NSNumber alloc] initWithLongLong:conversationId]];
        
        std::map<int, NSData *> tmpDict;
        bool update = false;
        
        if ([result next])
        {
            update = true;
            NSData *serializedProperties = [result dataForColumn:@"custom_properties"];
            
            int ptr = 0;
            
            int version = 0;
            [serializedProperties getBytes:&version range:NSMakeRange(ptr, 4)];
            ptr += 4;
            
            int count = 0;
            [serializedProperties getBytes:&count range:NSMakeRange(ptr, 4)];
            ptr += 4;
            
            for (int i = 0; i < count; i++)
            {
                int key = 0;
                [serializedProperties getBytes:&key range:NSMakeRange(ptr, 4)];
                ptr += 4;
                
                int valueLength = 0;
                [serializedProperties getBytes:&valueLength range:NSMakeRange(ptr, 4)];
                ptr += 4;
                
                uint8_t *valueBytes = (uint8_t *)malloc(valueLength);
                [serializedProperties getBytes:valueBytes range:NSMakeRange(ptr, valueLength)];
                ptr += valueLength;
                
                NSData *value = [[NSData alloc] initWithBytesNoCopy:valueBytes length:valueLength freeWhenDone:true];
                tmpDict.insert(std::pair<int, NSData *>(key, value));
            }
        }

        if (value != nil)
            tmpDict[name] = value;
        else
            tmpDict.erase(name);
        
        NSMutableData *outData = [[NSMutableData alloc] init];
        
        int outVersion = 0;
        [outData appendBytes:&outVersion length:4];
        
        int outCount = (int)tmpDict.size();
        [outData appendBytes:&outCount length:4];
        
        for (auto it = tmpDict.begin(); it != tmpDict.end(); it++)
        {
            int key = it->first;
            [outData appendBytes:&key length:4];
            
            int valueLength = (int)it->second.length;
            [outData appendBytes:&valueLength length:4];
            [outData appendData:it->second];
        }
        
        if (update)
        {
            [_database executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET custom_properties=? WHERE pid=?", _peerPropertiesTableName], outData, [[NSNumber alloc] initWithLongLong:conversationId]];
        }
        else
        {
            [_database executeUpdate:[NSString stringWithFormat:@"INSERT INTO %@ (pid, last_mid, last_media, notification_type, mute, preview_text, custom_properties) VALUES(?, 0, 0, 1, 0, 1, ?)", _peerPropertiesTableName], [[NSNumber alloc] initWithLongLong:conversationId], outData];
        }
    } synchronous:false];
}

- (void)conversationCustomProperty:(int64_t)conversationId name:(int)name completion:(void (^)(NSData *value))completion
{
    [self dispatchOnDatabaseThread:^
    {
        FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT custom_properties FROM %@ WHERE pid=%lld", _peerPropertiesTableName, conversationId]];
        
        id value = nil;
        
        if ([result next])
        {
            NSData *serializedProperties = [result dataForColumn:@"custom_properties"];
            if (serializedProperties != nil)
            {
                NSData *serializedProperties = [result dataForColumn:@"custom_properties"];
                
                int ptr = 0;
                
                int version = 0;
                [serializedProperties getBytes:&version range:NSMakeRange(ptr, 4)];
                ptr += 4;
                
                int count = 0;
                [serializedProperties getBytes:&count range:NSMakeRange(ptr, 4)];
                ptr += 4;
                
                for (int i = 0; i < count; i++)
                {
                    int key = 0;
                    [serializedProperties getBytes:&key range:NSMakeRange(ptr, 4)];
                    ptr += 4;
                    
                    int valueLength = 0;
                    [serializedProperties getBytes:&valueLength range:NSMakeRange(ptr, 4)];
                    ptr += 4;
                    
                    if (key == name)
                    {
                        uint8_t *valueBytes = (uint8_t *)malloc(valueLength);
                        [serializedProperties getBytes:valueBytes range:NSMakeRange(ptr, valueLength)];
                        
                        value = [[NSData alloc] initWithBytesNoCopy:valueBytes length:valueLength freeWhenDone:true];
                        
                        break;
                    }

                    ptr += valueLength;
                }
            }
        }
        
        if (completion)
            completion(value);
    } synchronous:false];
}

- (NSData *)conversationCustomPropertySync:(int64_t)conversationId name:(int)name
{
    __block id value = nil;
    
    [self dispatchOnDatabaseThread:^
    {
        FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT custom_properties FROM %@ WHERE pid=?", _peerPropertiesTableName], [[NSNumber alloc] initWithLongLong:conversationId]];
        
        if ([result next])
        {
            NSData *serializedProperties = [result dataForColumn:@"custom_properties"];
            if (serializedProperties != nil)
            {
                NSData *serializedProperties = [result dataForColumn:@"custom_properties"];
                
                int ptr = 0;
                
                int version = 0;
                [serializedProperties getBytes:&version range:NSMakeRange(ptr, 4)];
                ptr += 4;
                
                int count = 0;
                [serializedProperties getBytes:&count range:NSMakeRange(ptr, 4)];
                ptr += 4;
                
                for (int i = 0; i < count; i++)
                {
                    int key = 0;
                    [serializedProperties getBytes:&key range:NSMakeRange(ptr, 4)];
                    ptr += 4;
                    
                    int valueLength = 0;
                    [serializedProperties getBytes:&valueLength range:NSMakeRange(ptr, 4)];
                    ptr += 4;
                    
                    if (key == name)
                    {
                        uint8_t *valueBytes = (uint8_t *)malloc(valueLength);
                        [serializedProperties getBytes:valueBytes range:NSMakeRange(ptr, valueLength)];
                        
                        value = [[NSData alloc] initWithBytesNoCopy:valueBytes length:valueLength freeWhenDone:true];
                        
                        break;
                    }
                    
                    ptr += valueLength;
                }
            }
        }
    } synchronous:true];
    
    return value;
}

- (void)clearPeerNotificationSettings:(bool)writeToActionQueue
{
    [self dispatchOnDatabaseThread:^
    {
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"UPDATE %@ SET notification_type=1, mute=0, preview_text=1", _peerPropertiesTableName]];
        
        TG_SYNCHRONIZED_BEGIN(_mutedPeers);
        _mutedPeers.clear();
        TG_SYNCHRONIZED_END(_mutedPeers);
        
        if (writeToActionQueue)
        {
            TGClearNotificationsFutureAction *action = [[TGClearNotificationsFutureAction alloc] init];
            [self storeFutureActions:[NSArray arrayWithObject:action]];
        }
    } synchronous:false];
}

- (NSIndexSet *)_historyHolesInConversation:(int64_t)peerId
{
    NSIndexSet *indexSet = nil;
    
    FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT holes FROM %@ WHERE peer_id = ?", _peerHistoryHolesTableName], @(peerId)];
    if ([result next])
    {
        NSData *data = [result dataForColumn:@"holes"];
        if (data != nil)
            indexSet = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    return indexSet;
}

- (void)addConversationHistoryHole:(int64_t)peerId minMessageId:(int32_t)minMessageId maxMessageId:(int32_t)maxMessageId
{
    [self dispatchOnDatabaseThread:^
    {
        NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] initWithIndexSet:[self _historyHolesInConversation:peerId]];
        [indexSet addIndexesInRange:NSMakeRange(minMessageId, maxMessageId - minMessageId)];
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO %@ (peer_id, holes) VALUES (?, ?)", _peerHistoryHolesTableName], @(peerId), [NSKeyedArchiver archivedDataWithRootObject:indexSet]];
    } synchronous:false];
}

- (void)addConversationHistoryHoleToLoadedLaterMessages:(int64_t)peerId maxMessageId:(int32_t)maxMessageId
{
    [self dispatchOnDatabaseThread:^
    {
        //[self explainQuery:[[NSString alloc] initWithFormat:@"SELECT MIN(mid) FROM %@ WHERE cid = %" PRId64 " AND mid > %" PRId32 "", _messagesTableName, peerId, maxMessageId]];
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT MIN(mid) FROM %@ WHERE cid = ? AND mid > ?", _messagesTableName], @(peerId), @(maxMessageId)];
        if ([result next])
        {
            int32_t nextMessage = [result intForColumn:@"MIN(mid)"];
            if (nextMessage - 1 > maxMessageId + 1)
            {
                [self addConversationHistoryHole:peerId minMessageId:maxMessageId + 1 maxMessageId:nextMessage - 1];
            }
        }
    } synchronous:false];
}

- (void)fillConversationHistoryHole:(int64_t)peerId indexSet:(NSIndexSet *)filledIndexSet
{
    [self dispatchOnDatabaseThread:^
    {
        NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] initWithIndexSet:[self _historyHolesInConversation:peerId]];
        [indexSet removeIndexes:filledIndexSet];
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO %@ (peer_id, holes) VALUES (?, ?)", _peerHistoryHolesTableName], @(peerId), [NSKeyedArchiver archivedDataWithRootObject:indexSet]];
    } synchronous:false];
}

- (bool)conversationContainsHole:(int64_t)peerId minMessageId:(int32_t)minMessageId maxMessageId:(int32_t)maxMessageId
{
    __block bool contains = false;
    
    [self dispatchOnDatabaseThread:^
    {
        NSIndexSet *indexSet = [self _historyHolesInConversation:peerId];
        NSRange range = NSMakeRange(minMessageId, maxMessageId - minMessageId);
        contains = [indexSet intersectsIndexesInRange:range];
    } synchronous:true];
    
    return contains;
}

- (NSArray *)excludeMessagesWithHolesFromArray:(NSArray *)messages peerId:(int64_t)peerId aroundMessageId:(int32_t)aroundMessageId
{
    if (messages.count <= 1)
        return messages;
    NSMutableArray *filteredMessages = [[NSMutableArray alloc] init];
    
    [self dispatchOnDatabaseThread:^
    {
        NSArray *sortedMessages = [messages sortedArrayUsingComparator:^NSComparisonResult(TGMessage *message1, TGMessage *message2)
        {
            NSTimeInterval date1 = message1.date;
            NSTimeInterval date2 = message2.date;
            
            if (ABS(date1 - date2) < DBL_EPSILON)
            {
                if (message1.mid > message2.mid)
                    return NSOrderedAscending;
                else
                    return NSOrderedDescending;
            }
            
            return date1 > date2 ? NSOrderedAscending : NSOrderedDescending;
        }];
        
        NSIndexSet *indexSet = [self _historyHolesInConversation:peerId];
        
        NSUInteger fromIndex = NSNotFound;
        NSInteger index = -1;
        for (TGMessage *message in sortedMessages)
        {
            index++;
            if (message.mid == aroundMessageId)
            {
                fromIndex = (NSUInteger)index;
                break;
            }
        }
        
        if (fromIndex == NSNotFound)
        {
            int32_t lastRemoteMessageId = 0;
            for (TGMessage *message in sortedMessages)
            {
                if (message.mid < TGMessageLocalMidBaseline)
                {
                    if (lastRemoteMessageId != 0)
                    {
                        if ([indexSet intersectsIndexesInRange:NSMakeRange(MIN(message.mid, lastRemoteMessageId), MAX(message.mid, lastRemoteMessageId) - MIN(message.mid, lastRemoteMessageId))])
                            break;
                    }
                    
                    lastRemoteMessageId = message.mid;
                }
                
                [filteredMessages addObject:message];
            }
        }
        else
        {
            int32_t lastRemoteMessageId = 0;
            for (NSInteger i = fromIndex; i >= 0; i--)
            {
                TGMessage *message = sortedMessages[i];
                
                if (message.mid < TGMessageLocalMidBaseline)
                {
                    if (lastRemoteMessageId != 0)
                    {
                        if ([indexSet intersectsIndexesInRange:NSMakeRange(MIN(message.mid, lastRemoteMessageId), MAX(message.mid, lastRemoteMessageId) - MIN(message.mid, lastRemoteMessageId))])
                            break;
                    }
                    
                    lastRemoteMessageId = message.mid;
                }
                
                [filteredMessages addObject:message];
            }
            
            lastRemoteMessageId = 0;
            for (NSInteger i = fromIndex + 1; i < (NSInteger)sortedMessages.count; i++)
            {
                TGMessage *message = sortedMessages[i];
                
                if (message.mid < TGMessageLocalMidBaseline)
                {
                    if (lastRemoteMessageId != 0)
                    {
                        if ([indexSet intersectsIndexesInRange:NSMakeRange(MIN(message.mid, lastRemoteMessageId), MAX(message.mid, lastRemoteMessageId) - MIN(message.mid, lastRemoteMessageId))])
                            break;
                    }
                    
                    lastRemoteMessageId = message.mid;
                }
                
                [filteredMessages addObject:message];
            }
        }
    } synchronous:true];
    
    return filteredMessages;
}

- (void)setAssetIsStored:(NSString *)url
{
    [self dispatchOnDatabaseThread:^
    {
        NSData *data = [url dataUsingEncoding:NSUTF8StringEncoding];
        const char *ptr = (const char *)[data bytes];
        unsigned char md5Buffer[16];
        CC_MD5(ptr, (CC_LONG)data.length, md5Buffer);
        
        int64_t hash_high = 0;
        memcpy(&hash_high, md5Buffer, 8);
        int64_t hash_low = 0;
        memcpy(&hash_low, md5Buffer + 8, 8);
        
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO %@ VALUES (?, ?)", _assetsTableName], [[NSNumber alloc] initWithLongLong:hash_high], [[NSNumber alloc] initWithLongLong:hash_low]];
    } synchronous:false];
}

- (void)checkIfAssetIsStored:(NSString *)url completion:(void (^)(bool stored))completion
{
    [self dispatchOnDatabaseThread:^
    {
        bool result = false;
        
        NSData *data = [url dataUsingEncoding:NSUTF8StringEncoding];
        const char *ptr = (const char *)[data bytes];
        unsigned char md5Buffer[16];
        CC_MD5(ptr, (CC_LONG)data.length, md5Buffer);
        
        int64_t hash_high = 0;
        memcpy(&hash_high, md5Buffer, 8);
        int64_t hash_low = 0;
        memcpy(&hash_low, md5Buffer + 8, 8);
        
        FMResultSet *resultSet = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE hash_high=? AND hash_low=?", _assetsTableName], [[NSNumber alloc] initWithLongLong:hash_high], [[NSNumber alloc] initWithLongLong:hash_low]];
        result = [resultSet next];
        resultSet = nil;
        
        if (completion)
            completion(result);
    } synchronous:false];
}

- (void)setPeerIsBlocked:(int64_t)peerId blocked:(bool)blocked writeToActionQueue:(bool)writeToActionQueue
{
    [self dispatchOnDatabaseThread:^
    {
        NSNumber *nPeerId = [[NSNumber alloc] initWithLongLong:peerId];
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT pid FROM %@ WHERE pid=?", _blockedUsersTableName], nPeerId];
        bool currentBlocked = [result next];
        result = nil;
        
        if (blocked != currentBlocked)
        {
            if (blocked)
                [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT INTO %@ (pid, date) VALUES (?, ?)", _blockedUsersTableName], nPeerId, [[NSNumber alloc] initWithInt:(int)((CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970))]];
            else
                [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE pid=?", _blockedUsersTableName], nPeerId];
            
            if (writeToActionQueue)
            {
                [self storeFutureActions:[NSArray arrayWithObject:[[TGChangePeerBlockStatusFutureAction alloc] initWithPeerId:[nPeerId longLongValue] block:blocked]]];
            }
        }
    } synchronous:false];
}

- (void)_filterPeersAreBlockedSync:(std::set<int> *)pSet
{
    [self dispatchOnDatabaseThread:^
    {
        auto it = pSet->begin();
        while (it != pSet->end())
        {
            FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT pid FROM %@ WHERE pid=?", _blockedUsersTableName], [[NSNumber alloc] initWithLongLong:*it]];
            bool blocked = [result next];
            
            if (blocked)
                pSet->erase(it++);
            else
                ++it;
        }
    } synchronous:true];
}

- (void)loadPeerIsBlocked:(int64_t)peerId completion:(void (^)(bool blocked))completion
{
    [self dispatchOnDatabaseThread:^
    {
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT pid FROM %@ WHERE pid=?", _blockedUsersTableName], [[NSNumber alloc] initWithLongLong:peerId]];
        bool blocked = [result next];
        if (completion)
            completion(blocked);
    } synchronous:false];
}

- (void)replaceBlockedList:(NSArray *)blockedPeers
{
    [self dispatchOnDatabaseThread:^
    {
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@", _blockedUsersTableName]];
        [_database beginTransaction];
        for (NSArray *record in blockedPeers)
        {
            [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT INTO %@ (pid, date) VALUES (?, ?)", _blockedUsersTableName], [record objectAtIndex:0], [record objectAtIndex:1]];
        }
        [_database commit];
    } synchronous:false];
}

- (void)loadBlockedList:(void (^)(NSArray *blockedList))completion
{
    [self dispatchOnDatabaseThread:^
    {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT * FROM %@ ORDER BY date DESC", _blockedUsersTableName]];
        int pidIndex = [result columnIndexForName:@"pid"];
        
        while ([result next])
        {
            int64_t pid = [result longLongIntForColumnIndex:pidIndex];
            [array addObject:[[NSNumber alloc] initWithLongLong:pid]];
        }
        
        if (completion)
            completion(array);
    } synchronous:false];
}

- (int)loadBlockedDate:(int64_t)peerId
{
    __block int date = 0;
    
    [self dispatchOnDatabaseThread:^
    {
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT date FROM %@ WHERE pid=?", _blockedUsersTableName], [[NSNumber alloc] initWithLongLong:peerId]];
        if ([result next])
        {
            date = [result intForColumn:@"date"];
        }
    } synchronous:true];
    
    return date;
}

- (void)storePeerProfilePhotos:(int64_t)peerId photosArray:(NSArray *)photosArray append:(bool)append
{
    [self dispatchOnDatabaseThread:^
    {
        [_database beginTransaction];
        
        NSNumber *nPeerId = [[NSNumber alloc] initWithLongLong:peerId];
        
        if (!append)
            [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE peer_id=?", _peerProfilePhotosTableName], nPeerId];
        
        NSString *insertFormat = [[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO %@ (photo_id, peer_id, data) VALUES (?, ?, ?)", _peerProfilePhotosTableName];
        
        for (TGImageMediaAttachment *imageAttachment in photosArray)
        {
            NSMutableData *data = [[NSMutableData alloc] init];
            [imageAttachment serialize:data];
            [_database executeUpdate:insertFormat, [[NSNumber alloc] initWithLongLong:imageAttachment.imageId], nPeerId, data];
        }
        
        [_database commit];
    } synchronous:false];
}

- (NSArray *)addPeerProfilePhotos:(int64_t)peerId photosArray:(NSArray *)photosArray
{
    NSMutableArray *nonExistingIds = [[NSMutableArray alloc] init];
    
    [self dispatchOnDatabaseThread:^
    {
        [_database beginTransaction];
        
        NSNumber *nPeerId = [[NSNumber alloc] initWithLongLong:peerId];
        
        NSString *insertFormat = [[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO %@ (photo_id, peer_id, data) VALUES (?, ?, ?)", _peerProfilePhotosTableName];
        NSString *selectFormat = [[NSString alloc] initWithFormat:@"SELECT photo_id FROM %@ WHERE peer_id=? AND photo_id=?", _peerProfilePhotosTableName];
        
        for (TGImageMediaAttachment *imageAttachment in photosArray)
        {
            NSNumber *nPhotoId = [[NSNumber alloc] initWithLongLong:imageAttachment.imageId];
            
            FMResultSet *result = [_database executeQuery:selectFormat, nPeerId, nPhotoId];
            if (![result next])
            {
                NSMutableData *data = [[NSMutableData alloc] init];
                [imageAttachment serialize:data];
                [_database executeUpdate:insertFormat, [[NSNumber alloc] initWithLongLong:imageAttachment.imageId], nPeerId, data];
                
                [nonExistingIds addObject:nPhotoId];
            }
        }
        
        [_database commit];
    } synchronous:true];
    
    return nonExistingIds;
}

- (void)loadPeerProfilePhotos:(int64_t)peerId completion:(void (^)(NSArray *photosArray))completion
{
    [self dispatchOnDatabaseThread:^
    {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        FMResultSet *resultSet = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT data FROM %@ WHERE peer_id=?", _peerProfilePhotosTableName], [[NSNumber alloc] initWithLongLong:peerId]];
        
        int indexData = [resultSet columnIndexForName:@"data"];
        
        TGImageMediaAttachment *parser = [[TGImageMediaAttachment alloc] init];
        
        while ([resultSet next])
        {
            NSData *data = [resultSet dataForColumnIndex:indexData];
            
            NSInputStream *is = [[NSInputStream alloc] initWithData:data];
            [is open];
            TGImageMediaAttachment *imageAttachment = (TGImageMediaAttachment *)[parser parseMediaAttachment:is];
            [is close];
            
            if (imageAttachment != nil)
                [array addObject:imageAttachment];
        }
        
        if (completion)
            completion(array);
    } synchronous:false];
}

- (void)deletePeerProfilePhotos:(int64_t)peerId imageIds:(NSArray *)imageIds
{
    [self dispatchOnDatabaseThread:^
    {
        NSNumber *nPeerId = [[NSNumber alloc] initWithLongLong:peerId];
        
        NSMutableString *idsString = [[NSMutableString alloc] init];
        for (NSNumber *nImageId in imageIds)
        {
            if (idsString.length != 0)
                [idsString appendString:@","];
            [idsString appendFormat:@"%lld", [nImageId longLongValue]];
        }
        
        [_database setSoftShouldCacheStatements:false];
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE peer_id=? AND photo_id IN (%@)", _peerProfilePhotosTableName, idsString], nPeerId];
        [_database setSoftShouldCacheStatements:true];
    } synchronous:false];
}

- (void)clearPeerProfilePhotos
{
    [self dispatchOnDatabaseThread:^
    {
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@", _peerProfilePhotosTableName]];
    } synchronous:false];
}

- (void)clearPeerProfilePhotos:(int64_t)peerId
{
    [self dispatchOnDatabaseThread:^
     {
         [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE peer_id=?", _peerProfilePhotosTableName], @(peerId)];
     } synchronous:false];
}

- (void)updateLatestMessageId:(int)mid applied:(bool)applied completion:(void (^)(int greaterMidForSynchronization))completion
{
    [self dispatchOnDatabaseThread:^
    {
        int databaseMid = 0;
        
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT value FROM %@ WHERE key=?", _serviceTableName], [[NSNumber alloc] initWithInt:_serviceLatestSynchronizedMidKey]];
        if ([result next])
        {
            NSData *data = [result dataForColumn:@"value"];
            [data getBytes:&databaseMid length:4];
        }
        
        if (databaseMid <= mid)
        {
            uint8_t dataBytes[5];
            *((int *)(dataBytes + 0)) = mid;
            dataBytes[4] = applied ? 1 : 0;
            
            NSData *data = [[NSData alloc] initWithBytes:dataBytes length:5];
            if (databaseMid == 0)
                [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT INTO %@ (key, value) VALUES (?, ?)", _serviceTableName], [[NSNumber alloc] initWithInt:_serviceLatestSynchronizedMidKey], data];
            else
                [_database executeUpdate:[[NSString alloc] initWithFormat:@"UPDATE %@ SET value=? WHERE key=?", _serviceTableName], data, [[NSNumber alloc] initWithInt:_serviceLatestSynchronizedMidKey]];
            
            if (completion)
                completion(mid);
        }
        else
        {
            if (completion)
                completion(0);
        }
    } synchronous:false];
}

- (void)updateLatestQts:(int32_t)qts applied:(bool)applied completion:(void (^)(int greaterQtsForSynchronization))completion
{
    [self dispatchOnDatabaseThread:^
    {
        int databaseQts = 0;
        
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT value FROM %@ WHERE key=?", _serviceTableName], [[NSNumber alloc] initWithInt:_serviceLatestSynchronizedQtsKey]];
        if ([result next])
        {
            NSData *data = [result dataForColumn:@"value"];
            [data getBytes:&databaseQts length:4];
        }
        
        if (databaseQts <= qts)
        {
            uint8_t dataBytes[5];
            *((int *)(dataBytes + 0)) = qts;
            dataBytes[4] = applied ? 1 : 0;
            
            NSData *data = [[NSData alloc] initWithBytes:dataBytes length:5];
            if (databaseQts == 0)
                [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT INTO %@ (key, value) VALUES (?, ?)", _serviceTableName], [[NSNumber alloc] initWithInt:_serviceLatestSynchronizedQtsKey], data];
            else
                [_database executeUpdate:[[NSString alloc] initWithFormat:@"UPDATE %@ SET value=? WHERE key=?", _serviceTableName], data, [[NSNumber alloc] initWithInt:_serviceLatestSynchronizedQtsKey]];
            
            if (completion)
                completion(databaseQts != qts ? qts : 0);
        }
        else
        {
            if (completion)
                completion(0);
        }
    } synchronous:false];
}

- (void)checkIfLatestMessageIdIsNotApplied:(void (^)(int midForSinchronization))completion
{
    [self dispatchOnDatabaseThread:^
    {
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT value FROM %@ WHERE key=?", _serviceTableName], [[NSNumber alloc] initWithInt:_serviceLatestSynchronizedMidKey]];
        if ([result next])
        {
            NSData *data = [result dataForColumn:@"value"];
            int databaseMid = 0;
            uint8_t databaseApplied = 0;
            [data getBytes:&databaseMid length:4];
            [data getBytes:&databaseApplied range:NSMakeRange(4, 1)];
            
            if (completion)
                completion(databaseApplied != 0 ? 0 : databaseMid);
        }
        else
        {
            if (completion)
                completion(0);
        }
    } synchronous:false];
}

- (void)checkIfLatestQtsIsNotApplied:(void (^)(int qtsForSinchronization))completion
{
    [self dispatchOnDatabaseThread:^
    {
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT value FROM %@ WHERE key=?", _serviceTableName], [[NSNumber alloc] initWithInt:_serviceLatestSynchronizedQtsKey]];
        if ([result next])
        {
            NSData *data = [result dataForColumn:@"value"];
            int databaseQts = 0;
            uint8_t databaseApplied = 0;
            [data getBytes:&databaseQts length:4];
            [data getBytes:&databaseApplied range:NSMakeRange(4, 1)];
            
            if (completion)
                completion(databaseApplied != 0 ? 0 : databaseQts);
        }
        else
        {
            if (completion)
                completion(0);
        }
    } synchronous:false];
}

- (TGMediaAttachment *)loadServerAssetData:(NSString *)key
{
    __block TGMediaAttachment *attachment = nil;
    
    [self dispatchOnDatabaseThread:^
    {
        int64_t hash_high = 0;
        int64_t hash_low = 0;
        
        NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
        
        if (keyData.length == 16)
        {
            memcpy(&hash_high, [keyData bytes], 8);
            memcpy(&hash_low, ((uint8_t *)[keyData bytes]) + 8, 8);
        }
        else
        {
            const char *ptr = (const char *)[keyData bytes];
            unsigned char md5Buffer[16];
            CC_MD5(ptr, (CC_LONG)keyData.length, md5Buffer);
            
            memcpy(&hash_high, md5Buffer, 8);
            memcpy(&hash_low, md5Buffer + 8, 8);
        }
        
        FMResultSet *resultSet = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT data FROM %@ WHERE hash_high=? AND hash_low=?", _serverAssetsTableName], [[NSNumber alloc] initWithLongLong:hash_high], [[NSNumber alloc] initWithLongLong:hash_low]];
        
        if ([resultSet next])
        {
            NSData *data = [resultSet dataForColumn:@"data"];
            if (data.length >= 4)
            {
                NSInputStream *is = [[NSInputStream alloc] initWithData:data];
                [is open];
                
                int type = 0;
                [is read:(uint8_t *)&type maxLength:4];
                
                if (type == 0)
                {
                    TGImageMediaAttachment *imageAttachment = (TGImageMediaAttachment *)[[[TGImageMediaAttachment alloc] init] parseMediaAttachment:is];
                    if (imageAttachment != nil)
                        attachment = imageAttachment;
                }
                else if (type == 1)
                {
                    TGVideoMediaAttachment *videoAttachment = (TGVideoMediaAttachment *)[[[TGVideoMediaAttachment alloc] init] parseMediaAttachment:is];
                    if (videoAttachment != nil)
                        attachment = videoAttachment;
                }
                
                [is close];
            }
        }
        
    } synchronous:true];
    
    return attachment;
}

- (void)storeServerAssetData:(NSString *)key attachment:(TGMediaAttachment *)attachment
{
    [self dispatchOnDatabaseThread:^
    {
        NSMutableData *data = [[NSMutableData alloc] init];
        if (attachment.type == TGImageMediaAttachmentType)
        {
            int type = 0;
            [data appendBytes:&type length:4];
            
            [(TGImageMediaAttachment *)attachment serialize:data];
        }
        else if (attachment.type == TGVideoMediaAttachmentType)
        {
            int type = 1;
            [data appendBytes:&type length:4];
            
            [(TGVideoMediaAttachment *)attachment serialize:data];
        }
        
        if (data.length != 0)
        {
            NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
            const char *ptr = (const char *)[keyData bytes];
            unsigned char md5Buffer[16];
            CC_MD5(ptr, (CC_LONG)keyData.length, md5Buffer);
            
            int64_t hash_high = 0;
            memcpy(&hash_high, md5Buffer, 8);
            int64_t hash_low = 0;
            memcpy(&hash_low, md5Buffer + 8, 8);
            
            [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO %@ (hash_high, hash_low, data) VALUES(?, ?, ?)", _serverAssetsTableName], [[NSNumber alloc] initWithLongLong:hash_high], [[NSNumber alloc] initWithLongLong:hash_low], data];
        }
    } synchronous:false];
}

- (void)clearServerAssetData
{
    [self dispatchOnDatabaseThread:^
    {
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@", _serverAssetsTableName]];
    } synchronous:false];
}

- (int64_t)peerIdForEncryptedConversationId:(int64_t)encryptedConversationId
{
    return [self peerIdForEncryptedConversationId:encryptedConversationId createIfNecessary:true];
}

- (int64_t)peerIdForEncryptedConversationId:(int64_t)encryptedConversationId createIfNecessary:(bool)createIfNecessary
{
    int64_t result = 0;
    
    TG_SYNCHRONIZED_BEGIN(_encryptedConversationIds);
    
    auto it = _encryptedConversationIds.find(encryptedConversationId);
    if (it != _encryptedConversationIds.end())
    {
        result = it->second;
        TG_SYNCHRONIZED_END(_encryptedConversationIds);
    }
    else
    {
        TG_SYNCHRONIZED_END(_encryptedConversationIds);
        
        __block int64_t blockResult = 0;
        
        [self dispatchOnDatabaseThread:^
        {
            FMResultSet *encryptedConversationIdResult = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE encrypted_id=?", _encryptedConversationIdsTableName], [[NSNumber alloc] initWithLongLong:encryptedConversationId]];
            if ([encryptedConversationIdResult next])
            {
                blockResult = [encryptedConversationIdResult longLongIntForColumn:@"cid"];
            }
            else if (createIfNecessary)
            {
                int localCount = 0;
                
                FMResultSet *encryptedConversationCountResult = [_database executeQuery:[NSString stringWithFormat:@"SELECT * from %@ WHERE key=?", _serviceTableName], [[NSNumber alloc] initWithInt:_serviceEncryptedConversationCount]];
                if ([encryptedConversationCountResult next])
                {
                    NSData *value = [encryptedConversationCountResult dataForColumn:@"value"];
                    int intValue = 0;
                    [value getBytes:&intValue range:NSMakeRange(0, 4)];
                    localCount = intValue;
                }
                
                blockResult = (int64_t)INT_MIN - (int64_t)localCount;
                int newCount = localCount + 1;
            
                [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT INTO %@(encrypted_id, cid) VALUES(?, ?)", _encryptedConversationIdsTableName], [[NSNumber alloc] initWithLongLong:encryptedConversationId], [[NSNumber alloc] initWithLongLong:blockResult]];
                [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO %@(key, value) VALUES(?, ?)", _serviceTableName], [[NSNumber alloc] initWithInt:_serviceEncryptedConversationCount], [[NSData alloc] initWithBytes:&newCount length:4]];
                
                TGLog(@"===== allocated new encrypted conversation id %lld -> %lld", encryptedConversationId, blockResult);
            }
        } synchronous:true];
        
        result = blockResult;
        if (result != 0)
        {
            TG_SYNCHRONIZED_BEGIN(_encryptedConversationIds);
            _encryptedConversationIds[encryptedConversationId] = result;
            _peerIdsForEncryptedConversationIds[result] = encryptedConversationId;
            TG_SYNCHRONIZED_END(_encryptedConversationIds);
        }
    }
    
    return result;
}

- (int64_t)encryptedConversationIdForPeerId:(int64_t)peerId
{
    __block int64_t encryptedConversationId = 0;
    
    TG_SYNCHRONIZED_BEGIN(_encryptedConversationIds);
    
    auto it = _peerIdsForEncryptedConversationIds.find(peerId);
    if (it != _peerIdsForEncryptedConversationIds.end())
        encryptedConversationId = it->second;
    
    TG_SYNCHRONIZED_END(_encryptedConversationIds);
    
    if (encryptedConversationId == 0)
    {
        [self dispatchOnDatabaseThread:^
        {
            FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT encrypted_id FROM %@ WHERE cid=? LIMIT 1", _encryptedConversationIdsTableName], [[NSNumber alloc] initWithLongLong:peerId]];
            if ([result next])
                encryptedConversationId = [result longLongIntForColumn:@"encrypted_id"];
        } synchronous:true];
    }
    
    return encryptedConversationId;
}

- (int64_t)encryptedConversationAccessHash:(int64_t)conversationId
{
    int64_t accessHash = 0;
    
    TG_SYNCHRONIZED_BEGIN(_encryptedConversationAccessHash);
    auto it = _encryptedConversationAccessHash.find(conversationId);
    if (it != _encryptedConversationAccessHash.end())
        accessHash = it->second;
    TG_SYNCHRONIZED_END(_encryptedConversationAccessHash);
    
    if (accessHash == 0)
    {
        accessHash = [[self loadConversationWithId:conversationId] encryptedData].accessHash;
        if (accessHash != 0)
        {
            TG_SYNCHRONIZED_BEGIN(_encryptedConversationAccessHash);
            _encryptedConversationAccessHash[conversationId] = accessHash;
            TG_SYNCHRONIZED_END(_encryptedConversationAccessHash);
        }
    }
    
    return accessHash;
}

- (NSData *)encryptionKeyForConversationId:(int64_t)conversationId requestedKeyFingerprint:(int64_t)requestedKeyFingerprint outKeyFingerprint:(int64_t *)outKeyFingerprint
{
    bool found = false;
    NSData *key = nil;
    int64_t fingerprint = 0;
    
    TG_SYNCHRONIZED_BEGIN(_conversationEncryptionKeys);
    auto it = _conversationEncryptionKeys.find(conversationId);
    if (it != _conversationEncryptionKeys.end())
    {
        found = true;
        
        if (!it->second.empty() && requestedKeyFingerprint == 0)
        {
            auto record = it->second.at(it->second.size() - 1);
            fingerprint = record.keyId;
            key = record.key;
        }
        else
        {
            for (auto record : it->second)
            {
                if (record.keyId == requestedKeyFingerprint)
                {
                    key = record.key;
                    fingerprint = record.keyId;
                }
            }
        }
    }
    TG_SYNCHRONIZED_END(_conversationEncryptionKeys);
    
    if (!found)
    {
        std::vector<TGEncryptionKeyData *> loadedKeys;
        
        NSData *data = [self conversationCustomPropertySync:conversationId name:murMurHash32(@"encryptionKey")];
        if (data.length > 8)
        {
            int64_t legacyFingerprint = 0;
            [data getBytes:&legacyFingerprint range:NSMakeRange(0, 8)];
            NSData *legacyKey = [data subdataWithRange:NSMakeRange(8, data.length - 8)];
            loadedKeys.push_back([[TGEncryptionKeyData alloc] initWithKeyId:legacyFingerprint key:legacyKey firstSeqOut:0]);
        }
        
        data = [self conversationCustomPropertySync:conversationId name:murMurHash32(@"encryptionKeys")];
        if (data != nil)
        {
            for (TGEncryptionKeyData *keyData in [NSKeyedUnarchiver unarchiveObjectWithData:data])
            {
                loadedKeys.push_back(keyData);
            }
        }
        
        TG_SYNCHRONIZED_BEGIN(_conversationEncryptionKeys);
        _conversationEncryptionKeys[conversationId] = loadedKeys;
        
        it = _conversationEncryptionKeys.find(conversationId);
        if (!it->second.empty() && requestedKeyFingerprint == 0)
        {
            auto record = it->second.at(it->second.size() - 1);
            fingerprint = record.keyId;
            key = record.key;
        }
        else
        {
            for (auto record : it->second)
            {
                if (record.keyId == requestedKeyFingerprint)
                {
                    key = record.key;
                    fingerprint = record.keyId;
                }
            }
        }
        TG_SYNCHRONIZED_END(_conversationEncryptionKeys);
    }
    
    if (outKeyFingerprint)
        *outKeyFingerprint = fingerprint;
    
    return key;
}

- (NSData *)encryptionKeySignatureForConversationId:(int64_t)conversationId
{
    NSData *sha1 = [self conversationCustomPropertySync:conversationId name:murMurHash32(@"encryptionKeySha1")];
    if (sha1 != nil)
        return sha1;
    
    NSData *key = [self encryptionKeyForConversationId:conversationId requestedKeyFingerprint:0 outKeyFingerprint:NULL];
    if (key != nil)
    {
        NSData *sha1 = MTSha1(key);
        [self setConversationCustomProperty:conversationId name:murMurHash32(@"encryptionKeySha1") value:sha1];
        
        return sha1;
    }
    
    return nil;
}

- (int32_t)currentEncryptionKeyUseCount:(int64_t)peerId
{
    [self encryptionKeyForConversationId:peerId requestedKeyFingerprint:0 outKeyFingerprint:NULL];
    
    int32_t useCount = 0;
    int32_t nextSeqOut = [self peerNextSeqOut:peerId];
    
    TG_SYNCHRONIZED_BEGIN(_conversationEncryptionKeys);
    if (!_conversationEncryptionKeys[peerId].empty())
    {
        useCount = nextSeqOut - _conversationEncryptionKeys[peerId][_conversationEncryptionKeys[peerId].size() - 1].firstSeqOut;
    }
    TG_SYNCHRONIZED_END(_conversationEncryptionKeys);
    
    return useCount;
}

- (void)discardEncryptionKeysForConversationId:(int64_t)conversationId beforeSeqOut:(int32_t)beforeSeqOut
{
    [self encryptionKeyForConversationId:conversationId requestedKeyFingerprint:0 outKeyFingerprint:NULL];
    
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    
    bool foundCurrent = false;
    
    TG_SYNCHRONIZED_BEGIN(_conversationEncryptionKeys);
    int32_t maxKeySeqOut = 0;
    for (auto it = _conversationEncryptionKeys[conversationId].begin(); it != _conversationEncryptionKeys[conversationId].end();  it++)
    {
        if ((*it).firstSeqOut > maxKeySeqOut)
        {
            maxKeySeqOut = (*it).firstSeqOut;
        }
    }
    
    if (beforeSeqOut > maxKeySeqOut)
    {
        for (auto it = _conversationEncryptionKeys[conversationId].begin(); it != _conversationEncryptionKeys[conversationId].end(); )
        {
            if ((*it).firstSeqOut != maxKeySeqOut)
            {
                foundCurrent = true;
                it = _conversationEncryptionKeys[conversationId].erase(it);
            }
            else
                it++;
        }
    }
    
    for (auto record : _conversationEncryptionKeys[conversationId])
    {
        [keys addObject:record];
    }
    TG_SYNCHRONIZED_END(_conversationEncryptionKeys);
    
    if (foundCurrent)
    {
        TGLog(@"Discarded past keys for peer %" PRId64 ", %d keys left", conversationId, (int)keys.count);
        [self setConversationCustomProperty:conversationId name:murMurHash32(@"encryptionKey") value:[NSData data]];
        [self setConversationCustomProperty:conversationId name:murMurHash32(@"encryptionKeys") value:[NSKeyedArchiver archivedDataWithRootObject:keys]];
    }
}

- (void)storeEncryptionKeyForConversationId:(int64_t)conversationId key:(NSData *)key keyFingerprint:(int64_t)keyFingerprint firstSeqOut:(int32_t)firstSeqOut
{
    if ([self encryptionKeyForConversationId:conversationId requestedKeyFingerprint:keyFingerprint outKeyFingerprint:NULL] == nil)
    {
        if ([self conversationCustomPropertySync:conversationId name:murMurHash32(@"encryptionKeySha1")] == nil)
            [self encryptionKeySignatureForConversationId:conversationId];
        
        NSMutableArray *keys = [[NSMutableArray alloc] init];
        
        TG_SYNCHRONIZED_BEGIN(_conversationEncryptionKeys);
        _conversationEncryptionKeys[conversationId].push_back([[TGEncryptionKeyData alloc] initWithKeyId:keyFingerprint key:key firstSeqOut:firstSeqOut]);
        for (auto record : _conversationEncryptionKeys[conversationId])
        {
            [keys addObject:record];
        }
        TG_SYNCHRONIZED_END(_conversationEncryptionKeys);
        
        TGLog(@"Added encryption key %" PRId64 " for peer %" PRId64 " (expires after seq_in reaches %d)", keyFingerprint, conversationId, firstSeqOut);
        
        [self setConversationCustomProperty:conversationId name:murMurHash32(@"encryptionKey") value:[NSData data]];
        [self setConversationCustomProperty:conversationId name:murMurHash32(@"encryptionKeys") value:[NSKeyedArchiver archivedDataWithRootObject:keys]];
    }
}

- (int)encryptedParticipantIdForConversationId:(int64_t)conversationId
{
    int32_t uid = 0;
    
    TG_SYNCHRONIZED_BEGIN(_encryptedParticipantIds);
    auto it = _encryptedParticipantIds.find(conversationId);
    if (it != _encryptedParticipantIds.end())
        uid = it->second;
    TG_SYNCHRONIZED_END(_encryptedParticipantIds);
    
    if (uid == 0)
    {
        TGConversation *conversation = [self loadConversationWithId:conversationId];
        
        if (conversation != nil && conversation.chatParticipants.chatParticipantUids.count != 0)
        {
            uid = [conversation.chatParticipants.chatParticipantUids[0] intValue];
            
            if (uid != 0)
            {
                TG_SYNCHRONIZED_BEGIN(_encryptedParticipantIds);
                _encryptedParticipantIds[conversationId] = uid;
                TG_SYNCHRONIZED_END(_encryptedParticipantIds);
            }
        }
    }
    
    return uid;
}

- (bool)encryptedConversationIsCreator:(int64_t)conversationId
{
    bool value = false;
    bool found = false;
    
    TG_SYNCHRONIZED_BEGIN(_encryptedConversationIsCreator);
    auto it = _encryptedConversationIsCreator.find(conversationId);
    if (it != _encryptedConversationIsCreator.end())
    {
        found = true;
        value = it->second;
    }
    TG_SYNCHRONIZED_END(_encryptedConversationIsCreator);
    
    if (!found)
    {
        TGConversation *conversation = [self loadConversationWithId:conversationId];
        
        if (conversation != nil && conversation.chatParticipants != nil)
        {
            value = conversation.chatParticipants.chatAdminId == TGTelegraphInstance.clientUserId;

            TG_SYNCHRONIZED_BEGIN(_encryptedConversationIsCreator);
            _encryptedConversationIsCreator[conversationId] = value;
            TG_SYNCHRONIZED_END(_encryptedConversationIsCreator);
        }
    }
    
    return value;
}

- (void)filterExistingRandomIds:(std::set<int64_t> *)randomIds
{
    [self dispatchOnDatabaseThread:^
    {
        [_database setSoftShouldCacheStatements:false];
        NSMutableString *rangeString = [[NSMutableString alloc] init];
        
        const int batchSize = 256;
        for (auto it = randomIds->begin(); it != randomIds->end(); )
        {
            [rangeString deleteCharactersInRange:NSMakeRange(0, rangeString.length)];
            bool first = true;
            
            for (int i = 0; i < batchSize && it != randomIds->end(); i++, it++)
            {
                if (first)
                {
                    first = false;
                    [rangeString appendFormat:@"%lld", *it];
                }
                else
                    [rangeString appendFormat:@",%lld", *it];
            }
            
            FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT random_id FROM %@ WHERE random_id IN (%@)", _randomIdsTableName, rangeString]];
            int randomIdIndex = [result columnIndexForName:@"random_id"];
            while ([result next])
            {
                int64_t randomId = [result longLongIntForColumnIndex:randomIdIndex];
                randomIds->erase(randomId);
            }
        }
        [_database setSoftShouldCacheStatements:true];
    } synchronous:true];
}

- (int64_t)activeEncryptedPeerIdForUserId:(int)userId
{
    __block int64_t activePeerId = 0;
    
    [self dispatchOnDatabaseThread:^
    {
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE cid<=%d", _conversationListTableName, INT_MIN]];
        int maxDate = 0;
        int64_t peerIdWithMaxDate = 0;
        
        while ([result next])
        {
            TGConversation *conversation = loadConversationFromDatabase(result);
            if (conversation.chatParticipants.chatParticipantUids.count != 0)
            {
                if ([conversation.chatParticipants.chatParticipantUids[0] intValue] == userId)
                {
                    if (conversation.encryptedData.handshakeState != 3)
                    {
                        if (maxDate == 0 || conversation.date > maxDate)
                            peerIdWithMaxDate = conversation.conversationId;
                    }
                }
            }
        }
        
        activePeerId = peerIdWithMaxDate;
    } synchronous:true];
    
    return activePeerId;
}

- (bool)hasBroadcastConversations
{
    __block bool value = false;
    
    [TGDatabaseInstance() dispatchOnDatabaseThread:^
    {
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT * FROM %@ LIMIT 1", _broadcastConversationListTableName]];
        if ([result next])
            value = true;
    } synchronous:true];
    
    return value;
}

- (void)addBroadcastConversation:(NSString *)title userIds:(NSArray *)userIds completion:(void (^)(TGConversation *conversation))completion
{
    [TGDatabaseInstance() dispatchOnDatabaseThread:^
    {
        int64_t conversationId = INT_MIN;

        int localCount = 0;
        
        FMResultSet *encryptedConversationCountResult = [_database executeQuery:[NSString stringWithFormat:@"SELECT * from %@ WHERE key=?", _serviceTableName], [[NSNumber alloc] initWithInt:_serviceEncryptedConversationCount]];
        if ([encryptedConversationCountResult next])
        {
            NSData *value = [encryptedConversationCountResult dataForColumn:@"value"];
            int intValue = 0;
            [value getBytes:&intValue range:NSMakeRange(0, 4)];
            localCount = intValue;
        }
        
        conversationId = (int64_t)INT_MIN - (int64_t)localCount;
        int newCount = localCount + 1;
        
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO %@(key, value) VALUES(?, ?)", _serviceTableName], [[NSNumber alloc] initWithInt:_serviceEncryptedConversationCount], [[NSData alloc] initWithBytes:&newCount length:4]];
        
        _isConversationBroadcast[conversationId] = true;
        
        TGLog(@"===== allocated new local conversation id %lld", conversationId);
        
        TGConversation *conversation = [[TGConversation alloc] init];
        conversation.isChat = true;
        conversation.chatTitle = title;
        conversation.conversationId = conversationId;
        conversation.chatParticipantCount = (int)userIds.count;
        TGConversationParticipantsData *chatParticipants = [[TGConversationParticipantsData alloc] init];
        for (NSNumber *nUid in userIds)
        {
            [chatParticipants addParticipantWithId:[nUid intValue] invitedBy:0 date:0];
        }
        conversation.chatParticipants = chatParticipants;
        
        TGMessage *message = [[TGMessage alloc] init];
        TGActionMediaAttachment *actionMedia = [[TGActionMediaAttachment alloc] init];
        actionMedia.actionType = TGMessageActionCreateBroadcastList;
        actionMedia.actionData = @{@"title": title, @"uids": userIds};
        message.date = (int)(CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970 + _timeDifferenceFromUTC);
        message.mediaAttachments = @[actionMedia];
        
        [self addMessagesToConversation:@[message] conversationId:conversationId updateConversation:conversation dispatch:true countUnread:false];
        
        //[self actualizeConversation:conversationId dispatch:true conversation:conversation forceUpdate:true addUnreadCount:0 addServiceUnreadCount:0 keepDate:false];
        
        if (completion)
            completion(conversation);
    } synchronous:false];
}

- (int)messageLifetimeForPeerId:(int64_t)peerId
{
    int32_t result = 0;
    bool found = false;
    
    TG_SYNCHRONIZED_BEGIN(_messageLifetimeByPeerId);
    auto it = _messageLifetimeByPeerId.find(peerId);
    if (it != _messageLifetimeByPeerId.end())
    {
        result = it->second;
        found = true;
    }
    TG_SYNCHRONIZED_END(_messageLifetimeByPeerId);
    
    if (!found)
    {
        NSData *data = [self conversationCustomPropertySync:peerId name:murMurHash32(@"messageLifetime")];
        if (data != nil && data.length >= 4)
        {
            [data getBytes:&result length:4];
        }
        
        TG_SYNCHRONIZED_BEGIN(_messageLifetimeByPeerId);
        _messageLifetimeByPeerId[peerId] = result;
        TG_SYNCHRONIZED_END(_messageLifetimeByPeerId);
    }
    
    return result;
}

- (void)setMessageLifetimeForPeerId:(int64_t)peerId encryptedConversationId:(int64_t)__unused encryptedConversationId messageLifetime:(int)messageLifetime writeToActionQueue:(bool)writeToActionQueue
{
    bool updated = true;
    
    TG_SYNCHRONIZED_BEGIN(_messageLifetimeByPeerId);
    auto it = _messageLifetimeByPeerId.find(peerId);
    if (it != _messageLifetimeByPeerId.end())
    {
        if (it->second == messageLifetime)
            updated = false;
    }
    _messageLifetimeByPeerId[peerId] = messageLifetime;
    TG_SYNCHRONIZED_END(_messageLifetimeByPeerId);
    
    if (updated)
    {
        int32_t value = messageLifetime;
        [self setConversationCustomProperty:peerId name:murMurHash32(@"messageLifetime") value:[[NSData alloc] initWithBytes:&value length:4]];
        
        [self processAndScheduleSelfDestruct];
        
        [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversationMessageLifetime/(%lld)", peerId] resource:@(messageLifetime)];
    }
    
    if (writeToActionQueue)
    {
        [self dispatchOnDatabaseThread:^
        {
            int64_t randomId = 0;
            arc4random_buf(&randomId, 8);
            
            NSUInteger peerLayer = MIN([TGDatabaseInstance() peerLayer:peerId], [TGModernSendSecretMessageActor currentLayer]);
            
            NSData *messageData = [TGModernSendSecretMessageActor decryptedServiceMessageActionWithLayer:MIN(peerLayer, [TGModernSendSecretMessageActor currentLayer]) setTTL:messageLifetime randomId:randomId];
            
            if (messageData != nil)
            {
                [TGModernSendSecretMessageActor enqueueOutgoingServiceMessageForPeerId:peerId layer:peerLayer keyId:0 randomId:randomId messageData:messageData];
                
                TGMessage *message = [[TGMessage alloc] init];
                
                message.fromUid = TGTelegraphInstance.clientUserId;
                message.toUid = peerId;
                message.date = [[TGTelegramNetworking instance] approximateRemoteTime];
                message.unread = true;
                message.outgoing = true;
                message.cid = peerId;
                
                TGActionMediaAttachment *actionAttachment = [[TGActionMediaAttachment alloc] init];
                actionAttachment.actionType = TGMessageActionEncryptedChatMessageLifetime;
                actionAttachment.actionData = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithInt:messageLifetime], @"messageLifetime", nil];
                message.mediaAttachments = @[actionAttachment];
                
                static int messageActionId = 1000000;
                [[[TGConversationAddMessagesActor alloc] initWithPath:[NSString stringWithFormat:@"/tg/addmessage/(%dact)", messageActionId++]] execute:[NSDictionary dictionaryWithObjectsAndKeys:[[NSArray alloc] initWithObjects:message, nil], @"messages", nil]];
            }
        } synchronous:false];
    }
}

- (void)_filterConversationIdsByMessageLifetime:(std::map<int64_t, int> *)pMap
{
    std::vector<int64_t> unknownCids;
    
    TG_SYNCHRONIZED_BEGIN(_messageLifetimeByPeerId);
    
    for (auto it = pMap->begin(); it != pMap->end(); it++)
    {
        auto foundIt = _messageLifetimeByPeerId.find(it->first);
        if (foundIt != _messageLifetimeByPeerId.end())
        {
            if (foundIt->second == 0)
                pMap->erase(foundIt->second);
            else
                it->second = foundIt->second;
        }
        else
            unknownCids.push_back(it->first);
    }
    
    TG_SYNCHRONIZED_END(_messageLifetimeByPeerId);
    
    if (!unknownCids.empty())
    {
        for (auto it = unknownCids.begin(); it != unknownCids.end(); it++)
        {
            int messageLifetime = [self messageLifetimeForPeerId:*it];
            
            if (messageLifetime == 0)
                pMap->erase(*it);
            else
            {
                auto mapIt = pMap->find(*it);
                if (mapIt != pMap->end())
                    mapIt->second = messageLifetime;
            }
        }
    }
}

- (void)_scheduleSelfDestruct:(std::vector<std::pair<int, int> > *)pMidsWithLifetime referenceDate:(int)referenceDate
{
    NSString *selfDestructInsertQuery = [[NSString alloc] initWithFormat:@"INSERT OR IGNORE INTO %@ (mid, date) VALUES (?, ?)", _selfDestructTableName];
    
    [_database beginTransaction];
    for (auto it : *pMidsWithLifetime)
    {
        NSNumber *nDate = [[NSNumber alloc] initWithInt:referenceDate + it.second];
        [_database executeUpdate:selfDestructInsertQuery, [[NSNumber alloc] initWithInt:it.first], nDate];
    }
    [_database commit];
    
    [self processAndScheduleSelfDestruct];
}

- (void)processAndScheduleSelfDestruct
{
    [self dispatchOnDatabaseThread:^
    {
        if (_selfDestructTimer != nil)
        {
            [_selfDestructTimer invalidate];
            _selfDestructTimer = nil;
        }
        
        int currentDate = (int)(CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970 + _timeDifferenceFromUTC);
        
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT mid FROM %@ WHERE date<=?", _selfDestructTableName], [[NSNumber alloc] initWithInt:currentDate]];
        
        NSMutableArray *deleteMids = [[NSMutableArray alloc] init];
        
        int midIndex = [result columnIndexForName:@"mid"];
        
        while ([result next])
        {
            int mid = [result intForColumnIndex:midIndex];
            
            [deleteMids addObject:[[NSNumber alloc] initWithInt:mid]];
        }
        
        
        if (deleteMids.count != 0)
        {
            NSMutableDictionary *messagesByConversation = [[NSMutableDictionary alloc] init];
            [self deleteMessages:deleteMids populateActionQueue:false fillMessagesByConversationId:messagesByConversation keepDate:true populateActionQueueIfIncoming:true];
            
            [messagesByConversation enumerateKeysAndObjectsUsingBlock:^(NSNumber *nConversationId, NSArray *messagesInConversation, __unused BOOL *stop)
             {
                 [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messagesDeleted", [nConversationId longLongValue]] resource:[[SGraphObjectNode alloc] initWithObject:messagesInConversation]];
             }];
            
            [ActionStageInstance() requestActor:@"/tg/service/synchronizeactionqueue/(global)" options:nil watcher:TGTelegraphInstance];
        }
        
        FMResultSet *nextDateResult = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT MIN(date) FROM %@", _selfDestructTableName]];
        if ([nextDateResult next])
        {
            int nextDate = [nextDateResult intForColumn:@"MIN(date)"];
            if (nextDate != 0)
            {
                NSTimeInterval delay = MAX(0, nextDate - currentDate + 0.25);
#if TARGET_IPHONE_SIMULATOR
                //TGLog(@"(autodeletion timeout: %f s)", delay);
#endif
                _selfDestructTimer = [[TGTimer alloc] initWithTimeout:delay repeat:false completion:^
                {
                    [self processAndScheduleSelfDestruct];
                } queue:[self databaseQueue]];
                [_selfDestructTimer start];
            }
        }
    } synchronous:false];
}

- (void)initiateSelfDestructForMessageIds:(NSArray *)messageIds
{
    [self dispatchOnDatabaseThread:^
    {
        [_database setSoftShouldCacheStatements:false];
        NSMutableArray *messages = [[NSMutableArray alloc] init];
        NSMutableString *midsString = [[NSMutableString alloc] init];
        for (NSUInteger i = 0; i < messageIds.count; i++)
        {
            [midsString deleteCharactersInRange:NSMakeRange(0, midsString.length)];
            
            for (int j = 0; j < 256 && i < messageIds.count; j++, i++)
            {
                int32_t mid = [messageIds[i] intValue];
                
                if (j != 0)
                    [midsString appendFormat:@",%" PRId32 "", mid];
                else
                    [midsString appendFormat:@"%" PRId32 "", mid];
            }
            
            FMResultSet *resultSet = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE mid IN (%@)", _messagesTableName, midsString]];
            
            while ([resultSet next])
            {
                TGMessage *message = loadMessageFromQueryResult(resultSet);
                if (message != nil)
                    [messages addObject:message];
            }
        }
        [_database setSoftShouldCacheStatements:true];
        
        int currentDate = (int)(CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970 + _timeDifferenceFromUTC);
        NSString *selfDestructInsertQuery = [[NSString alloc] initWithFormat:@"INSERT OR IGNORE INTO %@ (mid, date) VALUES (?, ?)", _selfDestructTableName];
        
        [_database beginTransaction];
        for (TGMessage *message in messages)
        {
            if (message.messageLifetime != 0)
            {
                NSNumber *nDate = [[NSNumber alloc] initWithInt:currentDate + message.messageLifetime];
                [_database executeUpdate:selfDestructInsertQuery, [[NSNumber alloc] initWithInt:message.mid], nDate];
            }
        }
        [_database commit];
        
        [self processAndScheduleSelfDestruct];
    } synchronous:false];
}

- (NSTimeInterval)messageCountdownLocalTime:(int32_t)mid enqueueIfNotQueued:(bool)enqueueIfNotQueued initiatedCountdown:(bool *)initiatedCountdown
{
    __block NSTimeInterval countdownTime = 0.0;
    
    [self dispatchOnDatabaseThread:^
    {
        FMResultSet *messageResult = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT localMid, cid FROM %@ WHERE mid=?", _messagesTableName], @(mid)];
        if ([messageResult next])
        {
            int messageLifetime = [messageResult intForColumn:@"localMid"];
            
            FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT date FROM %@ WHERE mid=?", _selfDestructTableName], [[NSNumber alloc] initWithInt:mid]];
            if ([result next])
                countdownTime = [result intForColumn:@"date"] - messageLifetime - (kCFAbsoluteTimeIntervalSince1970 + _timeDifferenceFromUTC);
            else if (enqueueIfNotQueued)
            {
                int currentDate = (int)(CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970 + _timeDifferenceFromUTC);
                NSString *selfDestructInsertQuery = [[NSString alloc] initWithFormat:@"INSERT OR IGNORE INTO %@ (mid, date) VALUES (?, ?)", _selfDestructTableName];
                [_database executeUpdate:selfDestructInsertQuery, @(mid), @(currentDate + messageLifetime)];
                
                [self raiseSecretMessageFlagsByMessageId:mid flagsToRise:TGSecretMessageFlagViewed];
                
                [self processAndScheduleSelfDestruct];
                
                if (initiatedCountdown != NULL)
                    *initiatedCountdown = true;
                
                countdownTime = (int)(currentDate - (kCFAbsoluteTimeIntervalSince1970 + _timeDifferenceFromUTC));
                
                int64_t peerId = [messageResult longLongIntForColumn:@"cid"];
                int64_t encryptedConversationId = [self encryptedConversationIdForPeerId:peerId];
                int64_t randomId = [self randomIdForMessageId:mid];
                int64_t messageRandomId = 0;
                arc4random_buf(&messageRandomId, 8);
                
                [self storeFutureActions:@[[[TGEncryptedChatServiceAction alloc] initWithEncryptedConversationId:encryptedConversationId messageRandomId:messageRandomId action:TGEncryptedChatServiceActionViewMessage actionContext:randomId]]];
                
                [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messageFlagChanges", peerId] resource:@{@(mid): @([self secretMessageFlags:mid])}];
                [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/messageViewDateChanges"] resource:@{@(mid): @(countdownTime)}];
            }
        }
    } synchronous:true];
    
    return countdownTime;
}

- (void)raiseSecretMessageFlagsByRandomId:(int64_t)randomId flagsToRise:(int)flagsToRise
{
    [self dispatchOnDatabaseThread:^
    {
        int32_t messageId = [self messageIdForRandomId:randomId];
        if (messageId != 0)
        {
            FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT flags FROM %@ WHERE mid=?", _secretMediaAttributesTableName], @(messageId)];
            if ([result next])
            {
                int currentFlags = [result intForColumn:@"flags"];
                currentFlags |= flagsToRise;
                
                [_database executeUpdate:[[NSString alloc] initWithFormat:@"UPDATE %@ SET flags=? WHERE mid=?", _secretMediaAttributesTableName], @(currentFlags), @(messageId)];
            }
            else
            {
                [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT INTO %@ (mid, flags) VALUES (?, ?)", _secretMediaAttributesTableName], @(messageId), @(flagsToRise)];
            }
        }
    } synchronous:false];
}

- (void)raiseSecretMessageFlagsByMessageId:(int32_t)messageId flagsToRise:(int)flagsToRise
{
    [self dispatchOnDatabaseThread:^
    {
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT flags FROM %@ WHERE mid=?", _secretMediaAttributesTableName], @(messageId)];
        if ([result next])
        {
            int currentFlags = [result intForColumn:@"flags"];
            currentFlags |= flagsToRise;
            
            [_database executeUpdate:[[NSString alloc] initWithFormat:@"UPDATE %@ SET flags=? WHERE mid=?", _secretMediaAttributesTableName], @(currentFlags), @(messageId)];
        }
        else
        {
            [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT INTO %@ (mid, flags) VALUES (?, ?)", _secretMediaAttributesTableName], @(messageId), @(flagsToRise)];
        }
    } synchronous:false];
}

- (int)secretMessageFlags:(int32_t)messageId
{
    __block int messageFlags = 0;
    
    [self dispatchOnDatabaseThread:^
    {
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT flags FROM %@ WHERE mid=?", _secretMediaAttributesTableName], @(messageId)];
        if ([result next])
        {
            messageFlags = [result intForColumn:@"flags"];
        }
    } synchronous:true];
    
    return messageFlags;
}

- (void)findAllMediaMessages:(void (^)(NSArray *))completion isCancelled:(bool (^)())isCancelled
{
    [self dispatchOnDatabaseThread:^
    {
        int cancelCheckCounter = 0;
        
        NSMutableArray *messages = [[NSMutableArray alloc] init];
        
        std::set<int32_t> mids;
        
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT mids FROM %@", _storedFilesTableName]];
        int midsIndex = [result columnIndexForName:@"mids"];
        while ([result next])
        {
            NSData *midsData = [result dataForColumnIndex:midsIndex];
            int *midsPtr = (int *)[midsData bytes];
            int numMids = (int)midsData.length / 4;
            for (int i = 0; i < numMids; i++)
            {
                mids.insert(midsPtr[i]);
            }
            
            cancelCheckCounter++;
            if (cancelCheckCounter % 256 == 0)
            {
                if (isCancelled && isCancelled())
                    return;
            }
        }
        
        result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT mids FROM %@", _videosTableName]];
        midsIndex = [result columnIndexForName:@"mids"];
        while ([result next])
        {
            NSData *midsData = [result dataForColumnIndex:midsIndex];
            int *midsPtr = (int *)[midsData bytes];
            int numMids = (int)midsData.length / 4;
            for (int i = 0; i < numMids; i++)
            {
                mids.insert(midsPtr[i]);
            }
            
            cancelCheckCounter++;
            if (cancelCheckCounter % 256 == 0)
            {
                if (isCancelled && isCancelled())
                    return;
            }
        }
        
        result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT mids FROM %@", _localFilesTableName]];
        midsIndex = [result columnIndexForName:@"mids"];
        while ([result next])
        {
            NSData *midsData = [result dataForColumnIndex:midsIndex];
            int *midsPtr = (int *)[midsData bytes];
            int numMids = (int)midsData.length / 4;
            for (int i = 0; i < numMids; i++)
            {
                mids.insert(midsPtr[i]);
            }
            
            cancelCheckCounter++;
            if (cancelCheckCounter % 256 == 0)
            {
                if (isCancelled && isCancelled())
                    return;
            }
        }
        
        result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT mid FROM %@", _conversationMediaTableName]];
        int midIndex = [result columnIndexForName:@"mid"];
        while ([result next])
        {
            mids.insert([result intForColumnIndex:midIndex]);
        }
        
        [_database setSoftShouldCacheStatements:false];
        
        NSMutableString *midsString = [[NSMutableString alloc] init];
        
        for (auto it = mids.begin(); it != mids.end(); )
        {
            [midsString deleteCharactersInRange:NSMakeRange(0, midsString.length)];
            
            for (int j = 0; j < 256 && it != mids.end(); j++, it++)
            {
                int32_t mid = *it;
                
                if (j != 0)
                    [midsString appendFormat:@",%" PRId32 "", mid];
                else
                    [midsString appendFormat:@"%" PRId32 "", mid];
            }
            
            FMResultSet *resultSet = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE mid IN (%@)", _messagesTableName, midsString]];
            
            while ([resultSet next])
            {
                TGMessage *message = loadMessageFromQueryResult(resultSet);
                if (message != nil)
                    [messages addObject:message];
            }
            
            cancelCheckCounter++;
            if (cancelCheckCounter % 256 == 0)
            {
                if (isCancelled && isCancelled())
                    return;
            }
        }
        
        [_database setSoftShouldCacheStatements:true];
        
        if (completion)
            completion(messages);
    } synchronous:true];
}

typedef struct {
    int32_t messageId;
    int32_t mediaType;
    int64_t mediaId;
    int32_t date;
} TGUpdateLastUseRecord;

- (void)_updateLastUseDateRecords:(std::vector<TGUpdateLastUseRecord> const *)records
{
    [_database beginTransaction];
    
    NSString *selectQuery = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE media_type=? AND media_id=?", _mediaCacheInvalidationTableName];
    NSString *updateQuery = [[NSString alloc] initWithFormat:@"UPDATE %@ SET date=?", _mediaCacheInvalidationTableName];
    NSString *insertQuery = [[NSString alloc] initWithFormat:@"INSERT INTO %@ (date, media_type, media_id, mids) VALUES (?, ?, ?, ?)", _mediaCacheInvalidationTableName];
    
    for (auto it : *records)
    {
        FMResultSet *result = [_database executeQuery:selectQuery, @(it.mediaType), @(it.mediaId)];
        if ([result next])
        {
            NSData *midsData = [result dataForColumn:@"mids"];
            int32_t const *midPtr = (int32_t *)midsData.bytes;
            int32_t const *midsEnd = (int32_t *)(((uint8_t *)midsData.bytes) + midsData.length);
            bool foundMid = false;
            while (midPtr != midsEnd)
            {
                if (*midPtr == it.messageId)
                {
                    foundMid = true;
                    break;
                }
                midPtr++;
            }
            
            NSData *updatedMidsData = midsData;
            if (!foundMid)
            {
                updatedMidsData = [[NSMutableData alloc] initWithData:midsData];
                [(NSMutableData *)updatedMidsData appendBytes:&it.messageId length:4];
            }
            
            [_database executeUpdate:updateQuery, @(it.date)];
        }
        else
        {
            NSMutableData *midsData = [[NSMutableData alloc] initWithBytes:&it.messageId length:4];
            [_database executeUpdate:insertQuery, @(it.date), @(it.mediaType), @(it.mediaId), midsData];
        }
    }
    [_database commit];
}

- (void)updateLastUseDateForMediaType:(int32_t)mediaType mediaId:(int64_t)mediaId messageId:(int32_t)messageId
{
    [self dispatchOnDatabaseThread:^
    {
        int currentDate = (int)(CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970 + _timeDifferenceFromUTC);
        
        std::vector<TGUpdateLastUseRecord> records;
        TGUpdateLastUseRecord record = {.messageId = messageId, .mediaType = mediaType, .mediaId = mediaId, .date = currentDate};
        records.push_back(record);
        [self _updateLastUseDateRecords:&records];
        
        [self processAndScheduleMediaCleanup];
    } synchronous:false];
}

- (void)processAndScheduleMediaCleanup
{
    [self dispatchOnDatabaseThread:^
    {
        if (_mediaCleanupTimer != nil)
        {
            [_mediaCleanupTimer invalidate];
            _mediaCleanupTimer = nil;
        }
        
        int keepMediaSeconds = INT_MAX;
        NSNumber *nKeepMediaSeconds = [[NSUserDefaults standardUserDefaults] objectForKey:@"keepMediaSeconds"];
        if (nKeepMediaSeconds != nil)
            keepMediaSeconds = [nKeepMediaSeconds intValue];
        
        if (keepMediaSeconds == INT_MAX)
            return;
        
        int currentDate = (int)(CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970 + _timeDifferenceFromUTC) ;
        int removeDate = currentDate - keepMediaSeconds;
        
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE date<=?", _mediaCacheInvalidationTableName], @(removeDate)];
        
        std::vector<std::pair<int32_t, int64_t> > removeKeys;
        NSMutableArray *removeMidSets = [[NSMutableArray alloc] init];
        NSMutableSet *removedMids = [[NSMutableSet alloc] init];
        
        while ([result next])
        {
            int32_t mediaType = [result intForColumn:@"media_type"];
            int64_t mediaId = [result longLongIntForColumn:@"media_id"];
            NSData *midsData = [result dataForColumn:@"mids"];
            
            NSMutableArray *midsSet = [[NSMutableArray alloc] init];
            int32_t const *midPtr = (int32_t *)midsData.bytes;
            int32_t const *midsEnd = (int32_t *)(((uint8_t *)midsData.bytes) + midsData.length);
            while (midPtr != midsEnd)
            {
                [midsSet addObject:@(*midPtr)];
                [removedMids addObject:@(*midPtr)];
                midPtr++;
            }
            
            removeKeys.push_back(std::pair<int32_t, int64_t>(mediaType, mediaId));
            [removeMidSets addObject:midsSet];
        }
        
        NSMutableArray *removedMedias = [[NSMutableArray alloc] init];
        
        [_database beginTransaction];
        for (auto it : removeKeys)
        {
            [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE media_type=? and media_id=?", _mediaCacheInvalidationTableName], @(it.first), @(it.second)];
        }
        
        NSMutableArray *filePathsForDeletion = [[NSMutableArray alloc] init];
        
        for (NSArray *midsSet in removeMidSets)
        {
            TGMessage *foundMessage = nil;
            for (NSNumber *nMid in midsSet)
            {
                TGMessage *message = [self loadMessageWithMid:[nMid intValue] peerId:0];
                if (message != nil)
                {
                    foundMessage = message;
                    break;
                }
            }
            if (foundMessage == nil)
            {
                for (NSNumber *nMid in midsSet)
                {
                    TGMessage *message = [self loadMediaMessageWithMid:[nMid intValue]];
                    if (message != nil)
                    {
                        foundMessage = message;
                        break;
                    }
                }
            }
            
            if (foundMessage != nil)
            {
                for (id media in foundMessage.mediaAttachments)
                {
                    NSString *mediaFilePath = [self _filePathForDeletionOfMedia:media];
                    if (mediaFilePath != nil)
                        [filePathsForDeletion addObject:mediaFilePath];
                    [removedMedias addObject:media];
                }
            }
        }
        [_database commit];
        
        [self _enqueueFilesToDelete:filePathsForDeletion];
        
        if (removedMedias.count != 0)
            [ActionStageInstance() dispatchResource:@"/tg/removedMediasForMessageIds" resource:removedMids];
        
        FMResultSet *nextDateResult = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT MIN(date) FROM %@", _mediaCacheInvalidationTableName]];
        if ([nextDateResult next])
        {
            int nextDate = [nextDateResult intForColumn:@"MIN(date)"];
            if (nextDate != 0)
            {
                NSTimeInterval delay = MAX(0, nextDate + keepMediaSeconds - currentDate + 0.25);

                _mediaCleanupTimer = [[TGTimer alloc] initWithTimeout:delay repeat:false completion:^
                {
                    [self processAndScheduleMediaCleanup];
                } queue:[self databaseQueue]];
                [_mediaCleanupTimer start];
            }
        }
    } synchronous:false];
}

- (NSString *)filePathForVideoId:(int64_t)videoId local:(bool)local
{
    static NSString *videosDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        NSString *documentsDirectory = [TGAppDelegate documentsPath];
        videosDirectory = [documentsDirectory stringByAppendingPathComponent:@"video"];
    });
    
    return [videosDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%@%" PRIx64 ".mov", local ? @"local" : @"remote", videoId]];
}

- (NSString *)filePathForAudio:(TGAudioMediaAttachment *)audio
{
    NSString *filePath = nil;
    if (audio.audioId != 0)
        filePath = [TGPreparedLocalAudioMessage localAudioFilePathForRemoteAudioId1:audio.audioId];
    else
        filePath = [TGPreparedLocalAudioMessage localAudioFilePathForLocalAudioId1:audio.localAudioId];
    return filePath;
}

- (NSString *)filePathForDocument:(TGDocumentMediaAttachment *)document
{
    NSString *directory = nil;
    if (document.documentId != 0)
        directory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:document.documentId];
    else
        directory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:document.localDocumentId];
    
    NSString *filePath = [directory stringByAppendingPathComponent:[TGDocumentMediaAttachment safeFileNameForFileName:document.fileName]];
    return filePath;
}

- (void)_beginBackgroundIndexing
{
    [_backgroundFileIndexingQueue dispatch:^
    {
        TGLog(@"[TGDatabase starting background media indexing]");
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSMutableDictionary *imageFileByUrlHash = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *videoFileById = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *videoFileByLocalId = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *documentFileById = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *documentFileByLocalId = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *audioFileById = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *audioFileByLocalId = [[NSMutableDictionary alloc] init];
        
        NSString *cachesPath = [TGAppDelegate cachePath];
        for (NSURL *fileUrl in [fileManager contentsOfDirectoryAtURL:[NSURL fileURLWithPath:cachesPath] includingPropertiesForKeys:@[NSURLIsDirectoryKey, NSURLCreationDateKey] options:0 error:nil])
        {
            NSNumber *isDirectory = nil;
            if ([fileUrl getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL] && ![isDirectory boolValue])
            {
                int32_t date = 0;
                NSDate *accessDate = nil;
                [fileUrl getResourceValue:&accessDate forKey:NSURLCreationDateKey error:nil];
                date = (int32_t)[accessDate timeIntervalSince1970];
                
                NSString *filePath = [fileUrl path];
                NSString *fileName = [filePath lastPathComponent];
                
                const char *utf8Bytes = [fileName UTF8String];
                bool containsInvalidCharacters = false;
                while (*utf8Bytes != 0)
                {
                    char c = *utf8Bytes;
                    if (!((c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F')))
                    {
                        containsInvalidCharacters = true;
                        break;
                    }
                    
                    utf8Bytes++;
                }
                if (!containsInvalidCharacters)
                {
                    imageFileByUrlHash[fileName] = [[TGCacheFileDesc alloc] initWithFilePath:filePath date:date];
                }
            }
        }
        
        NSString *systemDocumentsDirectory = [TGAppDelegate documentsPath];
        
        NSString *videosDirectory = [systemDocumentsDirectory stringByAppendingPathComponent:@"video"];
        NSString *audiosDirectory = [systemDocumentsDirectory stringByAppendingPathComponent:@"audio"];
        NSString *documentsDirectory = [systemDocumentsDirectory stringByAppendingPathComponent:@"files"];
        
        for (NSURL *fileUrl in [fileManager contentsOfDirectoryAtURL:[NSURL fileURLWithPath:videosDirectory] includingPropertiesForKeys:@[NSURLIsDirectoryKey, NSURLCreationDateKey] options:0 error:nil])
        {
            NSNumber *isDirectory = nil;
            if ([fileUrl getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL] && ![isDirectory boolValue])
            {
                int32_t date = 0;
                NSDate *accessDate = nil;
                [fileUrl getResourceValue:&accessDate forKey:NSURLCreationDateKey error:nil];
                date = (int32_t)[accessDate timeIntervalSince1970];
                
                NSString *filePath = [fileUrl path];
                NSString *fileName = [filePath lastPathComponent];
                bool hasSuffixMov = [fileName hasSuffix:@".mov"];
                bool hasSuffixMovparts = [fileName hasSuffix:@".mov.parts"];
                if (hasSuffixMov || hasSuffixMovparts)
                {
                    int suffixLength = hasSuffixMov ? 4 : 10;
                    if ([fileName hasPrefix:@"remote"])
                    {
                        NSScanner *scanner = [[NSScanner alloc] initWithString:[fileName substringWithRange:NSMakeRange(6, fileName.length - suffixLength - 6)]];
                        long long videoId = 0;
                        [scanner scanHexLongLong:(unsigned long long *)&videoId];
                        
                        if (videoId != 0)
                            videoFileById[@((int64_t)videoId)] = [[TGCacheFileDesc alloc] initWithFilePath:filePath date:date];
                    }
                    else if ([fileName hasPrefix:@"local"])
                    {
                        NSScanner *scanner = [[NSScanner alloc] initWithString:[fileName substringWithRange:NSMakeRange(5, fileName.length - suffixLength - 5)]];
                        long long localVideoId = 0;
                        [scanner scanHexLongLong:(unsigned long long *)&localVideoId];
                        
                        if (localVideoId != 0)
                            videoFileByLocalId[@((int64_t)localVideoId)] = [[TGCacheFileDesc alloc] initWithFilePath:filePath date:date];
                    }
                }
            }
        }
        
        for (NSURL *fileUrl in [fileManager contentsOfDirectoryAtURL:[NSURL fileURLWithPath:audiosDirectory] includingPropertiesForKeys:@[NSURLIsDirectoryKey, NSURLCreationDateKey] options:0 error:nil])
        {
            NSNumber *isDirectory = nil;
            if ([fileUrl getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL] && [isDirectory boolValue])
            {
                int32_t date = 0;
                NSDate *accessDate = nil;
                [fileUrl getResourceValue:&accessDate forKey:NSURLCreationDateKey error:nil];
                date = (int32_t)[accessDate timeIntervalSince1970];
                
                NSString *filePath = [fileUrl path];
                NSString *fileName = [filePath lastPathComponent];
                if ([fileName hasPrefix:@"local"])
                {
                    NSScanner *scanner = [[NSScanner alloc] initWithString:[fileName substringFromIndex:5]];
                    long long localAudioId = 0;
                    [scanner scanHexLongLong:(unsigned long long *)&localAudioId];
                    
                    if (localAudioId != 0)
                        audioFileByLocalId[@((int64_t)localAudioId)] = [[TGCacheFileDesc alloc] initWithFilePath:filePath date:date];
                }
                else
                {
                    NSScanner *scanner = [[NSScanner alloc] initWithString:fileName];
                    long long audioId = 0;
                    [scanner scanHexLongLong:(unsigned long long *)&audioId];
                    
                    if (audioId != 0)
                        audioFileById[@((int64_t)audioId)] = [[TGCacheFileDesc alloc] initWithFilePath:filePath date:date];
                }
            }
        }
        
        for (NSURL *fileUrl in [fileManager contentsOfDirectoryAtURL:[NSURL fileURLWithPath:documentsDirectory] includingPropertiesForKeys:@[NSURLIsDirectoryKey, NSURLCreationDateKey] options:0 error:nil])
        {
            NSNumber *isDirectory = nil;
            if ([fileUrl getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL] && [isDirectory boolValue])
            {
                int32_t date = 0;
                NSDate *accessDate = nil;
                [fileUrl getResourceValue:&accessDate forKey:NSURLCreationDateKey error:nil];
                date = (int32_t)[accessDate timeIntervalSince1970];
                
                NSString *filePath = [fileUrl path];
                NSString *fileName = [filePath lastPathComponent];
                if ([fileName hasPrefix:@"local"])
                {
                    NSScanner *scanner = [[NSScanner alloc] initWithString:[fileName substringFromIndex:5]];
                    long long localDocumentId = 0;
                    [scanner scanHexLongLong:(unsigned long long *)&localDocumentId];
                    
                    if (localDocumentId != 0)
                        documentFileByLocalId[@((int64_t)localDocumentId)] = [[TGCacheFileDesc alloc] initWithFilePath:filePath date:date];
                }
                else
                {
                    NSScanner *scanner = [[NSScanner alloc] initWithString:fileName];
                    long long documentId = 0;
                    [scanner scanHexLongLong:(unsigned long long *)&documentId];
                    
                    if (documentId != 0)
                        documentFileById[@((int64_t)documentId)] = [[TGCacheFileDesc alloc] initWithFilePath:filePath date:date];
                }
            }
        }
        
        NSMutableArray *mediaDataList = [[NSMutableArray alloc] init];
        
        TGLog(@"[TGDatabase starting media extraction]");
        
        int counter = 0;
        __block int32_t lastMid = INT_MAX;
        while (true)
        {
            counter++;
            
            int currentMid = lastMid;
            [self dispatchOnDatabaseThread:^
            {
                FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT mid, media, cid FROM %@ WHERE mid < ? ORDER BY mid DESC LIMIT 512", _messagesTableName], @(lastMid)];
                int midIndex = [result columnIndexForName:@"mid"];
                int dataIndex = [result columnIndexForName:@"media"];
                int cidIndex = [result columnIndexForName:@"cid"];
                while ([result next])
                {
                    int32_t mid = [result intForColumnIndex:midIndex];
                    int64_t peerId = [result longLongIntForColumnIndex:cidIndex];
                    
                    NSData *mediaData = [result dataForColumnIndex:dataIndex];
                    if (mediaData.length != 0)
                    {
                        [mediaDataList addObject:[[TGMediaDataDesc alloc] initWithMessageId:mid mediaData:mediaData peerId:peerId]];
                    }
                    
                    lastMid = mid;
                }
            } synchronous:true];
            
            if (lastMid == currentMid)
                break;
            
            usleep(20 * 1000);
        }
        
        TGLog(@"[TGDatabase completed media extraction in %d passes]", counter);
        
        TGLog(@"[TGDatabase starting avatar extraction]");
        
        NSMutableSet *activeAvatarUrls = [[NSMutableSet alloc] init];
        
        counter = 0;
        __block int32_t lastUid = INT_MAX;
        while (true)
        {
            counter++;
            
            int currentUid = lastUid;
            [self dispatchOnDatabaseThread:^
            {
                FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT uid, photo_small, photo_big FROM %@ WHERE uid < ? ORDER BY uid DESC LIMIT 512", _usersTableName], @(lastUid)];
                int uidIndex = [result columnIndexForName:@"uid"];
                int photoSmallIndex = [result columnIndexForName:@"photo_small"];
                int photoBigIndex = [result columnIndexForName:@"photo_big"];
                while ([result next])
                {
                    int32_t uid = [result intForColumnIndex:uidIndex];
                    NSString *photoSmall = [result stringForColumnIndex:photoSmallIndex];
                    NSString *photoBig = [result stringForColumnIndex:photoBigIndex];
                    
                    if (photoSmall.length != 0)
                        [activeAvatarUrls addObject:photoSmall];
                    if (photoBig.length != 0)
                        [activeAvatarUrls addObject:photoBig];
                    
                    lastUid = uid;
                }
            } synchronous:true];
            
            if (lastUid == currentUid)
                break;
            
            usleep(20 * 1000);
        }
        
        counter = 0;
        __block int64_t lastPeerId = 0;
        while (true)
        {
            counter++;
            
            int64_t currentPeerId = lastPeerId;
            [self dispatchOnDatabaseThread:^
             {
                 FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT cid, chat_photo FROM %@ WHERE cid < ? AND cid > ? ORDER BY cid DESC LIMIT 512", _conversationListTableName], @(lastPeerId), @(INT_MIN)];
                 int cidIndex = [result columnIndexForName:@"cid"];
                 int photoIndex = [result columnIndexForName:@"chat_photo"];
                 TGConversation *tmpConversation = [[TGConversation alloc] init];
                 while ([result next])
                 {
                     int64_t cid = [result longLongIntForColumnIndex:cidIndex];
                     NSData *photoData = [result dataForColumnIndex:photoIndex];
                     [tmpConversation deserializeChatPhoto:photoData];
                     
                     if (tmpConversation.chatPhotoSmall.length != 0)
                         [activeAvatarUrls addObject:tmpConversation.chatPhotoSmall];
                     if (tmpConversation.chatPhotoBig.length != 0)
                         [activeAvatarUrls addObject:tmpConversation.chatPhotoBig];
                     
                     lastPeerId = cid;
                 }
             } synchronous:true];
            
            if (lastPeerId == currentPeerId)
                break;
            
            usleep(20 * 1000);
        }
        
        TGLog(@"[TGDatabase completed avatar extraction in %d passes]", counter);
        
        std::vector<std::pair<NSString *, NSString *> > immediatelyDeleteFiles;
        
        std::vector<TGUpdateLastUseRecord> updateLastUseRecords;
        
        for (TGMediaDataDesc *mediaData in mediaDataList)
        {
            for (id media in [TGMessage parseMediaAttachments:mediaData.mediaData])
            {
                if ([media isKindOfClass:[TGImageMediaAttachment class]])
                {
                    NSString *url = [((TGImageMediaAttachment *)media).imageInfo imageUrlForLargestSize:NULL];
                    NSString *urlHash = md5String(url);
                    if (urlHash != nil)
                    {
                        TGCacheFileDesc *desc = imageFileByUrlHash[urlHash];
                        if (desc != nil)
                        {
                            [imageFileByUrlHash removeObjectForKey:urlHash];
                            
                            if (((TGImageMediaAttachment *)media).imageId != 0)
                            {
                                TGUpdateLastUseRecord record = {.messageId = mediaData.messageId, .mediaType = 2, .mediaId = ((TGImageMediaAttachment *)media).imageId, .date = desc.date};
                                updateLastUseRecords.push_back(record);
                            }
                        }
                    }
                }
                else if ([media isKindOfClass:[TGLocationMediaAttachment class]])
                {
                    //TODO:
                }
                else if ([media isKindOfClass:[TGVideoMediaAttachment class]])
                {
                    TGVideoMediaAttachment *videoAttachment = media;
                    TGCacheFileDesc *desc = nil;
                    if (videoAttachment.videoId != 0)
                    {
                        desc = videoFileById[@(videoAttachment.videoId)];
                        if (desc != nil)
                            [videoFileById removeObjectForKey:@(videoAttachment.videoId)];
                    }
                    else
                    {
                        desc = videoFileByLocalId[@(videoAttachment.localVideoId)];
                        if (desc != nil)
                            [videoFileByLocalId removeObjectForKey:@(videoAttachment.localVideoId)];
                    }
                    if (desc != nil)
                    {
                        if (videoAttachment.videoId != 0)
                        {
                            TGUpdateLastUseRecord record = {.messageId = mediaData.messageId, .mediaType = 1, .mediaId = videoAttachment.videoId != 0 ? videoAttachment.videoId : videoAttachment.localVideoId, .date = desc.date};
                            updateLastUseRecords.push_back(record);
                        }
                    }
                }
                else if ([media isKindOfClass:[TGAudioMediaAttachment class]])
                {
                    TGAudioMediaAttachment *audioAttachment = media;
                    TGCacheFileDesc *desc = nil;
                    if (audioAttachment.audioId != 0)
                    {
                        desc = audioFileById[@(audioAttachment.audioId)];
                        if (desc != nil)
                            [audioFileById removeObjectForKey:@(audioAttachment.audioId)];
                    }
                    else
                    {
                        desc = audioFileByLocalId[@(audioAttachment.localAudioId)];
                        if (desc != nil)
                            [audioFileByLocalId removeObjectForKey:@(audioAttachment.localAudioId)];
                    }
                    if (desc != nil)
                    {
                        if (audioAttachment.audioId != 0)
                        {
                            TGUpdateLastUseRecord record = {.messageId = mediaData.messageId, .mediaType = 4, .mediaId = audioAttachment.audioId != 0 ? audioAttachment.audioId : audioAttachment.localAudioId, .date = desc.date};
                            updateLastUseRecords.push_back(record);
                        }
                    }
                }
                else if ([media isKindOfClass:[TGDocumentMediaAttachment class]])
                {
                    TGDocumentMediaAttachment *documentAttachment = media;
                    TGCacheFileDesc *desc = nil;
                    if (documentAttachment.documentId != 0)
                    {
                        desc = documentFileById[@(documentAttachment.documentId)];
                        if (desc != nil)
                            [documentFileById removeObjectForKey:@(documentAttachment.documentId)];
                    }
                    else
                    {
                        desc = documentFileByLocalId[@(documentAttachment.localDocumentId)];
                        if (desc != nil)
                            [documentFileByLocalId removeObjectForKey:@(documentAttachment.localDocumentId)];
                    }
                    
                    NSString *thumbnailUrl = [documentAttachment.thumbnailInfo imageUrlForLargestSize:NULL];
                    if (thumbnailUrl.length != 0)
                        [imageFileByUrlHash removeObjectForKey:md5String(thumbnailUrl)];
                    
                    if (desc != nil)
                    {
                        if (documentAttachment.documentId != 0)
                        {
                            TGUpdateLastUseRecord record = {.messageId = mediaData.messageId, .mediaType = 3, .mediaId = documentAttachment.documentId != 0 ? documentAttachment.documentId : documentAttachment.localDocumentId, .date = desc.date};
                            updateLastUseRecords.push_back(record);
                        }
                    }
                }
            }
        }
        
        [activeAvatarUrls enumerateObjectsUsingBlock:^(NSString *url, __unused BOOL *stop)
        {
            NSString *urlHash = md5String(url);
            [imageFileByUrlHash removeObjectForKey:urlHash];
        }];
        
        TGLog(@"[TGDatabase starting last use date updates for %d records]", (int)updateLastUseRecords.size());
        
        auto it = updateLastUseRecords.begin();
        while (it != updateLastUseRecords.end())
        {
            std::vector<TGUpdateLastUseRecord> currentSet;
            auto *pCurrentSet = &currentSet;
            for (int i = 0; i < 512 && it != updateLastUseRecords.end(); i++, it++)
            {
                currentSet.push_back(*it);
            }
            
            if (!currentSet.empty())
            {
                [self dispatchOnDatabaseThread:^
                {
                    [self _updateLastUseDateRecords:pCurrentSet];
                } synchronous:true];
            }
        }
        
        TGLog(@"[TGDatabase completed last use date updates]");
        
        NSMutableArray *unreferencedFiles = [[NSMutableArray alloc] init];
        [unreferencedFiles addObjectsFromArray:[imageFileByUrlHash allValues]];
        [unreferencedFiles addObjectsFromArray:[videoFileById allValues]];
        [unreferencedFiles addObjectsFromArray:[videoFileByLocalId allValues]];
        [unreferencedFiles addObjectsFromArray:[documentFileById allValues]];
        [unreferencedFiles addObjectsFromArray:[documentFileByLocalId allValues]];
        [unreferencedFiles addObjectsFromArray:[audioFileById allValues]];
        [unreferencedFiles addObjectsFromArray:[audioFileByLocalId allValues]];
        
        TGLog(@"[TGDatabase scheduling %d unreferenced files for deletion]", unreferencedFiles.count);
        NSUInteger unreferencedCounter = 0;
        while (unreferencedCounter < unreferencedFiles.count)
        {
            NSMutableArray *filePathsSet = [[NSMutableArray alloc] init];
            for (int i = 0; i < 512 && unreferencedCounter < unreferencedFiles.count; i++, unreferencedCounter++)
            {
                [filePathsSet addObject:((TGCacheFileDesc *)unreferencedFiles[unreferencedCounter]).filePath];
            }
            
            [self _enqueueFilesToDelete:filePathsSet];
        }
        
        TGLog(@"[TGDatabase completed background media indexing]");
        int32_t one = 1;
        [self setCustomProperty:@"backgroundMediaIndexingCompleted" value:[NSData dataWithBytes:&one length:4]];
        
        [self processAndScheduleMediaCleanup];
    }];
}

- (void)_enqueueFilesToDelete:(NSArray *)filesToDelete
{
    [self dispatchOnDatabaseThread:^
    {
        [_database beginTransaction];
        
        NSString *insertQuery = [[NSString alloc] initWithFormat:@"INSERT OR IGNORE INTO %@ (hash0, hash1, path) VALUES (?, ?, ?)", _fileDeletionTableName];
        
        for (NSString *filePath in filesToDelete)
        {
            const char *ptr = [filePath UTF8String];
            unsigned char md5Buffer[16];
            CC_MD5(ptr, (CC_LONG)[filePath lengthOfBytesUsingEncoding:NSUTF8StringEncoding], md5Buffer);
            
            int64_t hash0 = *((int64_t *)md5Buffer);
            int64_t hash1 = *((int64_t *)(md5Buffer + 8));
            
            [_database executeUpdate:insertQuery, @(hash0), @(hash1), filePath];
        }
        
        [_database commit];
        
        [self _processDeletionQueue];
    } synchronous:false];
}

- (void)_processDeletionQueue
{
    [self dispatchOnDatabaseThread:^
    {
        if (_deletionInProgress)
            return;
        
        [_deletionTickTimer invalidate];
        _deletionTickTimer = nil;
        
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT * FROM %@ LIMIT 128", _fileDeletionTableName]];
        NSMutableArray *deleteFiles = [[NSMutableArray alloc] init];
        while ([result next])
        {
            int64_t hash0 = [result longLongIntForColumn:@"hash0"];
            int64_t hash1 = [result longLongIntForColumn:@"hash1"];
            NSString *filePath = [result stringForColumn:@"path"];
            
            [deleteFiles addObject:[[TGDeleteFileDesc alloc] initWithHash0:hash0 hash1:hash1 filePath:filePath]];
        }
        
        if (deleteFiles.count != 0)
        {
            _deletionInProgress = true;
            
            [_fileDeletionQueue dispatch:^
            {
                NSFileManager *fileManager = [NSFileManager defaultManager];
                for (TGDeleteFileDesc *desc in deleteFiles)
                {
#ifdef DEBUG
                    TGLog(@"Delete: %@", desc.filePath);
#endif
                    [fileManager removeItemAtPath:desc.filePath error:nil];
                    [fileManager removeItemAtPath:[desc.filePath stringByAppendingString:@""] error:nil];
                }
                
                [self dispatchOnDatabaseThread:^
                {
                    NSString *queryString = [[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE hash0=? AND hash1=?", _fileDeletionTableName];
                    [_database beginTransaction];
                    for (TGDeleteFileDesc *desc in deleteFiles)
                    {
                        [_database executeUpdate:queryString, @(desc.hash0), @(desc.hash1)];
                    }
                    [_database commit];
                    
                    _deletionTickTimer = [[TGTimer alloc] initWithTimeout:0.1 repeat:false completion:^
                    {
                        _deletionInProgress = false;
                        [self _processDeletionQueue];
                    } queue:[self databaseQueue]];
                    [_deletionTickTimer start];
                } synchronous:false];
            }];
        }
    } synchronous:false];
}

- (NSString *)_filePathForDeletionOfMedia:(id)media
{
    if ([media isKindOfClass:[TGImageMediaAttachment class]])
    {
        TGImageMediaAttachment *imageAttachment = media;
        NSString *url = [imageAttachment.imageInfo imageUrlForLargestSize:NULL];
        NSString *path = [[TGRemoteImageView sharedCache] pathForCachedData:url];
        return path;
    }
    else if ([media isKindOfClass:[TGVideoMediaAttachment class]])
    {
        TGVideoMediaAttachment *videoAttachment = media;
        NSString *filePath = [self filePathForVideoId:videoAttachment.videoId != 0 ? videoAttachment.videoId : videoAttachment.localVideoId local:videoAttachment.videoId == 0];
        return filePath;
    }
    else if ([media isKindOfClass:[TGAudioMediaAttachment class]])
    {
        TGAudioMediaAttachment *audioAttachment = media;
        NSString *filePath = [self filePathForAudio:audioAttachment];
        return filePath;
    }
    else if ([media isKindOfClass:[TGDocumentMediaAttachment class]])
    {
        TGDocumentMediaAttachment *documentAttachment = media;
        NSString *filePath = [self filePathForDocument:documentAttachment];
        return filePath;
    }
    
    return nil;
}

- (void)setLastReportedToPeerLayer:(int64_t)peerId layer:(NSUInteger)layer
{
    bool updated = false;
    TG_SYNCHRONIZED_BEGIN(_lastReportedToPeerLayers);
    auto it = _lastReportedToPeerLayers.find(peerId);
    if (it == _lastReportedToPeerLayers.end() || it->second != layer)
        updated = true;
    _lastReportedToPeerLayers[peerId] = layer;
    TG_SYNCHRONIZED_END(_lastReportedToPeerLayers);
    
    if (updated)
    {
        [self dispatchOnDatabaseThread:^
        {
            int32_t localLayer = (int32_t)layer;
            [self setConversationCustomProperty:peerId name:reportedLayer_hash value:[[NSData alloc] initWithBytes:(const void *)&localLayer length:4]];
        } synchronous:false];
    }
}

- (NSUInteger)lastReportedToPeerLayer:(int64_t)peerId
{
    __block NSUInteger result = 1;
    bool found = false;
    TG_SYNCHRONIZED_BEGIN(_lastReportedToPeerLayers);
    auto it = _lastReportedToPeerLayers.find(peerId);
    if (it != _lastReportedToPeerLayers.end())
    {
        found = true;
        result = it->second;
    }
    TG_SYNCHRONIZED_END(_lastReportedToPeerLayers);
    
    if (!found)
    {
        [self dispatchOnDatabaseThread:^
        {
            NSData *data = [self conversationCustomPropertySync:peerId name:reportedLayer_hash];
            if (data.length < 4)
                result = 1;
            else
            {
                int32_t localResult = 0;
                [data getBytes:&localResult length:4];
                result = (NSUInteger)localResult;
            }
        } synchronous:true];
    }
    
    TG_SYNCHRONIZED_BEGIN(_lastReportedToPeerLayers);
    _lastReportedToPeerLayers[peerId] = result;
    TG_SYNCHRONIZED_END(_lastReportedToPeerLayers);
    
    return result;
}

- (void)setPeerLayer:(int64_t)peerId layer:(NSUInteger)layer
{
    bool updated = false;
    TG_SYNCHRONIZED_BEGIN(_peerLayers);
    auto it = _peerLayers.find(peerId);
    if (it == _peerLayers.end() || it->second != layer)
        updated = true;
    _peerLayers[peerId] = layer;
    TG_SYNCHRONIZED_END(_peerLayers);
    
    if (updated)
    {
        [self dispatchOnDatabaseThread:^
        {
            int32_t localLayer = (int32_t)layer;
            [self setConversationCustomProperty:peerId name:layer_hash value:[[NSData alloc] initWithBytes:(const void *)&localLayer length:4]];
        } synchronous:false];
    }
}

- (NSUInteger)peerLayer:(int64_t)peerId
{
    __block NSUInteger result = 1;
    bool found = false;
    TG_SYNCHRONIZED_BEGIN(_peerLayers);
    auto it = _peerLayers.find(peerId);
    if (it != _peerLayers.end())
    {
        found = true;
        result = it->second;
    }
    TG_SYNCHRONIZED_END(_peerLayers);
    
    if (!found)
    {
        [self dispatchOnDatabaseThread:^
        {
            NSData *data = [self conversationCustomPropertySync:peerId name:layer_hash];
            if (data.length < 4)
                result = 1;
            else
            {
                int32_t localResult = 0;
                [data getBytes:&localResult length:4];
                result = (NSUInteger)localResult;
            }
        } synchronous:true];
    }
    
    TG_SYNCHRONIZED_BEGIN(_peerLayers);
    _peerLayers[peerId] = result;
    TG_SYNCHRONIZED_END(_peerLayers);
    
    return result;
}

- (void)loadAllSercretChatPeerIds:(void (^)(NSArray *))completion
{
    [self dispatchOnDatabaseThread:^
    {
        NSMutableArray *peerIds = [[NSMutableArray alloc] init];
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT cid FROM %@ WHERE cid<=%d ORDER BY cid DESC", _conversationListTableName, INT_MIN]];
        int cidIndex = [result columnIndexForName:@"cid"];
        while ([result next])
        {
            int64_t peerId = [result longLongIntForColumnIndex:cidIndex];
            [peerIds addObject:[[NSNumber alloc] initWithLongLong:peerId]];
        }
        if (completion)
            completion(peerIds);
    } synchronous:false];
}

- (void)peersWithOutgoingAndIncomingActions:(void (^)(NSArray *, NSArray *))completion
{
    [self dispatchOnDatabaseThread:^
    {
        NSMutableSet *outgoingPeerIds = [[NSMutableSet alloc] init];
        NSMutableSet *incomingPeerIds = [[NSMutableSet alloc] init];
        
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT DISTINCT peer_id FROM %@", _secretPeerOutgoingTableName]];
        while ([result next])
        {
            [outgoingPeerIds addObject:@([result longLongIntForColumn:@"peer_id"])];
        }
        
        result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT DISTINCT peer_id FROM %@", _secretPeerOutgoingResendTableName]];
        while ([result next])
        {
            [outgoingPeerIds addObject:@([result longLongIntForColumn:@"peer_id"])];
        }
        
        result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT DISTINCT peer_id FROM %@", _secretPeerIncomingTableName]];
        while ([result next])
        {
            [incomingPeerIds addObject:@([result longLongIntForColumn:@"peer_id"])];
        }
        
        result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT DISTINCT peer_id FROM %@", _secretPeerIncomingEncryptedTableName]];
        while ([result next])
        {
            NSNumber *nPeerId = @([result longLongIntForColumn:@"peer_id"]);
            if (![incomingPeerIds containsObject:nPeerId])
                [incomingPeerIds addObject:nPeerId];
        }
        
        if (completion)
            completion([outgoingPeerIds allObjects], [incomingPeerIds allObjects]);
    } synchronous:false];
}

- (int32_t)peerNextSeqOut:(int64_t)peerId
{
    __block int32_t blockSeqOut = 0;
    
    [self dispatchOnDatabaseThread:^
    {
        NSData *seqOutData = [self conversationCustomPropertySync:peerId name:seq_out_hash];
        if (seqOutData.length == 4)
        {
            int32_t value = 0;
            [seqOutData getBytes:&value length:4];
            blockSeqOut = value + 1;
        }
    } synchronous:true];
    
    return blockSeqOut;
}

- (void)enqueuePeerOutgoingAction:(int64_t)peerId action:(id<PSCoding>)action useSeq:(bool)useSeq seqOut:(int32_t *)seqOut seqIn:(int32_t *)seqIn actionId:(int32_t *)actionId
{
    __block int32_t blockSeqIn = 0;
    __block int32_t blockSeqOut = 0;
    __block int32_t blockActionId = 0;
    
    [self dispatchOnDatabaseThread:^
    {
        [_database beginTransaction];
        if (useSeq)
        {
            NSData *seqOutData = [self conversationCustomPropertySync:peerId name:seq_out_hash];
            NSData *seqInData = [self conversationCustomPropertySync:peerId name:seq_in_hash];
            if (seqOutData.length == 4)
            {
                int32_t value = 0;
                [seqOutData getBytes:&value length:4];
                blockSeqOut = value + 1;
            }
            if (seqInData.length == 4)
            {
                int32_t value = 0;
                [seqInData getBytes:&value length:4];
                blockSeqIn = value;
            }
            
            [self setConversationCustomProperty:peerId name:seq_out_hash value:[[NSData alloc] initWithBytes:&blockSeqOut length:4]];
        }
        
        PSKeyValueEncoder *encoder = [[PSKeyValueEncoder alloc] init];
        [encoder encodeObject:action forCKey:"action"];
        NSData *data = [encoder data];
        
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT INTO %@ (peer_id, seq_out, seq_in, data) VALUES (?, ?, ?, ?)", _secretPeerOutgoingTableName], @(peerId), @(blockSeqOut), @(blockSeqIn), data];
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT MAX(rowid) FROM %@", _secretPeerOutgoingTableName]];
        if ([result next])
            blockActionId = [result intForColumn:@"MAX(rowid)"];
        [_database commit];
    } synchronous:true];
    
    if (seqOut)
        *seqOut = blockSeqOut;
    if (seqIn)
        *seqIn = blockSeqIn;
    if (actionId)
        *actionId = blockActionId;
}

- (void)dequeuePeerOutgoingActions:(int64_t)peerId completion:(void (^)(NSArray *, NSArray *))completion
{
    [self dispatchOnDatabaseThread:^
    {
        NSMutableArray *actions = [[NSMutableArray alloc] init];
        NSArray *resendActions = [self _dequeuePeerOutgoingResendActions:peerId];
        
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE peer_id=? ORDER BY action_id ASC", _secretPeerOutgoingTableName], @(peerId)];
        int32_t sentSeqOut = [self currentPeerSentSeqOut:peerId];
        if ([self peerLayer:peerId] < 17)
            sentSeqOut = -1;
        PSKeyValueDecoder *decoder = [[PSKeyValueDecoder alloc] init];
        while ([result next])
        {
            int32_t seqOut = (int32_t)[result intForColumn:@"seq_out"];
            if (seqOut > sentSeqOut)
            {
                int32_t actionId = (int32_t)[result intForColumn:@"action_id"];
                
                int32_t seqIn = (int32_t)[result intForColumn:@"seq_in"];
                NSData *data = [result dataForColumn:@"data"];
                [decoder resetData:data];
                
                id<PSCoding> action = [decoder decodeObjectForCKey:"action"];
                [actions addObject:[[TGStoredSecretActionWithSeq alloc] initWithActionId:TGStoredSecretActionWithSeqActionIdMake(TGStoredSecretActionWithSeqActionIdGeneric, actionId) action:action seqIn:seqIn seqOut:seqOut]];
            }
        }
        
        if (completion)
            completion(actions, resendActions);
    } synchronous:false];
}

- (void)_enqueuePeerOutgoingResendActions:(int64_t)peerId actions:(NSArray *)actions
{
    for (TGStoredSecretActionWithSeq *action in actions)
    {
        PSKeyValueEncoder *encoder = [[PSKeyValueEncoder alloc] init];
        [encoder encodeObject:action.action forCKey:"action"];
        NSData *data = [encoder data];
        
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT INTO %@ (peer_id, seq_out, seq_in, data) VALUES (?, ?, ?, ?)", _secretPeerOutgoingResendTableName], @(peerId), @(action.seqOut), @(action.seqIn), data];
    }
}

- (NSArray *)_dequeuePeerOutgoingResendActions:(int64_t)peerId
{
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    
    FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE peer_id=? ORDER BY action_id ASC", _secretPeerOutgoingResendTableName], @(peerId)];
    PSKeyValueDecoder *decoder = [[PSKeyValueDecoder alloc] init];
    while ([result next])
    {
        int32_t seqOut = (int32_t)[result intForColumn:@"seq_out"];
        int32_t actionId = (int32_t)[result intForColumn:@"action_id"];
        
        int32_t seqIn = (int32_t)[result intForColumn:@"seq_in"];
        NSData *data = [result dataForColumn:@"data"];
        [decoder resetData:data];
        
        id<PSCoding> action = [decoder decodeObjectForCKey:"action"];
        [actions addObject:[[TGStoredSecretActionWithSeq alloc] initWithActionId:TGStoredSecretActionWithSeqActionIdMake(TGStoredSecretActionWithSeqActionIdGeneric, actionId) action:action seqIn:seqIn seqOut:seqOut]];
    }

    return actions;
}

- (void)deletePeerOutgoingResendActions:(int64_t)peerId actionIds:(NSArray *)actionIds
{
    [self dispatchOnDatabaseThread:^
    {
        NSMutableString *actionIdsString = [[NSMutableString alloc] init];
        for (NSNumber *nActionId in actionIds)
        {
            if (actionIdsString.length == 0)
                [actionIdsString appendFormat:@"%d", [nActionId intValue]];
            else
                [actionIdsString appendFormat:@",%d", [nActionId intValue]];
        }
        
        [_database setSoftShouldCacheStatements:false];
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE peer_id=? AND action_id IN (%@)", _secretPeerOutgoingResendTableName, actionIdsString], @(peerId)];
        [_database setSoftShouldCacheStatements:true];
    } synchronous:false];
}

- (void)enqueuePeerOutgoingResendActions:(int64_t)peerId fromSeq:(int32_t)fromSeq toSeq:(int32_t)toSeq completion:(void (^)(bool))completion
{
    [self dispatchOnDatabaseThread:^
    {
        NSMutableArray *actions = [[NSMutableArray alloc] init];
        
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE peer_id=? AND seq_out>=? AND seq_out<=? ORDER BY seq_out ASC", _secretPeerOutgoingTableName], @(peerId), @(fromSeq), @(toSeq)];
        NSMutableSet *indices = [[NSMutableSet alloc] init];
        for (int32_t seq = fromSeq; seq <= toSeq; seq++)
        {
            [indices addObject:@(seq)];
        }
        PSKeyValueDecoder *decoder = [[PSKeyValueDecoder alloc] init];
        while ([result next])
        {
            int32_t seqOut = (int32_t)[result intForColumn:@"seq_out"];
            int32_t actionId = (int32_t)[result intForColumn:@"action_id"];
            
            int32_t seqIn = (int32_t)[result intForColumn:@"seq_in"];
            NSData *data = [result dataForColumn:@"data"];
            [decoder resetData:data];
            
            id<PSCoding> action = [decoder decodeObjectForCKey:"action"];
            [actions addObject:[[TGStoredSecretActionWithSeq alloc] initWithActionId:TGStoredSecretActionWithSeqActionIdMake(TGStoredSecretActionWithSeqActionIdGeneric, actionId) action:action seqIn:seqIn seqOut:seqOut]];
            [indices removeObject:@(seqOut)];
        }
        
        [self _enqueuePeerOutgoingResendActions:peerId actions:actions];
        
        if (completion)
            completion(indices.count == 0);
    } synchronous:false];
}

- (void)deletePeerOutgoingActions:(int64_t)peerId actionIds:(NSArray *)actionIds
{
    [self dispatchOnDatabaseThread:^
    {
        NSMutableString *actionIdsString = [[NSMutableString alloc] init];
        for (NSNumber *nActionId in actionIds)
        {
            if (actionIdsString.length == 0)
                [actionIdsString appendFormat:@"%d", [nActionId intValue]];
            else
                [actionIdsString appendFormat:@",%d", [nActionId intValue]];
        }
        
        [_database setSoftShouldCacheStatements:false];
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE peer_id=? AND action_id IN (%@)", _secretPeerOutgoingTableName, actionIdsString], @(peerId)];
        [_database setSoftShouldCacheStatements:true];
    } synchronous:false];
}

- (void)enqueuePeerIncomingActions:(int64_t)peerId actions:(NSArray *)actions
{
    [self dispatchOnDatabaseThread:^
    {
        PSKeyValueEncoder *encoder = [[PSKeyValueEncoder alloc] init];
        
        for (TGStoredSecretIncomingActionWithSeq *action in actions)
        {
            [encoder reset];
            [encoder encodeObject:action.action forCKey:"action"];
            NSData *data = [encoder data];
            [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO %@ (peer_id, seq_in, seq_out, data) VALUES (?, ?, ?, ?)", _secretPeerIncomingTableName], @(peerId), @(action.seqIn), @(action.seqOut), data];
        }
    } synchronous:false];
}

- (void)enqueuePeerIncomingEncryptedActions:(int64_t)peerId actions:(NSArray *)actions
{
    [self dispatchOnDatabaseThread:^
    {
        PSKeyValueEncoder *encoder = [[PSKeyValueEncoder alloc] init];
        
        for (TGStoredIncomingEncryptedDataSecretAction *action in actions)
        {
            [encoder reset];
            [encoder encodeObject:action forCKey:"action"];
            NSData *data = [encoder data];
            [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO %@ (peer_id, data) VALUES (?, ?)", _secretPeerIncomingEncryptedTableName], @(peerId), data];
        }
    } synchronous:false];
}

- (void)dequeuePeerIncomingActions:(int64_t)peerId completion:(void (^)(NSArray *, int32_t, NSArray *))completion
{
    [self dispatchOnDatabaseThread:^
    {
        NSMutableArray *actions = [[NSMutableArray alloc] init];
        
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE peer_id=? ORDER BY action_id ASC", _secretPeerIncomingTableName], @(peerId)];
        PSKeyValueDecoder *decoder = [[PSKeyValueDecoder alloc] init];
        while ([result next])
        {
            int32_t actionId = (int32_t)[result intForColumn:@"action_id"];
            int32_t seqIn = (int32_t)[result intForColumn:@"seq_in"];
            int32_t seqOut = (int32_t)[result intForColumn:@"seq_out"];
            NSData *data = [result dataForColumn:@"data"];
            [decoder resetData:data];
            
            id<PSCoding> action = [decoder decodeObjectForCKey:"action"];
            [actions addObject:[[TGStoredSecretActionWithSeq alloc] initWithActionId:TGStoredSecretActionWithSeqActionIdMake(TGStoredSecretActionWithSeqActionIdGeneric, actionId) action:action seqIn:seqIn seqOut:seqOut]];
        }
        
        int32_t nextExpectedSeqOut = 0;
        NSData *seqInData = [self conversationCustomPropertySync:peerId name:seq_in_hash];
        if (seqInData.length == 4)
        {
            int32_t value = 0;
            [seqInData getBytes:&value length:4];
            nextExpectedSeqOut = value;
        }
        
        [actions sortUsingComparator:^NSComparisonResult(TGStoredSecretActionWithSeq *action1, TGStoredSecretActionWithSeq *action2)
        {
            if (action1.seqOut != action2.seqOut)
            {
                if (action1.seqOut < action2.seqOut)
                    return NSOrderedAscending;
                else
                    return NSOrderedDescending;
            }
            else if (action1.actionId.value < action2.actionId.value)
                return NSOrderedAscending;
            else if (action1.actionId.value > action2.actionId.value)
                return NSOrderedDescending;
            else
                return NSOrderedSame;
        }];
        
        NSArray *encryptedActions = [self _dequeuePeerIncomingEncryptedActions:peerId];
        
        if (completion)
            completion(actions, nextExpectedSeqOut, encryptedActions);
    } synchronous:false];
}

- (NSArray *)_dequeuePeerIncomingEncryptedActions:(int64_t)peerId
{
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    
    FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE peer_id=? ORDER BY action_id ASC", _secretPeerIncomingEncryptedTableName], @(peerId)];
    PSKeyValueDecoder *decoder = [[PSKeyValueDecoder alloc] init];
    while ([result next])
    {
        int32_t actionId = (int32_t)[result intForColumn:@"action_id"];
        NSData *data = [result dataForColumn:@"data"];
        [decoder resetData:data];
        
        id<PSCoding> action = [decoder decodeObjectForCKey:"action"];
        [actions addObject:[[TGStoredIncomingEncryptedDataSecretActionWithActionId alloc] initWithActionId:actionId action:action]];
    }
    
    [actions sortUsingComparator:^NSComparisonResult(TGStoredIncomingEncryptedDataSecretActionWithActionId *action1, TGStoredIncomingEncryptedDataSecretActionWithActionId *action2)
    {
        if (action1.actionId < action2.actionId)
            return NSOrderedAscending;
        else if (action1.actionId > action2.actionId)
            return NSOrderedDescending;
        else
            return NSOrderedSame;
    }];
    
    return actions;
}

- (void)applyPeerSeqOut:(int64_t)peerId seqOut:(int32_t)seqOut
{
    [self dispatchOnDatabaseThread:^
    {
        int32_t localSeqOut = seqOut;
        [self setConversationCustomProperty:peerId name:sent_seq_out_hash value:[[NSData alloc] initWithBytes:&localSeqOut length:4]];
    } synchronous:false];
}

- (void)confirmPeerSeqOut:(int64_t)peerId seqOut:(int32_t)seqOut
{
    [self dispatchOnDatabaseThread:^
    {
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE peer_id=? AND seq_out<=?", _secretPeerOutgoingTableName], @(peerId), @(seqOut)];
    } synchronous:false];
}

- (int32_t)currentPeerSentSeqOut:(int64_t)peerId
{
    int32_t sentSeqOut = -1;
    
    NSData *seqInData = [self conversationCustomPropertySync:peerId name:sent_seq_out_hash];
    if (seqInData.length == 4)
    {
        int32_t value = 0;
        [seqInData getBytes:&value length:4];
        sentSeqOut = value;
    }
    
    return sentSeqOut;
}

- (void)applyPeerSeqIn:(int64_t)peerId seqIn:(int32_t)seqIn
{
    [self dispatchOnDatabaseThread:^
    {
        int32_t localSeqIn = seqIn;
        [self setConversationCustomProperty:peerId name:seq_in_hash value:[[NSData alloc] initWithBytes:&localSeqIn length:4]];
    } synchronous:false];
}

- (bool)currentPeerResendSeqIn:(int64_t)peerId seqIn:(int32_t *)seqIn
{
    bool found = false;
    
    NSData *seqInData = [self conversationCustomPropertySync:peerId name:resend_seq_in_hash];
    if (seqInData.length == 4)
    {
        found = true;
        int32_t value = 0;
        [seqInData getBytes:&value length:4];
        if (seqIn)
            *seqIn = value;
    }
    
    return found;
}

- (void)setCurrentPeerResendSeqIn:(int64_t)peerId seqIn:(int32_t)seqIn
{
    [self dispatchOnDatabaseThread:^
    {
        int32_t localSeqIn = seqIn;
        [self setConversationCustomProperty:peerId name:resend_seq_in_hash value:[[NSData alloc] initWithBytes:&localSeqIn length:4]];
    } synchronous:false];
}

- (void)deletePeerIncomingActions:(int64_t)peerId actionIds:(NSArray *)actionIds
{
    [self dispatchOnDatabaseThread:^
     {
         NSMutableString *actionIdsString = [[NSMutableString alloc] init];
         for (NSNumber *nActionId in actionIds)
         {
             if (actionIdsString.length == 0)
                 [actionIdsString appendFormat:@"%d", [nActionId intValue]];
             else
                 [actionIdsString appendFormat:@",%d", [nActionId intValue]];
         }
         
         [_database setSoftShouldCacheStatements:false];
         [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE peer_id=? AND action_id IN (%@)", _secretPeerIncomingTableName, actionIdsString], @(peerId)];
         [_database setSoftShouldCacheStatements:true];
     } synchronous:false];
}

- (void)deletePeerIncomingEncryptedActions:(int64_t)peerId actionIds:(NSArray *)actionIds
{
    [self dispatchOnDatabaseThread:^
    {
        NSMutableString *actionIdsString = [[NSMutableString alloc] init];
        for (NSNumber *nActionId in actionIds)
        {
            if (actionIdsString.length == 0)
                [actionIdsString appendFormat:@"%d", [nActionId intValue]];
            else
                [actionIdsString appendFormat:@",%d", [nActionId intValue]];
        }
        
        [_database setSoftShouldCacheStatements:false];
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE peer_id=? AND action_id IN (%@)", _secretPeerIncomingEncryptedTableName, actionIdsString], @(peerId)];
        [_database setSoftShouldCacheStatements:true];
    } synchronous:false];
}

- (void)processAndScheduleMute
{
    [self dispatchOnDatabaseThread:^
    {
        if (_updateMuteTimer != nil)
        {
            [_updateMuteTimer invalidate];
            _updateMuteTimer = nil;
        }
        
        int currentDate = (int)(CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970 + _timeDifferenceFromUTC);

        FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT pid, mute FROM %@ WHERE mute!=0", _peerPropertiesTableName]];
        int peerIdIndex = [result columnIndexForName:@"pid"];
        int muteIndex = [result columnIndexForName:@"mute"];
        
        NSTimeInterval nextMuteDate = 0.0;
        
        NSMutableArray *resetMuteForPeerIds = [[NSMutableArray alloc] init];
        
        while ([result next])
        {
            int64_t peerId = [result longLongIntForColumnIndex:peerIdIndex];
            int muteDate = [result intForColumnIndex:muteIndex];
            if (nextMuteDate < DBL_EPSILON || nextMuteDate > muteDate)
                nextMuteDate = muteDate;
            
            if (muteDate <= currentDate)
            {
                [resetMuteForPeerIds addObject:@(peerId)];
            }
        }
        
        NSMutableString *peerIdsString = [[NSMutableString alloc] init];
        for (NSNumber *nPeerId in resetMuteForPeerIds)
        {
            if (peerIdsString.length != 0)
                [peerIdsString appendString:@","];
            [peerIdsString appendFormat:@"%" PRId64 "", (int64_t)[nPeerId longLongValue]];
            
            int currentSoundId = 0;
            int currentMuteUntil = 0;
            bool currentPreviewText = true;
            bool currentPhotoNotificationsEnabled = true;
            [TGDatabaseInstance() loadPeerNotificationSettings:[nPeerId longLongValue] soundId:&currentSoundId muteUntil:&currentMuteUntil previewText:&currentPreviewText photoNotificationsEnabled:&currentPhotoNotificationsEnabled notFound:NULL];
            
            [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/peerSettings/(%lld)", [nPeerId longLongValue]] resource:[[SGraphObjectNode alloc] initWithObject:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithInt:currentSoundId], @"soundId", [[NSNumber alloc] initWithInt:0], @"muteUntil", [[NSNumber alloc] initWithBool:currentPreviewText], @"previewText", [[NSNumber alloc] initWithBool:currentPhotoNotificationsEnabled], @"photoNotificationsEnabled", nil]]];
        }
        
        [_database setSoftShouldCacheStatements:false];
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"UPDATE %@ SET mute=0 WHERE pid IN (%@)", _peerPropertiesTableName, peerIdsString]];
        [_database setSoftShouldCacheStatements:true];
        
        if (nextMuteDate > DBL_EPSILON)
        {
            NSTimeInterval delay = MAX(0.05, nextMuteDate - currentDate + 0.25);
            _updateMuteTimer = [[TGTimer alloc] initWithTimeout:delay repeat:false completion:^
            {
                [self processAndScheduleMute];
            } queue:[self databaseQueue]];
            [_updateMuteTimer start];
        }
    } synchronous:false];
}

- (void)removeMediaFromCacheForPeerId:(int64_t)peerId messageIds:(NSArray *)messageIds
{
    [self dispatchOnDatabaseThread:^
    {
        bool inTransaction = [_database inTransaction];
        if (!inTransaction)
            [_database beginTransaction];
        [_database setSoftShouldCacheStatements:false];
        NSMutableString *messageIdsString = [[NSMutableString alloc] init];
        for (NSUInteger i = 0; i < messageIds.count; i++)
        {
            [messageIdsString deleteCharactersInRange:NSMakeRange(0, messageIdsString.length)];
            for (NSUInteger j = i; j < i + 256 && j < messageIds.count; j++)
            {
                if (j != i)
                    [messageIdsString appendString:@","];
                [messageIdsString appendFormat:@"%d", (int)([messageIds[j] intValue])];
            }
            
            [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE peer_id=? AND message_id IN (%@)", _sharedMediaCacheTableName, messageIdsString], @(peerId)];
        }
        [_database setSoftShouldCacheStatements:true];
        if (!inTransaction)
            [_database commit];
    } synchronous:false];
}

- (void)removeMediaFromCacheForPeerId:(int64_t)peerId
{
    bool inTransaction = [_database inTransaction];
    if (!inTransaction)
        [_database beginTransaction];
    [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE peer_id=?", _sharedMediaCacheTableName], @(peerId)];
    if (!inTransaction)
        [_database commit];
}

- (void)cacheMediaForPeerId:(int64_t)peerId messages:(NSArray *)messages
{
    [self dispatchOnDatabaseThread:^
    {
        bool inTransaction = [_database inTransaction];
        if (!inTransaction)
            [_database beginTransaction];
        
        PSKeyValueEncoder *encoder = [[PSKeyValueEncoder alloc] init];
        
        for (TGMessage *message in messages)
        {
            if (message.messageLifetime > 0 && message.messageLifetime <= 60 && message.layer >= 17)
                continue;
            
            bool encodeMessage = false;
            TGSharedMediaCacheItemType itemType = TGSharedMediaCacheItemTypePhoto;
            NSNumber *additionalItemType = nil;
            std::vector<TGSharedMediaCacheItemType> cacheTypes;
            
            for (id attachment in message.mediaAttachments)
            {
                if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
                {
                    encodeMessage = true;
                    itemType = TGSharedMediaCacheItemTypePhoto;
                    cacheTypes.push_back(TGSharedMediaCacheItemTypePhotoVideo);
                }
                else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
                {
                    encodeMessage = true;
                    itemType = TGSharedMediaCacheItemTypeVideo;
                    cacheTypes.push_back(TGSharedMediaCacheItemTypePhotoVideo);
                }
                else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
                {
                    bool isSticker = false;
                    for (id attribute in ((TGDocumentMediaAttachment *)attachment).attributes)
                    {
                        if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]])
                        {
                            isSticker = true;
                            break;
                        }
                        else if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]])
                        {
                            additionalItemType = @(TGSharedMediaCacheItemTypeAudio);
                            encodeMessage = true;
                        cacheTypes.push_back(TGSharedMediaCacheItemTypeAudio);
                        }
                    }
                    
                    if (!isSticker)
                    {
                        encodeMessage = true;
                        itemType = TGSharedMediaCacheItemTypeFile;
                        cacheTypes.push_back(TGSharedMediaCacheItemTypeFile);
                    }
                }
                else if ([attachment isKindOfClass:[TGMessageEntitiesAttachment class]])
                {
                    for (id entity in ((TGMessageEntitiesAttachment *)attachment).entities)
                    {
                        if ([entity isKindOfClass:[TGMessageEntityUrl class]] || [entity isKindOfClass:[TGMessageEntityTextUrl class]] || [entity isKindOfClass:[TGMessageEntityEmail class]])
                        {
                            encodeMessage = true;
                            itemType = TGSharedMediaCacheItemTypeLink;
                            cacheTypes.push_back(TGSharedMediaCacheItemTypeLink);
                            break;
                        }
                    }
                }
            }
            
            if (TGPeerIdIsChannel(peerId)) {
                for (auto it : cacheTypes) {
                    [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO %@ (cid, mid, tag, tag_sort_key) VALUES (?, ?, ?, ?)", _channelMessageTagsTableName], @(peerId), @(message.mid), @(it), TGTaggedMessageSortKeyData(it, message.sortKey)];
                }
            } else {
                if (encodeMessage)
                {
                    [encoder reset];
                    [message encodeWithKeyValueCoder:encoder];
                    
                    NSData *messageData = [encoder data];
                    
                    [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO %@ (peer_id, type, date, message_id, message) VALUES (?, ?, ?, ?, ?)", _sharedMediaCacheTableName], @(peerId), @(itemType), @((int)message.date), @(message.mid), messageData];
                    
                    if (itemType == TGSharedMediaCacheItemTypePhoto || itemType == TGSharedMediaCacheItemTypeVideo)
                    {
                        [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO %@ (peer_id, type, date, message_id, message) VALUES (?, ?, ?, ?, ?)", _sharedMediaCacheTableName], @(peerId), @(TGSharedMediaCacheItemTypePhotoVideo), @((int)message.date), @(message.mid), messageData];
                    }
                    
                    if (additionalItemType != nil)
                    {
                        [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO %@ (peer_id, type, date, message_id, message) VALUES (?, ?, ?, ?, ?)", _sharedMediaCacheTableName], @(peerId), additionalItemType, @((int)message.date), @(message.mid), messageData];
                    }
                    
                    [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO %@ (peer_id, type, date, message_id, message) VALUES (?, ?, ?, ?, ?)", _sharedMediaCacheTableName], @(peerId), @(TGSharedMediaCacheItemTypePhotoVideoFile), @((int)message.date), @(message.mid), messageData];
                }
            }
        }
        
        if (!inTransaction)
            [_database commit];
    } synchronous:false];
}

- (bool)_cacheBuiltForPeerId:(int64_t)peerId
{
    FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE peer_id=?", _sharedMediaIndexBuiltTableName], @(peerId)];
    if ([result next])
        return [result intForColumn:@"cache_built"] != 0;
    
    return false;
}

- (bool)_indexDownloadedForPeerId:(int64_t)peerId itemType:(TGSharedMediaCacheItemType)itemType
{
    FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE peer_id=? and type=?", _sharedMediaIndexDownloadedTableName], @(peerId), @((int)itemType)];
    if ([result next])
        return [result intForColumn:@"index_downloaded"] != 0;
    
    return false;
}

- (void)_buildCacheForPeerId:(int64_t)peerId isCancelled:(bool (^)())isCancelled
{
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    
    FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE cid=? ORDER BY date DESC", _messagesTableName], @(peerId)];
    bool cacheBuilt = true;
    int counter = 0;
    while ([result next])
    {
        counter++;
        if (counter / 256 == 0)
        {
            if (isCancelled && isCancelled())
            {
                cacheBuilt = false;
                break;
            }
        }
        
        TGMessage *message = loadMessageFromQueryResult(result);
        if (message != nil)
            [messages addObject:message];
        
        if (counter >= 1024)
            break;
    }
    
    TGLog(@"Built media cache for %lld from %d messages", (long long int)peerId, (int)messages.count);
    
    [self cacheMediaForPeerId:peerId messages:messages];
    
    if (cacheBuilt)
    {
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO %@ (peer_id, cache_built) VALUES (?, ?)", _sharedMediaIndexBuiltTableName], @(peerId), @(1)];
    }
}

- (void)cachedMediaForPeerId:(int64_t)peerId itemType:(TGSharedMediaCacheItemType)itemType limit:(NSUInteger)limit important:(bool)important completion:(void (^)(NSArray *, bool))completion buildIndex:(bool)buildIndex isCancelled:(bool (^)())isCancelled
{
    [self dispatchOnDatabaseThread:^
    {
        if (TGPeerIdIsChannel(peerId)) {
            FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT mid FROM %@ WHERE tag_sort_key > ? AND tag_sort_key < ?", _channelMessageTagsTableName], TGTaggedMessageSortKeyData(itemType, TGMessageSortKeyLowerBound(peerId, important ? TGMessageSpaceImportant : TGMessageSpaceUnimportant)), TGTaggedMessageSortKeyData(itemType, TGMessageSortKeyUpperBound(peerId, important ? TGMessageSpaceImportant : TGMessageSpaceUnimportant))];
            NSMutableArray *messageIds = [[NSMutableArray alloc] init];
            while ([result next]) {
                [messageIds addObject:@([result intForColumnIndex:0])];
            }
            
            NSMutableArray *messages = [[NSMutableArray alloc] init];
            PSKeyValueDecoder *decoder = [[PSKeyValueDecoder alloc] init];
            
            NSMutableString *queryString = [[NSMutableString alloc] init];
            for (NSUInteger i = 0; i < messageIds.count; i++) {
                [queryString deleteCharactersInRange:NSMakeRange(0, queryString.length)];
                [queryString appendFormat:@"SELECT data FROM %@ WHERE cid=? AND mid IN (", _channelMessagesTableName];
                NSUInteger maxJ = i + 1024;
                bool first = true;
                for (NSUInteger j = i; j < maxJ && j < messageIds.count; j++, i++) {
                    if (first) {
                        first = false;
                    } else {
                        [queryString appendString:@","];
                    }
                    [queryString appendFormat:@"%d", [messageIds[j] intValue]];
                }
                [queryString appendString:@")"];
                
                FMResultSet *messagesResult = [_database executeQuery:queryString, @(peerId)];
                while ([messagesResult next]) {
                    [decoder resetData:[messagesResult dataForColumnIndex:0]];
                    TGMessage *message = [[TGMessage alloc] initWithKeyValueCoder:decoder];
                    if (message.cid == peerId) {
                        [messages addObject:message];
                    } else {
                        TGLog(@"Parsed message has invalid peerId");
                    }
                }
            }
            
            if (completion) {
                completion(messages, true);
            }
        } else {
            if (buildIndex)
            {
                if (![self _cacheBuiltForPeerId:peerId])
                    [self _buildCacheForPeerId:peerId isCancelled:isCancelled];
            }
            
            PSKeyValueDecoder *decoder = [[PSKeyValueDecoder alloc] init];
            NSMutableArray *messages = [[NSMutableArray alloc] init];
            
            FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE peer_id=? AND type=? ORDER BY date DESC%@", _sharedMediaCacheTableName, limit == 0 ? @"" : [[NSString alloc] initWithFormat:@" LIMIT %d", (int)limit]], @(peerId), @(itemType)];
            int messageIndex = [result columnIndexForName:@"message"];
            while ([result next])
            {
                NSData *messageData = [result dataForColumnIndex:messageIndex];
                [decoder resetData:messageData];
                TGMessage *message = [[TGMessage alloc] initWithKeyValueCoder:decoder];
                if (message != nil)
                {
                    [messages addObject:message];
                }
                else
                    TGLog(@"message parse error");
            }
            
            bool indexDownloaded = [self _indexDownloadedForPeerId:peerId itemType:itemType];
            
            if (completion)
                completion(messages, indexDownloaded);
        }
    } synchronous:false];
}

- (TGMessage *)_cachedMediaMessageForId:(int32_t)messageId
{
    PSKeyValueDecoder *decoder = [[PSKeyValueDecoder alloc] init];
    
    FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE message_id=? LIMIT 1", _sharedMediaCacheTableName], @(messageId)];
    int messageIndex = [result columnIndexForName:@"message"];
    if ([result next])
    {
        NSData *messageData = [result dataForColumnIndex:messageIndex];
        [decoder resetData:messageData];
        TGMessage *message = [[TGMessage alloc] initWithKeyValueCoder:decoder];
        if (message != nil)
            return message;
        else
            TGLog(@"message parse error");
    }
    
    return nil;
}

- (void)setSharedMediaIndexDownloadedForPeerId:(int64_t)peerId itemType:(TGSharedMediaCacheItemType)itemType
{
    [self dispatchOnDatabaseThread:^
    {
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO %@ (peer_id, type, index_downloaded) VALUES (?, ?, ?)", _sharedMediaIndexDownloadedTableName], @(peerId), @((int)itemType), @(true)];
    } synchronous:false];
}

- (void)clearCachedMedia
{
    [self dispatchOnDatabaseThread:^
    {
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@", _sharedMediaCacheTableName]];
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@", _sharedMediaIndexBuiltTableName]];
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@", _sharedMediaIndexDownloadedTableName]];
    } synchronous:false];
}

- (TGBotInfo *)botInfoForUserId:(int32_t)userId
{
    __block TGBotInfo *botInfo = nil;
    [self dispatchOnDatabaseThread:^
    {
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE user_id=?", _botInfoTableName], @(userId)];
        if ([result next])
        {
            PSKeyValueDecoder *decoder = [[PSKeyValueDecoder alloc] initWithData:[result dataForColumn:@"data"]];
            botInfo = [[TGBotInfo alloc] initWithKeyValueCoder:decoder];
        }
    } synchronous:true];
    
    return botInfo;
}

- (void)storeBotInfo:(TGBotInfo *)botInfo forUserId:(int32_t)userId
{
    [self dispatchOnDatabaseThread:^
    {
        PSKeyValueEncoder *encoder = [[PSKeyValueEncoder alloc] init];
        [botInfo encodeWithKeyValueCoder:encoder];
        NSData *data = [encoder data];
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO %@ (user_id, data) VALUES (?, ?)", _botInfoTableName], @(userId), data];
    } synchronous:false];
}

- (SSignal *)signalBotReplyMarkupForPeerId:(int64_t)peerId
{
    return [[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        TGBotReplyMarkup *markup = [self botReplyMarkupForPeerId:peerId];
        [subscriber putNext:markup];
        [subscriber putCompletion];
        return nil;
    }] then:[_multicastManager multicastedPipeForKey:[[NSString alloc] initWithFormat:@"%lld", (long long)peerId]]];
}

- (TGBotReplyMarkup *)botReplyMarkupForPeerId:(int64_t)peerId
{
    __block TGBotReplyMarkup *botReplyMarkup = nil;
    [self dispatchOnDatabaseThread:^
    {
        NSData *data = [self conversationCustomPropertySync:peerId name:murMurHash32(@"replyMarkup")];
        if (data != nil)
        {
            PSKeyValueDecoder *decoder = [[PSKeyValueDecoder alloc] initWithData:data];
            if ([decoder decodeInt32ForCKey:"__hasMarkup"] != 0)
                botReplyMarkup = [[TGBotReplyMarkup alloc] initWithKeyValueCoder:decoder];
        }
    } synchronous:true];
    
    return botReplyMarkup;
}

- (void)storeBotReplyMarkup:(TGBotReplyMarkup *)botReplyMarkup hideMarkupAuthorId:(int32_t)hideMarkupAuthorId forPeerId:(int64_t)peerId messageId:(int32_t)messageId
{
    [self dispatchOnDatabaseThread:^
    {
        TGBotReplyMarkup *currentMarkup = nil;
        
        NSData *data = [self conversationCustomPropertySync:peerId name:murMurHash32(@"replyMarkup")];
        if (data != nil)
        {
            PSKeyValueDecoder *decoder = [[PSKeyValueDecoder alloc] initWithData:data];
            if (messageId != -1 && [decoder decodeInt32ForCKey:"__messageId"] >= messageId)
                return;
            if ([decoder decodeInt32ForCKey:"__hasMarkup"] != 0)
                currentMarkup = [[TGBotReplyMarkup alloc] initWithKeyValueCoder:decoder];
        }
        
        bool updatedMarkup = false;
        if (botReplyMarkup == nil)
        {
            if (currentMarkup != nil && (messageId == -1 || (hideMarkupAuthorId != 0 && currentMarkup.userId == hideMarkupAuthorId)))
            {
                PSKeyValueEncoder *encoder = [[PSKeyValueEncoder alloc] init];
                [encoder encodeInt32:0 forCKey:"__hasMarkup"];
                [encoder encodeInt32:messageId forCKey:"__messageId"];
                [self setConversationCustomProperty:peerId name:murMurHash32(@"replyMarkup") value:[encoder data]];
                updatedMarkup = true;
            }
        }
        else
        {
            PSKeyValueEncoder *encoder = [[PSKeyValueEncoder alloc] init];
            [encoder encodeInt32:1 forCKey:"__hasMarkup"];
            [encoder encodeInt32:messageId forCKey:"__messageId"];
            [botReplyMarkup encodeWithKeyValueCoder:encoder];
            [self setConversationCustomProperty:peerId name:murMurHash32(@"replyMarkup") value:[encoder data]];
            updatedMarkup = true;
        }
        
        if (updatedMarkup)
        {
            [_multicastManager putNext:botReplyMarkup toMulticastedPipeForKey:[[NSString alloc] initWithFormat:@"%lld", (long long)peerId]];
        }
    } synchronous:false];
}

- (void)storeBotReplyMarkupActivated:(TGBotReplyMarkup *)botReplyMarkup forPeerId:(int64_t)peerId
{
    [self dispatchOnDatabaseThread:^
    {
        TGBotReplyMarkup *currentMarkup = nil;
        int32_t messageId = 0;
        
        NSData *data = [self conversationCustomPropertySync:peerId name:murMurHash32(@"replyMarkup")];
        if (data != nil)
        {
            PSKeyValueDecoder *decoder = [[PSKeyValueDecoder alloc] initWithData:data];
            if ([decoder decodeInt32ForCKey:"__hasMarkup"] != 0)
                currentMarkup = [[TGBotReplyMarkup alloc] initWithKeyValueCoder:decoder];
            messageId = [decoder decodeInt32ForCKey:"__messageId"];
        }
        
        if ([botReplyMarkup isEqual:currentMarkup] && !currentMarkup.alreadyActivated)
        {
            PSKeyValueEncoder *encoder = [[PSKeyValueEncoder alloc] init];
            [encoder encodeInt32:1 forCKey:"__hasMarkup"];
            [encoder encodeInt32:messageId forCKey:"__messageId"];
            [[botReplyMarkup activatedMarkup] encodeWithKeyValueCoder:encoder];
            [self setConversationCustomProperty:peerId name:murMurHash32(@"replyMarkup") value:[encoder data]];
        }
    } synchronous:false];
}

- (TGConversation *)_loadChannelConversation:(int64_t)peerId {
    FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT data FROM %@ WHERE cid=?", _channelListTableName], @(peerId)];
    if ([result next]) {
        NSData *data = [result dataForColumnIndex:0];
        TGConversation *conversation = [[TGConversation alloc] initWithKeyValueCoder:[[PSKeyValueDecoder alloc] initWithData:data]];
        if (conversation.conversationId != 0)
            return conversation;
    }
    return nil;
}

- (NSArray *)_loadChannelsWithLowerBound:(TGConversationSortKey)lowerBoundKey upperBound:(TGConversationSortKey)upperBoundKey count:(NSUInteger)count {
    PSKeyValueDecoder *decoder = [[PSKeyValueDecoder alloc] init];
    
    FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT data FROM %@ WHERE variant_sort_key > ? AND variant_sort_key < ? ORDER BY variant_sort_key DESC LIMIT ?", _channelListTableName], TGConversationSortKeyData(lowerBoundKey), TGConversationSortKeyData(upperBoundKey), @(count)];
    NSMutableArray *channels = [[NSMutableArray alloc] init];
    while ([result next]) {
        [decoder resetData:[result dataForColumnIndex:0]];
        TGConversation *channel = [[TGConversation alloc] initWithKeyValueCoder:decoder];
        if (channel.conversationId != 0) {
            [channels addObject:channel];
        } else {
            TGLog(@"Channel parsing error");
        }
    }
    return channels;
}

- (TGConversation *)_updateChannelConversation:(int64_t)peerId conversation:(TGConversation *)conversation {
    FMResultSet *existingResult = [_database executeQuery:[NSString stringWithFormat:@"SELECT data FROM %@ WHERE cid=?", _channelListTableName], @(peerId)];
    if ([existingResult next]) {
        TGConversation *currentConversation = [[TGConversation alloc] initWithKeyValueCoder:[[PSKeyValueDecoder alloc] initWithData:[existingResult dataForColumnIndex:0]]];
        
        PSKeyValueEncoder *encoder = [[PSKeyValueEncoder alloc] init];
        [currentConversation mergeChannel:conversation];
        [currentConversation encodeWithKeyValueCoder:encoder];
        
        [_database executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET data=? WHERE cid=?", _channelListTableName], encoder.data, @(peerId)];
        SPipe *pipe = _existingChannelPipes[@(peerId)];
        if (pipe != nil) {
            pipe.sink(currentConversation);
        }
        return currentConversation;
    } else {
        conversation = [conversation copy];
        conversation.pts = MAX(1, conversation.pts);
        PSKeyValueEncoder *encoder = [[PSKeyValueEncoder alloc] init];
        [conversation encodeWithKeyValueCoder:encoder];
        [_database executeUpdate:[NSString stringWithFormat:@"INSERT INTO %@ (cid, variant_sort_key, data) VALUES (?, ?, ?)", _channelListTableName], @(peerId), TGConversationSortKeyData(conversation.variantSortKey), encoder.data];
        SPipe *pipe = _existingChannelPipes[@(peerId)];
        if (pipe != nil) {
            pipe.sink(conversation);
        }
        return conversation;
    }
}

- (TGMessage *)_loadChannelMessage:(int64_t)peerId messageId:(int32_t)messageId {
    FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT data FROM %@ WHERE cid=? AND mid=?", _channelMessagesTableName], @(peerId), @(messageId)];
    if ([result next]) {
        TGMessage *message = [[TGMessage alloc] initWithKeyValueCoder:[[PSKeyValueDecoder alloc] initWithData:[result dataForColumnIndex:0]]];
        if (message.mid == messageId && message.cid == peerId) {
            return message;
        } else {
            TGLog(@"(TGDatabase _loadChannelMessage: unexpexted message properties (peerId = %lld, messageId = %d))", (long long)message.cid, (int)message.mid);
        }
    }
    
    return nil;
}

- (void)_updateChannelConversationSortKeys:(int64_t)peerId importantSortKey:(TGMessageSortKey)importantSortKey importantMessage:(TGMessage *)importantMessage unimportantSortKey:(TGMessageSortKey)unimportantSortKey unimportantMessage:(TGMessage *)unimportantMessage addImportantUnread:(int32_t)addImportantUnread addUnimportantUnread:(int32_t)addUnimportantUnread {
    FMResultSet *currentResult = [_database executeQuery:[NSString stringWithFormat:@"SELECT data FROM %@ WHERE cid=?", _channelListTableName], @(peerId)];
    if ([currentResult next]) {
        TGConversation *channel = [[TGConversation alloc] initWithKeyValueCoder:[[PSKeyValueDecoder alloc] initWithData:[currentResult dataForColumnIndex:0]]];
        
        int32_t displayVariant = channel.displayVariant;
        
        TGConversationSortKey currentImportantSortKey = channel.importantSortKey;
        TGConversationSortKey currentUnimportantSortKey = channel.unimportantSortKey;
        
        NSData *importantSortKeyData = TGConversationSortKeyData(channel.importantSortKey);
        NSData *unimportantSortKeyData = TGConversationSortKeyData(channel.unimportantSortKey);
        
        TGMessage *actualImportantMessage = nil;
        TGMessage *actualUnimportantMessage = nil;
        
        TGConversationSortKey conversationImportantSortKey = TGConversationSortKeyMake(channel.kind, TGMessageSortKeyTimestamp(importantSortKey), TGMessageSortKeyMid(importantSortKey));
        TGConversationSortKey conversationUnimportantSortKey = TGConversationSortKeyMake(channel.kind, TGMessageSortKeyTimestamp(unimportantSortKey), TGMessageSortKeyMid(unimportantSortKey));
        
        if (importantMessage != nil && TGConversationSortKeyCompare(conversationImportantSortKey, currentImportantSortKey) > 0) {
            importantSortKeyData = TGConversationSortKeyData(conversationImportantSortKey);
            channel.importantSortKey = conversationImportantSortKey;
            actualImportantMessage = importantMessage;
        } else {
            importantSortKeyData = TGConversationSortKeyData(currentImportantSortKey);
            channel.importantSortKey = currentImportantSortKey;
        }
        
        if (unimportantMessage != nil && TGConversationSortKeyCompare(conversationUnimportantSortKey, currentUnimportantSortKey) > 0) {
            unimportantSortKeyData = TGConversationSortKeyData(conversationUnimportantSortKey);
            channel.unimportantSortKey = conversationUnimportantSortKey;
            actualUnimportantMessage = unimportantMessage;
        } else {
            unimportantSortKeyData = TGConversationSortKeyData(currentUnimportantSortKey);
            channel.unimportantSortKey = currentUnimportantSortKey;
        }
        
        if (actualImportantMessage == nil) {
            actualImportantMessage = [self _topChannelMessage:peerId important:true];
        }
        
        if (actualUnimportantMessage == nil) {
            actualUnimportantMessage = [self _topChannelMessage:peerId important:false];
        }
        
        if (displayVariant == TGChannelDisplayVariantAll && TGConversationSortKeyCompare(conversationUnimportantSortKey, conversationImportantSortKey) > 0) {
            channel.variantSortKey = channel.unimportantSortKey;
            if (actualUnimportantMessage != nil)
                [channel mergeMessage:actualUnimportantMessage];
        } else {
            channel.variantSortKey = channel.importantSortKey;
            if (actualImportantMessage != nil)
                [channel mergeMessage:actualImportantMessage];
        }
        
        if (TGConversationSortKeyTimestamp(channel.variantSortKey) < channel.date) {
            channel.variantSortKey = TGConversationSortKeyMake(TGConversationSortKeyKind(channel.variantSortKey), channel.date, TGConversationSortKeyMid(channel.variantSortKey));
        }
        
        if (channel.kind == TGConversationKindPersistentChannel) {
            channel.unreadCount += addImportantUnread;
            channel.serviceUnreadCount += addUnimportantUnread;
        }
        
        PSKeyValueEncoder *encoder = [[PSKeyValueEncoder alloc] init];
        [channel encodeWithKeyValueCoder:encoder];
        
        [_database executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET variant_sort_key=?, data=? WHERE cid=?", _channelListTableName], TGConversationSortKeyData(channel.variantSortKey), encoder.data, @(peerId)];
        
        [[self _channelList] updateChannel:channel];
    }
}

- (void)_updateChannelConversation:(int64_t)peerId {
    FMResultSet *currentResult = [_database executeQuery:[NSString stringWithFormat:@"SELECT data FROM %@ WHERE cid=?", _channelListTableName], @(peerId)];
    if ([currentResult next]) {
        TGConversation *channel = [[TGConversation alloc] initWithKeyValueCoder:[[PSKeyValueDecoder alloc] initWithData:[currentResult dataForColumnIndex:0]]];
        
        int32_t displayVariant = channel.displayVariant;
        
        TGMessage *actualImportantMessage = [self _topChannelMessage:peerId important:true];
        TGMessage *actualUnimportantMessage = [self _topChannelMessage:peerId important:false];
        
        if (actualImportantMessage != nil) {
            channel.importantSortKey = TGConversationSortKeyMake(channel.kind, TGMessageSortKeyTimestamp(actualImportantMessage.sortKey), TGMessageSortKeyTimestamp(actualImportantMessage.sortKey));
        }
        
        if (actualUnimportantMessage != nil) {
            channel.unimportantSortKey = TGConversationSortKeyMake(channel.kind, TGMessageSortKeyTimestamp(actualUnimportantMessage.sortKey), TGMessageSortKeyTimestamp(actualUnimportantMessage.sortKey));
        }
        
        if (displayVariant == TGChannelDisplayVariantAll && actualUnimportantMessage != nil && actualImportantMessage != nil && TGMessageSortKeyCompare(actualUnimportantMessage.sortKey, actualImportantMessage.sortKey)) {
            channel.variantSortKey = channel.unimportantSortKey;
            [channel mergeMessage:actualUnimportantMessage];
        } else if (actualImportantMessage != nil) {
            channel.variantSortKey = channel.importantSortKey;
            [channel mergeMessage:actualImportantMessage];
        } else {
            channel.media = nil;
            channel.text = @"";
            channel.deliveryState = TGMessageDeliveryStateDelivered;
        }
        
        if (TGConversationSortKeyTimestamp(channel.variantSortKey) < channel.date) {
            channel.variantSortKey = TGConversationSortKeyMake(TGConversationSortKeyKind(channel.variantSortKey), channel.date, TGConversationSortKeyMid(channel.variantSortKey));
        }
        
        PSKeyValueEncoder *encoder = [[PSKeyValueEncoder alloc] init];
        [channel encodeWithKeyValueCoder:encoder];
        
        [_database executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET variant_sort_key=?, data=? WHERE cid=?", _channelListTableName], TGConversationSortKeyData(channel.variantSortKey), encoder.data, @(peerId)];
        
        [[self _channelList] updateChannel:channel];
        
        SPipe *pipe = _existingChannelPipes[@(peerId)];
        if (pipe != nil) {
            pipe.sink(channel);
        }
    }
    
    [[self _channelList] commitUpdatedChannels];
}

- (void)storeSynchronizedChannels:(NSArray *)channels {
    [self dispatchOnDatabaseThread:^{
        [_database beginTransaction];
        [self updateChannels:channels];
        int32_t one = 1;
        [self setCustomProperty:@"channelListSynchronized" value:[NSData dataWithBytes:&one length:4]];
        [_database commit];
    } synchronous:false];
}

- (void)updateChannels:(NSArray *)channels {
    [self dispatchOnDatabaseThread:^{
        NSMutableArray *updatedConversations = [[NSMutableArray alloc] init];
        for (TGConversation *conversation in channels) {
            TGConversation *updatedConversation = [self _updateChannelConversation:conversation.conversationId conversation:conversation];
            [updatedConversations addObject:updatedConversation];
            
            [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/conversation", conversation.conversationId] resource:[[SGraphObjectNode alloc] initWithObject:updatedConversation]];
        }

        for (TGConversation *conversation in updatedConversations) {
            [[self _channelList] updateChannel:conversation];
        }
        
        [[self _channelList] commitUpdatedChannels];
    } synchronous:false];
}

- (void)initializeChannel:(TGConversation *)conversation {
    [self dispatchOnDatabaseThread:^{
        TGConversation *updatedConversation = [self _updateChannelConversation:conversation.conversationId conversation:conversation];
            
        [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/conversation", conversation.conversationId] resource:[[SGraphObjectNode alloc] initWithObject:updatedConversation]];
        
        [[self _channelList] updateChannel:updatedConversation];
    } synchronous:false];
}

- (void)updateChannelDisplayVariant:(int64_t)peerId displayVariant:(int32_t)displayVariant {
    [self dispatchOnDatabaseThread:^{
        TGConversation *conversation = [[self _loadChannelConversation:peerId] copy];
        if (conversation != nil && conversation.displayVariant != displayVariant) {
            conversation.displayVariant = displayVariant;

            PSKeyValueEncoder *encoder = [[PSKeyValueEncoder alloc] init];
            [conversation encodeWithKeyValueCoder:encoder];
            
            [_database executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET data=? WHERE cid=?", _channelListTableName], encoder.data, @(peerId)];
            
            [self _updateChannelConversation:peerId];
        }
    } synchronous:false];
}

- (void)updateChannelDisplayExpanded:(int64_t)peerId displayExpanded:(bool)displayExpanded {
    [self dispatchOnDatabaseThread:^{
        TGConversation *conversation = [[self _loadChannelConversation:peerId] copy];
        if (conversation != nil && conversation.displayExpanded != displayExpanded) {
            conversation.displayExpanded = displayExpanded;
            
            PSKeyValueEncoder *encoder = [[PSKeyValueEncoder alloc] init];
            [conversation encodeWithKeyValueCoder:encoder];
            
            [_database executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET data=? WHERE cid=?", _channelListTableName], encoder.data, @(peerId)];
            
            [[self _channelList] updateChannel:conversation];
        }
    } synchronous:false];
}

- (void)updateChannelPostAsChannel:(int64_t)peerId postAsChannel:(bool)postAsChannel {
    [self dispatchOnDatabaseThread:^{
        TGConversation *conversation = [[self _loadChannelConversation:peerId] copy];
        if (conversation != nil && conversation.postAsChannel != postAsChannel) {
            conversation.postAsChannel = postAsChannel;
            
            PSKeyValueEncoder *encoder = [[PSKeyValueEncoder alloc] init];
            [conversation encodeWithKeyValueCoder:encoder];
            
            [_database executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET data=? WHERE cid=?", _channelListTableName], encoder.data, @(peerId)];
            
            [[self _channelList] updateChannel:conversation];
        }
    } synchronous:false];
}

- (void)updateChannelAbout:(int64_t)peerId about:(NSString *)about {
    [self dispatchOnDatabaseThread:^{
        TGConversation *conversation = [[self _loadChannelConversation:peerId] copy];
        if (conversation != nil && (!TGStringCompare(conversation.about, about))) {
            conversation.about = about;
            
            PSKeyValueEncoder *encoder = [[PSKeyValueEncoder alloc] init];
            [conversation encodeWithKeyValueCoder:encoder];
            
            [_database executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET data=? WHERE cid=?", _channelListTableName], encoder.data, @(peerId)];
            
            [[self _channelList] updateChannel:conversation];
            
            [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/conversation", peerId] resource:[[SGraphObjectNode alloc] initWithObject:conversation]];
        }
    } synchronous:false];
}

- (void)updateChannelUsername:(int64_t)peerId username:(NSString *)username {
    [self dispatchOnDatabaseThread:^{
        TGConversation *conversation = [[self _loadChannelConversation:peerId] copy];
        if (conversation != nil && (!TGStringCompare(conversation.username, username))) {
            conversation.username = username;
            
            PSKeyValueEncoder *encoder = [[PSKeyValueEncoder alloc] init];
            [conversation encodeWithKeyValueCoder:encoder];
            
            [_database executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET data=? WHERE cid=?", _channelListTableName], encoder.data, @(peerId)];
            
            [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/conversation", peerId] resource:[[SGraphObjectNode alloc] initWithObject:conversation]];
        }
    } synchronous:false];
}

- (void)updateChannelReadState:(int64_t)peerId maxReadId:(int32_t)maxReadId unreadImportantCount:(int32_t)unreadImportantCount unreadUnimportantCount:(int32_t)unreadUnimportantCount {
    [self dispatchOnDatabaseThread:^{
        TGConversation *conversation = [[self _loadChannelConversation:peerId] copy];
        if (conversation != nil) {
            conversation.maxReadMessageId = maxReadId;
            conversation.unreadCount = unreadImportantCount;
            conversation.serviceUnreadCount = unreadUnimportantCount;
            
            PSKeyValueEncoder *encoder = [[PSKeyValueEncoder alloc] init];
            [conversation encodeWithKeyValueCoder:encoder];
            
            [_database executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET data=? WHERE cid=?", _channelListTableName], encoder.data, @(peerId)];
            
            [[self _channelList] updateChannel:conversation];
            [[self _channelList] commitUpdatedChannels];
        }
    } synchronous:false];
}

- (void)updateChannelRead:(int64_t)peerId maxReadId:(int32_t)maxReadId {
    [self dispatchOnDatabaseThread:^{
        TGConversation *conversation = [[self _loadChannelConversation:peerId] copy];
        if (conversation != nil) {
            if (maxReadId > conversation.maxReadMessageId) {
                conversation.maxReadMessageId = maxReadId;
                conversation.unreadCount = 0;
                conversation.serviceUnreadCount = 0;
                
                PSKeyValueEncoder *encoder = [[PSKeyValueEncoder alloc] init];
                [conversation encodeWithKeyValueCoder:encoder];
                
                [_database executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET data=? WHERE cid=?", _channelListTableName], encoder.data, @(peerId)];
                
                [[self _channelList] updateChannel:conversation];
                [[self _channelList] commitUpdatedChannels];
            }
        }
    } synchronous:false];
}

- (TGMessageSortKey)_knownChannelEarlierMessageSortKey:(int64_t)peerId maxId:(int32_t)maxId {
    FMResultSet *messageResult = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT sort_key FROM %@ WHERE cid=? AND mid<=? ORDER BY mid DESC LIMIT 1", _channelMessagesTableName], @(peerId), @(maxId)];
    TGMessageSortKey sortKey = TGMessageSortKeyLowerBound(peerId, TGMessageSpaceImportant);
    if ([messageResult next]) {
        sortKey = TGMessageSortKeyFromData([messageResult dataForColumnIndex:0]);
    }
    
    FMResultSet *groupResult = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT max_sort_key FROM %@ WHERE cid=? AND max_id<=? ORDER BY max_id DESC LIMIT 1", _channelMessageUnimportantGroupsTableName], @(peerId), @(maxId)];
    TGMessageSortKey groupSortKey = sortKey;
    if ([groupResult next]) {
        TGMessageTransparentSortKey transparentSortKey = TGMessageTransparentSortKeyFromData([groupResult dataForColumnIndex:0]);
        groupSortKey = TGMessageSortKeyMake(peerId, TGMessageTransparentSortKeySpace(transparentSortKey), TGMessageTransparentSortKeyTimestamp(transparentSortKey), TGMessageTransparentSortKeyMid(transparentSortKey));
    }
    
    if (TGMessageSortKeyCompare(sortKey, groupSortKey) > 0) {
        return sortKey;
    } else {
        return groupSortKey;
    }
}

- (TGMessage *)_topChannelMessage:(int64_t)peerId important:(bool)important {
    TGMessageSortKey upperBound = TGMessageSortKeyUpperBound(peerId, important ? TGMessageSpaceImportant : TGMessageSpaceUnimportant);
    TGMessageSortKey lowerBound = TGMessageSortKeyLowerBound(peerId, important ? TGMessageSpaceImportant : TGMessageSpaceUnimportant);
    
    FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT data FROM %@ WHERE sort_key<? AND sort_key>? ORDER BY sort_key DESC LIMIT 1", _channelMessagesTableName], TGMessageSortKeyData(upperBound), TGMessageSortKeyData(lowerBound)];
    PSKeyValueDecoder *decoder = [[PSKeyValueDecoder alloc] init];
    if ([result next]) {
        [decoder resetData:[result dataForColumnIndex:0]];
        TGMessage *message = [[TGMessage alloc] initWithKeyValueCoder:decoder];
        if (message.mid != 0) {
            return message;
        }
    }
    
    return nil;
}

- (NSArray *)_loadChannelMessagesWithMinSortKey:(TGMessageTransparentSortKey)minSortKey maxSortKey:(TGMessageTransparentSortKey)maxSortKey count:(NSUInteger)count {
    if (TGMessageTransparentSortKeyCompare(minSortKey, maxSortKey) < 0) {
        FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT data FROM %@ WHERE transparent_sort_key<=? AND transparent_sort_key>? ORDER BY transparent_sort_key DESC LIMIT ?", _channelMessagesTableName], TGMessageTransparentSortKeyData(maxSortKey), TGMessageTransparentSortKeyData(minSortKey), @(count)];
        NSMutableArray *messages = [[NSMutableArray alloc] init];
        PSKeyValueDecoder *decoder = [[PSKeyValueDecoder alloc] init];
        while ([result next]) {
            [decoder resetData:[result dataForColumnIndex:0]];
            TGMessage *message = [[TGMessage alloc] initWithKeyValueCoder:decoder];
            if (message.mid != 0) {
                [messages addObject:message];
            }
        }
        
        return messages;
    } else {
        FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT data FROM %@ WHERE transparent_sort_key>? AND transparent_sort_key<? ORDER BY transparent_sort_key ASC LIMIT ?", _channelMessagesTableName], TGMessageTransparentSortKeyData(maxSortKey), TGMessageTransparentSortKeyData(minSortKey), @(count)];
        NSMutableArray *messages = [[NSMutableArray alloc] init];
        PSKeyValueDecoder *decoder = [[PSKeyValueDecoder alloc] init];
        while ([result next]) {
            [decoder resetData:[result dataForColumnIndex:0]];
            TGMessage *message = [[TGMessage alloc] initWithKeyValueCoder:decoder];
            if (message.mid != 0) {
                [messages addObject:message];
            }
        }
        
        return messages;
    }
}

- (NSArray *)_loadChannelImportantMessagesWithMinSortKey:(TGMessageTransparentSortKey)minSortKey maxSortKey:(TGMessageTransparentSortKey)maxSortKey count:(NSUInteger)count {
    TGMessageSortKey minSpaceSortKey = TGMessageSortKeyMake(TGMessageTransparentSortKeyPeerId(minSortKey), TGMessageSpaceImportant, TGMessageTransparentSortKeyTimestamp(minSortKey), TGMessageTransparentSortKeyMid(minSortKey));
    TGMessageSortKey maxSpaceSortKey = TGMessageSortKeyMake(TGMessageTransparentSortKeyPeerId(maxSortKey), TGMessageSpaceImportant, TGMessageTransparentSortKeyTimestamp(maxSortKey), TGMessageTransparentSortKeyMid(maxSortKey));
    
    if (TGMessageSortKeyCompare(minSpaceSortKey, maxSpaceSortKey) < 0) {
        FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT data FROM %@ WHERE sort_key<=? AND sort_key>? ORDER BY sort_key DESC LIMIT ?", _channelMessagesTableName], TGMessageSortKeyData(maxSpaceSortKey), TGMessageSortKeyData(minSpaceSortKey), @(count)];
        NSMutableArray *messages = [[NSMutableArray alloc] init];
        PSKeyValueDecoder *decoder = [[PSKeyValueDecoder alloc] init];
        while ([result next]) {
            [decoder resetData:[result dataForColumnIndex:0]];
            TGMessage *message = [[TGMessage alloc] initWithKeyValueCoder:decoder];
            if (message.mid != 0) {
                [messages addObject:message];
            }
        }
        
        return messages;
    } else {
        FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT data FROM %@ WHERE sort_key>? AND sort_key<? ORDER BY sort_key ASC LIMIT ?", _channelMessagesTableName], TGMessageSortKeyData(maxSpaceSortKey), TGMessageSortKeyData(minSpaceSortKey), @(count)];
        NSMutableArray *messages = [[NSMutableArray alloc] init];
        PSKeyValueDecoder *decoder = [[PSKeyValueDecoder alloc] init];
        while ([result next]) {
            [decoder resetData:[result dataForColumnIndex:0]];
            TGMessage *message = [[TGMessage alloc] initWithKeyValueCoder:decoder];
            if (message.mid != 0) {
                [messages addObject:message];
            }
        }
        
        return messages;
    }
}

- (void)addMessagesToChannel:(int64_t)peerId messages:(NSArray *)messages deleteMessages:(NSArray *)deleteMessages unimportantGroups:(NSArray *)unimportantGroups addedHoles:(NSArray *)addedHoles removedHoles:(NSArray *)removedHoles removedUnimportantHoles:(NSArray *)removedUnimportantHoles updatedMessageSortKeys:(NSArray *)updatedMessageSortKeys returnGroups:(bool)returnGroups changedMessages:(void (^)(NSArray *addedMessages, NSArray *removedMessages, NSDictionary *updatedMessages, NSArray *addedUnimportantHoles, NSArray *removedUnimportantHoles))changedMessages
{
    [self dispatchOnDatabaseThread:^{
        [_database beginTransaction];
        
        TGConversation *conversation = [self _loadChannelConversation:peerId];
        if (conversation != nil) {
            TGMessageSortKey maxImportantSortKey = TGMessageSortKeyLowerBound(peerId, TGMessageSpaceImportant);
            TGMessage *maxImportantMessage = nil;
            TGMessageSortKey maxUnimportantSortKey = TGMessageSortKeyLowerBound(peerId, TGMessageSpaceUnimportant);
            TGMessage *maxUnimportantMessage = nil;
            
            NSString *insertMessage = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (cid, mid, sort_key, data, transparent_sort_key) VALUES (?, ?, ?, ?, ?)", _channelMessagesTableName];
            PSKeyValueEncoder *encoder = [[PSKeyValueEncoder alloc] init];
            NSMutableArray *filledUnimportantGroups = [[NSMutableArray alloc] init];
            
            NSMutableArray *addedMessages = [[NSMutableArray alloc] init];
            NSMutableArray *removedMessages = [[NSMutableArray alloc] init];
            NSMutableDictionary *updatedMessages = [[NSMutableDictionary alloc] init];
            
            NSMutableArray *addedUnimportantHolesMessages = [[NSMutableArray alloc] init];
            NSMutableArray *removedUnimportantHolesMessages = [[NSMutableArray alloc] init];
            
            int32_t addImportantUnreadCount = 0;
            int32_t addUnimportantUnreadCount = 0;
            
            NSMutableSet *skipMessages = [[NSMutableSet alloc] init];
            
            NSMutableString *queryString = [[NSMutableString alloc] init];
            for (NSUInteger i = 0; i < messages.count; ) {
                [queryString deleteCharactersInRange:NSMakeRange(0, queryString.length)];
                [queryString appendFormat:@"SELECT mid FROM %@ WHERE cid=? AND mid IN (", _channelMessagesTableName];
                NSUInteger limit = i + 1024;
                for (NSUInteger j = i; j < messages.count && j < limit; i++, j++) {
                    if (j != i) {
                        [queryString appendString:@","];
                    }
                    [queryString appendFormat:@"%d", ((TGMessage *)messages[i]).mid];
                }
                [queryString appendString:@")"];
                [_database setSoftShouldCacheStatements:false];
                FMResultSet *result = [_database executeQuery:queryString, @(peerId)];
                while ([result next]) {
                    [skipMessages addObject:@([result intForColumnIndex:0])];
                }
                [_database setSoftShouldCacheStatements:true];
            }
            
            PSKeyValueDecoder *decoder = [[PSKeyValueDecoder alloc] init];
            for (NSNumber *nMessageId in deleteMessages) {
                FMResultSet *messageResult = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT data FROM %@ WHERE cid=? AND mid=?", _channelMessagesTableName], @(peerId), nMessageId];
                if ([messageResult next]) {
                    [decoder resetData:[messageResult dataForColumnIndex:0]];
                    TGMessage *message = [[TGMessage alloc] initWithKeyValueCoder:decoder];
                    if (message.mediaAttachments.count != 0) {
                        for (TGMediaAttachment *attachment in message.mediaAttachments) {
                            if (attachment.type == TGImageMediaAttachmentType) {
                                TGImageMediaAttachment *imageMedia = (TGImageMediaAttachment *)attachment;
                                removeFileMid(self, peerId, message.mid, imageMedia.imageId != 0 ? TGImageFileType : TGLocalImageFileType, imageMedia.imageId != 0 ? imageMedia.imageId : imageMedia.localImageId);
                            }
                            else if (attachment.type == TGVideoMediaAttachmentType)
                            {
                                TGVideoMediaAttachment *videoMedia = (TGVideoMediaAttachment *)attachment;
                                removeVideoMid(self, peerId, message.mid, videoMedia.videoId != 0 ? videoMedia.videoId : videoMedia.localVideoId, videoMedia.videoId != 0);
                            }
                            else if (attachment.type == TGDocumentMediaAttachmentType)
                            {
                                TGDocumentMediaAttachment *documentMedia = (TGDocumentMediaAttachment *)attachment;
                                if (documentMedia.documentId != 0)
                                    removeFileMid(self, peerId, message.mid, TGDocumentFileType, documentMedia.documentId);
                                else if (documentMedia.localDocumentId != 0)
                                    removeFileMid(self, peerId, message.mid, TGLocalDocumentFileType, documentMedia.localDocumentId);
                            }
                            else if (attachment.type == TGAudioMediaAttachmentType)
                            {
                                TGAudioMediaAttachment *audioMedia = (TGAudioMediaAttachment *)attachment;
                                if (audioMedia.audioId != 0)
                                    removeFileMid(self, peerId, message.mid, TGAudioFileType, audioMedia.audioId);
                                else if (audioMedia.localAudioId != 0)
                                    removeFileMid(self, peerId, message.mid, TGLocalAudioFileType, audioMedia.localAudioId);
                            }
                        }
                    }
                }
                
                [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE cid=? AND mid=?", _channelMessagesTableName], @(peerId), nMessageId];
                [removedMessages addObject:nMessageId];
            }
            
            for (NSNumber *nMessageId in deleteMessages) {
                [self _deleteMessageFromUnimportantMessageGroup:peerId messageId:[nMessageId intValue] removedMessages:removedMessages updatedMessages:updatedMessages];
            }
            
            for (TGMessage *message in messages) {
                if ([skipMessages containsObject:@(message.mid)]) {
                    continue;
                }
                
                [encoder reset];
                [message encodeWithKeyValueCoder:encoder];
                
                [addedMessages addObject:message];
                
                if (TGMessageSortKeySpace(message.sortKey) == TGMessageSpaceImportant) {
                    if (!message.outgoing && message.mid > conversation.maxReadMessageId) {
                        addImportantUnreadCount++;
                    }
                    
                    if (TGMessageSortKeyCompare(message.sortKey, maxImportantSortKey) > 0) {
                        maxImportantSortKey = message.sortKey;
                        maxImportantMessage = message;
                    }
                } else {
                    if (!message.outgoing && message.mid > conversation.maxReadMessageId) {
                        addUnimportantUnreadCount++;
                    }
                    
                    if (message.mid < TGMessageLocalMidBaseline) {
                        [filledUnimportantGroups addObject:[[TGMessageGroup alloc] initWithMinId:message.mid minTimestamp:(int32_t)message.date maxId:message.mid maxTimestamp:(int32_t)message.date count:1]];
                    }
                    
                    if (TGMessageSortKeyCompare(message.sortKey, maxUnimportantSortKey) > 0) {
                        maxUnimportantSortKey = message.sortKey;
                        maxUnimportantMessage = message;
                    }
                }
                
                [_database executeUpdate:insertMessage, @(peerId), @(message.mid), TGMessageSortKeyData(message.sortKey), encoder.data, TGMessageTransparentSortKeyData(message.transparentSortKey)];
                
                if (message.mediaAttachments != nil && message.mediaAttachments.count != 0) {
                    for (TGMediaAttachment *attachment in message.mediaAttachments) {
                        if (attachment.type == TGImageMediaAttachmentType) {
                            TGImageMediaAttachment *imageMedia = (TGImageMediaAttachment *)attachment;
                            addFileMid(self, peerId, message.mid, imageMedia.imageId != 0 ? TGImageFileType : TGLocalImageFileType, imageMedia.imageId != 0 ? imageMedia.imageId : imageMedia.localImageId);
                        }
                        else if (attachment.type == TGVideoMediaAttachmentType)
                        {
                            TGVideoMediaAttachment *videoMedia = (TGVideoMediaAttachment *)attachment;
                            addVideoMid(self, peerId, message.mid, videoMedia.videoId != 0 ? videoMedia.videoId : videoMedia.localVideoId, videoMedia.videoId != 0);
                        }
                        else if (attachment.type == TGDocumentMediaAttachmentType)
                        {
                            TGDocumentMediaAttachment *documentMedia = (TGDocumentMediaAttachment *)attachment;
                            if (documentMedia.documentId != 0)
                                addFileMid(self, peerId, message.mid, TGDocumentFileType, documentMedia.documentId);
                            else if (documentMedia.localDocumentId != 0)
                                addFileMid(self, peerId, message.mid, TGLocalDocumentFileType, documentMedia.localDocumentId);
                        }
                        else if (attachment.type == TGAudioMediaAttachmentType)
                        {
                            TGAudioMediaAttachment *audioMedia = (TGAudioMediaAttachment *)attachment;
                            if (audioMedia.audioId != 0)
                                addFileMid(self, peerId, message.mid, TGAudioFileType, audioMedia.audioId);
                            else if (audioMedia.localAudioId != 0)
                                addFileMid(self, peerId, message.mid, TGLocalAudioFileType, audioMedia.localAudioId);
                        }
                    }
                }
            }
            
            for (NSUInteger i = 0; i < updatedMessageSortKeys.count; i += 2) {
                TGMessageSortKey previousSortKey = TGMessageSortKeyFromData(updatedMessageSortKeys[i + 0]);
                TGMessageSortKey updatedSortKey = TGMessageSortKeyFromData(updatedMessageSortKeys[i + 1]);
                
                if (TGMessageSortKeySpace(previousSortKey) == TGMessageSpaceUnimportant && TGMessageSortKeyMid(previousSortKey) >= TGMessageLocalMidBaseline && TGMessageSortKeyMid(updatedSortKey) < TGMessageLocalMidBaseline) {
                    [filledUnimportantGroups addObject:[[TGMessageGroup alloc] initWithMinId:TGMessageSortKeyMid(updatedSortKey) minTimestamp:TGMessageSortKeyTimestamp(updatedSortKey) maxId:TGMessageSortKeyMid(updatedSortKey) maxTimestamp:(int32_t)TGMessageSortKeyTimestamp(updatedSortKey) count:1]];
                }
            }
            
            for (TGMessageHole *hole in removedHoles) {
                [self _removeChannelHole:peerId hole:hole unimportant:false addedMessages:addedMessages removedMessages:removedMessages];
            }
            
            for (TGMessageHole *hole in removedUnimportantHoles) {
                [self _removeChannelHole:peerId hole:hole unimportant:true addedMessages:addedUnimportantHolesMessages removedMessages:removedUnimportantHolesMessages];
            }
            
            for (TGMessageGroup *group in filledUnimportantGroups) {
                [self _addChannelUnimportantMessageGroup:peerId maxId:group.maxId maxTimestamp:group.maxTimestamp minId:group.minId minTimestamp:group.minTimestamp count:group.count filled:true addedMessages:returnGroups ? addedMessages : nil removedMessages:returnGroups ? removedMessages : nil addedUnimportantHoles:addedUnimportantHolesMessages removedUnimportantHoles:removedUnimportantHolesMessages updatedMessages:updatedMessages];
            }
            
            for (TGMessageGroup *group in unimportantGroups) {
                [self _addChannelUnimportantMessageGroup:peerId maxId:group.maxId maxTimestamp:group.maxTimestamp minId:group.minId minTimestamp:group.minTimestamp count:group.count filled:false addedMessages:returnGroups ? addedMessages : nil removedMessages:returnGroups ? removedMessages : nil addedUnimportantHoles:addedUnimportantHolesMessages removedUnimportantHoles:removedUnimportantHolesMessages updatedMessages:updatedMessages];
                
                if (group.minId > conversation.maxReadMessageId) {
                    addImportantUnreadCount += group.count;
                }
            }
            
            for (TGMessageHole *hole in addedHoles) {
                [self _addChannelHole:peerId hole:hole unimportant:false addedMessages:addedMessages removedMessages:removedMessages];
            }
            
            [self cacheMediaForPeerId:peerId messages:messages];
            
            [self _updateChannelConversationSortKeys:peerId importantSortKey:maxImportantSortKey importantMessage:maxImportantMessage unimportantSortKey:maxUnimportantSortKey unimportantMessage:maxUnimportantMessage addImportantUnread:addImportantUnreadCount addUnimportantUnread:addUnimportantUnreadCount];
            
            [_database commit];
            
            [[self _channelList] commitUpdatedChannels];
            
            if (changedMessages) {
                changedMessages(addedMessages, removedMessages, updatedMessages, addedUnimportantHolesMessages, removedUnimportantHolesMessages);
            }
        } else {
            if (changedMessages) {
                changedMessages(nil, nil, nil, nil, nil);
            }
        }
    } synchronous:false];
}

- (void)addTrailingHoleToChannelAndDispatch:(int64_t)peerId messages:(NSArray *)messages pts:(int32_t)pts importantUnreadCount:(int32_t)importantUnreadCount unimportantUnreadCount:(int32_t)unimportantUnreadCount maxReadId:(int32_t)maxReadId {
    [self dispatchOnDatabaseThread:^{
        TGMessageSortKey earlierSortKey = [self _knownChannelEarlierMessageSortKey:peerId maxId:INT32_MAX];
        NSMutableArray *filteredMessages = [[NSMutableArray alloc] init];
        for (TGMessage *message in messages) {
            if (message.mid > TGMessageSortKeyMid(earlierSortKey)) {
                [filteredMessages addObject:message];
            }
        }
        [filteredMessages sortedArrayUsingComparator:^NSComparisonResult(TGMessage *lhs, TGMessage *rhs) {
            return lhs.mid < rhs.mid ? NSOrderedAscending : NSOrderedDescending;
        }];
        
        if (filteredMessages.count != 0) {
            NSMutableArray *holes = [[NSMutableArray alloc] init];
            
            for (NSUInteger i = 0; i < filteredMessages.count; i++) {
                TGMessage *message = filteredMessages[i];
                TGMessage *earlierMessage = i == filteredMessages.count - 1 ? nil : filteredMessages[i + 1];
                if (earlierMessage == nil) {
                    if (message.mid - 1 >= TGMessageSortKeyMid(earlierSortKey) + 1) {
                        [holes addObject:[[TGMessageHole alloc] initWithMinId:TGMessageSortKeyMid(earlierSortKey) + 1 minTimestamp:TGMessageSortKeyTimestamp(earlierSortKey) + 1 maxId:message.mid - 1 maxTimestamp:(int32_t)message.date]];
                    }
                } else if (earlierMessage.mid != message.mid - 1) {
                    if (message.mid - 1 >= earlierMessage.mid + 1) {
                        [holes addObject:[[TGMessageHole alloc] initWithMinId:earlierMessage.mid + 1 minTimestamp:(int32_t)earlierMessage.date + 1 maxId:message.mid - 1 maxTimestamp:(int32_t)message.date]];
                    }
                }
            }
            
            [self addMessagesToChannelAndDispatch:peerId messages:filteredMessages deletedMessages:nil holes:holes pts:pts];
            
            [self updateChannelReadState:peerId maxReadId:maxReadId unreadImportantCount:importantUnreadCount unreadUnimportantCount:unimportantUnreadCount];
        }
    } synchronous:false];
}

- (void)addMessagesToChannelAndDispatch:(int64_t)peerId messages:(NSArray *)messages deletedMessages:(NSArray *)deletedMessages holes:(NSArray *)holes pts:(int32_t)pts {
    [self dispatchOnDatabaseThread:^{
        TGConversation *conversation = [[self _loadChannelConversation:peerId] copy];
        if (pts > 0) {
            conversation.pts = pts;
        }
        if (conversation == nil) {
            TGLog(@"addMessagesToChannelAndDispatch: peerId not found");
            return;
        }
        
        PSKeyValueEncoder *encoder = [[PSKeyValueEncoder alloc] init];
        [conversation encodeWithKeyValueCoder:encoder];
        [_database executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET data=? WHERE cid=?", _channelListTableName], encoder.data, @(peerId)];
        
        [self addMessagesToChannel:peerId messages:messages deleteMessages:deletedMessages unimportantGroups:nil addedHoles:holes removedHoles:nil removedUnimportantHoles:nil updatedMessageSortKeys:nil returnGroups:true changedMessages:^(NSArray *addedMessages, NSArray *removedMessages, NSDictionary *updatedMessages, NSArray *addedUnimportantHoles, NSArray *removedUnimportantHoles) {
            NSMutableArray *addedImportantMessages = [[NSMutableArray alloc] init];
            NSMutableArray *addedUnimportantMessages = [[NSMutableArray alloc] init];
            for (TGMessage *message in addedMessages) {
                if (message.hole != nil) {
                    [addedImportantMessages addObject:message];
                    [addedUnimportantMessages addObject:message];
                }
                else if (message.group != nil) {
                    [addedImportantMessages addObject:message];
                } else if (TGMessageSortKeySpace(message.sortKey) == TGMessageSpaceImportant) {
                    [addedImportantMessages addObject:message];
                    [addedUnimportantMessages addObject:message];
                } else {
                    [addedUnimportantMessages addObject:message];
                }
            }
            
            [addedUnimportantMessages addObjectsFromArray:addedUnimportantHoles];
            
            NSMutableArray *removedImportantMessages = [[NSMutableArray alloc] init];
            NSMutableArray *removedUnimportantMessages = [[NSMutableArray alloc] init];
            
            NSMutableDictionary *updatedImportantMessages = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *updatedUnimportantMessages = [[NSMutableDictionary alloc] init];
            
            [updatedImportantMessages addEntriesFromDictionary:updatedMessages];
            [updatedUnimportantMessages addEntriesFromDictionary:updatedMessages];
            
            [removedImportantMessages addObjectsFromArray:removedMessages];
            [removedUnimportantMessages addObjectsFromArray:removedMessages];
            [removedUnimportantMessages addObjectsFromArray:removedUnimportantHoles];
            
            [ActionStageInstance() dispatchResource:[NSString stringWithFormat:@"/tg/conversation/(%lld)/importantMessages", peerId] resource:@{@"removed": removedImportantMessages, @"added": addedImportantMessages, @"updated": updatedImportantMessages}];
            [ActionStageInstance() dispatchResource:[NSString stringWithFormat:@"/tg/conversation/(%lld)/unimportantMessages", peerId] resource:@{@"removed": removedUnimportantMessages, @"added": addedUnimportantMessages, @"updated": updatedUnimportantMessages}];
        }];
    } synchronous:false];
}

- (void)updateChannelMessageSortKeyAndDispatch:(int64_t)peerId previousSortKey:(TGMessageSortKey)previousSortKey updatedSortKey:(TGMessageSortKey)updatedSortKey {
    [self dispatchOnDatabaseThread:^{
        [self addMessagesToChannel:peerId messages:nil deleteMessages:nil unimportantGroups:nil addedHoles:nil removedHoles:nil removedUnimportantHoles:nil updatedMessageSortKeys:@[TGMessageSortKeyData(previousSortKey), TGMessageSortKeyData(updatedSortKey)] returnGroups:false changedMessages:^(NSArray *addedMessages, NSArray *removedMessages, NSDictionary *updatedMessages, NSArray *addedUnimportantHoles, NSArray *removedUnimportantHoles) {
            NSMutableArray *addedImportantMessages = [[NSMutableArray alloc] init];
            NSMutableArray *addedUnimportantMessages = [[NSMutableArray alloc] init];
            for (TGMessage *message in addedMessages) {
                if (message.hole != nil) {
                    [addedImportantMessages addObject:message];
                    [addedUnimportantMessages addObject:message];
                }
                else if (message.group != nil) {
                    [addedImportantMessages addObject:message];
                } else if (TGMessageSortKeySpace(message.sortKey) == TGMessageSpaceImportant) {
                    [addedImportantMessages addObject:message];
                    [addedUnimportantMessages addObject:message];
                } else {
                    [addedUnimportantMessages addObject:message];
                }
            }
            
            [addedUnimportantMessages addObjectsFromArray:addedUnimportantHoles];
            
            NSMutableArray *removedImportantMessages = [[NSMutableArray alloc] init];
            NSMutableArray *removedUnimportantMessages = [[NSMutableArray alloc] init];
            
            NSMutableDictionary *updatedImportantMessages = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *updatedUnimportantMessages = [[NSMutableDictionary alloc] init];
            
            [updatedImportantMessages addEntriesFromDictionary:updatedMessages];
            [updatedUnimportantMessages addEntriesFromDictionary:updatedMessages];
            
            [removedImportantMessages addObjectsFromArray:removedMessages];
            [removedUnimportantMessages addObjectsFromArray:removedMessages];
            [removedUnimportantMessages addObjectsFromArray:removedUnimportantHoles];
            
            [ActionStageInstance() dispatchResource:[NSString stringWithFormat:@"/tg/conversation/(%lld)/importantMessages", peerId] resource:@{@"removed": removedImportantMessages, @"added": addedImportantMessages, @"updated": updatedImportantMessages}];
            [ActionStageInstance() dispatchResource:[NSString stringWithFormat:@"/tg/conversation/(%lld)/unimportantMessages", peerId] resource:@{@"removed": removedUnimportantMessages, @"added": addedUnimportantMessages, @"updated": updatedUnimportantMessages}];
        }];
    } synchronous:false];
}

- (void)channelPts:(int64_t)peerId completion:(void (^)(int32_t pts))completion {
    [self dispatchOnDatabaseThread:^{
        TGConversation *conversation = [self _loadChannelConversation:peerId];
        if (completion) {
            completion(conversation.pts);
        }
    } synchronous:false];
}

- (NSString *)_holesTableName:(bool)unimportant {
    return unimportant ? _channelMessageUnimportantHolesTableName : _channelMessageHolesTableName;
}

- (NSArray *)_intersectingHoles:(int64_t)peerId hole:(TGMessageHole *)hole unimportant:(bool)unimportant {
    NSMutableArray *holes = [[NSMutableArray alloc] init];
    
    FMResultSet *previousResults = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT max_id, max_timestamp, min_id, min_timestamp FROM %@ WHERE cid=? AND max_id >= ? AND max_id <= ?", [self _holesTableName:unimportant]], @(peerId), @(hole.minId), @(hole.maxId)];
    while ([previousResults next]) {
        TGMessageHole *resultHole = [[TGMessageHole alloc] initWithMinId:[previousResults intForColumnIndex:2] minTimestamp:[previousResults intForColumnIndex:3] maxId:[previousResults intForColumnIndex:0] maxTimestamp:[previousResults intForColumnIndex:1]];
        [holes addObject:resultHole];
    }
    
    FMResultSet *nextResult = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT max_id, max_timestamp, min_id, min_timestamp FROM %@ WHERE cid=? AND max_id > ? ORDER BY max_id ASC LIMIT 1", [self _holesTableName:unimportant]], @(peerId), @(hole.maxId)];
    if ([nextResult next]) {
        TGMessageHole *resultHole = [[TGMessageHole alloc] initWithMinId:[nextResult intForColumnIndex:2] minTimestamp:[nextResult intForColumnIndex:3] maxId:[nextResult intForColumnIndex:0] maxTimestamp:[nextResult intForColumnIndex:1]];
        if ([hole intersects:resultHole]) {
            [holes addObject:resultHole];
        }
    }
    
    [holes sortUsingComparator:^NSComparisonResult(TGMessageHole *lhs, TGMessageHole *rhs) {
        if (lhs.maxId < rhs.maxId) {
            return NSOrderedAscending;
        } else if (lhs.maxId > rhs.maxId) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    
    return holes;
}

- (NSArray *)_messagesFromHoles:(NSArray *)holes peerId:(int64_t)peerId {
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    for (TGMessageHole *hole in holes) {
        TGMessage *message = [[TGMessage alloc] init];
        message.cid = peerId;
        message.mid = -hole.maxId;
        message.date = hole.maxTimestamp;
        message.hole = hole;
        message.sortKey = TGMessageSortKeyMake(peerId, TGMessageSpaceHole, hole.maxTimestamp, hole.maxId);
        [messages addObject:message];
    }
    return messages;
}

- (NSArray *)_messageIdsFromHoles:(NSArray *)holes {
    NSMutableArray *messageIds = [[NSMutableArray alloc] init];
    for (TGMessageHole *hole in holes) {
        [messageIds addObject:@(-hole.maxId)];
    }
    return messageIds;
}

- (NSArray *)_messagesFromGroups:(NSArray *)groups peerId:(int64_t)peerId {
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    for (TGMessageGroup *group in groups) {
        TGMessage *message = [[TGMessage alloc] init];
        message.cid = peerId;
        message.mid = -group.maxId;
        message.date = group.maxTimestamp;
        message.group = group;
        message.sortKey = TGMessageSortKeyMake(peerId, TGMessageSpaceHole, group.maxTimestamp, group.maxId);
        [messages addObject:message];
    }
    return messages;
}

- (NSArray *)_messageIdsFromGroups:(NSArray *)groups {
    NSMutableArray *messageIds = [[NSMutableArray alloc] init];
    for (TGMessageGroup *group in groups) {
        [messageIds addObject:@(-group.maxId)];
    }
    return messageIds;
}

- (void)_addChannelHole:(int64_t)peerId hole:(TGMessageHole *)hole unimportant:(bool)unimportant addedMessages:(NSMutableArray *)addedMessages removedMessages:(NSMutableArray *)removedMessages {
    NSArray *intersectedHoles = [self _intersectingHoles:peerId hole:hole unimportant:unimportant];
    if (intersectedHoles.count == 0) {
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT INTO %@ (cid, max_id, max_timestamp, min_id, min_timestamp, max_sort_key) VALUES (?, ?, ?, ?, ?, ?)", [self _holesTableName:unimportant]], @(peerId), @(hole.maxId), @(hole.maxTimestamp), @(hole.minId), @(hole.minTimestamp), TGMessageTransparentSortKeyData(TGMessageTransparentSortKeyMake(peerId, hole.maxTimestamp, hole.maxId, TGMessageSpaceHole))];
        
        [addedMessages addObjectsFromArray:[self _messagesFromHoles:@[hole] peerId:peerId]];
    } else {
        int32_t minId = hole.minId;
        int32_t minTimestamp = hole.minTimestamp;
        int32_t maxId = hole.maxId;
        int32_t maxTimestamp = hole.maxTimestamp;
        
        for (TGMessageHole *currentHole in intersectedHoles) {
            if (currentHole.maxId > maxId) {
                maxId = currentHole.maxId;
                maxTimestamp = currentHole.maxTimestamp;
            }
            if (currentHole.minId < minId) {
                minId = currentHole.minId;
                minTimestamp = currentHole.minTimestamp;
            }
            [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE cid=? AND max_id=?", [self _holesTableName:unimportant]], @(peerId), @(hole.maxId)];
            
            [removedMessages addObjectsFromArray:[self _messageIdsFromHoles:@[hole]]];
        }
        
        TGMessageHole *updatedHole = [[TGMessageHole alloc] initWithMinId:minId minTimestamp:minTimestamp maxId:maxId maxTimestamp:maxTimestamp];
        [addedMessages addObjectsFromArray:[self _messagesFromHoles:@[updatedHole] peerId:peerId]];
        
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT INTO %@ (cid, max_id, max_timestamp, min_id, min_timestamp, max_sort_key) VALUES (?, ?, ?, ?, ?, ?)", [self _holesTableName:unimportant]], @(peerId), @(updatedHole.maxId), @(updatedHole.maxTimestamp), @(updatedHole.minId), @(updatedHole.minTimestamp), TGMessageTransparentSortKeyData(TGMessageTransparentSortKeyMake(peerId, updatedHole.maxTimestamp, updatedHole.maxId, TGMessageSpaceHole))];
    }
}

- (void)_removeChannelHole:(int64_t)peerId hole:(TGMessageHole *)hole unimportant:(bool)unimportant addedMessages:(NSMutableArray *)addedMessages removedMessages:(NSMutableArray *)removedMessages {
    NSArray *intersectedHoles = [self _intersectingHoles:peerId hole:hole unimportant:unimportant];
    if (intersectedHoles.count != 0) {
        NSMutableArray *addedHoles = [[NSMutableArray alloc] init];
        for (TGMessageHole *currentHole in intersectedHoles) {
            if (![hole covers:currentHole]) {
                [addedHoles addObjectsFromArray:[currentHole exclude:hole]];
            }
        }
        
        for (TGMessageHole *currentHole in intersectedHoles) {
            [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE cid=? AND max_id=?", [self _holesTableName:unimportant]], @(peerId), @(currentHole.maxId)];
        }
        
        for (TGMessageHole *addedHole in addedHoles) {
            [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT INTO %@ (cid, max_id, max_timestamp, min_id, min_timestamp, max_sort_key) VALUES (?, ?, ?, ?, ?, ?)", [self _holesTableName:unimportant]], @(peerId), @(addedHole.maxId), @(addedHole.maxTimestamp), @(addedHole.minId), @(addedHole.minTimestamp), TGMessageTransparentSortKeyData(TGMessageTransparentSortKeyMake(peerId, addedHole.maxTimestamp, addedHole.maxId, TGMessageSpaceHole))];
        }
        
        [removedMessages addObjectsFromArray:[self _messageIdsFromHoles:intersectedHoles]];
        [addedMessages addObjectsFromArray:[self _messagesFromHoles:addedHoles peerId:peerId]];
    }
}

- (NSArray *)_loadChannelHolesWithMinSortKey:(TGMessageTransparentSortKey)minSortKey maxTransparentSortKey:(TGMessageTransparentSortKey)maxSortKey unimportant:(bool)unimportant count:(NSUInteger)count {
    if (TGMessageTransparentSortKeyCompare(minSortKey, maxSortKey) < 0) {
        FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT max_id, max_timestamp, min_id, min_timestamp FROM %@ WHERE max_sort_key<=? AND max_sort_key>? ORDER BY max_sort_key DESC LIMIT ?", [self _holesTableName:unimportant]], TGMessageTransparentSortKeyData(maxSortKey), TGMessageTransparentSortKeyData(minSortKey), @(count)];
        NSMutableArray *holes = [[NSMutableArray alloc] init];
        while ([result next]) {
            TGMessageHole *hole = [[TGMessageHole alloc] initWithMinId:[result intForColumnIndex:2] minTimestamp:[result intForColumnIndex:3] maxId:[result intForColumnIndex:0] maxTimestamp:[result intForColumnIndex:1]];
            [holes addObject:hole];
        }
        
        return holes;
    } else {
        FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT max_id, max_timestamp, min_id, min_timestamp FROM %@ WHERE max_sort_key>? AND max_sort_key<? ORDER BY max_sort_key ASC LIMIT ?", [self _holesTableName:unimportant]], TGMessageTransparentSortKeyData(maxSortKey), TGMessageTransparentSortKeyData(minSortKey), @(count)];
        NSMutableArray *holes = [[NSMutableArray alloc] init];
        while ([result next]) {
            TGMessageHole *hole = [[TGMessageHole alloc] initWithMinId:[result intForColumnIndex:2] minTimestamp:[result intForColumnIndex:3] maxId:[result intForColumnIndex:0] maxTimestamp:[result intForColumnIndex:1]];
            [holes addObject:hole];
        }
        
        return holes;
    }
}

- (void)_addChannelUnimportantMessageGroup:(int64_t)peerId maxId:(int32_t)maxId maxTimestamp:(int32_t)maxTimestamp minId:(int32_t)minId minTimestamp:(int32_t)minTimestamp count:(int32_t)count filled:(bool)filled addedMessages:(NSMutableArray *)addedMessages removedMessages:(NSMutableArray *)__unused removedMessages addedUnimportantHoles:(NSMutableArray *)addedUnimportantHoles removedUnimportantHoles:(NSMutableArray *)removedUnimportantHoles updatedMessages:(NSMutableDictionary *)updatedMessages {
    FMResultSet *earlierResult = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT max_id, max_timestamp, min_id, min_timestamp, count FROM %@ WHERE cid=? AND max_id<=? ORDER BY max_id DESC LIMIT 1", _channelMessageUnimportantGroupsTableName] ,@(peerId), @(maxId)];
    TGMessageGroup *earlierGroup = nil;
    if ([earlierResult next]) {
        earlierGroup = [[TGMessageGroup alloc] initWithMinId:[earlierResult intForColumnIndex:2] minTimestamp:[earlierResult intForColumnIndex:3] maxId:[earlierResult intForColumnIndex:0] maxTimestamp:[earlierResult intForColumnIndex:1] count:[earlierResult intForColumnIndex:4]];
    }
    
    FMResultSet *laterResult = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT max_id, max_timestamp, min_id, min_timestamp, count FROM %@ WHERE cid=? AND max_id>? ORDER BY max_id ASC LIMIT 1", _channelMessageUnimportantGroupsTableName] ,@(peerId), @(maxId)];
    TGMessageGroup *laterGroup = nil;
    if ([laterResult next]) {
        laterGroup = [[TGMessageGroup alloc] initWithMinId:[laterResult intForColumnIndex:2] minTimestamp:[laterResult intForColumnIndex:3] maxId:[laterResult intForColumnIndex:0] maxTimestamp:[laterResult intForColumnIndex:1] count:[laterResult intForColumnIndex:4]];
    }
    
    FMResultSet *earlierImportantMessageResult = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT sort_key FROM %@ WHERE sort_key<=? AND sort_key>? ORDER BY sort_key DESC LIMIT 1", _channelMessagesTableName], TGMessageSortKeyData(TGMessageSortKeyMake(peerId, TGMessageSpaceImportant, maxTimestamp, maxId)), TGMessageSortKeyData(TGMessageSortKeyLowerBound(peerId, TGMessageSpaceImportant))];
    TGMessageSortKey earlierSortKey = TGMessageSortKeyLowerBound(peerId, TGMessageSpaceImportant);
    if ([earlierImportantMessageResult next]) {
        earlierSortKey = TGMessageSortKeyFromData([earlierImportantMessageResult dataForColumnIndex:0]);
    }
    
    FMResultSet *laterImportantMessageResult = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT sort_key FROM %@ WHERE sort_key>? AND sort_key<? ORDER BY sort_key ASC LIMIT 1", _channelMessagesTableName], TGMessageSortKeyData(TGMessageSortKeyMake(peerId, TGMessageSpaceImportant, maxTimestamp, maxId)), TGMessageSortKeyData(TGMessageSortKeyUpperBound(peerId, TGMessageSpaceImportant))];
    TGMessageSortKey laterSortKey = TGMessageSortKeyUpperBound(peerId, TGMessageSpaceImportant);
    if ([laterImportantMessageResult next]) {
        laterSortKey = TGMessageSortKeyFromData([laterImportantMessageResult dataForColumnIndex:0]);
    }
    
    if (earlierGroup != nil && TGMessageSortKeyCompare(earlierSortKey, TGMessageSortKeyMake(peerId, TGMessageSpaceImportant, earlierGroup.maxTimestamp, earlierGroup.maxId)) < 0) {
        int32_t updatedCount = 0;
        if (minId <= earlierGroup.minId) {
            updatedCount = count;
        } else if (!filled || minId > earlierGroup.maxId) {
            updatedCount = count + earlierGroup.count;
        } else {
            updatedCount = earlierGroup.count;
        }
        
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE cid=? AND max_id=?", _channelMessageUnimportantGroupsTableName], @(peerId), @(earlierGroup.maxId)];
        
        int32_t updatedMinId = 0;
        int32_t updatedMinTimestamp = 0;
        if (minId < earlierGroup.minId) {
            updatedMinId = minId;
            updatedMinTimestamp = minTimestamp;
        } else {
            updatedMinId = earlierGroup.minId;
            updatedMinTimestamp = earlierGroup.minTimestamp;
        }
        
        int32_t updatedMaxId = 0;
        int32_t updatedMaxTimestamp = 0;
        if (maxId > earlierGroup.maxId) {
            updatedMaxId = maxId;
            updatedMaxTimestamp = maxTimestamp;
        } else {
            updatedMaxId = earlierGroup.maxId;
            updatedMaxTimestamp = earlierGroup.maxTimestamp;
        }
        
        TGMessageGroup *updatedGroup = [[TGMessageGroup alloc] initWithMinId:updatedMinId minTimestamp:updatedMinTimestamp maxId:updatedMaxId maxTimestamp:updatedMaxTimestamp count:updatedCount];
        
        if (!filled) {
            [self _addChannelHole:peerId hole:[[TGMessageHole alloc] initWithMinId:minId minTimestamp:minTimestamp maxId:maxId maxTimestamp:maxTimestamp] unimportant:true addedMessages:addedUnimportantHoles removedMessages:removedUnimportantHoles];
        }
        
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT INTO %@ (cid, max_id, max_timestamp, min_id, min_timestamp, max_sort_key, count) VALUES (?, ?, ?, ?, ?, ?, ?)", _channelMessageUnimportantGroupsTableName], @(peerId), @(updatedGroup.maxId), @(updatedGroup.maxTimestamp), @(updatedGroup.minId), @(updatedGroup.minTimestamp), TGMessageTransparentSortKeyData(TGMessageTransparentSortKeyMake(peerId, updatedGroup.maxTimestamp, updatedGroup.maxId, TGMessageSpaceUnimportantGroup)), @(updatedGroup.count)];
        
        updatedMessages[[self _messageIdsFromGroups:@[earlierGroup]][0]] = [self _messagesFromGroups:@[updatedGroup] peerId:peerId][0];
    } else if (laterGroup != nil && TGMessageSortKeyMid(laterSortKey) > laterGroup.minId) {
        int32_t updatedCount = 0;
        if (maxId >= laterGroup.maxId) {
            updatedCount = count;
        } else if (!filled || maxId < laterGroup.minId) {
            updatedCount = count + laterGroup.count;
        } else {
            updatedCount = laterGroup.count;
        }
        
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE cid=? AND max_id=?", _channelMessageUnimportantGroupsTableName], @(peerId), @(laterGroup.maxId)];
        
        int32_t updatedMinId = 0;
        int32_t updatedMinTimestamp = 0;
        if (minId < laterGroup.minId) {
            updatedMinId = minId;
            updatedMinTimestamp = minTimestamp;
        } else {
            updatedMinId = laterGroup.minId;
            updatedMinTimestamp = laterGroup.minTimestamp;
        }
        
        int32_t updatedMaxId = 0;
        int32_t updatedMaxTimestamp = 0;
        if (maxId > laterGroup.maxId) {
            updatedMaxId = maxId;
            updatedMaxTimestamp = maxTimestamp;
        } else {
            updatedMaxId = laterGroup.maxId;
            updatedMaxTimestamp = laterGroup.maxTimestamp;
        }
        
        TGMessageGroup *updatedGroup = [[TGMessageGroup alloc] initWithMinId:updatedMinId minTimestamp:updatedMinTimestamp maxId:updatedMaxId maxTimestamp:updatedMaxTimestamp count:updatedCount];
        
        if (!filled) {
            [self _addChannelHole:peerId hole:[[TGMessageHole alloc] initWithMinId:minId minTimestamp:minTimestamp maxId:maxId maxTimestamp:maxTimestamp] unimportant:true addedMessages:addedUnimportantHoles removedMessages:removedUnimportantHoles];
        }
        
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT INTO %@ (cid, max_id, max_timestamp, min_id, min_timestamp, max_sort_key, count) VALUES (?, ?, ?, ?, ?, ?, ?)", _channelMessageUnimportantGroupsTableName], @(peerId), @(updatedGroup.maxId), @(updatedGroup.maxTimestamp), @(updatedGroup.minId), @(updatedGroup.minTimestamp), TGMessageTransparentSortKeyData(TGMessageTransparentSortKeyMake(peerId, updatedGroup.maxTimestamp, updatedGroup.maxId, TGMessageSpaceUnimportantGroup)), @(updatedGroup.count)];
        
        updatedMessages[[self _messageIdsFromGroups:@[laterGroup]][0]] = [self _messagesFromGroups:@[updatedGroup] peerId:peerId][0];
    } else {
        TGMessageGroup *updatedGroup = [[TGMessageGroup alloc] initWithMinId:minId minTimestamp:minTimestamp maxId:maxId maxTimestamp:maxTimestamp count:count];
        
        if (!filled && maxId > earlierGroup.maxId) {
            [self _addChannelHole:peerId hole:[[TGMessageHole alloc] initWithMinId:minId minTimestamp:minTimestamp maxId:maxId maxTimestamp:maxTimestamp] unimportant:true addedMessages:addedUnimportantHoles removedMessages:removedUnimportantHoles];
        }
        
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT INTO %@ (cid, max_id, max_timestamp, min_id, min_timestamp, max_sort_key, count) VALUES (?, ?, ?, ?, ?, ?, ?)", _channelMessageUnimportantGroupsTableName], @(peerId), @(updatedGroup.maxId), @(updatedGroup.maxTimestamp), @(updatedGroup.minId), @(updatedGroup.minTimestamp), TGMessageTransparentSortKeyData(TGMessageTransparentSortKeyMake(peerId, updatedGroup.maxTimestamp, updatedGroup.maxId, TGMessageSpaceUnimportantGroup)), @(updatedGroup.count)];
        
        [addedMessages addObjectsFromArray:[self _messagesFromGroups:@[updatedGroup] peerId:peerId]];
    }
}

- (void)_deleteMessageFromUnimportantMessageGroup:(int64_t)peerId messageId:(int32_t)messageId removedMessages:(NSMutableArray *)removedMessages updatedMessages:(NSMutableDictionary *)updatedMessages {
    FMResultSet *laterResult = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT max_id, max_timestamp, min_id, min_timestamp, count FROM %@ WHERE cid=? AND max_id>=? ORDER BY max_id ASC LIMIT 1", _channelMessageUnimportantGroupsTableName] ,@(peerId), @(messageId)];
    TGMessageGroup *laterGroup = nil;
    if ([laterResult next]) {
        laterGroup = [[TGMessageGroup alloc] initWithMinId:[laterResult intForColumnIndex:2] minTimestamp:[laterResult intForColumnIndex:3] maxId:[laterResult intForColumnIndex:0] maxTimestamp:[laterResult intForColumnIndex:1] count:[laterResult intForColumnIndex:4]];
    }
    
    if (laterGroup != nil && laterGroup.minId <= messageId && laterGroup.maxId >= messageId) {
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE cid=? AND max_id=?", _channelMessageUnimportantGroupsTableName], @(peerId), @(laterGroup.maxId)];
        
        if (laterGroup.count == 1) {
            [removedMessages addObjectsFromArray:[self _messageIdsFromGroups:@[laterGroup]]];
        } else {
            TGMessageGroup *updatedGroup = [[TGMessageGroup alloc] initWithMinId:laterGroup.minId minTimestamp:laterGroup.minTimestamp maxId:laterGroup.maxId maxTimestamp:laterGroup.maxTimestamp count:laterGroup.count - 1];
            
            [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT INTO %@ (cid, max_id, max_timestamp, min_id, min_timestamp, max_sort_key, count) VALUES (?, ?, ?, ?, ?, ?, ?)", _channelMessageUnimportantGroupsTableName], @(peerId), @(updatedGroup.maxId), @(updatedGroup.maxTimestamp), @(updatedGroup.minId), @(updatedGroup.minTimestamp), TGMessageTransparentSortKeyData(TGMessageTransparentSortKeyMake(peerId, updatedGroup.maxTimestamp, updatedGroup.maxId, TGMessageSpaceUnimportantGroup)), @(updatedGroup.count)];
            
            updatedMessages[[self _messageIdsFromGroups:@[laterGroup]][0]] = [self _messagesFromGroups:@[updatedGroup] peerId:peerId][0];
        }
    }
}

- (NSArray *)_loadChannelUnimportantGroupsWithMinSortKey:(TGMessageTransparentSortKey)minSortKey maxTransparentSortKey:(TGMessageTransparentSortKey)maxSortKey count:(NSUInteger)count {
    if (TGMessageTransparentSortKeyCompare(minSortKey, maxSortKey) < 0) {
        FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT max_id, max_timestamp, min_id, min_timestamp, count FROM %@ WHERE max_sort_key<=? AND max_sort_key>? ORDER BY max_sort_key DESC LIMIT ?", _channelMessageUnimportantGroupsTableName], TGMessageTransparentSortKeyData(maxSortKey), TGMessageTransparentSortKeyData(minSortKey), @(count)];
        NSMutableArray *groups = [[NSMutableArray alloc] init];
        while ([result next]) {
            TGMessageGroup *group = [[TGMessageGroup alloc] initWithMinId:[result intForColumnIndex:2] minTimestamp:[result intForColumnIndex:3] maxId:[result intForColumnIndex:0] maxTimestamp:[result intForColumnIndex:1] count:[result intForColumnIndex:4]];
            [groups addObject:group];
        }
        
        return groups;
    } else {
        FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT max_id, max_timestamp, min_id, min_timestamp, count FROM %@ WHERE max_sort_key>? AND max_sort_key<? ORDER BY max_sort_key ASC LIMIT ?", _channelMessageUnimportantGroupsTableName], TGMessageTransparentSortKeyData(maxSortKey), TGMessageTransparentSortKeyData(minSortKey), @(count)];
        NSMutableArray *groups = [[NSMutableArray alloc] init];
        while ([result next]) {
            TGMessageGroup *group = [[TGMessageGroup alloc] initWithMinId:[result intForColumnIndex:2] minTimestamp:[result intForColumnIndex:3] maxId:[result intForColumnIndex:0] maxTimestamp:[result intForColumnIndex:1] count:[result intForColumnIndex:4]];
            [groups addObject:group];
        }
        
        return groups;
    }
}

- (NSArray *)_loadChannelList {
    FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT data FROM %@ WHERE variant_sort_key>? AND variant_sort_key<? ORDER BY variant_sort_key DESC", _channelListTableName], TGConversationSortKeyData(TGConversationSortKeyLowerBound(TGConversationKindPersistentChannel)), TGConversationSortKeyData(TGConversationSortKeyUpperBound(TGConversationKindPersistentChannel))];
    NSMutableArray *channels = [[NSMutableArray alloc] init];
    PSKeyValueDecoder *decoder = [[PSKeyValueDecoder alloc] init];
    while ([result next]) {
        [decoder resetData:[result dataForColumnIndex:0]];
        TGConversation *conversation = [[TGConversation alloc] initWithKeyValueCoder:decoder];
        
        TGMessage *importantMessage = [self _topChannelMessage:conversation.conversationId important:true];
        TGMessage *unimportantMessage = [self _topChannelMessage:conversation.conversationId important:false];
        
        if (conversation.conversationId != 0) {
            if (conversation.displayVariant == TGChannelDisplayVariantImportant) {
                if (importantMessage != nil) {
                    [conversation mergeMessage:importantMessage];
                }
            } else {
                if (importantMessage != nil && unimportantMessage != nil && TGMessageSortKeyCompare(importantMessage.sortKey, unimportantMessage.sortKey) > 0) {
                    [conversation mergeMessage:importantMessage];
                } else if (unimportantMessage != nil) {
                    [conversation mergeMessage:unimportantMessage];
                }
            }
            [channels addObject:conversation];
        }
    }
    
    return channels;
}

- (TGChannelList *)_channelList {
    if (_storedChannelList == nil) {
        _storedChannelList = [[TGChannelList alloc] initWithChannels:[self _loadChannelList]];
    }
    return _storedChannelList;
}

- (void)channelMessages:(int64_t)peerId maxTransparentSortKey:(TGMessageTransparentSortKey)maxSortKey count:(NSUInteger)count important:(bool)important mode:(TGChannelHistoryRequestMode)mode completion:(void (^)(NSArray *messages, bool hasLater))completion {
    [self dispatchOnDatabaseThread:^{
        NSMutableArray *result = [[NSMutableArray alloc] init];
        NSMutableArray *laterResult = [[NSMutableArray alloc] init];
        
        if (important) {
            if (mode & TGChannelHistoryRequestEarlier) {
                [result addObjectsFromArray:[self _loadChannelImportantMessagesWithMinSortKey:TGMessageTransparentSortKeyLowerBound(peerId) maxSortKey:maxSortKey count:count]];
            }
            if (mode & TGChannelHistoryRequestLater) {
                [laterResult addObjectsFromArray:[self _loadChannelImportantMessagesWithMinSortKey:TGMessageTransparentSortKeyUpperBound(peerId) maxSortKey:maxSortKey count:count]];
            }
        } else {
            if (mode & TGChannelHistoryRequestEarlier) {
                [result addObjectsFromArray:[self _loadChannelMessagesWithMinSortKey:TGMessageTransparentSortKeyLowerBound(peerId) maxSortKey:maxSortKey count:count]];
            }
            if (mode & TGChannelHistoryRequestLater) {
                [laterResult addObjectsFromArray:[self _loadChannelMessagesWithMinSortKey:TGMessageTransparentSortKeyUpperBound(peerId) maxSortKey:maxSortKey count:count]];
            }
        }
        
        if (mode & TGChannelHistoryRequestEarlier) {
            NSArray *holes = [self _loadChannelHolesWithMinSortKey:TGMessageTransparentSortKeyLowerBound(peerId) maxTransparentSortKey:maxSortKey unimportant:false count:count];
            [result addObjectsFromArray:[self _messagesFromHoles:holes peerId:peerId]];
        }
        
        if (mode & TGChannelHistoryRequestLater) {
            NSArray *laterHoles = [self _loadChannelHolesWithMinSortKey:TGMessageTransparentSortKeyUpperBound(peerId) maxTransparentSortKey:maxSortKey unimportant:false count:count];
            [laterResult addObjectsFromArray:[self _messagesFromHoles:laterHoles peerId:peerId]];
        }
        
        if (!important) {
            if (mode & TGChannelHistoryRequestEarlier) {
                NSArray *unimportantHoles = [self _loadChannelHolesWithMinSortKey:TGMessageTransparentSortKeyLowerBound(peerId) maxTransparentSortKey:maxSortKey unimportant:true count:count];
                [result addObjectsFromArray:[self _messagesFromHoles:unimportantHoles peerId:peerId]];
            }
            
            if (mode & TGChannelHistoryRequestLater) {
                NSArray *unimportantLaterHoles = [self _loadChannelHolesWithMinSortKey:TGMessageTransparentSortKeyUpperBound(peerId) maxTransparentSortKey:maxSortKey unimportant:true count:count];
                [laterResult addObjectsFromArray:[self _messagesFromHoles:unimportantLaterHoles peerId:peerId]];
            }
        }
        
        if (important) {
            if (mode & TGChannelHistoryRequestEarlier) {
                NSArray *groups = [self _loadChannelUnimportantGroupsWithMinSortKey:TGMessageTransparentSortKeyLowerBound(peerId) maxTransparentSortKey:maxSortKey count:count];
                [result addObjectsFromArray:[self _messagesFromGroups:groups peerId:peerId]];
            }
            
            if (mode & TGChannelHistoryRequestLater) {
                NSArray *laterGroups = [self _loadChannelUnimportantGroupsWithMinSortKey:TGMessageTransparentSortKeyUpperBound(peerId) maxTransparentSortKey:maxSortKey count:count];
                [laterResult addObjectsFromArray:[self _messagesFromGroups:laterGroups peerId:peerId]];
            }
        }
        
        [result sortUsingComparator:^NSComparisonResult(TGMessage *lhs, TGMessage *rhs) {
            int result = TGMessageTransparentSortKeyCompare(lhs.transparentSortKey, rhs.transparentSortKey);
            if (result < 0) {
                return NSOrderedDescending;
            } else if (result > 0) {
                return NSOrderedAscending;
            } else {
                return NSOrderedSame;
            }
        }];
        
        [laterResult sortUsingComparator:^NSComparisonResult(TGMessage *lhs, TGMessage *rhs) {
            int result = TGMessageTransparentSortKeyCompare(lhs.transparentSortKey, rhs.transparentSortKey);
            if (result < 0) {
                return NSOrderedAscending;
            } else if (result > 0) {
                return NSOrderedDescending;
            } else {
                return NSOrderedSame;
            }
        }];
        
        if (result.count > count) {
            [result removeObjectsInRange:NSMakeRange(count, result.count - count)];
        }
        
        if (laterResult.count > count) {
            [laterResult removeObjectsInRange:NSMakeRange(count, laterResult.count - count)];
        }
        
        [result addObjectsFromArray:laterResult];
        
        [result sortUsingComparator:^NSComparisonResult(TGMessage *lhs, TGMessage *rhs) {
            int result = TGMessageTransparentSortKeyCompare(lhs.transparentSortKey, rhs.transparentSortKey);
            if (result < 0) {
                return NSOrderedDescending;
            } else if (result > 0) {
                return NSOrderedAscending;
            } else {
                return NSOrderedSame;
            }
        }];
        
        completion(result, laterResult.count != 0);
    } synchronous:false];
}

- (void)channelMessageExists:(int64_t)peerId messageId:(int32_t)messageId completion:(void (^)(bool exists, TGMessageSortKey key))completion {
    [self dispatchOnDatabaseThread:^{
        FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT sort_key FROM %@ WHERE cid=? AND mid=?", _channelMessagesTableName], @(peerId), @(messageId)];
        bool exists = false;
        TGMessageSortKey sortKey = TGMessageSortKeyUpperBound(peerId, 0);
        if ([result next]) {
            exists = true;
            sortKey = TGMessageSortKeyFromData([result dataForColumnIndex:0]);
        }
        if (completion) {
            completion(exists, sortKey);
        }
    } synchronous:false];
}

- (void)channelEarlierMessage:(int64_t)peerId messageId:(int32_t)messageId timestamp:(int32_t)timestamp important:(bool)important completion:(void (^)(bool exists, TGMessageSortKey key))completion {
    [self dispatchOnDatabaseThread:^{
        uint8_t space = important ? TGMessageSpaceImportant : TGMessageSpaceUnimportant;
        FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT sort_key FROM %@ WHERE sort_key > ? AND sort_key <= ? ORDER BY sort_key DESC LIMIT 1", _channelMessagesTableName], TGMessageSortKeyData(TGMessageSortKeyLowerBound(peerId, space)), TGMessageSortKeyData(TGMessageSortKeyMake(peerId, space, timestamp, messageId))];
        bool exists = false;
        TGMessageSortKey sortKey = TGMessageSortKeyUpperBound(peerId, space);
        if ([result next]) {
            exists = true;
            sortKey = TGMessageSortKeyFromData([result dataForColumnIndex:0]);
        }
        if (completion) {
            completion(exists, sortKey);
        }
    } synchronous:false];
}

- (SSignal *)existingChannel:(int64_t)peerId {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        SMetaDisposable *disposable = [[SMetaDisposable alloc] init];
        
        [self dispatchOnDatabaseThread:^{
            TGConversation *conversation = [self _loadChannelConversation:peerId];
            if (conversation != nil) {
                [subscriber putNext:conversation];
            }

            SPipe *pipe = _existingChannelPipes[@(peerId)];
            if (pipe == nil) {
                pipe = [[SPipe alloc] init];
                _existingChannelPipes[@(peerId)] = pipe;
            }
            
            [disposable setDisposable:[pipe.signalProducer() startWithNext:^(TGConversation *next) {
                [subscriber putNext:next];
            }]];
        } synchronous:false];
        
        return disposable;
    }];
}

- (bool)_channelExists:(int64_t)peerId {
    __block bool exists = false;
    [self dispatchOnDatabaseThread:^{
        exists = [self _loadChannelConversation:peerId] != nil;
    } synchronous:true];
    
    return exists;
}

- (NSDictionary *)loadChannels:(NSArray *)peerIds {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [self dispatchOnDatabaseThread:^{
        for (NSNumber *nPeerId in peerIds) {
            TGConversation *conversation = [self _loadChannelConversation:[nPeerId longLongValue]];
            if (conversation != nil) {
                dict[@(conversation.conversationId)] = conversation;
            }
        }
    } synchronous:true];
    return dict;
}

- (SSignal *)areChannelsSynchronized {
    return [[self modify:^id{
        [self _channelList];
        
        return [SSignal single:@([self customProperty:@"channelListSynchronized"].length != 0)];
    }] switchToLatest];
}

- (SSignal *)channelList {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        [self dispatchOnDatabaseThread:^{
            [subscriber putNext:[self _loadChannelList]];
            [subscriber putCompletion];
        } synchronous:false];
        return nil;
    }];
}

- (void)enqueueDeleteChannelMessages:(int64_t)peerId messageIds:(NSArray *)messageIds {
    [self dispatchOnDatabaseThread:^{
        [_database beginTransaction];
        TGConversation *conversation = [self _loadChannelConversation:peerId];
        if (conversation != nil) {
            for (NSNumberFormatter *nMessageId in messageIds) {
                [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT OR IGNORE INTO %@ (cid, mid) VALUES (?, ?)", _channelDeleteMessagesTableName], @(peerId), nMessageId];
            }
        }
        [_database commit];
        
        if (conversation != nil) {
            _queuedDeleteChannelMessages.sink([[TGQueuedDeleteChannelMessages alloc] initWithPeerId:peerId accessHash:conversation.accessHash messageIds:messageIds]);
        }
    } synchronous:false];
}

- (void)confirmChannelMessagesDeleted:(TGQueuedDeleteChannelMessages *)messages {
    [self dispatchOnDatabaseThread:^{
        [_database beginTransaction];
        for (NSNumber *nMessageId in messages.messageIds) {
            [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE cid=? AND mid=?", _channelDeleteMessagesTableName], @(messages.peerId), nMessageId];
        }
        [_database commit];
    } synchronous:false];
}

- (void)enqueueReadChannelHistory:(int64_t)peerId {
    [self dispatchOnDatabaseThread:^{
        TGConversation *conversation = [self _loadChannelConversation:peerId];
        
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT MAX(mid) FROM %@ WHERE cid=? AND mid<?", _channelMessagesTableName], @(peerId), @(TGMessageLocalMidBaseline)];
        
        int32_t topMessageId = 1;
        if ([result next]) {
            topMessageId = [result intForColumnIndex:0];
        }
        
        if (conversation != nil && (conversation.unreadCount != 0 || conversation.serviceUnreadCount != 0)) {
            [_database beginTransaction];
            
            [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO %@ (cid, mid) VALUES (?, ?)", _channelReadHistoryTableName], @(peerId), @(topMessageId)];
            
            conversation = [conversation copy];
            conversation.unreadCount = 0;
            conversation.serviceUnreadCount = 0;
            conversation.maxReadMessageId = MAX(topMessageId, conversation.maxReadMessageId);
            PSKeyValueEncoder *encoder = [[PSKeyValueEncoder alloc] init];
            [conversation encodeWithKeyValueCoder:encoder];
            [_database executeUpdate:[[NSString alloc] initWithFormat:@"UPDATE %@ SET data=? WHERE cid=?", _channelListTableName], encoder.data, @(peerId)];
            
            [_database commit];
            
            _queuedReadChannelMessages.sink([[TGQueuedReadChannelMessages alloc] initWithPeerId:peerId accessHash:conversation.accessHash maxId:topMessageId]);
            
            [[self _channelList] updateChannel:conversation];
            [[self _channelList] commitUpdatedChannels];
        }
        
    } synchronous:false];
}

- (void)confirmChannelHistoryRead:(TGQueuedReadChannelMessages *)messages {
    [self dispatchOnDatabaseThread:^{
        [_database beginTransaction];
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE cid=? AND mid=?", _channelReadHistoryTableName], @(messages.peerId), @(messages.maxId)];
        [_database commit];
    } synchronous:false];
}

- (SSignal *)enqueuedReadChannelMessages {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        SMetaDisposable *disposable = [[SMetaDisposable alloc] init];
        
        [self dispatchOnDatabaseThread:^{
            FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT cid, mid FROM %@", _channelReadHistoryTableName]];
            NSMutableDictionary *peerIdsWithMaxId = [[NSMutableDictionary alloc] init];
            while ([result next]) {
                peerIdsWithMaxId[@([result longLongIntForColumnIndex:0])] = @([result intForColumnIndex:1]);
            }
            
            NSMutableArray *queuedReadChannelMessages = [[NSMutableArray alloc] init];
            
            [peerIdsWithMaxId enumerateKeysAndObjectsUsingBlock:^(NSNumber *nPeerId, NSNumber *nMid, __unused BOOL * _Nonnull stop) {
                TGConversation *conversation = [self _loadChannelConversation:[nPeerId longLongValue]];
                [queuedReadChannelMessages addObject:[[TGQueuedReadChannelMessages alloc] initWithPeerId:conversation.conversationId accessHash:conversation.accessHash maxId:[nMid intValue]]];
            }];
            
            for (TGQueuedDeleteChannelMessages *queued in queuedReadChannelMessages) {
                [subscriber putNext:queued];
            }
            
            [disposable setDisposable:[_queuedReadChannelMessages.signalProducer() startWithNext:^(id next) {
                [subscriber putNext:next];
            }]];
        } synchronous:false];
        
        return disposable;
    }];
}

- (SSignal *)enqueuedDeleteChannelMessages {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        SMetaDisposable *disposable = [[SMetaDisposable alloc] init];
        
        [self dispatchOnDatabaseThread:^{
            FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT cid, mid FROM %@", _channelDeleteMessagesTableName]];
            NSMutableDictionary *messageIdsByPeerId = [[NSMutableDictionary alloc] init];
            while ([result next]) {
                int64_t peerId = [result longLongIntForColumnIndex:0];
                NSMutableArray *messageIds = messageIdsByPeerId[@(peerId)];
                if (messageIds == nil) {
                    messageIds = [[NSMutableArray alloc] init];
                    messageIdsByPeerId[@(peerId)] = messageIds;
                }
                [messageIds addObject:@([result intForColumnIndex:1])];
            }
            
            NSMutableArray *queuedDeleteMessages = [[NSMutableArray alloc] init];
            [messageIdsByPeerId enumerateKeysAndObjectsUsingBlock:^(NSNumber *nPeerId, NSArray *messageIds, __unused BOOL *stop) {
                TGConversation *conversation = [self _loadChannelConversation:[nPeerId longLongValue]];
                if (conversation != nil) {
                    [queuedDeleteMessages addObject:[[TGQueuedDeleteChannelMessages alloc] initWithPeerId:[nPeerId longLongValue] accessHash:conversation.accessHash messageIds:messageIds]];
                } else {
                    [self confirmChannelMessagesDeleted:[[TGQueuedDeleteChannelMessages alloc] initWithPeerId:[nPeerId longLongValue] accessHash:0 messageIds:messageIds]];
                }
            }];
            
            for (TGQueuedDeleteChannelMessages *queued in queuedDeleteMessages) {
                [subscriber putNext:queued];
            }
            
            [disposable setDisposable:[_queuedDeleteChannelMessages.signalProducer() startWithNext:^(id next) {
                [subscriber putNext:next];
            }]];
        } synchronous:false];
        
        return disposable;
    }];
}

- (void)enqueueLeaveChannel:(int64_t)peerId {
    [self dispatchOnDatabaseThread:^{
        TGConversation *conversation = [[self _loadChannelConversation:peerId] copy];
        if (conversation != nil) {
            [TGGlobalMessageSearchSignals removeRecentPeerResult:peerId];
            
            [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO %@ (cid, access_hash) VALUES (?, ?)", _channelLeaveTableName], @(peerId), @(conversation.accessHash)];
            
            _queuedLeaveChannels.sink([[TGQueuedLeaveChannel alloc] initWithPeerId:peerId accessHash:conversation.accessHash]);
            
            conversation.kind = TGConversationKindTemporaryChannel;
            
            PSKeyValueEncoder *encoder = [[PSKeyValueEncoder alloc] init];
            [conversation encodeWithKeyValueCoder:encoder];
            
            [_database executeUpdate:[[NSString alloc] initWithFormat:@"UPDATE %@ SET data=?, variant_sort_key=? WHERE cid=?", _channelListTableName], encoder.data, TGConversationSortKeyData(conversation.variantSortKey), @(conversation.conversationId)];
            [[self _channelList] updateChannel:conversation];
            [[self _channelList] commitUpdatedChannels];
            
            TGConversation *dispatchConversation = [conversation copy];
            [ActionStageInstance() dispatchResource:@"/tg/conversations" resource:[[SGraphObjectNode alloc] initWithObject:@[dispatchConversation]]];
            
            SPipe *pipe = _existingChannelPipes[@(peerId)];
            if (pipe != nil) {
                pipe.sink(dispatchConversation);
            }
        }
    } synchronous:false];
}

- (void)confirmChannelLeaved:(TGQueuedLeaveChannel *)leaveChannel {
    [self dispatchOnDatabaseThread:^{
        [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE cid=?", _channelLeaveTableName], @(leaveChannel.peerId)];
    } synchronous:false];
}

- (SSignal *)enqueuedLeaveChannels {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        SMetaDisposable *disposable = [[SMetaDisposable alloc] init];
        
        [self dispatchOnDatabaseThread:^{
            FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT cid, access_hash FROM %@", _channelLeaveTableName]];
            NSMutableArray *leaveChannels = [[NSMutableArray alloc] init];
            while ([result next]) {
                [leaveChannels addObject:[[TGQueuedLeaveChannel alloc] initWithPeerId:[result longLongIntForColumnIndex:0] accessHash:[result longLongIntForColumnIndex:1]]];
            }
            
            for (TGQueuedLeaveChannel *queued in leaveChannels) {
                [subscriber putNext:queued];
            }
            
            [disposable setDisposable:[_queuedLeaveChannels.signalProducer() startWithNext:^(id next) {
                [subscriber putNext:next];
            }]];
        } synchronous:false];
        
        return disposable;
    }];
}

- (void)updateChannelCachedData:(int64_t)peerId block:(TGCachedConversationData *(^)(TGCachedConversationData *))block {
    [self dispatchOnDatabaseThread:^{
        FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT data FROM %@ WHERE cid=?", _channelCachedDataTableName], @(peerId)];
        TGCachedConversationData *cachedData = nil;
        if ([result next]) {
            PSKeyValueDecoder *decoder = [[PSKeyValueDecoder alloc] initWithData:[result dataForColumnIndex:0]];
            cachedData = [[TGCachedConversationData alloc] initWithKeyValueCoder:decoder];
        }
        
        cachedData = block(cachedData);
        if (cachedData != nil) {
            PSKeyValueEncoder *encoder = [[PSKeyValueEncoder alloc] init];
            [cachedData encodeWithKeyValueCoder:encoder];
            
            [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO %@ (cid, data) VALUES (?, ?)", _channelCachedDataTableName], @(peerId), encoder.data];
            
            SPipe *pipe = _cachedChannelDataPipes[@(peerId)];
            if (pipe != nil) {
                pipe.sink(cachedData);
            }
        }
    } synchronous:false];
}

- (SSignal *)channelCachedData:(int64_t)peerId {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        SMetaDisposable *disposable = [[SMetaDisposable alloc] init];
        
        [self dispatchOnDatabaseThread:^{
            FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT data FROM %@ WHERE cid=?", _channelCachedDataTableName], @(peerId)];
            if ([result next]) {
                PSKeyValueDecoder *decoder = [[PSKeyValueDecoder alloc] initWithData:[result dataForColumnIndex:0]];
                TGCachedConversationData *cachedData = [[TGCachedConversationData alloc] initWithKeyValueCoder:decoder];
                [subscriber putNext:cachedData];
            } else {
                [subscriber putNext:nil];
            }
            
            SPipe *pipe = _cachedChannelDataPipes[@(peerId)];
            if (pipe == nil) {
                pipe = [[SPipe alloc] init];
                _cachedChannelDataPipes[@(peerId)] = pipe;
            }
            
            [disposable setDisposable:[pipe.signalProducer() startWithNext:^(id next) {
                [subscriber putNext:next];
            }]];
        } synchronous:false];
        
        return disposable;
    }];
}

- (SSignal *)modify:(id (^)())block {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        [self dispatchOnDatabaseThread:^{
            id result = block();
            [subscriber putNext:result];
            [subscriber putCompletion];
        } synchronous:false];
        return nil;
    }];
}

- (SSignal *)modifyChannel:(int64_t)peerId block:(id (^)(int32_t pts))block {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        [self dispatchOnDatabaseThread:^{
            TGConversation *conversation = [self _loadChannelConversation:peerId];
            id result = block(conversation.pts);
            [subscriber putNext:result];
            [subscriber putCompletion];
        } synchronous:false];
        return nil;
    }];
}

- (void)_dropChannels {
    [self dispatchOnDatabaseThread:^{
        [self setCustomProperty:@"channelListSynchronized" value:[NSData data]];
        [_database beginTransaction];
        
        [_database executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@", _channelListTableName]];
        [_database executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@", _channelMessagesRandomIdTableName]];
        [_database executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@", _channelMessagesTableName]];
        [_database executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@", _channelMessageTagsTableName]];
        [_database executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@", _channelMessageHolesTableName]];
        [_database executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@", _channelMessageUnimportantHolesTableName]];
        [_database executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@", _channelMessageUnimportantGroupsTableName]];
        [_database executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@", _channelDeleteMessagesTableName]];
        
        [_database commit];
    } synchronous:true];
}



@end
