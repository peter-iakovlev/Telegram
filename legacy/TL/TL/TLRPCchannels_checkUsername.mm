#import "TLRPCchannels_checkUsername.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputChannel.h"

@implementation TLRPCchannels_checkUsername


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

@implementation TLRPCchannels_checkUsername$channels_checkUsername : TLRPCchannels_checkUsername


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x10e6bd2c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x6cd67c9d;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCchannels_checkUsername$channels_checkUsername *object = [[TLRPCchannels_checkUsername$channels_checkUsername alloc] init];
    object.channel = metaObject->getObject((int32_t)0xe11f3d41);
    object.username = metaObject->getString((int32_t)0x626830ca);
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
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.username;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x626830ca, value));
    }
}


@end

