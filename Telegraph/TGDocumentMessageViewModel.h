#import "TGContentBubbleViewModel.h"

@class TGDocumentMediaAttachment;

@interface TGDocumentMessageViewModel : TGContentBubbleViewModel

- (instancetype)initWithMessage:(TGMessage *)message document:(TGDocumentMediaAttachment *)document author:(TGUser *)author context:(TGModernViewContext *)context;

@end
