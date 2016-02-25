#import "TGContentBubbleViewModel.h"

@interface TGMusicAudioMessageModel : TGContentBubbleViewModel

- (instancetype)initWithMessage:(TGMessage *)message authorPeer:(id)authorPeer viaUser:(TGUser *)viaUser context:(TGModernViewContext *)context;

@end
