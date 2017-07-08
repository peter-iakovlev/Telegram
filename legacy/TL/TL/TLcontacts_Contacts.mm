#import "TLcontacts_Contacts.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLcontacts_Contacts


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

@implementation TLcontacts_Contacts$contacts_contacts : TLcontacts_Contacts


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x6f8b8cb2;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1eb2e51b;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLcontacts_Contacts$contacts_contacts *object = [[TLcontacts_Contacts$contacts_contacts alloc] init];
    object.contacts = metaObject->getArray((int32_t)0x48dc7107);
    object.users = metaObject->getArray((int32_t)0x933e5ff3);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.contacts;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x48dc7107, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.users;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x933e5ff3, value));
    }
}


@end

@implementation TLcontacts_Contacts$contacts_contactsNotModified : TLcontacts_Contacts


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xb74ba9d2;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x17d85a83;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLcontacts_Contacts$contacts_contactsNotModified *object = [[TLcontacts_Contacts$contacts_contactsNotModified alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

