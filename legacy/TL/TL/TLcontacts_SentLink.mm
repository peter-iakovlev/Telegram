#import "TLcontacts_SentLink.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLmessages_Message.h"
#import "TLcontacts_Link.h"

@implementation TLcontacts_SentLink


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

@implementation TLcontacts_SentLink$contacts_sentLink : TLcontacts_SentLink


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x96a0c63e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x9d4b1aca;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLcontacts_SentLink$contacts_sentLink *object = [[TLcontacts_SentLink$contacts_sentLink alloc] init];
    object.message = metaObject->getObject((int32_t)0xc43b7853);
    object.link = metaObject->getObject((int32_t)0xc58224f9);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.message;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc43b7853, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.link;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc58224f9, value));
    }
}


@end

