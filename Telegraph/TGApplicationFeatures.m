#import "TGApplicationFeatures.h"

#import "TGApplicationFeatureDescription.h"

#import "TGDatabase.h"

static bool inBatchUpdate = false;

static NSMutableDictionary *cachedFeatures()
{
    static NSMutableDictionary *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        dict = [[NSMutableDictionary alloc] init];
        
        NSData *storedData = [TGDatabaseInstance() customProperty:@"applicationFeatures"];
        if (storedData != nil)
        {
            NSArray *featureList = [NSKeyedUnarchiver unarchiveObjectWithData:storedData];
            for (TGApplicationFeatureDescription *feature in featureList)
            {
                dict[feature.identifier] = feature;
            }
        }
    });
    return dict;
}

static NSUInteger cachedLargeGroupLimit = 100;

@implementation TGApplicationFeatures

+ (bool)_isFeatureEnabledForIdentifier:(NSString *)identifier disabledMessage:(__autoreleasing NSString **)disabledMessage
{
    TGApplicationFeatureDescription *feature = cachedFeatures()[identifier];
    if (feature == nil)
        return true;
    
    if (!feature.enabled && disabledMessage)
        *disabledMessage = feature.disabledMessage;
    return feature.enabled;
}

+ (void)_setFeatureEnabledForIdentifier:(NSString *)identifier enabled:(bool)enabled disabledMessage:(NSString *)disabledMessage
{
    cachedFeatures()[identifier] = [[TGApplicationFeatureDescription alloc] initWithIdentifier:identifier enabled:enabled disabledMessage:disabledMessage];
    if (!inBatchUpdate)
        [self _storeCachedFeatures];
}

+ (bool)isGroupLarge:(NSUInteger)memberCount
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        NSData *data = [TGDatabaseInstance() customProperty:@"largeGroupMemberCountLimit"];
        if (data != nil && data.length >= 4)
        {
            int32_t value = 0;
            [data getBytes:&value length:4];
            cachedLargeGroupLimit = (NSUInteger)value;
        }
    });
    return memberCount >= cachedLargeGroupLimit;
}

+ (void)setLargeGroupMemberCountLimit:(NSUInteger)memberCount
{
    cachedLargeGroupLimit = memberCount;
    int32_t value = (int32_t)memberCount;
    [TGDatabaseInstance() setCustomProperty:@"largeGroupMemberCountLimit" value:[NSData dataWithBytes:&value length:4]];
}

+ (void)batchUpdate:(dispatch_block_t)block
{
    inBatchUpdate = true;
    block();
    inBatchUpdate = false;
    [self _storeCachedFeatures];
}

+ (void)rawUpdate:(NSArray *)features
{
    [cachedFeatures() removeAllObjects];
    for (TGApplicationFeatureDescription *feature in features)
    {
        cachedFeatures()[feature.identifier] = feature;
    }
    [self _storeCachedFeatures];
}

+ (void)_storeCachedFeatures
{
    NSData *storedData = [NSKeyedArchiver archivedDataWithRootObject:[cachedFeatures() allValues]];
    [TGDatabaseInstance() setCustomProperty:@"applicationFeatures" value:storedData];
}

+ (bool)isPhotoUploadEnabledForPeerType:(TGApplicationFeaturePeerType)peerType disabledMessage:(__autoreleasing NSString **)disabledMessage
{
    switch (peerType)
    {
        case TGApplicationFeaturePeerPrivate:
            return [self _isFeatureEnabledForIdentifier:@"pm_upload_photo" disabledMessage:disabledMessage];
        case TGApplicationFeaturePeerGroup:
            return [self _isFeatureEnabledForIdentifier:@"chat_upload_photo" disabledMessage:disabledMessage];
        case TGApplicationFeaturePeerLargeGroup:
            return [self _isFeatureEnabledForIdentifier:@"bigchat_upload_photo" disabledMessage:disabledMessage];
    }
}

+ (bool)isFileUploadEnabledForPeerType:(TGApplicationFeaturePeerType)peerType disabledMessage:(__autoreleasing NSString **)disabledMessage
{
    switch (peerType)
    {
        case TGApplicationFeaturePeerPrivate:
            return [self _isFeatureEnabledForIdentifier:@"pm_upload_document" disabledMessage:disabledMessage];
        case TGApplicationFeaturePeerGroup:
            return [self _isFeatureEnabledForIdentifier:@"chat_upload_document" disabledMessage:disabledMessage];
        case TGApplicationFeaturePeerLargeGroup:
            return [self _isFeatureEnabledForIdentifier:@"bigchat_upload_document" disabledMessage:disabledMessage];
    }
}

+ (bool)isAudioUploadEnabledForPeerType:(TGApplicationFeaturePeerType)peerType disabledMessage:(__autoreleasing NSString **)disabledMessage
{
    switch (peerType)
    {
        case TGApplicationFeaturePeerPrivate:
            return [self _isFeatureEnabledForIdentifier:@"pm_upload_audio" disabledMessage:disabledMessage];
        case TGApplicationFeaturePeerGroup:
            return [self _isFeatureEnabledForIdentifier:@"chat_upload_audio" disabledMessage:disabledMessage];
        case TGApplicationFeaturePeerLargeGroup:
            return [self _isFeatureEnabledForIdentifier:@"bigchat_upload_audio" disabledMessage:disabledMessage];
    }
}

