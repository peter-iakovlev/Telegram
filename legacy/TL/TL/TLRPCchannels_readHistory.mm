#import "TLRPCchannels_readHistory.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputChannel.h"

@implementation TLRPCchannels_readHistory


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
    return 38;
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

@implementation TLRPCchannels_readHistory$channels_readHistory : TLRPCchannels_readHistory


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xcc104937;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xdeb4256d;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCchannels_readHistory$channels_readHistory *object = [[TLRPCchannels_readHistory$channels_readHistory alloc] init];
    object.channel = metaObject->getObject((int32_t)0xe11f3d41);
    object.max_id = metaObject->getInt32((int32_t)0xe2c00ace);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.channel;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe11f3d41, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.max_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe2c00ace, value));
    }
}


@end

