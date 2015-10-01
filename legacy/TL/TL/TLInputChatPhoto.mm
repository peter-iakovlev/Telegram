#import "TLInputChatPhoto.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputFile.h"
#import "TLInputPhotoCrop.h"
#import "TLInputPhoto.h"

@implementation TLInputChatPhoto


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

@implementation TLInputChatPhoto$inputChatPhotoEmpty : TLInputChatPhoto


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x1ca48f57;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa748307c;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLInputChatPhoto$inputChatPhotoEmpty *object = [[TLInputChatPhoto$inputChatPhotoEmpty alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLInputChatPhoto$inputChatUploadedPhoto : TLInputChatPhoto


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x94254732;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xfa544488;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLInputChatPhoto$inputChatUploadedPhoto *object = [[TLInputChatPhoto$inputChatUploadedPhoto alloc] init];
    object.file = metaObject->getObject((int32_t)0x3187ec9);
    object.crop = metaObject->getObject((int32_t)0x987dc5e1);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.file;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x3187ec9, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.crop;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x987dc5e1, value));
    }
}


@end

@implementation TLInputChatPhoto$inputChatPhoto : TLInputChatPhoto


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xb2e1bf08;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x93b721ca;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLInputChatPhoto$inputChatPhoto *object = [[TLInputChatPhoto$inputChatPhoto alloc] init];
    object.n_id = metaObject->getObject((int32_t)0x7a5601fb);
    object.crop = metaObject->getObject((int32_t)0x987dc5e1);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7a5601fb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.crop;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x987dc5e1, value));
    }
}


@end

