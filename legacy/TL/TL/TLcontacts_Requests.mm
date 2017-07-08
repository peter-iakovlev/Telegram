#import "TLcontacts_Requests.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLcontacts_Requests


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

@implementation TLcontacts_Requests$contacts_requests : TLcontacts_Requests


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x6262c36c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x84e1c318;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLcontacts_Requests$contacts_requests *object = [[TLcontacts_Requests$contacts_requests alloc] init];
    object.requests = metaObject->getArray((int32_t)0x5926a24b);
    object.users = metaObject->getArray((int32_t)0x933e5ff3);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.requests;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5926a24b, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.users;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x933e5ff3, value));
    }
}


@end

@implementation TLcontacts_Requests$contacts_requestsSlice : TLcontacts_Requests


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x6f585b8c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x190088f5;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLcontacts_Requests$contacts_requestsSlice *object = [[TLcontacts_Requests$contacts_requestsSlice alloc] init];
    object.count = metaObject->getInt32((int32_t)0x5fa6aa74);
    object.requests = metaObject->getArray((int32_t)0x5926a24b);
    object.users = metaObject->getArray((int32_t)0x933e5ff3);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.count;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5fa6aa74, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.requests;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5926a24b, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.users;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x933e5ff3, value));
    }
}


@end

