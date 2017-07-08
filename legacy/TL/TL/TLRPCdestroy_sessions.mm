#import "TLRPCdestroy_sessions.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLDestroySessionsRes.h"

@implementation TLRPCdestroy_sessions


- (Class)responseClass
{
    return [TLDestroySessionsRes class];
}

- (int)impliedResponseSignature
{
    return (int)0xfb95abcd;
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

@implementation TLRPCdestroy_sessions$destroy_sessions : TLRPCdestroy_sessions


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa13dc52f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xf4a3e682;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCdestroy_sessions$destroy_sessions *object = [[TLRPCdestroy_sessions$destroy_sessions alloc] init];
    object.session_ids = metaObject->getObject((int32_t)0xf0896a48);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.session_ids;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xf0896a48, value));
    }
}


@end

