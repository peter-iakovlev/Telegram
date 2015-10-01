#import "TGCollectionItemView.h"

@interface TGCountryAndPhoneCollectionItemView : TGCollectionItemView

@property (nonatomic, copy) void (^presentViewController)(UIViewController *);
@property (nonatomic, copy) void (^phoneChanged)(NSString *);

- (void)makeCountryFieldFirstResponder;

@end
