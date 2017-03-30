#import "TGContentBubbleViewModel.h"

@class TGActionMediaAttachment;

@interface TGCallMessageViewModel : TGContentBubbleViewModel

- (instancetype)initWithMessage:(TGMessage *)message actionMedia:(TGActionMediaAttachment *)actionMedia authorPeer:(id)authorPeer additionalUsers:(NSArray *)additionalUsers context:(TGModernViewContext *)context;

@end
