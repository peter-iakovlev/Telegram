#import "TLRPCphotos_updateProfilePhoto.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputPhoto.h"
#import "TLInputPhotoCrop.h"
#import "TLUserProfilePhoto.h"

@implementation TLRPCphotos_updateProfilePhoto


- (Class)responseClass
{
    return [TLUserProfilePhoto class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 8;
}

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

@implementation TLRPCphotos_updateProfilePhoto$photos_updateProfilePhoto : TLRPCphotos_updateProfilePhoto


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xeef579a0;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x9d39aee4;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCphotos_updateProfilePhoto$photos_updateProfilePhoto *object = [[TLRPCphotos_updateProfilePhoto$photos_updateProfilePhoto alloc] init];
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

