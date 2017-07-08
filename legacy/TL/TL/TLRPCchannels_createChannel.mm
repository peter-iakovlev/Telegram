#import "TLRPCchannels_createChannel.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLUpdates.h"

@implementation TLRPCchannels_createChannel


- (Class)responseClass
{
    return [TLUpdates class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 41;
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

@implementation TLRPCchannels_createChannel$channels_createChannel : TLRPCchannels_createChannel


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xf4893d7f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xc7171da5;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCchannels_createChannel$channels_createChannel *object = [[TLRPCchannels_createChannel$channels_createChannel alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.title = metaObject->getString((int32_t)0xcdebf414);
    object.about = metaObject->getString((int32_t)0xdf4f0b19);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.flags;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x81915c23, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.title;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xcdebf414, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.about;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xdf4f0b19, value));
    }
}


@end

