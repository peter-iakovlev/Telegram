#import "TGAttachmentSheetItemView.h"

@interface TGAttachmentSheetFileInstructionItemView : TGAttachmentSheetItemView

@property (nonatomic, copy) void (^pressed)(void);

@property (nonatomic, assign) bool folded;

@end
