#import "TGWebpageFooterModel.h"

@class TGWebPageMediaAttachment;

@interface TGArticleWebpageFooterModel : TGWebpageFooterModel

- (instancetype)initWithWithIncoming:(bool)incoming webPage:(TGWebPageMediaAttachment *)webPage imageInText:(bool)imageInText hasViews:(bool)hasViews;

@end
