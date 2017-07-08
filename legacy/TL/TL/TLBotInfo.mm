#import "TLBotInfo.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLBotInfo


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

@implementation TLBotInfo$botInfo : TLBotInfo


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x98e81d3a;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1db27dc2;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLBotInfo$botInfo *object = [[TLBotInfo$botInfo alloc] init];
    object.user_id = metaObject->getInt32((int32_t)0xafdf4073);
    object.n_description = metaObject->getString((int32_t)0x9e47ce86);
    object.commands = metaObject->getArray((int32_t)0x1780d851);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xafdf4073, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.n_description;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9e47ce86, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.commands;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1780d851, value));
    }
}


@end

