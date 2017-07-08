#import "TLPopularContact.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLPopularContact


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

@implementation TLPopularContact$popularContact : TLPopularContact


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x5ce14175;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x6f7a8174;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLPopularContact$popularContact *object = [[TLPopularContact$popularContact alloc] init];
    object.client_id = metaObject->getInt64((int32_t)0x78ae14ea);
    object.importers = metaObject->getInt32((int32_t)0x840bbc0a);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.client_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x78ae14ea, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.importers;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x840bbc0a, value));
    }
}


@end

