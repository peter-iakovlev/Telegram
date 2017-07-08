#import "TGMessageViewModel.h"

@class TGVideoMediaAttachment;

@interface TGRoundMessageViewModel : TGMessageViewModel

- (instancetype)initWithMessage:(TGMessage *)message video:(TGVideoMediaAttachment *)video authorPeer:(id)authorPeer context:(TGModernViewContext *)context forwardPeer:(id)forwardPeer forwardAuthor:(id)forwardAuthor forwardMessageId:(int32_t)forwardMessageId replyHeader:(TGMessage *)replyHeader replyPeer:(id)replyPeer;

@end
