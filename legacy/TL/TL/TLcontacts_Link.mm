#import "TLcontacts_Link.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLContactLink.h"
#import "TLUser.h"

@implementation TLcontacts_Link


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

@implementation TLcontacts_Link$contacts_link : TLcontacts_Link


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x3ace484c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa4041d8c;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLcontacts_Link$contacts_link *object = [[TLcontacts_Link$contacts_link alloc] init];
    object.my_link = metaObject->getObject((int32_t)0xc9f9705a);
    object.foreign_link = metaObject->getObject((int32_t)0x1c49ffaf);
    object.user = metaObject->getObject((int32_t)0x2275eda7);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.my_link;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc9f9705a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.foreign_link;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1c49ffaf, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.user;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x2275eda7, value));
    }
}


@end

