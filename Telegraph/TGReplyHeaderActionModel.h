#import "TGReplyHeaderModel.h"

@class TGUser;
@class TGActionMediaAttachment;

@interface TGReplyHeaderActionModel : TGReplyHeaderModel

- (instancetype)initWithPeer:(id)peer actionMedia:(TGActionMediaAttachment *)actionMedia incoming:(bool)incoming system:(bool)system;

+ (NSString *)messageTextForActionMedia:(TGActionMediaAttachment *)actionMedia author:(id)author;

@end
