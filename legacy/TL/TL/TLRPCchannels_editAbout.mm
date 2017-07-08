#import "TLRPCchannels_editAbout.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputChannel.h"

@implementation TLRPCchannels_editAbout


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

@implementation TLRPCchannels_editAbout$channels_editAbout : TLRPCchannels_editAbout


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x13e27f1e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x16d8d10a;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCchannels_editAbout$channels_editAbout *object = [[TLRPCchannels_editAbout$channels_editAbout alloc] init];
    object.channel = metaObject->getObject((int32_t)0xe11f3d41);
    object.about = metaObject->getString((int32_t)0xdf4f0b19);
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
        value.nativeObject = self.about;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xdf4f0b19, value));
    }
}


@end

