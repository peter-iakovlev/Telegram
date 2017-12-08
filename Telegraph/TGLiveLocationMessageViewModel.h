#import "TGContentBubbleViewModel.h"

@interface TGLiveLocationMessageViewModel : TGContentBubbleViewModel

- (instancetype)initWithLatitude:(double)latitude longitude:(double)longitude period:(int32_t)period message:(TGMessage *)message authorPeer:(id)authorPeer useAuthor:(bool)useAuthor context:(TGModernViewContext *)context viaUser:(TGUser *)viaUser;

@end
