#import "TLInputBotInlineResult.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputBotInlineMessage.h"

@implementation TLInputBotInlineResult


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

@implementation TLInputBotInlineResult$inputBotInlineResultGame : TLInputBotInlineResult


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x4fa417f2;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x37249336;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLInputBotInlineResult$inputBotInlineResultGame *object = [[TLInputBotInlineResult$inputBotInlineResultGame alloc] init];
    object.n_id = metaObject->getString((int32_t)0x7a5601fb);
    object.short_name = metaObject->getString((int32_t)0xfccec594);
    object.send_message = metaObject->getObject((int32_t)0x6d920cae);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7a5601fb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.short_name;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xfccec594, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.send_message;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x6d920cae, value));
    }
}


@end

