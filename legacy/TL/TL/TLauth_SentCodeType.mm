#import "TLauth_SentCodeType.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLauth_SentCodeType


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

@implementation TLauth_SentCodeType$auth_sentCodeTypeApp : TLauth_SentCodeType


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x3dbb5986;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x435260a8;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLauth_SentCodeType$auth_sentCodeTypeApp *object = [[TLauth_SentCodeType$auth_sentCodeTypeApp alloc] init];
    object.length = metaObject->getInt32((int32_t)0x18492126);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.length;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x18492126, value));
    }
}


@end

@implementation TLauth_SentCodeType$auth_sentCodeTypeSms : TLauth_SentCodeType


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xc000bba2;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb96de300;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLauth_SentCodeType$auth_sentCodeTypeSms *object = [[TLauth_SentCodeType$auth_sentCodeTypeSms alloc] init];
    object.length = metaObject->getInt32((int32_t)0x18492126);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.length;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x18492126, value));
    }
}


@end

@implementation TLauth_SentCodeType$auth_sentCodeTypeCall : TLauth_SentCodeType


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x5353e5a7;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x7028cf80;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLauth_SentCodeType$auth_sentCodeTypeCall *object = [[TLauth_SentCodeType$auth_sentCodeTypeCall alloc] init];
    object.length = metaObject->getInt32((int32_t)0x18492126);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.length;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x18492126, value));
    }
}


@end

@implementation TLauth_SentCodeType$auth_sentCodeTypeFlashCall : TLauth_SentCodeType


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xab03c6d9;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x5bb63a1;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLauth_SentCodeType$auth_sentCodeTypeFlashCall *object = [[TLauth_SentCodeType$auth_sentCodeTypeFlashCall alloc] init];
    object.pattern = metaObject->getString((int32_t)0x79346463);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.pattern;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x79346463, value));
    }
}


@end

