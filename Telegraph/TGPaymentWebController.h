#import <UIKit/UIKit.h>

#import "TGViewController.h"

@interface TGPaymentWebController : TGViewController

@property (nonatomic, copy) void (^completed)(NSString *data, NSString *title, bool save);
@property (nonatomic, copy) void (^completedConfirmation)();

- (instancetype)initWithUrl:(NSString *)url confirmation:(bool)confirmation canSave:(bool)canSave allowSaving:(bool)allowSaving;

@end
