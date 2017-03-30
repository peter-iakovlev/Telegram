#import "TGPhotoEditorTabController.h"

@class PGPhotoEditor;
@class TGPhotoEditorPreviewView;
@class TGPhotoQualityController;

@interface TGPhotoDummyController : TGPhotoEditorTabController

@property (nonatomic, weak) TGPhotoQualityController *controller;

- (instancetype)initWithPhotoEditor:(PGPhotoEditor *)photoEditor previewView:(TGPhotoEditorPreviewView *)previewView;

@end
