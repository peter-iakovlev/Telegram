#import "TGContentBubbleViewModel.h"

@class TGDocumentMediaAttachment;

@interface TGDocumentMessageViewModel : TGContentBubbleViewModel

- (instancetype)initWithMessage:(TGMessage *)message document:(TGDocumentMediaAttachment *)document authorPeer:(id)authorPeer context:(TGModernViewContext *)context;

@end
