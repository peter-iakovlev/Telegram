#import "TGReplyHeaderImageModel.h"

@class TGUser;
@class TGDocumentMediaAttachment;

@interface TGReplyHeaderFileModel : TGReplyHeaderImageModel

- (instancetype)initWithPeer:(id)peer fileMedia:(TGDocumentMediaAttachment *)fileMedia incoming:(bool)incoming system:(bool)system;
- (instancetype)initWithPeer:(id)peer fileMedia:(TGDocumentMediaAttachment *)fileMedia incoming:(bool)incoming system:(bool)system caption:(NSString *)caption;


@end
