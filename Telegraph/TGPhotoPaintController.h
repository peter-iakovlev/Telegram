#import "TGPhotoEditorTabController.h"

@class PGPhotoEditor;
@class TGPhotoEditorPreviewView;

@interface TGPhotoPaintController : TGPhotoEditorTabController

- (instancetype)initWithPhotoEditor:(PGPhotoEditor *)photoEditor previewView:(TGPhotoEditorPreviewView *)previewView;

- (TGPaintingData *)paintingData;

+ (CGRect)photoContainerFrameForParentViewFrame:(CGRect)parentViewFrame toolbarLandscapeSize:(CGFloat)toolbarLandscapeSize orientation:(UIInterfaceOrientation)orientation panelSize:(CGFloat)panelSize;

@end

extern const CGFloat TGPhotoPaintTopPanelSize;
extern const CGFloat TGPhotoPaintBottomPanelSize;
