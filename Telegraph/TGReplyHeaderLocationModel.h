#import "TGReplyHeaderModel.h"

@class TGUser;

@interface TGReplyHeaderLocationModel : TGReplyHeaderModel

- (instancetype)initWithPeer:(id)peer latitude:(double)latitude longitude:(double)longitude incoming:(bool)incoming system:(bool)system;

@end
