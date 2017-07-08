#import "TLRPCdestroy_session.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLDestroySessionRes.h"

@implementation TLRPCdestroy_session


- (Class)responseClass
{
    return [TLDestroySessionRes class];
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

@implementation TLRPCdestroy_session$destroy_session : TLRPCdestroy_session


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xe7512126;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x7b8fe314;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCdestroy_session$destroy_session *object = [[TLRPCdestroy_session$destroy_session alloc] init];
    object.session_id = metaObject->getInt64((int32_t)0xacf0d2dd);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.session_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xacf0d2dd, value));
    }
}


@end

