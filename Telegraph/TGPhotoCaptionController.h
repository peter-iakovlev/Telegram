#import "TGPhotoEditorTabController.h"

@class SSignal;
@class PGPhotoEditor;
@class TGPhotoEditorPreviewView;

@interface TGPhotoCaptionController : TGPhotoEditorTabController

@property (nonatomic, copy) void (^captionSet)(NSString *caption);

@property (nonatomic, copy) SSignal *(^userListSignal)(NSString *mention);
@property (nonatomic, copy) SSignal *(^hashtagListSignal)(NSString *hashtag);

- (instancetype)initWithPhotoEditor:(PGPhotoEditor *)photoEditor previewView:(TGPhotoEditorPreviewView *)previewView caption:(NSString *)caption;

@end
