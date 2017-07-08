#import "TLKeyboardButton.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLKeyboardButton


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

@implementation TLKeyboardButton$keyboardButton : TLKeyboardButton


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa2fa4880;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xe71a782a;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLKeyboardButton$keyboardButton *object = [[TLKeyboardButton$keyboardButton alloc] init];
    object.text = metaObject->getString((int32_t)0x94f1580d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.text;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x94f1580d, value));
    }
}


@end

@implementation TLKeyboardButton$keyboardButtonUrl : TLKeyboardButton


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x258aff05;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xe834ec84;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLKeyboardButton$keyboardButtonUrl *object = [[TLKeyboardButton$keyboardButtonUrl alloc] init];
    object.text = metaObject->getString((int32_t)0x94f1580d);
    object.url = metaObject->getString((int32_t)0xeaf7861e);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.text;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x94f1580d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.url;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xeaf7861e, value));
    }
}


@end

@implementation TLKeyboardButton$keyboardButtonCallback : TLKeyboardButton


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x683a5e46;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x81365104;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLKeyboardButton$keyboardButtonCallback *object = [[TLKeyboardButton$keyboardButtonCallback alloc] init];
    object.text = metaObject->getString((int32_t)0x94f1580d);
    object.data = metaObject->getBytes((int32_t)0xa361765d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.text;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x94f1580d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.data;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa361765d, value));
    }
}


@end

@implementation TLKeyboardButton$keyboardButtonRequestPhone : TLKeyboardButton


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xb16a6c29;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xf5700be8;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLKeyboardButton$keyboardButtonRequestPhone *object = [[TLKeyboardButton$keyboardButtonRequestPhone alloc] init];
    object.text = metaObject->getString((int32_t)0x94f1580d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.text;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x94f1580d, value));
    }
}


@end

@implementation TLKeyboardButton$keyboardButtonRequestGeoLocation : TLKeyboardButton


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xfc796b3f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x540f6860;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLKeyboardButton$keyboardButtonRequestGeoLocation *object = [[TLKeyboardButton$keyboardButtonRequestGeoLocation alloc] init];
    object.text = metaObject->getString((int32_t)0x94f1580d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.text;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x94f1580d, value));
    }
}


@end

@implementation TLKeyboardButton$keyboardButtonSwitchInline : TLKeyboardButton


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x568a748;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xf1356aa1;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLKeyboardButton$keyboardButtonSwitchInline *object = [[TLKeyboardButton$keyboardButtonSwitchInline alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.text = metaObject->getString((int32_t)0x94f1580d);
    object.query = metaObject->getString((int32_t)0x5de9dcb1);
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
        value.nativeObject = self.text;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x94f1580d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.query;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5de9dcb1, value));
    }
}


@end

@implementation TLKeyboardButton$keyboardButtonGame : TLKeyboardButton


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x50f41ccf;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa81e7110;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLKeyboardButton$keyboardButtonGame *object = [[TLKeyboardButton$keyboardButtonGame alloc] init];
    object.text = metaObject->getString((int32_t)0x94f1580d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.text;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x94f1580d, value));
    }
}


@end

@implementation TLKeyboardButton$keyboardButtonBuy : TLKeyboardButton


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xafd93fbb;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x681b516f;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLKeyboardButton$keyboardButtonBuy *object = [[TLKeyboardButton$keyboardButtonBuy alloc] init];
    object.text = metaObject->getString((int32_t)0x94f1580d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.text;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x94f1580d, value));
    }
}


@end

