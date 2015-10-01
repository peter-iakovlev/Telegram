#import "TGCollectionItem.h"

@interface TGPhoneCodeCollectionItem : TGCollectionItem

@property (nonatomic, copy) void (^codeChanged)(NSString *);

- (void)becomeFirstResponder;

@end
