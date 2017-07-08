#import "TLImportedContact.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLImportedContact


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

@implementation TLImportedContact$importedContact : TLImportedContact


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xd0028438;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1ecefc34;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLImportedContact$importedContact *object = [[TLImportedContact$importedContact alloc] init];
    object.user_id = metaObject->getInt32((int32_t)0xafdf4073);
    object.client_id = metaObject->getInt64((int32_t)0x78ae14ea);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xafdf4073, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.client_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x78ae14ea, value));
    }
}


@end

