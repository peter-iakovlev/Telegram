#import "TLCdnPublicKey.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLCdnPublicKey


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

@implementation TLCdnPublicKey$cdnPublicKey : TLCdnPublicKey


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xc982eaba;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x4c493829;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLCdnPublicKey$cdnPublicKey *object = [[TLCdnPublicKey$cdnPublicKey alloc] init];
    object.dc_id = metaObject->getInt32((int32_t)0xae973dc4);
    object.public_key = metaObject->getString((int32_t)0x2f97cb8a);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.dc_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xae973dc4, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.public_key;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x2f97cb8a, value));
    }
}


@end

