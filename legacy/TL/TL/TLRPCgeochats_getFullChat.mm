#import "TLRPCgeochats_getFullChat.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputGeoChat.h"
#import "TLmessages_ChatFull.h"

@implementation TLRPCgeochats_getFullChat


- (Class)responseClass
{
    return [TLmessages_ChatFull class];
}

- (int)impliedResponseSignature
{
    return (int)0xe5d7d19c;
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

@implementation TLRPCgeochats_getFullChat$geochats_getFullChat : TLRPCgeochats_getFullChat


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x6722dd6f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb2e44e4;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCgeochats_getFullChat$geochats_getFullChat *object = [[TLRPCgeochats_getFullChat$geochats_getFullChat alloc] init];
    object.peer = metaObject->getObject((int32_t)0x9344c37d);
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
}


@end

