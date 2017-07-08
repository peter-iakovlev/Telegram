#import "TLProtoMessageCopy.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLProtoMessage.h"

@implementation TLProtoMessageCopy


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

@implementation TLProtoMessageCopy$msg_copy : TLProtoMessageCopy


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xe06046b2;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x27a996b5;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLProtoMessageCopy$msg_copy *object = [[TLProtoMessageCopy$msg_copy alloc] init];
    object.orig_message = metaObject->getObject((int32_t)0x62cb891c);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.orig_message;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x62cb891c, value));
    }
}


@end

