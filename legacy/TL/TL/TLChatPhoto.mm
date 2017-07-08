#import "TLChatPhoto.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLFileLocation.h"

@implementation TLChatPhoto


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

@implementation TLChatPhoto$chatPhotoEmpty : TLChatPhoto


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x37c1011c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x276a59a0;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLChatPhoto$chatPhotoEmpty *object = [[TLChatPhoto$chatPhotoEmpty alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLChatPhoto$chatPhoto : TLChatPhoto


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x6153276a;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x39bae953;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLChatPhoto$chatPhoto *object = [[TLChatPhoto$chatPhoto alloc] init];
    object.photo_small = metaObject->getObject((int32_t)0x139af8d6);
    object.photo_big = metaObject->getObject((int32_t)0x764b3bbc);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
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

