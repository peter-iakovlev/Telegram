#import "TGReplyHeaderModel.h"

@class TGUser;

@interface TGReplyHeaderContactModel : TGReplyHeaderModel

- (instancetype)initWithPeer:(id)peer incoming:(bool)incoming system:(bool)system presentation:(TGPresentation *)presentation;

@end
