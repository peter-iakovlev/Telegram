#import "TLmessages_StickerSetInstallResult.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLmessages_StickerSetInstallResult


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

@implementation TLmessages_StickerSetInstallResult$messages_stickerSetInstallResultSuccess : TLmessages_StickerSetInstallResult


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x38641628;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x73b60230;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLmessages_StickerSetInstallResult$messages_stickerSetInstallResultSuccess *object = [[TLmessages_StickerSetInstallResult$messages_stickerSetInstallResultSuccess alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLmessages_StickerSetInstallResult$messages_stickerSetInstallResultArchive : TLmessages_StickerSetInstallResult


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x35e410a8;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x2dd4853e;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLmessages_StickerSetInstallResult$messages_stickerSetInstallResultArchive *object = [[TLmessages_StickerSetInstallResult$messages_stickerSetInstallResultArchive alloc] init];
    object.sets = metaObject->getArray((int32_t)0xc535ffc6);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.sets;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc535ffc6, value));
    }
}


@end

