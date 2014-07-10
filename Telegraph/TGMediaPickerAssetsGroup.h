#import <Foundation/Foundation.h>

@interface TGMediaPickerAssetsGroup : NSObject

- (instancetype)initWithLatestAssets:(NSArray *)latestAssets groupThumbnail:(UIImage *)groupThumbnail persistentId:(NSString *)persistentId title:(NSString *)title assetCount:(NSUInteger)assetCount;

- (NSArray *)latestAssets;
- (UIImage *)groupThumbnail;

- (NSString *)persistentId;
- (NSString *)title;
- (NSUInteger)assetCount;

@end
