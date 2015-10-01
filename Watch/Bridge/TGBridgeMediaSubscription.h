#import "TGBridgeSubscription.h"
#import <CoreGraphics/CoreGraphics.h>

@class TGBridgeImageMediaAttachment;
@class TGBridgeVideoMediaAttachment;

@interface TGBridgeMediaPhotoThumbnailSubscription : TGBridgeSubscription

@property (nonatomic, readonly) TGBridgeImageMediaAttachment *imageAttachment;
@property (nonatomic, readonly) CGSize size;

- (instancetype)initWithImageAttachment:(TGBridgeImageMediaAttachment *)imageAttachment size:(CGSize)size;

@end

@interface TGBridgeMediaVideoThumbnailSubscription : TGBridgeSubscription

@property (nonatomic, readonly) TGBridgeVideoMediaAttachment *videoAttachment;
@property (nonatomic, readonly) CGSize size;

- (instancetype)initWithVideoAttachment:(TGBridgeVideoMediaAttachment *)videoAttachment size:(CGSize)size;

@end

typedef NS_ENUM(NSUInteger, TGBridgeMediaAvatarType) {
    TGBridgeMediaAvatarTypeSmall,
    TGBridgeMediaAvatarTypeProfile,
    TGBridgeMediaAvatarTypeLarge
};

@interface TGBridgeMediaAvatarSubscription : TGBridgeSubscription

@property (nonatomic, readonly) NSString *url;
@property (nonatomic, readonly) TGBridgeMediaAvatarType type;

- (instancetype)initWithUrl:(NSString *)url type:(TGBridgeMediaAvatarType)type;

@end

@interface TGBridgeMediaStickerSubscription : TGBridgeSubscription

@property (nonatomic, readonly) int64_t documentId;
@property (nonatomic, readonly) int64_t accessHash;
@property (nonatomic, readonly) int32_t datacenterId;
@property (nonatomic, readonly) NSString *legacyThumbnailUri;
@property (nonatomic, readonly) CGSize size;

- (instancetype)initWithDocumentId:(int64_t)documentId accessHash:(int64_t)accessHash datacenterId:(int32_t)datacenterId legacyThumbnailUri:(NSString *)legacyThumbnailUri size:(CGSize)size;

@end
