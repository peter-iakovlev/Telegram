#import "TLReplyMarkup.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLReplyMarkup


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

@implementation TLReplyMarkup$replyKeyboardHide : TLReplyMarkup


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa03e5b85;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x4fd88fbd;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLReplyMarkup$replyKeyboardHide *object = [[TLReplyMarkup$replyKeyboardHide alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.flags;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x81915c23, value));
    }
}


@end

@implementation TLReplyMarkup$replyKeyboardForceReply : TLReplyMarkup


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xf4108aa0;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x8f52bf3f;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLReplyMarkup$replyKeyboardForceReply *object = [[TLReplyMarkup$replyKeyboardForceReply alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.flags;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x81915c23, value));
    }
}


@end

@implementation TLReplyMarkup$replyKeyboardMarkup : TLReplyMarkup


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x3502758c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x82aadd81;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLReplyMarkup$replyKeyboardMarkup *object = [[TLReplyMarkup$replyKeyboardMarkup alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.rows = metaObject->getArray((int32_t)0x441aa5c6);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.flags;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x81915c23, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.rows;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x441aa5c6, value));
    }
}


@end

@implementation TLReplyMarkup$replyInlineMarkup : TLReplyMarkup


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x48a30254;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb4cb9b07;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLReplyMarkup$replyInlineMarkup *object = [[TLReplyMarkup$replyInlineMarkup alloc] init];
    object.rows = metaObject->getArray((int32_t)0x441aa5c6);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.rows;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x441aa5c6, value));
    }
}


@end

