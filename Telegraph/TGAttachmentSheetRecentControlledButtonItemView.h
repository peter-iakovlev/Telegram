#import "TGAttachmentSheetButtonItemView.h"

@interface TGAttachmentSheetRecentControlledButtonItemView : TGAttachmentSheetButtonItemView

@property (nonatomic, copy) void (^alternatePressed)();

- (instancetype)initWithTitle:(NSString *)title pressed:(void (^)())pressed alternatePressed:(void (^)())alternatePressed;

- (void)setAlternateWithTitle:(NSString *)title;
- (void)setDefault;

@end
