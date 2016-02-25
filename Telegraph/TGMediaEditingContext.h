#import <SSignalKit/SSignalKit.h>

@protocol TGMediaEditableItem <NSObject>

@property (nonatomic, readonly) NSString *uniqueIdentifier;
@property (nonatomic, readonly) CGSize originalSize;

- (SSignal *)thumbnailImageSignal;
- (SSignal *)screenImageSignal;
- (SSignal *)originalImageSignal;

@end


@protocol TGMediaEditAdjustments <NSObject>

@property (nonatomic, readonly) CGSize originalSize;
@property (nonatomic, readonly) CGRect cropRect;
@property (nonatomic, readonly) UIImageOrientation cropOrientation;
@property (nonatomic, readonly) CGFloat cropLockedAspectRatio;

- (bool)cropAppliedForAvatar:(bool)forAvatar;
- (bool)isDefaultValuesForAvatar:(bool)forAvatar;

- (bool)isCropEqualWith:(id<TGMediaEditAdjustments>)adjusments;

@end


@interface TGMediaEditingContext : NSObject

- (SSignal *)imageSignalForItem:(NSObject<TGMediaEditableItem> *)item;
- (SSignal *)imageSignalForItem:(NSObject<TGMediaEditableItem> *)item withUpdates:(bool)withUpdates;
- (SSignal *)thumbnailImageSignalForItem:(NSObject<TGMediaEditableItem> *)item;
- (SSignal *)thumbnailImageSignalForItem:(id<TGMediaEditableItem>)item withUpdates:(bool)withUpdates synchronous:(bool)synchronous;
- (SSignal *)fastImageSignalForItem:(NSObject<TGMediaEditableItem> *)item withUpdates:(bool)withUpdates;

- (void)setImage:(UIImage *)image thumbnailImage:(UIImage *)thumbnailImage forItem:(id<TGMediaEditableItem>)item synchronous:(bool)synchronous;
- (void)setFullSizeImage:(UIImage *)image forItem:(id<TGMediaEditableItem>)item;

- (void)setTemporaryRep:(id)rep forItem:(id<TGMediaEditableItem>)item;

- (SSignal *)fullSizeImageUrlForItem:(id<TGMediaEditableItem>)item;

- (NSString *)captionForItem:(NSObject<TGMediaEditableItem> *)item;
- (SSignal *)captionSignalForItem:(NSObject<TGMediaEditableItem> *)item;
- (void)setCaption:(NSString *)caption forItem:(NSObject<TGMediaEditableItem> *)item;

- (NSObject<TGMediaEditAdjustments> *)adjustmentsForItem:(NSObject<TGMediaEditableItem> *)item;
- (SSignal *)adjustmentsSignalForItem:(NSObject<TGMediaEditableItem> *)item;
- (void)setAdjustments:(NSObject<TGMediaEditAdjustments> *)adjustments forItem:(NSObject<TGMediaEditableItem> *)item;

- (SSignal *)cropAdjustmentsUpdatedSignal;

- (void)requestOriginalThumbnailImageForItem:(id<TGMediaEditableItem>)item completion:(void (^)(UIImage *))completion;
- (void)requestOriginalImageForItem:(id<TGMediaEditableItem>)itemId completion:(void (^)(UIImage *image))completion;
- (void)setOriginalImage:(UIImage *)image forItem:(id<TGMediaEditableItem>)item synchronous:(bool)synchronous;

@end
