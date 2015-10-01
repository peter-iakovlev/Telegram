#import "TGCollectionItem.h"

@interface TGCollectionMultilineInputItem : TGCollectionItem

@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) NSString *text;
@property (nonatomic) bool editable;
@property (nonatomic) NSUInteger maxLength;
@property (nonatomic, copy) void (^textChanged)(NSString *);
@property (nonatomic, copy) void (^heightChanged)();

@end
