#import "TGReplyHeaderImageModel.h"

@class TGUser;
@class TGImageMediaAttachment;

@interface TGReplyHeaderPhotoModel : TGReplyHeaderImageModel

- (instancetype)initWithPeer:(id)peer imageMedia:(TGImageMediaAttachment *)imageMedia incoming:(bool)incoming system:(bool)system;
- (instancetype)initWithPeer:(id)peer imageMedia:(TGImageMediaAttachment *)imageMedia incoming:(bool)incoming system:(bool)system caption:(NSString *)caption;

@end
