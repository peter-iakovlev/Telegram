#import "TLInputBotInlineMessage.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLReplyMarkup.h"

@implementation TLInputBotInlineMessage


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

@implementation TLInputBotInlineMessage$inputBotInlineMessageGame : TLInputBotInlineMessage


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x3c00f8aa;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xbee56e20;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLInputBotInlineMessage$inputBotInlineMessageGame *object = [[TLInputBotInlineMessage$inputBotInlineMessageGame alloc] init];
    object.reply_markup = metaObject->getObject((int32_t)0x35f2c195);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.reply_markup;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x35f2c195, value));
    }
}


@end

