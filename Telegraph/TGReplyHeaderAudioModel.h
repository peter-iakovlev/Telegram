#import "TGReplyHeaderModel.h"

@class TGUser;
@class TGAudioMediaAttachment;

@interface TGReplyHeaderAudioModel : TGReplyHeaderModel

- (instancetype)initWithPeer:(id)peer audioMedia:(TGAudioMediaAttachment *)audioMedia incoming:(bool)incoming system:(bool)system;

@end
