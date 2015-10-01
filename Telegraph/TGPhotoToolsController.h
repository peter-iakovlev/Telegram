#import "TGPhotoEditorTabController.h"

@class PGPhotoEditor;
@class TGPhotoEditorPreviewView;

@interface TGPhotoToolsController : TGPhotoEditorTabController

- (instancetype)initWithPhotoEditor:(PGPhotoEditor *)photoEditor previewView:(TGPhotoEditorPreviewView *)previewView;

- (void)updateValues;

- (void)prepareForCombinedAppearance;
- (void)finishedCombinedAppearance;

@end
