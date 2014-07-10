#import <Foundation/Foundation.h>

@interface TGPhonebookPhone : NSObject

@property (nonatomic, strong, readonly) NSString *label;
@property (nonatomic, strong, readonly) NSString *number;

- (instancetype)initWithLabel:(NSString *)label number:(NSString *)number;

@end
