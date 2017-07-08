#import "TLUserProfilePhoto.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLFileLocation.h"

@implementation TLUserProfilePhoto


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

@implementation TLUserProfilePhoto$userProfilePhotoEmpty : TLUserProfilePhoto


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x4f11bae1;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x32a9eac7;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLUserProfilePhoto$userProfilePhotoEmpty *object = [[TLUserProfilePhoto$userProfilePhotoEmpty alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLUserProfilePhoto$userProfilePhoto : TLUserProfilePhoto


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xd559d8c8;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x633f7034;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLUserProfilePhoto$userProfilePhoto *object = [[TLUserProfilePhoto$userProfilePhoto alloc] init];
    object.photo_id = metaObject->getInt64((int32_t)0xa4b26129);
    object.photo_small = metaObject->getObject((int32_t)0x139af8d6);
    object.photo_big = metaObject->getObject((int32_t)0x764b3bbc);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.photo_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa4b26129, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.photo_small;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x139af8d6, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.photo_big;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x764b3bbc, value));
    }
}


@end

