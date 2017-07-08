#import "TLStickerSetCovered.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLStickerSet.h"
#import "TLDocument.h"

@implementation TLStickerSetCovered


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

@implementation TLStickerSetCovered$stickerSetCovered : TLStickerSetCovered


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x6410a5d2;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x41bf2fa7;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLStickerSetCovered$stickerSetCovered *object = [[TLStickerSetCovered$stickerSetCovered alloc] init];
    object.set = metaObject->getObject((int32_t)0xb2c820f9);
    object.cover = metaObject->getObject((int32_t)0x7c051309);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.set;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb2c820f9, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.cover;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7c051309, value));
    }
}


@end

@implementation TLStickerSetCovered$stickerSetMultiCovered : TLStickerSetCovered


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x3407e51b;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x511fc2e1;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLStickerSetCovered$stickerSetMultiCovered *object = [[TLStickerSetCovered$stickerSetMultiCovered alloc] init];
    object.set = metaObject->getObject((int32_t)0xb2c820f9);
    object.covers = metaObject->getArray((int32_t)0xc1ab3692);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.set;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb2c820f9, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.covers;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc1ab3692, value));
    }
}


@end

