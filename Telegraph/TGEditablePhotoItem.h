#import <Foundation/Foundation.h>

@class PGPhotoEditorValues;
@protocol TGMediaEditAdjustments;

@protocol TGEditablePhotoItem <NSObject>

@property (nonatomic, readonly) CGSize originalSize;

@property (nonatomic, copy) id<TGMediaEditAdjustments> (^fetchEditorValues)(id<TGEditablePhotoItem> item);
@property (nonatomic, copy) NSString * (^fetchCaption)(id<TGEditablePhotoItem> item);
@property (nonatomic, copy) UIImage *(^fetchThumbnailImage)(id<TGEditablePhotoItem> item);
@property (nonatomic, copy) UIImage *(^fetchScreenImage)(id<TGEditablePhotoItem> item);

@property (nonatomic, copy) void(^fetchOriginalImage)(id<TGEditablePhotoItem> item, void(^)(UIImage *image));
@property (nonatomic, copy) void(^fetchOriginalThumbnailImage)(id<TGEditablePhotoItem> item, void(^)(UIImage *image));

- (void)fetchThumbnailImageWithCompletion:(void (^)(UIImage *image))completion;
- (void)fetchOriginalScreenSizeImageWithCompletion:(void (^)(UIImage *image))completion;
- (void)fetchOriginalFullSizeImageWithCompletion:(void (^)(UIImage *image))completion;
- (NSString *)uniqueId;

@optional
- (void)fetchMetadataWithCompletion:(void (^)(NSDictionary *metadata))completion;

@end
