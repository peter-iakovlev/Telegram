#import <Foundation/Foundation.h>

@interface TGPhonebookNumber : NSObject

@property (nonatomic, strong, readonly) NSString *phone;
@property (nonatomic, strong, readonly) NSString *label;

- (instancetype)initWithPhone:(NSString *)phone label:(NSString *)label;

@end
