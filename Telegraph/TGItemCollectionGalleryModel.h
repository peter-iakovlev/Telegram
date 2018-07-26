#import <LegacyComponents/TGModernGalleryModel.h>

#import "TGInstantPageMedia.h"

@interface TGItemCollectionGalleryModel : TGModernGalleryModel

@property (nonatomic, copy) void (^openLinkRequested)(NSString *url);

- (instancetype)initWithMedias:(NSArray *)medias centralMedia:(TGInstantPageMedia *)centralMedia;

@end
