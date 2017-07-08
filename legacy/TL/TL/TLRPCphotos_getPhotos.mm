#import "TLRPCphotos_getPhotos.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLphotos_Photos.h"

@implementation TLRPCphotos_getPhotos


- (Class)responseClass
{
    return [TLphotos_Photos class];
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

@implementation TLRPCphotos_getPhotos$photos_getPhotos : TLRPCphotos_getPhotos


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x13258ee;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x29233652;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCphotos_getPhotos$photos_getPhotos *object = [[TLRPCphotos_getPhotos$photos_getPhotos alloc] init];
    object.n_id = metaObject->getArray((int32_t)0x7a5601fb);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7a5601fb, value));
    }
}


@end

