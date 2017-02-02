#import <Foundation/Foundation.h>

@interface TGResetAccountState : NSObject <NSCoding>

@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic) NSTimeInterval protectedUntilDate;

- (instancetype)initWithPhoneNumber:(NSString *)phoneNumber protectedUntilDate:(NSTimeInterval)protectedUntilDate;

@end
