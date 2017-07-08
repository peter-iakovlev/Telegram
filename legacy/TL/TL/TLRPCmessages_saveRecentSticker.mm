#import "TLRPCmessages_saveRecentSticker.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputDocument.h"

@implementation TLRPCmessages_saveRecentSticker


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
    return 54;
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

@implementation TLRPCmessages_saveRecentSticker$messages_saveRecentSticker : TLRPCmessages_saveRecentSticker


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x348e39bf;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xfb028aa4;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_saveRecentSticker$messages_saveRecentSticker *object = [[TLRPCmessages_saveRecentSticker$messages_saveRecentSticker alloc] init];
    object.n_id = metaObject->getObject((int32_t)0x7a5601fb);
    object.unsave = metaObject->getBool((int32_t)0xb4a6ae0c);
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
        value.primitive.boolValue = self.unsave;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb4a6ae0c, value));
    }
}


@end

