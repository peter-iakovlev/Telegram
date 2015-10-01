#import "TGContentBubbleViewModel.h"

@interface TGMusicAudioMessageModel : TGContentBubbleViewModel

- (instancetype)initWithMessage:(TGMessage *)message authorPeer:(id)authorPeer context:(TGModernViewContext *)context;

@end
