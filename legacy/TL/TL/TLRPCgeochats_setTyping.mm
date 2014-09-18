#import "TLRPCgeochats_setTyping.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputGeoChat.h"

@implementation TLRPCgeochats_setTyping


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
    return 4;
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

@implementation TLRPCgeochats_setTyping$geochats_setTyping : TLRPCgeochats_setTyping


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x8b8a729;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa93801ea;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCgeochats_setTyping$geochats_setTyping *object = [[TLRPCgeochats_setTyping$geochats_setTyping alloc] init];
    object.peer = metaObject->getObject((int32_t)0x9344c37d);
    object.typing = metaObject->getBool((int32_t)0x77929cef);
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
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.typing;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x77929cef, value));
    }
}


@end

