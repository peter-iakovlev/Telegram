#import "TGMediaPickerAsset.h"
#import "TGMediaPickerAssetsGroup.h"

typedef enum {
    TGMediaPickerAuthorizationStatusNotDetermined,
    TGMediaPickerAuthorizationStatusRestricted,
    TGMediaPickerAuthorizationStatusDenied,
    TGMediaPickerAuthorizationStatusAuthorized
} TGMediaPickerAuthorizationStatus;

@interface TGMediaPickerAssetsLibrary : NSObject

@property (nonatomic, readonly) TGMediaPickerAuthorizationStatus authorizationStatus;
@property (nonatomic, readonly) TGMediaPickerAssetType assetType;

@property (nonatomic, copy) void (^libraryChanged)(void);

- (instancetype)initForAssetType:(TGMediaPickerAssetType)assetType;

- (void)fetchAssetsGroupsWithCompletionBlock:(void(^)(NSArray *groups, TGMediaPickerAuthorizationStatus status, NSError *error))completionBlock;
- (void)fetchAssetsOfAssetsGroup:(TGMediaPickerAssetsGroup *)assetsGroup withCompletionBlock:(void (^)(NSArray *assets, TGMediaPickerAuthorizationStatus status, NSError *error))completionBlock;
- (void)fetchAssetsOfAssetsGroup:(TGMediaPickerAssetsGroup *)assetsGroup reversed:(bool)reversed withEnumerationBlock:(void (^)(TGMediaPickerAsset *, TGMediaPickerAuthorizationStatus, NSError *))enumerationBlock;

- (void)saveAssetWithImage:(UIImage *)image completionBlock:(void(^)(bool success, NSString *uniqueId, NSError *error))completionBlock;
- (void)saveAssetWithImageData:(NSData *)data completionBlock:(void(^)(bool success, NSString *uniqueId, NSError *error))completionBlock;
- (void)saveAssetWithImageAtURL:(NSURL *)url completionBlock:(void(^)(bool success, NSString *uniqueId, NSError *error))completionBlock;
- (void)saveAssetWithVideoAtURL:(NSURL *)url completionBlock:(void(^)(bool success, NSString *uniqueId, NSError *error))completionBlock;

+ (instancetype)sharedLibrary;

@end
