#import "TGPhonebookNumber.h"

@implementation TGPhonebookNumber

- (instancetype)initWithPhone:(NSString *)phone label:(NSString *)label
{
    self = [super init];
    if (self != nil)
    {
        _phone = phone;
        _label = label;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGPhonebookNumber class]] && TGStringCompare(((TGPhonebookNumber *)object)->_phone, _phone) && TGStringCompare(((TGPhonebookNumber *)object)->_label, _label);
}

@end
