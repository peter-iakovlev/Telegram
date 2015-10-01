#import "TLMessagesFilter.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLMessagesFilter


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

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TGLog(@"TLbuildFromMetaObject is not implemented for base type");
    return nil;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
    TGLog(@"TLfillFieldsWithValues is not implemented for base type");
}


@end

@implementation TLMessagesFilter$inputMessagesFilterEmpty : TLMessagesFilter


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x57e2f66c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb251cae0;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLMessagesFilter$inputMessagesFilterEmpty *object = [[TLMessagesFilter$inputMessagesFilterEmpty alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLMessagesFilter$inputMessagesFilterPhotos : TLMessagesFilter


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x9609a51c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb48bc46b;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLMessagesFilter$inputMessagesFilterPhotos *object = [[TLMessagesFilter$inputMessagesFilterPhotos alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLMessagesFilter$inputMessagesFilterVideo : TLMessagesFilter


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x9fc00e65;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x46081055;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLMessagesFilter$inputMessagesFilterVideo *object = [[TLMessagesFilter$inputMessagesFilterVideo alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLMessagesFilter$inputMessagesFilterPhotoVideo : TLMessagesFilter


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x56e9f0e4;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1f9a0830;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLMessagesFilter$inputMessagesFilterPhotoVideo *object = [[TLMessagesFilter$inputMessagesFilterPhotoVideo alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLMessagesFilter$inputMessagesFilterDocument : TLMessagesFilter


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x9eddf188;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x2703fa7c;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLMessagesFilter$inputMessagesFilterDocument *object = [[TLMessagesFilter$inputMessagesFilterDocument alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLMessagesFilter$inputMessagesFilterAudio : TLMessagesFilter


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xcfc87522;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xd0436d20;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLMessagesFilter$inputMessagesFilterAudio *object = [[TLMessagesFilter$inputMessagesFilterAudio alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLMessagesFilter$inputMessagesFilterPhotoVideoDocuments : TLMessagesFilter


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xd95e73bb;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x8134f213;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLMessagesFilter$inputMessagesFilterPhotoVideoDocuments *object = [[TLMessagesFilter$inputMessagesFilterPhotoVideoDocuments alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLMessagesFilter$inputMessagesFilterUrl : TLMessagesFilter


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x7ef0dd87;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xf7d4c7b2;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLMessagesFilter$inputMessagesFilterUrl *object = [[TLMessagesFilter$inputMessagesFilterUrl alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

