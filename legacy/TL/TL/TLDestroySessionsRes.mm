#import "TLDestroySessionsRes.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLDestroySessionsRes


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

@implementation TLDestroySessionsRes$destroy_sessions_res : TLDestroySessionsRes


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xfb95abcd;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xe0fad008;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLDestroySessionsRes$destroy_sessions_res *object = [[TLDestroySessionsRes$destroy_sessions_res alloc] init];
    object.destroy_results = metaObject->getObject((int32_t)0x1fc66ac4);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.destroy_results;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1fc66ac4, value));
    }
}


@end

