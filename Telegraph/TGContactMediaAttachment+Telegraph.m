#import "TGContactMediaAttachment+Telegraph.h"

@implementation TGContactMediaAttachment (Telegraph)

- (id)initWithTelegraphContactDesc:(TLMessageMedia$messageMediaContact *)desc
{
    self = [super init];
    if (self != nil)
    {
        self.type = TGContactMediaAttachmentType;
        
        self.uid = desc.user_id;
        self.firstName = desc.first_name;
        self.lastName = desc.last_name;
        self.phoneNumber = desc.phone_number;
    }
    return self;
}

@end
