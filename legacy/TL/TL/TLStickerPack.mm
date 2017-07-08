#import "TLStickerPack.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLStickerPack


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

@implementation TLStickerPack$stickerPack : TLStickerPack


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x12b299d4;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x6cdf9cef;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLStickerPack$stickerPack *object = [[TLStickerPack$stickerPack alloc] init];
    object.emoticon = metaObject->getString((int32_t)0x9458ad3a);
    object.documents = metaObject->getArray((int32_t)0xbf7d927d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.emoticon;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9458ad3a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.documents;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xbf7d927d, value));
    }
}


@end

