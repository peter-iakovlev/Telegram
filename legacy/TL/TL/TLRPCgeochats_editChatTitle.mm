#import "TLRPCgeochats_editChatTitle.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputGeoChat.h"
#import "TLgeochats_StatedMessage.h"

@implementation TLRPCgeochats_editChatTitle


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

@implementation TLRPCgeochats_editChatTitle$geochats_editChatTitle : TLRPCgeochats_editChatTitle


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x4c8e2273;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xaacd37c0;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCgeochats_editChatTitle$geochats_editChatTitle *object = [[TLRPCgeochats_editChatTitle$geochats_editChatTitle alloc] init];
    object.peer = metaObject->getObject((int32_t)0x9344c37d);
    object.title = metaObject->getString((int32_t)0xcdebf414);
    object.address = metaObject->getString((int32_t)0x1a893fea);
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
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.title;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xcdebf414, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.address;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1a893fea, value));
    }
}


@end

