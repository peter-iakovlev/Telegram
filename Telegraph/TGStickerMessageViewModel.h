#import "TGMessageViewModel.h"

@class TGMessage;
@class TGDocumentMediaAttachment;

@interface TGStickerMessageViewModel : TGMessageViewModel

- (instancetype)initWithMessage:(TGMessage *)message document:(TGDocumentMediaAttachment *)document size:(CGSize)size authorPeer:(id)authorPeer context:(TGModernViewContext *)context replyHeader:(TGMessage *)replyHeader replyPeer:(id)replyPeer viaUser:(TGUser *)viaUser;

@end
