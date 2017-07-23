#import "TGCollectionItemView.h"

@interface TGCollectionMultilineInputItemView : TGCollectionItemView

@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) NSString *text;
@property (nonatomic) NSUInteger maxLength;
@property (nonatomic) bool editable;
@property (nonatomic) bool disallowNewLines;
@property (nonatomic) bool showRemainingCount;
@property (nonatomic, assign) UIEdgeInsets insets;
@property (nonatomic, copy) void (^textChanged)(NSString *);
@property (nonatomic, copy) void (^returned)();

- (void)setReturnKeyType:(UIReturnKeyType)returnKeyType;
+ (CGFloat)heightForText:(NSString *)text width:(CGFloat)width;

@end
