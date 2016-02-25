#import "TGMenuSheetItemView.h"
#import "TGMediaAsset.h"

@class TGMediaSelectionContext;
@class TGMediaEditingContext;
@class TGSuggestionContext;
@class TGViewController;
@class TGAttachmentCameraView;

@interface TGAttachmentCarouselItemView : TGMenuSheetItemView

@property (nonatomic, weak) TGViewController *parentController;

@property (nonatomic, readonly) TGMediaSelectionContext *selectionContext;
@property (nonatomic, readonly) TGMediaEditingContext *editingContext;
@property (nonatomic, strong) TGSuggestionContext *suggestionContext;
@property (nonatomic) bool allowCaptions;

@property (nonatomic, strong) NSArray *underlyingViews;
@property (nonatomic, assign) bool openEditor;

@property (nonatomic, copy) void (^cameraPressed)(TGAttachmentCameraView *cameraView);
@property (nonatomic, copy) void (^sendPressed)(TGMediaAsset *currentItem, bool asFiles);
@property (nonatomic, copy) void (^avatarCompletionBlock)(UIImage *image);

@property (nonatomic, copy) void (^editorOpened)(void);
@property (nonatomic, copy) void (^editorClosed)(void);

@property (nonatomic, assign) bool condensed;

- (instancetype)initWithCamera:(bool)hasCamera selfPortrait:(bool)selfPortrait forProfilePhoto:(bool)forProfilePhoto assetType:(TGMediaAssetType)assetType;

@end
