#import "TGReplyHeaderModel.h"

@class TGUser;

@interface TGReplyHeaderTextModel : TGReplyHeaderModel

- (instancetype)initWithPeer:(id)peer text:(NSString *)text incoming:(bool)incoming system:(bool)system;

@end
