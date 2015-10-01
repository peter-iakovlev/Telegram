#import "TGPhotoEditorInterfaceAssets.h"

@interface TGPhotoEditorButton : UIControl

@property (nonatomic, strong) UIImage *iconImage;
@property (nonatomic, assign) bool active;
@property (nonatomic, assign) bool dontHighlightOnSelection;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated;

@end
