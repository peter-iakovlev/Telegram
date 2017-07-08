#import "TLRPChelp_saveNetworkStats.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLRPChelp_saveNetworkStats


- (Class)responseClass
{
    return [NSNumber class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 8;
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

@implementation TLRPChelp_saveNetworkStats$help_saveNetworkStats : TLRPChelp_saveNetworkStats


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xbda22fad;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x33ae9178;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPChelp_saveNetworkStats$help_saveNetworkStats *object = [[TLRPChelp_saveNetworkStats$help_saveNetworkStats alloc] init];
    object.stats = metaObject->getArray((int32_t)0x2887a01d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.stats;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x2887a01d, value));
    }
}


@end

