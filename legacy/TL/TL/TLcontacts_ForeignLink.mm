#import "TLcontacts_ForeignLink.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLcontacts_ForeignLink


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

@implementation TLcontacts_ForeignLink$contacts_foreignLinkUnknown : TLcontacts_ForeignLink


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x133421f8;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x15bce3ba;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLcontacts_ForeignLink$contacts_foreignLinkUnknown *object = [[TLcontacts_ForeignLink$contacts_foreignLinkUnknown alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLcontacts_ForeignLink$contacts_foreignLinkRequested : TLcontacts_ForeignLink


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa7801f47;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xf0395e38;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLcontacts_ForeignLink$contacts_foreignLinkRequested *object = [[TLcontacts_ForeignLink$contacts_foreignLinkRequested alloc] init];
    object.has_phone = metaObject->getBool((int32_t)0x217cda81);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.has_phone;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x217cda81, value));
    }
}


@end

@implementation TLcontacts_ForeignLink$contacts_foreignLinkMutual : TLcontacts_ForeignLink


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x1bea8ce1;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xc7d5d948;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLcontacts_ForeignLink$contacts_foreignLinkMutual *object = [[TLcontacts_ForeignLink$contacts_foreignLinkMutual alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

