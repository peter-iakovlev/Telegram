#import <Foundation/Foundation.h>

typedef enum {
    TGApplicationFeaturePeerPrivate,
    TGApplicationFeaturePeerGroup,
    TGApplicationFeaturePeerLargeGroup
} TGApplicationFeaturePeerType;

@interface TGApplicationFeatures : NSObject

+ (bool)isGroupLarge:(NSUInteger)memberCount;
+ (void)setLargeGroupMemberCountLimit:(NSUInteger)memberCount;

+ (bool)isPhotoUploadEnabledForPeerType:(TGApplicationFeaturePeerType)peerType disabledMessage:(__autoreleasing NSString **)disabledMessage;
+ (bool)isFileUploadEnabledForPeerType:(TGApplicationFeaturePeerType)peerType disabledMessage:(__autoreleasing NSString **)disabledMessage;
+ (bool)isAudioUploadEnabledForPeerType:(TGApplicationFeaturePeerType)peerType disabledMessage:(__autoreleasing NSString **)disabledMessage;
+ (bool)isTextMessageEnabledForPeerType:(TGApplicationFeaturePeerType)peerType disabledMessage:(__autoreleasing NSString **)disabledMessage;
+ (bool)isGroupCreationEnabled:(__autoreleasing NSString **)disabledMessage;
+ (bool)isBroadcastCreationEnabled:(__autoreleasing NSString **)disabledMessage;

+ (void)batchUpdate:(dispatch_block_t)block;
+ (void)rawUpdate:(NSArray *)features;
+ (void)setIsPhotoUploadEnabledForPeerType:(TGApplicationFeaturePeerType)peerType enabled:(bool)enabled disabledMessage:(NSString *)disabledMessage;
+ (void)setIsFileUploadEnabledForPeerType:(TGApplicationFeaturePeerType)peerType enabled:(bool)enabled disabledMessage:(NSString *)disabledMessage;
+ (void)setIsAudioUploadEnabledForPeerType:(TGApplicationFeaturePeerType)peerType enabled:(bool)enabled disabledMessage:(NSString *)disabledMessage;
+ (void)setIsTextMessageEnabledForPeerType:(TGApplicationFeaturePeerType)peerType enabled:(bool)enabled disabledMessage:(NSString *)disabledMessage;
+ (void)setIsPhotoGroupCreationEnabled:(bool)enabled disabledMessage:(NSString *)disabledMessage;
+ (void)setIsBroadcastCreationEnabled:(bool)enabled disabledMessage:(NSString *)disabledMessage;

@end
