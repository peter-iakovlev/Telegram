#import "TGCollectionItemView.h"

@interface TGCollectionMultilineInputItemView : TGCollectionItemView

@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) NSString *text;
@property (nonatomic) NSUInteger maxLength;
@property (nonatomic) bool editable;
@property (nonatomic, copy) void (^textChanged)(NSString *);

+ (CGFloat)heightForText:(NSString *)text width:(CGFloat)width;

@end