+ (bool)isTextMessageEnabledForPeerType:(TGApplicationFeaturePeerType)peerType disabledMessage:(__autoreleasing NSString **)disabledMessage
{
    switch (peerType)
    {
        case TGApplicationFeaturePeerPrivate:
            return [self _isFeatureEnabledForIdentifier:@"pm_message" disabledMessage:disabledMessage];
        case TGApplicationFeaturePeerGroup:
            return [self _isFeatureEnabledForIdentifier:@"chat_message" disabledMessage:disabledMessage];
        case TGApplicationFeaturePeerLargeGroup:
            return [self _isFeatureEnabledForIdentifier:@"bigchat_message" disabledMessage:disabledMessage];
    }
}

+ (bool)isGroupCreationEnabled:(__autoreleasing NSString **)disabledMessage
{
    return [self _isFeatureEnabledForIdentifier:@"chat_create" disabledMessage:disabledMessage];
}

+ (bool)isBroadcastCreationEnabled:(__autoreleasing NSString **)disabledMessage
{
    return [self _isFeatureEnabledForIdentifier:@"broadcast_create" disabledMessage:disabledMessage];
}

+ (void)setIsPhotoUploadEnabledForPeerType:(TGApplicationFeaturePeerType)peerType enabled:(bool)enabled disabledMessage:(NSString *)disabledMessage
{
    switch (peerType)
    {
        case TGApplicationFeaturePeerPrivate:
            [self _setFeatureEnabledForIdentifier:@"pm_upload_photo" enabled:enabled disabledMessage:disabledMessage];
            break;
        case TGApplicationFeaturePeerGroup:
            [self _setFeatureEnabledForIdentifier:@"chat_upload_photo" enabled:enabled disabledMessage:disabledMessage];
            break;
        case TGApplicationFeaturePeerLargeGroup:
            [self _setFeatureEnabledForIdentifier:@"bigchat_upload_photo" enabled:enabled disabledMessage:disabledMessage];
            break;
        default:
            break;
    }
}

+ (void)setIsFileUploadEnabledForPeerType:(TGApplicationFeaturePeerType)peerType enabled:(bool)enabled disabledMessage:(NSString *)disabledMessage
{
    switch (peerType)
    {
        case TGApplicationFeaturePeerPrivate:
            [self _setFeatureEnabledForIdentifier:@"pm_upload_document" enabled:enabled disabledMessage:disabledMessage];
            break;
        case TGApplicationFeaturePeerGroup:
            [self _setFeatureEnabledForIdentifier:@"chat_upload_document" enabled:enabled disabledMessage:disabledMessage];
            break;
        case TGApplicationFeaturePeerLargeGroup:
            [self _setFeatureEnabledForIdentifier:@"bigchat_upload_document" enabled:enabled disabledMessage:disabledMessage];
            break;
        default:
            break;
    }
}

+ (void)setIsAudioUploadEnabledForPeerType:(TGApplicationFeaturePeerType)peerType enabled:(bool)enabled disabledMessage:(NSString *)disabledMessage
{
    switch (peerType)
    {
        case TGApplicationFeaturePeerPrivate:
            [self _setFeatureEnabledForIdentifier:@"pm_upload_audio" enabled:enabled disabledMessage:disabledMessage];
            break;
        case TGApplicationFeaturePeerGroup:
            [self _setFeatureEnabledForIdentifier:@"chat_upload_audio" enabled:enabled disabledMessage:disabledMessage];
            break;
        case TGApplicationFeaturePeerLargeGroup:
            [self _setFeatureEnabledForIdentifier:@"bigchat_upload_audio" enabled:enabled disabledMessage:disabledMessage];
            break;
        default:
            break;
    }
}

+ (void)setIsTextMessageEnabledForPeerType:(TGApplicationFeaturePeerType)peerType enabled:(bool)enabled disabledMessage:(NSString *)disabledMessage
{
    switch (peerType)
    {
        case TGApplicationFeaturePeerPrivate:
            [self _setFeatureEnabledForIdentifier:@"pm_message" enabled:enabled disabledMessage:disabledMessage];
            break;
        case TGApplicationFeaturePeerGroup:
            [self _setFeatureEnabledForIdentifier:@"chat_message" enabled:enabled disabledMessage:disabledMessage];
            break;
        case TGApplicationFeaturePeerLargeGroup:
            [self _setFeatureEnabledForIdentifier:@"bigchat_message" enabled:enabled disabledMessage:disabledMessage];
            break;
        default:
            break;
    }
}

+ (void)setIsPhotoGroupCreationEnabled:(bool)enabled disabledMessage:(NSString *)disabledMessage
{
    [self _setFeatureEnabledForIdentifier:@"chat_create" enabled:enabled disabledMessage:disabledMessage];
}

+ (void)setIsBroadcastCreationEnabled:(bool)enabled disabledMessage:(NSString *)disabledMessage
{
    [self _setFeatureEnabledForIdentifier:@"broadcast_create" enabled:enabled disabledMessage:disabledMessage];
}

@end
