#import "TGShareSheetItemView.h"

@interface TGAttachmentSheetCheckmarkVariantItemView : TGShareSheetItemView

@property (nonatomic, copy) void (^onCheckedChanged)(bool);
@property (nonatomic) bool disableAutoCheck;
@property (nonatomic) bool disableInsetIfNotChecked;

- (instancetype)initWithTitle:(NSString *)title variant:(NSString *)variant checked:(bool)checked;
- (instancetype)initWithTitle:(NSString *)title variant:(NSString *)variant checked:(bool)checked image:(UIImage *)image;

@end
