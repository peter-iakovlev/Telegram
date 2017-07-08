#import "TLRPCmessages_readMessageContents.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLmessages_AffectedMessages.h"

@implementation TLRPCmessages_readMessageContents


- (Class)responseClass
{
    return [TLmessages_AffectedMessages class];
}

- (int)impliedResponseSignature
{
    return (int)0x84d19185;
}

- (int)layerVersion
{
    return 24;
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

@implementation TLRPCmessages_readMessageContents$messages_readMessageContents : TLRPCmessages_readMessageContents


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x36a73f77;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x40cdc0b4;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_readMessageContents$messages_readMessageContents *object = [[TLRPCmessages_readMessageContents$messages_readMessageContents alloc] init];
    object.n_id = metaObject->getArray((int32_t)0x7a5601fb);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7a5601fb, value));
    }
}


@end

