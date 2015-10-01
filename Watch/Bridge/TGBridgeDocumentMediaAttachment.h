#import "TGBridgeMediaAttachment.h"

@interface TGBridgeDocumentMediaAttachment : TGBridgeMediaAttachment

@property (nonatomic, assign) int64_t documentId;
@property (nonatomic, assign) int64_t accessHash;
@property (nonatomic, assign) int32_t datacenterId;
@property (nonatomic, strong) NSString *legacyThumbnailUri;

@property (nonatomic, assign) int32_t fileSize;

@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSValue *imageSize;
@property (nonatomic, assign) bool isAnimated;
@property (nonatomic, assign) bool isSticker;
@property (nonatomic, strong) NSString *stickerAlt;

@property (nonatomic, assign) bool isAudio;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *performer;

@end
