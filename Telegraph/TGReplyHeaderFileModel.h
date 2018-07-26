#import "TGReplyHeaderImageModel.h"

@class TGUser;
@class TGDocumentMediaAttachment;

@interface TGReplyHeaderFileModel : TGReplyHeaderImageModel

- (instancetype)initWithPeer:(id)peer fileMedia:(TGDocumentMediaAttachment *)fileMedia incoming:(bool)incoming system:(bool)system presentation:(TGPresentation *)presentation;
- (instancetype)initWithPeer:(id)peer fileMedia:(TGDocumentMediaAttachment *)fileMedia incoming:(bool)incoming system:(bool)system caption:(NSString *)caption presentation:(TGPresentation *)presentation;


@end
