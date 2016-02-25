#import "TLBotInlineResult.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLDocument.h"
#import "TLBotInlineMessage.h"
#import "TLPhoto.h"

@implementation TLBotInlineResult


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

@implementation TLBotInlineResult$botInlineMediaResultDocument : TLBotInlineResult


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xf897d33e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xfb6fea40;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLBotInlineResult$botInlineMediaResultDocument *object = [[TLBotInlineResult$botInlineMediaResultDocument alloc] init];
    object.n_id = metaObject->getString((int32_t)0x7a5601fb);
    object.type = metaObject->getString((int32_t)0x9211ab0a);
    object.document = metaObject->getObject((int32_t)0xf1465b5f);
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
        value.nativeObject = self.type;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9211ab0a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.document;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xf1465b5f, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.send_message;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x6d920cae, value));
    }
}


@end

@implementation TLBotInlineResult$botInlineMediaResultPhoto : TLBotInlineResult


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xc5528587;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x9357a2eb;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLBotInlineResult$botInlineMediaResultPhoto *object = [[TLBotInlineResult$botInlineMediaResultPhoto alloc] init];
    object.n_id = metaObject->getString((int32_t)0x7a5601fb);
    object.type = metaObject->getString((int32_t)0x9211ab0a);
    object.photo = metaObject->getObject((int32_t)0xe6c52372);
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
        value.nativeObject = self.type;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9211ab0a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.photo;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe6c52372, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.send_message;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x6d920cae, value));
    }
}


@end

