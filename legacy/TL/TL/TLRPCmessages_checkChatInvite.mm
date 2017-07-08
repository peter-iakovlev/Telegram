#import "TLRPCmessages_checkChatInvite.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLChatInvite.h"

@implementation TLRPCmessages_checkChatInvite


- (Class)responseClass
{
    return [TLChatInvite class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 28;
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

@implementation TLRPCmessages_checkChatInvite$messages_checkChatInvite : TLRPCmessages_checkChatInvite


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x3eadb1bb;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x9fdaa53b;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_checkChatInvite$messages_checkChatInvite *object = [[TLRPCmessages_checkChatInvite$messages_checkChatInvite alloc] init];
    object.n_hash = metaObject->getString((int32_t)0xc152e470);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.n_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc152e470, value));
    }
}


@end

