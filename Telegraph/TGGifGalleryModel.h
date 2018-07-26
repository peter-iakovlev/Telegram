#import <LegacyComponents/TGModernGalleryModel.h>

@class TGMessage;

@interface TGGifGalleryModel : TGModernGalleryModel

@property (nonatomic, copy) void (^shareAction)(TGMessage *message, NSArray *peerIds, NSString *caption);
@property (nonatomic, copy) void (^openLinkRequested)(NSString *url);

- (instancetype)initWithMessage:(TGMessage *)message;

@end
