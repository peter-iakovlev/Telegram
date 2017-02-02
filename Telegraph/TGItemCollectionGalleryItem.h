#import <UIKit/UIKit.h>

#import "TGModernGalleryItem.h"
#import "TGInstantPageMedia.h"

@interface TGItemCollectionGalleryItem : NSObject <TGModernGalleryItem>

@property (nonatomic, strong, readonly) TGInstantPageMedia *media;

- (instancetype)initWithMedia:(TGInstantPageMedia *)media;

@end
