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

@implementation TLMessagesFilter$inputMessagesFilterEmpty : TLMessagesFilter


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x57e2f66c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb251cae0;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
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

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
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

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
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

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
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

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLMessagesFilter$inputMessagesFilterDocument *object = [[TLMessagesFilter$inputMessagesFilterDocument alloc] init];
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

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
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

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLMessagesFilter$inputMessagesFilterUrl *object = [[TLMessagesFilter$inputMessagesFilterUrl alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLMessagesFilter$inputMessagesFilterVoice : TLMessagesFilter


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x50f5c392;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xcb0789b9;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLMessagesFilter$inputMessagesFilterVoice *object = [[TLMessagesFilter$inputMessagesFilterVoice alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLMessagesFilter$inputMessagesFilterMusic : TLMessagesFilter


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x3751b49e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x951de5b3;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLMessagesFilter$inputMessagesFilterMusic *object = [[TLMessagesFilter$inputMessagesFilterMusic alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLMessagesFilter$inputMessagesFilterChatPhotos : TLMessagesFilter


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x3a20ecb8;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x9c280bf0;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLMessagesFilter$inputMessagesFilterChatPhotos *object = [[TLMessagesFilter$inputMessagesFilterChatPhotos alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLMessagesFilter$inputMessagesFilterPhoneCalls : TLMessagesFilter


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x80c99768;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xdaf53069;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessagesFilter$inputMessagesFilterPhoneCalls *object = [[TLMessagesFilter$inputMessagesFilterPhoneCalls alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.flags;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x81915c23, value));
    }
}


@end

@implementation TLMessagesFilter$inputMessagesFilterRoundVideo : TLMessagesFilter


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xb549da53;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x58fc0a00;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLMessagesFilter$inputMessagesFilterRoundVideo *object = [[TLMessagesFilter$inputMessagesFilterRoundVideo alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLMessagesFilter$inputMessagesFilterRoundVoice : TLMessagesFilter


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x7a7c17a4;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x37e60c8b;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLMessagesFilter$inputMessagesFilterRoundVoice *object = [[TLMessagesFilter$inputMessagesFilterRoundVoice alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

