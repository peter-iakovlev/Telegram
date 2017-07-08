#import "TGWebpageFooterModel.h"

@class TGWebPageMediaAttachment;
@class TGInvoiceMediaAttachment;

@interface TGArticleWebpageFooterModel : TGWebpageFooterModel

@property (nonatomic, copy) void (^instantPagePressed)(void);
@property (nonatomic, copy) void (^viewGroupPressed)(void);

- (instancetype)initWithContext:(TGModernViewContext *)context incoming:(bool)incoming webPage:(TGWebPageMediaAttachment *)webPage imageInText:(bool)imageInText invoice:(TGInvoiceMediaAttachment *)invoice;

@end
