#import "TLcontacts_Blocked.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLcontacts_Blocked


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

@implementation TLcontacts_Blocked$contacts_blocked : TLcontacts_Blocked


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x1c138d15;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xad72f1c3;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLcontacts_Blocked$contacts_blocked *object = [[TLcontacts_Blocked$contacts_blocked alloc] init];
    object.blocked = metaObject->getArray((int32_t)0xb651736f);
    object.users = metaObject->getArray((int32_t)0x933e5ff3);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.blocked;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb651736f, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.users;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x933e5ff3, value));
    }
}


@end

@implementation TLcontacts_Blocked$contacts_blockedSlice : TLcontacts_Blocked


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x900802a1;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xdd6282f6;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLcontacts_Blocked$contacts_blockedSlice *object = [[TLcontacts_Blocked$contacts_blockedSlice alloc] init];
    object.count = metaObject->getInt32((int32_t)0x5fa6aa74);
    object.blocked = metaObject->getArray((int32_t)0xb651736f);
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
        value.nativeObject = self.blocked;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb651736f, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.users;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x933e5ff3, value));
    }
}


@end

