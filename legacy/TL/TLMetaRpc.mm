#import "TLMetaRpc.h"

@implementation TLMetaRpc

- (Class)responseClass
{
    return nil;
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
    return 0xabcdef;
}

- (int32_t)TLconstructorName
{
    return 0xabcdef;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    return nil;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}

@end
