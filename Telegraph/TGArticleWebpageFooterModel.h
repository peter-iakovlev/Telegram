#import "TGWebpageFooterModel.h"

@class TGWebPageMediaAttachment;

@interface TGArticleWebpageFooterModel : TGWebpageFooterModel

- (instancetype)initWithContext:(TGModernViewContext *)context incoming:(bool)incoming webPage:(TGWebPageMediaAttachment *)webPage imageInText:(bool)imageInText hasViews:(bool)hasViews;

@end
