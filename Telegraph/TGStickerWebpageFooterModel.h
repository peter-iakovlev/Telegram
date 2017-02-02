#import "TGWebpageFooterModel.h"

@class TGWebPageMediaAttachment;

@interface TGStickerWebpageFooterModel : TGWebpageFooterModel

- (instancetype)initWithContext:(TGModernViewContext *)context incoming:(bool)incoming webPage:(TGWebPageMediaAttachment *)webPage hasViews:(bool)hasViews;

@end
