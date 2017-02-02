#import "TGModernGalleryModel.h"

#import "TGInstantPageMedia.h"

@interface TGItemCollectionGalleryModel : TGModernGalleryModel

- (instancetype)initWithMedias:(NSArray *)medias centralMedia:(TGInstantPageMedia *)centralMedia;

@end
