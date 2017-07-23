#import <Foundation/Foundation.h>
#import "TGMediaPickerGalleryModel.h"
#import "TGModernGalleryController.h"

@class TGMediaSelectionContext;
@class TGMediaEditingContext;
@class TGSuggestionContext;
@class TGMediaPickerGalleryItem;
@class TGMediaAssetFetchResult;
@class TGMediaAssetMomentList;

@interface TGMediaPickerModernGalleryMixin : NSObject

@property (nonatomic, weak, readonly) TGMediaPickerGalleryModel *galleryModel;

@property (nonatomic, copy) void (^itemFocused)(TGMediaPickerGalleryItem *);

@property (nonatomic, copy) void (^willTransitionIn)();
@property (nonatomic, copy) void (^willTransitionOut)();
@property (nonatomic, copy) void (^didTransitionOut)();
@property (nonatomic, copy) UIView *(^referenceViewForItem)(TGMediaPickerGalleryItem *);

@property (nonatomic, copy) void (^completeWithItem)(TGMediaPickerGalleryItem *item);

@property (nonatomic, copy) void (^editorOpened)(void);
@property (nonatomic, copy) void (^editorClosed)(void);

- (instancetype)initWithItem:(id)item fetchResult:(TGMediaAssetFetchResult *)fetchResult parentController:(TGViewController *)parentController thumbnailImage:(UIImage *)thumbnailImage selectionContext:(TGMediaSelectionContext *)selectionContext editingContext:(TGMediaEditingContext *)editingContext suggestionContext:(TGSuggestionContext *)suggestionContext hasCaptions:(bool)hasCaptions hasTimer:(bool)hasTimer inhibitDocumentCaptions:(bool)inhibitDocumentCaptions asFile:(bool)asFile itemsLimit:(NSUInteger)itemsLimit recipientName:(NSString *)recipientName;

- (instancetype)initWithItem:(id)item momentList:(TGMediaAssetMomentList *)momentList parentController:(TGViewController *)parentController thumbnailImage:(UIImage *)thumbnailImage selectionContext:(TGMediaSelectionContext *)selectionContext editingContext:(TGMediaEditingContext *)editingContext suggestionContext:(TGSuggestionContext *)suggestionContext hasCaptions:(bool)hasCaptions hasTimer:(bool)hasTimer inhibitDocumentCaptions:(bool)inhibitDocumentCaptions asFile:(bool)asFile itemsLimit:(NSUInteger)itemsLimit;

- (void)present;
- (void)updateWithFetchResult:(TGMediaAssetFetchResult *)fetchResult;

- (UIView *)currentReferenceView;

- (void)setThumbnailSignalForItem:(SSignal *(^)(id))thumbnailSignalForItem;

- (UIViewController *)galleryController;
- (void)setPreviewMode;

@end
