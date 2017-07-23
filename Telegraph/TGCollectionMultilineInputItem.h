#import "TGCollectionItem.h"

@interface TGCollectionMultilineInputItem : TGCollectionItem

@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) NSString *text;
@property (nonatomic) bool editable;
@property (nonatomic) NSUInteger maxLength;
@property (nonatomic) CGFloat minHeight;
@property (nonatomic) bool disallowNewLines;
@property (nonatomic) bool showRemainingCount;
@property (nonatomic) UIReturnKeyType returnKeyType;
@property (nonatomic) UIEdgeInsets insets;
@property (nonatomic, copy) void (^textChanged)(NSString *);
@property (nonatomic, copy) void (^returned)();
@property (nonatomic, copy) void (^heightChanged)();
@property (nonatomic, copy) void (^selected)();

- (void)becomeFirstResponder;

@end
