#import "TGCollectionItem.h"

@interface TGPhoneCodeCollectionItem : TGCollectionItem

@property (nonatomic, copy) void (^codeChanged)(NSString *);

- (void)resignFirstResponder;
- (void)becomeFirstResponder;

@end
