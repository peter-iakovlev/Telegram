#import "TLphotos_Photos.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLphotos_Photos


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

@implementation TLphotos_Photos$photos_photos : TLphotos_Photos


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x8dca6aa5;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x6e41eb76;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLphotos_Photos$photos_photos *object = [[TLphotos_Photos$photos_photos alloc] init];
    object.photos = metaObject->getArray((int32_t)0x26b9c95f);
    object.users = metaObject->getArray((int32_t)0x933e5ff3);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.photos;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x26b9c95f, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.users;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x933e5ff3, value));
    }
}


@end

@implementation TLphotos_Photos$photos_photosSlice : TLphotos_Photos


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x15051f54;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x261480f9;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLphotos_Photos$photos_photosSlice *object = [[TLphotos_Photos$photos_photosSlice alloc] init];
    object.count = metaObject->getInt32((int32_t)0x5fa6aa74);
    object.photos = metaObject->getArray((int32_t)0x26b9c95f);
    object.users = metaObject->getArray((int32_t)0x933e5ff3);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.count;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5fa6aa74, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.photos;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x26b9c95f, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.users;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x933e5ff3, value));
    }
}


@end

