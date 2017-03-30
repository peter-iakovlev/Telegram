#import "TGWebpageFooterModel.h"

@class TGWebPageMediaAttachment;
@class TGInvoiceMediaAttachment;

@interface TGArticleWebpageFooterModel : TGWebpageFooterModel

- (instancetype)initWithContext:(TGModernViewContext *)context incoming:(bool)incoming webPage:(TGWebPageMediaAttachment *)webPage imageInText:(bool)imageInText invoice:(TGInvoiceMediaAttachment *)invoice;

@end
