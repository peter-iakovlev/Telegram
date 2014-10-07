#import "TLSendMessageAction.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLSendMessageAction


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

@implementation TLSendMessageAction$sendMessageTypingAction : TLSendMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x16bf744e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa23f8326;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLSendMessageAction$sendMessageTypingAction *object = [[TLSendMessageAction$sendMessageTypingAction alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLSendMessageAction$sendMessageCancelAction : TLSendMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xfd5ec8f5;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xff2c7ded;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLSendMessageAction$sendMessageCancelAction *object = [[TLSendMessageAction$sendMessageCancelAction alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLSendMessageAction$sendMessageRecordVideoAction : TLSendMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa187d66f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb0361e8e;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLSendMessageAction$sendMessageRecordVideoAction *object = [[TLSendMessageAction$sendMessageRecordVideoAction alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLSendMessageAction$sendMessageUploadVideoAction : TLSendMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x92042ff7;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x7e543f1e;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLSendMessageAction$sendMessageUploadVideoAction *object = [[TLSendMessageAction$sendMessageUploadVideoAction alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLSendMessageAction$sendMessageRecordAudioAction : TLSendMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xd52f73f7;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x79437952;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLSendMessageAction$sendMessageRecordAudioAction *object = [[TLSendMessageAction$sendMessageRecordAudioAction alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLSendMessageAction$sendMessageUploadAudioAction : TLSendMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xe6ac8a6f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x18b3b5e7;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLSendMessageAction$sendMessageUploadAudioAction *object = [[TLSendMessageAction$sendMessageUploadAudioAction alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLSendMessageAction$sendMessageUploadPhotoAction : TLSendMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x990a3c1a;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1ccc146b;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLSendMessageAction$sendMessageUploadPhotoAction *object = [[TLSendMessageAction$sendMessageUploadPhotoAction alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLSendMessageAction$sendMessageUploadDocumentAction : TLSendMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x8faee98e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xc9b9e79c;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLSendMessageAction$sendMessageUploadDocumentAction *object = [[TLSendMessageAction$sendMessageUploadDocumentAction alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLSendMessageAction$sendMessageGeoLocationAction : TLSendMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x176f8ba1;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x7d9bdd68;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLSendMessageAction$sendMessageGeoLocationAction *object = [[TLSendMessageAction$sendMessageGeoLocationAction alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLSendMessageAction$sendMessageChooseContactAction : TLSendMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x628cbc6f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xe14f76c0;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLSendMessageAction$sendMessageChooseContactAction *object = [[TLSendMessageAction$sendMessageChooseContactAction alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

