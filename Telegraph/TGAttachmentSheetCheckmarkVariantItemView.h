#import "TGShareSheetItemView.h"

@interface TGAttachmentSheetCheckmarkVariantItemView : TGShareSheetItemView

@property (nonatomic, copy) void (^onCheckedChanged)(bool);

- (instancetype)initWithTitle:(NSString *)title variant:(NSString *)variant checked:(bool)checked;

@end
