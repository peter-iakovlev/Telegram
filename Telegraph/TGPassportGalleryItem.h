#import <UIKit/UIKit.h>

#import <LegacyComponents/TGModernGalleryItem.h>

@interface TGPassportGalleryItem : NSObject <TGModernGalleryItem>

@property (nonatomic, readonly) int32_t index;
@property (nonatomic, strong, readonly) id file;

@property (nonatomic, assign) CGSize contentSize;

@property (nonatomic, strong) NSArray *groupItems;
@property (nonatomic, assign) int64_t groupedId;

- (instancetype)initWithIndex:(int32_t)index file:(id)file;

@end
