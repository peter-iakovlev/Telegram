#import "TGPhotoEditorTabController.h"

@class PGPhotoEditor;
@class TGSuggestionContext;
@class TGPhotoEditorPreviewView;

@interface TGPhotoCaptionController : TGPhotoEditorTabController

@property (nonatomic, copy) void (^captionSet)(NSString *caption);

@property (nonatomic, strong) TGSuggestionContext *suggestionContext;

- (instancetype)initWithPhotoEditor:(PGPhotoEditor *)photoEditor previewView:(TGPhotoEditorPreviewView *)previewView caption:(NSString *)caption;

@end
