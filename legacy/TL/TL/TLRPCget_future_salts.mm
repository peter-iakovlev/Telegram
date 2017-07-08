#import "TLRPCget_future_salts.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLFutureSalts.h"

@implementation TLRPCget_future_salts


- (Class)responseClass
{
    return [TLFutureSalts class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 0;
}

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

@implementation TLRPCget_future_salts$get_future_salts : TLRPCget_future_salts


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xb921bd04;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb96ee025;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCget_future_salts$get_future_salts *object = [[TLRPCget_future_salts$get_future_salts alloc] init];
    object.num = metaObject->getInt32((int32_t)0x8d554573);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.num;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x8d554573, value));
    }
}


@end

