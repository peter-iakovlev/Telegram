#import "TGCollectionItem.h"

@interface TGCountryAndPhoneCollectionItem : TGCollectionItem

@property (nonatomic, copy) void (^presentViewController)(UIViewController *);
@property (nonatomic, copy) void (^phoneChanged)(NSString *);

- (void)becomeFirstResponder;

@end
