#import "TGPhotoEditorToolView.h"
#import "PGPhotoEditorItem.h"

@interface TGPhotoEditorGenericToolView : UIView <TGPhotoEditorToolView>

- (instancetype)initWithEditorItem:(id<PGPhotoEditorItem>)editorItem;

@end
