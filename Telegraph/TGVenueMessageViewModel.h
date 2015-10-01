#import "TGContentBubbleViewModel.h"

@class TGVenueAttachment;

@interface TGVenueMessageViewModel : TGContentBubbleViewModel

- (instancetype)initWithLatitude:(double)latitude longitude:(double)longitude venue:(TGVenueAttachment *)venue message:(TGMessage *)message authorPeer:(id)authorPeer context:(TGModernViewContext *)context;

@end
