#import "TLRPCmessages_faveSticker.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputDocument.h"

@implementation TLRPCmessages_faveSticker


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
    return 71;
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

@implementation TLRPCmessages_faveSticker$messages_faveSticker : TLRPCmessages_faveSticker


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xb9ffc55b;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x39c46b9a;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_faveSticker$messages_faveSticker *object = [[TLRPCmessages_faveSticker$messages_faveSticker alloc] init];
    object.n_id = metaObject->getObject((int32_t)0x7a5601fb);
    object.unfave = metaObject->getBool((int32_t)0x7d88abae);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7a5601fb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.unfave;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7d88abae, value));
    }
}


@end

