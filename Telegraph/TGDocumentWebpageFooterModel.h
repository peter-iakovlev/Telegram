#import "TGWebpageFooterModel.h"

@class TGWebPageMediaAttachment;

@interface TGDocumentWebpageFooterModel : TGWebpageFooterModel

- (instancetype)initWithContext:(TGModernViewContext *)context incoming:(bool)incoming webPage:(TGWebPageMediaAttachment *)webPage hasViews:(bool)hasViews;

@end
