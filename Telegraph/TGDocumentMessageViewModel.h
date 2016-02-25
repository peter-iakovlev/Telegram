#import "TGContentBubbleViewModel.h"

@class TGDocumentMediaAttachment;

@interface TGDocumentMessageViewModel : TGContentBubbleViewModel

- (instancetype)initWithMessage:(TGMessage *)message document:(TGDocumentMediaAttachment *)document authorPeer:(id)authorPeer viaUser:(TGUser *)viaUser context:(TGModernViewContext *)context;

@end
