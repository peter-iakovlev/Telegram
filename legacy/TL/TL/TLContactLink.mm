#import "TLContactLink.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLContactLink


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

@implementation TLContactLink$contactLinkUnknown : TLContactLink


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x5f4f9247;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xea033ab4;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLContactLink$contactLinkUnknown *object = [[TLContactLink$contactLinkUnknown alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLContactLink$contactLinkNone : TLContactLink


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xfeedd3ad;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xc13f076f;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLContactLink$contactLinkNone *object = [[TLContactLink$contactLinkNone alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLContactLink$contactLinkHasPhone : TLContactLink


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x268f3f59;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x8397c9a5;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLContactLink$contactLinkHasPhone *object = [[TLContactLink$contactLinkHasPhone alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLContactLink$contactLinkContact : TLContactLink


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xd502c2d0;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xfdfccded;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLContactLink$contactLinkContact *object = [[TLContactLink$contactLinkContact alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

