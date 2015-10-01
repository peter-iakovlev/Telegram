#import "TGCollectionItem.h"

@interface TGPasswordInputItem : TGCollectionItem

@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, copy) void (^passwordChanged)(NSString *);

- (void)makeTextFieldFirstResponder;

@end
