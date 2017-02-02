#import "TGResetAccountState.h"

@implementation TGResetAccountState

- (instancetype)initWithPhoneNumber:(NSString *)phoneNumber protectedUntilDate:(NSTimeInterval)protectedUntilDate {
    self = [super init];
    if (self != nil) {
        _phoneNumber = phoneNumber;
        _protectedUntilDate = protectedUntilDate;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithPhoneNumber:[aDecoder decodeObjectForKey:@"phoneNumber"] protectedUntilDate:[aDecoder decodeDoubleForKey:@"protectedUntilDate"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_phoneNumber forKey:@"phoneNumber"];
    [aCoder encodeDouble:_protectedUntilDate forKey:@"protectedUntilDate"];
}

@end
