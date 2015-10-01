#import "TGReplyHeaderImageModel.h"

@class TGUser;
@class TGVideoMediaAttachment;

@interface TGReplyHeaderVideoModel : TGReplyHeaderImageModel

- (instancetype)initWithPeer:(id)peer videoMedia:(TGVideoMediaAttachment *)videoMedia incoming:(bool)incoming system:(bool)system;

@end
