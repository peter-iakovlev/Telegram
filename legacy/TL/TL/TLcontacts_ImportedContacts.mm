#import "TLcontacts_ImportedContacts.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLcontacts_ImportedContacts


- (int32_t)TLconstructorSignature
{
    TGLog(@"constructorSignature is not implemented for base type");
    return 0;
}

- (int32_t)TLconstructorName
{
    TGLog(@"constructorName is not implemented for base type");
    return 0;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TGLog(@"TLbuildFromMetaObject is not implemented for base type");
    return nil;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
    TGLog(@"TLfillFieldsWithValues is not implemented for base type");
}


@end

@implementation TLcontacts_ImportedContacts$contacts_importedContacts : TLcontacts_ImportedContacts


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x77d01c3b;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xca675ec3;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLcontacts_ImportedContacts$contacts_importedContacts *object = [[TLcontacts_ImportedContacts$contacts_importedContacts alloc] init];
    object.imported = metaObject->getArray((int32_t)0xbdf8ab20);
    object.popular_invites = metaObject->getArray((int32_t)0xa1ffd45);
    object.retry_contacts = metaObject->getArray((int32_t)0x22de4fcc);
    object.users = metaObject->getArray((int32_t)0x933e5ff3);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.imported;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xbdf8ab20, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.popular_invites;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa1ffd45, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.retry_contacts;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x22de4fcc, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.users;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x933e5ff3, value));
    }
}


@end

