#import <UIKit/UIKit.h>

#import <LegacyComponents/TGModernGalleryItem.h>
#import "TGInstantPageMedia.h"

@interface TGItemCollectionGalleryItem : NSObject <TGModernGalleryItem>

@property (nonatomic, readonly) int32_t index;
@property (nonatomic, strong, readonly) TGInstantPageMedia *media;

@property (nonatomic, strong) NSArray *groupItems;
@property (nonatomic, assign) int64_t groupedId;

- (instancetype)initWithIndex:(int32_t)index media:(TGInstantPageMedia *)media;

@end
