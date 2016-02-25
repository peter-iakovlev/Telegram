#import "TLRPCmessages_getInlineBotResults.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputUser.h"
#import "TLmessages_BotResults.h"

@implementation TLRPCmessages_getInlineBotResults


- (Class)responseClass
{
    return [TLmessages_BotResults class];
}

- (int)impliedResponseSignature
{
    return (int)0x9f7e87b2;
}

- (int)layerVersion
{
    return 45;
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

@implementation TLRPCmessages_getInlineBotResults$messages_getInlineBotResults : TLRPCmessages_getInlineBotResults


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x9324600d;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1d360a90;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_getInlineBotResults$messages_getInlineBotResults *object = [[TLRPCmessages_getInlineBotResults$messages_getInlineBotResults alloc] init];
    object.bot = metaObject->getObject((int32_t)0x5b476acc);
    object.query = metaObject->getString((int32_t)0x5de9dcb1);
    object.offset = metaObject->getString((int32_t)0xfc56269);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.bot;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5b476acc, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.query;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5de9dcb1, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.offset;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xfc56269, value));
    }
}


@end

