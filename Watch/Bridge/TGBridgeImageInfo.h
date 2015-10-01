#import "TGBridgeCommon.h"

@interface TGBridgeImageSizeInfo : NSObject <NSCoding>

@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) CGSize dimensions;
@property (nonatomic, assign) int32_t fileSize;

@end

@interface TGBridgeImageInfo : NSObject <NSCoding>
{
    NSArray *_entries;
}

@property (nonatomic, readonly) NSArray *entries;

- (NSString *)closestImageUrlWithSize:(CGSize)size resultingSize:(CGSize *)resultingSize;
- (NSString *)imageUrlForSizeLargerThanSize:(CGSize)size actualSize:(CGSize *)actualSize;
- (NSString *)imageUrlForLargestSize:(CGSize *)actualSize;

@end
