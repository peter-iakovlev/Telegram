#import "TLLangPackString.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLLangPackString


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

@implementation TLLangPackString$langPackString : TLLangPackString


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xcad181f6;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xcf2cb57a;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLLangPackString$langPackString *object = [[TLLangPackString$langPackString alloc] init];
    object.key = metaObject->getString((int32_t)0x6d6f838d);
    object.value = metaObject->getString((int32_t)0xf348b8d4);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.key;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x6d6f838d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.value;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xf348b8d4, value));
    }
}


@end

@implementation TLLangPackString$langPackStringPluralized : TLLangPackString


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa2fe21da;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x8510bef6;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLLangPackString$langPackStringPluralized *object = [[TLLangPackString$langPackStringPluralized alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.key = metaObject->getString((int32_t)0x6d6f838d);
    object.zero_value = metaObject->getString((int32_t)0xd870b126);
    object.one_value = metaObject->getString((int32_t)0x82849a94);
    object.two_value = metaObject->getString((int32_t)0x49975766);
    object.few_value = metaObject->getString((int32_t)0x4c94f65e);
    object.many_value = metaObject->getString((int32_t)0x86ff5a67);
    object.other_value = metaObject->getString((int32_t)0x5b8001c0);
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
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.key;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x6d6f838d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.zero_value;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xd870b126, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.one_value;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x82849a94, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.two_value;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x49975766, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.few_value;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4c94f65e, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.many_value;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x86ff5a67, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.other_value;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5b8001c0, value));
    }
}


@end

@implementation TLLangPackString$langPackStringDeleted : TLLangPackString


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x2979eeb2;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x94a916af;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLLangPackString$langPackStringDeleted *object = [[TLLangPackString$langPackStringDeleted alloc] init];
    object.key = metaObject->getString((int32_t)0x6d6f838d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.key;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x6d6f838d, value));
    }
}


@end

