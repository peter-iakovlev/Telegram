#import "TGModernGalleryModel.h"

@class TGMessage;

@interface TGGifGalleryModel : TGModernGalleryModel

@property (nonatomic, copy) void (^shareAction)(TGMessage *message, NSArray *peerIds, NSString *caption);

- (instancetype)initWithMessage:(TGMessage *)message;

@end
