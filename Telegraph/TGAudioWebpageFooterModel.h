#import "TGWebpageFooterModel.h"

@class TGWebPageMediaAttachment;

@interface TGAudioWebpageFooterModel : TGWebpageFooterModel

- (instancetype)initWithContext:(TGModernViewContext *)context messageId:(int32_t)messageId authorPeerId:(int64_t)authorPeerId incoming:(bool)incoming webPage:(TGWebPageMediaAttachment *)webPage hasViews:(bool)hasViews;

@end
