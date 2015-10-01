#import <Foundation/Foundation.h>

@protocol TGMediaEditAdjustments <NSObject>

@property (nonatomic, readonly) CGSize originalSize;
@property (nonatomic, readonly) CGRect cropRect;
@property (nonatomic, readonly) UIImageOrientation cropOrientation;
@property (nonatomic, readonly) CGFloat cropLockedAspectRatio;

- (bool)cropAppliedForAvatar:(bool)forAvatar;
- (bool)isDefaultValuesForAvatar:(bool)forAvatar;

@end

@interface TGMediaEditingContext : NSObject

- (NSString *)captionForItemId:(NSString *)itemId;
- (void)setCaption:(NSString *)caption forItemId:(NSString *)itemId synchronous:(bool)synchronous;

- (id<TGMediaEditAdjustments>)adjustmentsForItemId:(NSString *)itemId;
- (void)setAdjustments:(id<TGMediaEditAdjustments>)editorValues forItemId:(NSString *)itemId synchronous:(bool)synchronous;

- (UIImage *)imageForItemId:(NSString *)itemId;
- (UIImage *)thumbnailImageForItemId:(NSString *)itemId;
- (void)setImage:(UIImage *)image thumbnailImage:(UIImage *)thumbnailImage forItemId:(NSString *)itemId synchronous:(bool)synchronous;

- (void)requestOriginalThumbnailImageForItemId:(NSString *)itemId completion:(void (^)(UIImage *image))completion;
- (void)requestOriginalImageForItemId:(NSString *)itemId completion:(void (^)(UIImage *image))completion;
- (void)setOriginalImage:(UIImage *)image forItemId:(NSString *)itemId synchronous:(bool)synchronous;

- (void)cleanup;

@end
