#import "TGCollectionItemView.h"

@interface TGPhoneCodeCollectionItemView : TGCollectionItemView

@property (nonatomic, copy) void (^codeChanged)(NSString *);

- (void)resignCodeFieldFirstResponder;
- (void)makeCodeFieldFirstResponder;

@end
