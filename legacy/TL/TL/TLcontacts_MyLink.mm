#import "TLcontacts_MyLink.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLcontacts_MyLink


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

@implementation TLcontacts_MyLink$contacts_myLinkEmpty : TLcontacts_MyLink


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xd22a1c60;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb4cf4e51;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLcontacts_MyLink$contacts_myLinkEmpty *object = [[TLcontacts_MyLink$contacts_myLinkEmpty alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLcontacts_MyLink$contacts_myLinkRequested : TLcontacts_MyLink


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x6c69efee;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x35bdcac7;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLcontacts_MyLink$contacts_myLinkRequested *object = [[TLcontacts_MyLink$contacts_myLinkRequested alloc] init];
    object.contact = metaObject->getBool((int32_t)0xa9d2a4b);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.contact;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa9d2a4b, value));
    }
}


@end

@implementation TLcontacts_MyLink$contacts_myLinkContact : TLcontacts_MyLink


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xc240ebd9;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xc69f50c4;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLcontacts_MyLink$contacts_myLinkContact *object = [[TLcontacts_MyLink$contacts_myLinkContact alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

