#import "TLRPCchannels_getMessageEditData.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputChannel.h"
#import "TLchannels_MessageEditData.h"

@implementation TLRPCchannels_getMessageEditData


- (Class)responseClass
{
    return [TLchannels_MessageEditData class];
}

- (int)impliedResponseSignature
{
    return (int)0xe38d9526;
}

- (int)layerVersion
{
    return 48;
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

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TGLog(@"TLbuildFromMetaObject is not implemented for base type");
    return nil;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
    TGLog(@"TLfillFieldsWithValues is not implemented for base type");
}


@end

@implementation TLRPCchannels_getMessageEditData$channels_getMessageEditData : TLRPCchannels_getMessageEditData


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x27ea3a28;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1fda8978;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCchannels_getMessageEditData$channels_getMessageEditData *object = [[TLRPCchannels_getMessageEditData$channels_getMessageEditData alloc] init];
    object.channel = metaObject->getObject((int32_t)0xe11f3d41);
    object.n_id = metaObject->getInt32((int32_t)0x7a5601fb);
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
        value.primitive.int32Value = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7a5601fb, value));
    }
}


@end

