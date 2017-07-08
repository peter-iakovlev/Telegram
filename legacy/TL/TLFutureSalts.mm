#import "TLFutureSalts.h"

#import "NSInputStream+TL.h"
#import "NSOutputStream+TL.h"

@implementation TLFutureSalts

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

@implementation TLFutureSalts$future_salts : TLFutureSalts


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xae500895;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x99e2ccd6;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLFutureSalts$future_salts *object = [[TLFutureSalts$future_salts alloc] init];
    object.req_msg_id = metaObject->getInt64((int32_t)0x96e02a8b);
    object.now = metaObject->getInt32((int32_t)0x9f985590);
    object.salts = metaObject->getArray((int32_t)0x6232b985);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.req_msg_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x96e02a8b, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.now;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9f985590, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.salts;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x6232b985, value));
    }
}

@end
