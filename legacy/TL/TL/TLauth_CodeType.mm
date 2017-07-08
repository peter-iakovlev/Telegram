#import "TLauth_CodeType.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLauth_CodeType


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

@implementation TLauth_CodeType$auth_codeTypeSms : TLauth_CodeType


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x72a3158c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa372a139;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLauth_CodeType$auth_codeTypeSms *object = [[TLauth_CodeType$auth_codeTypeSms alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLauth_CodeType$auth_codeTypeCall : TLauth_CodeType


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x741cd3e3;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x93c0e85f;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLauth_CodeType$auth_codeTypeCall *object = [[TLauth_CodeType$auth_codeTypeCall alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLauth_CodeType$auth_codeTypeFlashCall : TLauth_CodeType


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x226ccefb;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x702954ac;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLauth_CodeType$auth_codeTypeFlashCall *object = [[TLauth_CodeType$auth_codeTypeFlashCall alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

