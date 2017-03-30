#import <Foundation/Foundation.h>

@interface TGPaymentPasswordAlert : UIAlertController

+ (UIAlertController *)alertWithText:(NSString *)text result:(void (^)(NSString *))result;

@end
