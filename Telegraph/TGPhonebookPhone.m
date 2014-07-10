#import "TGPhonebookPhone.h"

@implementation TGPhonebookPhone

- (instancetype)initWithLabel:(NSString *)label number:(NSString *)number
{
    self = [super init];
    if (self != nil)
    {
        _label = label;
        _number = number;
    }
    return self;
}

@end
