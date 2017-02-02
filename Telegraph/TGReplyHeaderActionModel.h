#import "TGReplyHeaderModel.h"

@class TGUser;
@class TGActionMediaAttachment;

@interface TGReplyHeaderActionModel : TGReplyHeaderModel

- (instancetype)initWithPeer:(id)peer actionMedia:(TGActionMediaAttachment *)actionMedia otherAttachments:(NSArray *)otherAttachments incoming:(bool)incoming system:(bool)system;

+ (NSString *)messageTextForActionMedia:(TGActionMediaAttachment *)actionMedia otherAttachments:(NSArray *)otherAttachments author:(id)author;

@end
