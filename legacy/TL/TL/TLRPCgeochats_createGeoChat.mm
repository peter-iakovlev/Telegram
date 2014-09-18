#import "TLRPCgeochats_createGeoChat.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputGeoPoint.h"
#import "TLgeochats_StatedMessage.h"

@implementation TLRPCgeochats_createGeoChat


- (Class)responseClass
{
    return [TLgeochats_StatedMessage class];
}

- (int)impliedResponseSignature
{
    return (int)0x17b1578b;
}

- (int)layerVersion
{
    return 6;
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

@implementation TLRPCgeochats_createGeoChat$geochats_createGeoChat : TLRPCgeochats_createGeoChat


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xe092e16;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x75536de5;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCgeochats_createGeoChat$geochats_createGeoChat *object = [[TLRPCgeochats_createGeoChat$geochats_createGeoChat alloc] init];
    object.title = metaObject->getString((int32_t)0xcdebf414);
    object.geo_point = metaObject->getObject((int32_t)0xa4670371);
    object.address = metaObject->getString((int32_t)0x1a893fea);
    object.venue = metaObject->getString((int32_t)0x689665bb);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.title;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xcdebf414, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.geo_point;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa4670371, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.address;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1a893fea, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.venue;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x689665bb, value));
    }
}


@end

