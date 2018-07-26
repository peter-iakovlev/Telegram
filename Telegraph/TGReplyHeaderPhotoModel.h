#import "TGReplyHeaderImageModel.h"

@class TGUser;
@class TGImageMediaAttachment;

@interface TGReplyHeaderPhotoModel : TGReplyHeaderImageModel

- (instancetype)initWithPeer:(id)peer imageMedia:(TGImageMediaAttachment *)imageMedia incoming:(bool)incoming system:(bool)system presentation:(TGPresentation *)presentation;
- (instancetype)initWithPeer:(id)peer imageMedia:(TGImageMediaAttachment *)imageMedia incoming:(bool)incoming system:(bool)system caption:(NSString *)caption presentation:(TGPresentation *)presentation;

@end
