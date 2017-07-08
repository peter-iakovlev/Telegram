#import "TLMessageEntity.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputUser.h"

@implementation TLMessageEntity


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

@implementation TLMessageEntity$messageEntityUnknown : TLMessageEntity


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xbb92ba95;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x49391fa8;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageEntity$messageEntityUnknown *object = [[TLMessageEntity$messageEntityUnknown alloc] init];
    object.offset = metaObject->getInt32((int32_t)0xfc56269);
    object.length = metaObject->getInt32((int32_t)0x18492126);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.offset;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xfc56269, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.length;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x18492126, value));
    }
}


@end

@implementation TLMessageEntity$messageEntityMention : TLMessageEntity


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xfa04579d;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xec0b00e2;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageEntity$messageEntityMention *object = [[TLMessageEntity$messageEntityMention alloc] init];
    object.offset = metaObject->getInt32((int32_t)0xfc56269);
    object.length = metaObject->getInt32((int32_t)0x18492126);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.offset;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xfc56269, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.length;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x18492126, value));
    }
}


@end

@implementation TLMessageEntity$messageEntityHashtag : TLMessageEntity


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x6f635b0d;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xc5e2530d;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageEntity$messageEntityHashtag *object = [[TLMessageEntity$messageEntityHashtag alloc] init];
    object.offset = metaObject->getInt32((int32_t)0xfc56269);
    object.length = metaObject->getInt32((int32_t)0x18492126);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.offset;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xfc56269, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.length;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x18492126, value));
    }
}


@end

@implementation TLMessageEntity$messageEntityBotCommand : TLMessageEntity


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x6cef8ac7;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x7731806e;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageEntity$messageEntityBotCommand *object = [[TLMessageEntity$messageEntityBotCommand alloc] init];
    object.offset = metaObject->getInt32((int32_t)0xfc56269);
    object.length = metaObject->getInt32((int32_t)0x18492126);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.offset;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xfc56269, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.length;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x18492126, value));
    }
}


@end

@implementation TLMessageEntity$messageEntityUrl : TLMessageEntity


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x6ed02538;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xf95ff8ac;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageEntity$messageEntityUrl *object = [[TLMessageEntity$messageEntityUrl alloc] init];
    object.offset = metaObject->getInt32((int32_t)0xfc56269);
    object.length = metaObject->getInt32((int32_t)0x18492126);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.offset;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xfc56269, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.length;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x18492126, value));
    }
}


@end

@implementation TLMessageEntity$messageEntityEmail : TLMessageEntity


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x64e475c2;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xbdc7f80;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageEntity$messageEntityEmail *object = [[TLMessageEntity$messageEntityEmail alloc] init];
    object.offset = metaObject->getInt32((int32_t)0xfc56269);
    object.length = metaObject->getInt32((int32_t)0x18492126);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.offset;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xfc56269, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.length;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x18492126, value));
    }
}


@end

@implementation TLMessageEntity$messageEntityBold : TLMessageEntity


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xbd610bc9;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xe4046999;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageEntity$messageEntityBold *object = [[TLMessageEntity$messageEntityBold alloc] init];
    object.offset = metaObject->getInt32((int32_t)0xfc56269);
    object.length = metaObject->getInt32((int32_t)0x18492126);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.offset;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xfc56269, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.length;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x18492126, value));
    }
}


@end

@implementation TLMessageEntity$messageEntityItalic : TLMessageEntity


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x826f8b60;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1d3611f9;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageEntity$messageEntityItalic *object = [[TLMessageEntity$messageEntityItalic alloc] init];
    object.offset = metaObject->getInt32((int32_t)0xfc56269);
    object.length = metaObject->getInt32((int32_t)0x18492126);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.offset;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xfc56269, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.length;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x18492126, value));
    }
}


@end

@implementation TLMessageEntity$messageEntityCode : TLMessageEntity


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x28a20571;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xe801eca;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageEntity$messageEntityCode *object = [[TLMessageEntity$messageEntityCode alloc] init];
    object.offset = metaObject->getInt32((int32_t)0xfc56269);
    object.length = metaObject->getInt32((int32_t)0x18492126);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.offset;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xfc56269, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.length;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x18492126, value));
    }
}


@end

@implementation TLMessageEntity$messageEntityPre : TLMessageEntity


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x73924be0;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xebd4d098;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageEntity$messageEntityPre *object = [[TLMessageEntity$messageEntityPre alloc] init];
    object.offset = metaObject->getInt32((int32_t)0xfc56269);
    object.length = metaObject->getInt32((int32_t)0x18492126);
    object.language = metaObject->getString((int32_t)0x672497b4);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.offset;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xfc56269, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.length;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x18492126, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.language;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x672497b4, value));
    }
}


@end

@implementation TLMessageEntity$messageEntityTextUrl : TLMessageEntity


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x76a6d327;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x6c3e5402;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageEntity$messageEntityTextUrl *object = [[TLMessageEntity$messageEntityTextUrl alloc] init];
    object.offset = metaObject->getInt32((int32_t)0xfc56269);
    object.length = metaObject->getInt32((int32_t)0x18492126);
    object.url = metaObject->getString((int32_t)0xeaf7861e);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.offset;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xfc56269, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.length;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x18492126, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.url;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xeaf7861e, value));
    }
}


@end

@implementation TLMessageEntity$messageEntityMentionName : TLMessageEntity


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x352dca58;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xe727402c;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageEntity$messageEntityMentionName *object = [[TLMessageEntity$messageEntityMentionName alloc] init];
    object.offset = metaObject->getInt32((int32_t)0xfc56269);
    object.length = metaObject->getInt32((int32_t)0x18492126);
    object.user_id = metaObject->getInt32((int32_t)0xafdf4073);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.offset;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xfc56269, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.length;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x18492126, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xafdf4073, value));
    }
}


@end

@implementation TLMessageEntity$inputMessageEntityMentionName : TLMessageEntity


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x208e68c9;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x7b78b06f;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageEntity$inputMessageEntityMentionName *object = [[TLMessageEntity$inputMessageEntityMentionName alloc] init];
    object.offset = metaObject->getInt32((int32_t)0xfc56269);
    object.length = metaObject->getInt32((int32_t)0x18492126);
    object.user_id = metaObject->getObject((int32_t)0xafdf4073);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.offset;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xfc56269, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.length;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x18492126, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xafdf4073, value));
    }
}


@end

