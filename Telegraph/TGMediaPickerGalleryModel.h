#import "TGModernGalleryModel.h"

#import "TGMediaPickerGalleryInterfaceView.h"
#import "TGModernGalleryController.h"

#import "TGPhotoEditorController.h"

@class TGModernGalleryController;
@class TGMediaPickerGallerySelectedItemsModel;
@protocol TGMediaEditAdjustments;
@protocol TGModernMediaListItem;

@interface TGMediaPickerGalleryModel : TGModernGalleryModel

@property (nonatomic, copy) void(^saveEditedItem)(id<TGEditablePhotoItem> item, id<TGMediaEditAdjustments> editorValues, UIImage *resultImage, UIImage *thumbnailImage);
@property (nonatomic, copy) void(^saveItemCaption)(id<TGEditablePhotoItem> item, NSString *caption);

@property (nonatomic, copy) void(^storeOriginalImageForItem)(id<TGEditablePhotoItem> item, UIImage *originalImage);

@property (nonatomic, assign) bool useGalleryImageAsEditableItemImage;
@property (nonatomic, weak) TGModernGalleryController *controller;
@property (nonatomic, strong) TGMediaPickerGallerySelectedItemsModel *selectedItemsModel;
@property (nonatomic, strong, readonly) TGMediaPickerGalleryInterfaceView *interfaceView;

@property (nonatomic, copy) SSignal *(^userListSignal)(NSString *mention);
@property (nonatomic, copy) SSignal *(^hashtagListSignal)(NSString *hashtag);

- (instancetype)initWithItems:(NSArray *)items focusItem:(id<TGModernGalleryItem>)focusItem allowsSelection:(bool)allowsSelection allowsEditing:(bool)allowsEditing hasCaptions:(bool)hasCaptions forVideo:(bool)forVideo;

- (void)setCurrentItemWithListItem:(id<TGModernMediaListItem>)listItem direction:(TGModernGalleryScrollAnimationDirection)direction;

@end
