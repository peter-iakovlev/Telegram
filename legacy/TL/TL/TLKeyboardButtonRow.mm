#import "TLKeyboardButtonRow.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLKeyboardButtonRow


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

@implementation TLKeyboardButtonRow$keyboardButtonRow : TLKeyboardButtonRow


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x77608b83;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x844efad3;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLKeyboardButtonRow$keyboardButtonRow *object = [[TLKeyboardButtonRow$keyboardButtonRow alloc] init];
    object.buttons = metaObject->getArray((int32_t)0x93d43879);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.buttons;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x93d43879, value));
    }
}


@end

