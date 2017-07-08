#import "TLRPCphone_saveCallDebug.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputPhoneCall.h"
#import "TLDataJSON.h"

@implementation TLRPCphone_saveCallDebug


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
    return 64;
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

@implementation TLRPCphone_saveCallDebug$phone_saveCallDebug : TLRPCphone_saveCallDebug


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x277add7e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xdec7584;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCphone_saveCallDebug$phone_saveCallDebug *object = [[TLRPCphone_saveCallDebug$phone_saveCallDebug alloc] init];
    object.peer = metaObject->getObject((int32_t)0x9344c37d);
    object.debug = metaObject->getObject((int32_t)0x859bf05a);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.peer;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9344c37d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.debug;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x859bf05a, value));
    }
}


@end

