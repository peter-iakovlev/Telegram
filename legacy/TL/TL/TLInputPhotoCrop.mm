#import "TLInputPhotoCrop.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLInputPhotoCrop


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

@implementation TLInputPhotoCrop$inputPhotoCropAuto : TLInputPhotoCrop


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xade6b004;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xdbf47abb;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLInputPhotoCrop$inputPhotoCropAuto *object = [[TLInputPhotoCrop$inputPhotoCropAuto alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLInputPhotoCrop$inputPhotoCrop : TLInputPhotoCrop


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xd9915325;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xc05dc5bf;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLInputPhotoCrop$inputPhotoCrop *object = [[TLInputPhotoCrop$inputPhotoCrop alloc] init];
    object.crop_left = metaObject->getDouble((int32_t)0x47270b7f);
    object.crop_top = metaObject->getDouble((int32_t)0x804ef5cc);
    object.crop_width = metaObject->getDouble((int32_t)0x2bd4155b);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveDouble;
        value.primitive.doubleValue = self.crop_left;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x47270b7f, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveDouble;
        value.primitive.doubleValue = self.crop_top;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x804ef5cc, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveDouble;
        value.primitive.doubleValue = self.crop_width;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x2bd4155b, value));
    }
}


@end

