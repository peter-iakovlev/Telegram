#import <LegacyComponents/TGModernGalleryModel.h>

@class TGWebPageMediaAttachment;

@interface TGExternalGalleryModel : TGModernGalleryModel

@property (nonatomic, copy) void (^openLinkRequested)(NSString *url);

- (instancetype)initWithWebPage:(TGWebPageMediaAttachment *)webPage peerId:(int64_t)peerId messageId:(int32_t)messageId;

@end
