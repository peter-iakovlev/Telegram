#import "TLRPCmessages_getWebPagePreview.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLMessageMedia.h"

@implementation TLRPCmessages_getWebPagePreview


- (Class)responseClass
{
    return [TLMessageMedia class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 26;
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

@implementation TLRPCmessages_getWebPagePreview$messages_getWebPagePreview : TLRPCmessages_getWebPagePreview


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x25223e24;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xf3394118;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_getWebPagePreview$messages_getWebPagePreview *object = [[TLRPCmessages_getWebPagePreview$messages_getWebPagePreview alloc] init];
    object.message = metaObject->getString((int32_t)0xc43b7853);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.message;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc43b7853, value));
    }
}


@end

