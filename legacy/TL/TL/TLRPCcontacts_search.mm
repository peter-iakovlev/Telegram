#import "TLRPCcontacts_search.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLcontacts_Found.h"

@implementation TLRPCcontacts_search


- (Class)responseClass
{
    return [TLcontacts_Found class];
}

- (int)impliedResponseSignature
{
    return (int)0x1aa1f784;
}

- (int)layerVersion
{
    return 18;
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

@implementation TLRPCcontacts_search$contacts_search : TLRPCcontacts_search


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x11f812d8;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa19c29b8;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCcontacts_search$contacts_search *object = [[TLRPCcontacts_search$contacts_search alloc] init];
    object.q = metaObject->getString((int32_t)0xcd45cb1c);
    object.limit = metaObject->getInt32((int32_t)0xb8433fca);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.q;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xcd45cb1c, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.limit;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb8433fca, value));
    }
}


@end

