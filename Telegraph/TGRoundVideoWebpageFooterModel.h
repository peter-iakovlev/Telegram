#import "TGWebpageFooterModel.h"

@class TGWebPageMediaAttachment;

@interface TGRoundVideoWebpageFooterModel : TGWebpageFooterModel

- (instancetype)initWithContext:(TGModernViewContext *)context messageId:(int32_t)messageId incoming:(bool)incoming webPage:(TGWebPageMediaAttachment *)webPage;

@end
