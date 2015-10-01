#import <SSignalKit/SSignalKit.h>
#import "TGBridgeMediaSubscription.h"

@class TGBridgeImageMediaAttachment;
@class TGBridgeVideoMediaAttachment;
@class TGBridgeDocumentMediaAttachment;

typedef enum
{
    TGMediaStickerImageTypeList,
    TGMediaStickerImageTypeNormal,
    TGMediaStickerImageTypeInput
} TGMediaStickerImageType;

@interface TGBridgeMediaSignals : NSObject

+ (SSignal *)previewWithImageAttachment:(TGBridgeImageMediaAttachment *)imageAttachment size:(CGSize)size;
+ (SSignal *)previewWithVideoAttachment:(TGBridgeVideoMediaAttachment *)videoAttachment size:(CGSize)size;

+ (SSignal *)avatarWithUrl:(NSString *)url type:(TGBridgeMediaAvatarType)type;

+ (SSignal *)stickerWithDocumentAttachment:(TGBridgeDocumentMediaAttachment *)documentAttachment type:(TGMediaStickerImageType)type;

@end
