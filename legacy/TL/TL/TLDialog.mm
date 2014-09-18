#import "TLDialog.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLPeer.h"
#import "TLPeerNotifySettings.h"

@implementation TLDialog


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

@implementation TLDialog$dialog : TLDialog


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xab3a99ac;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x2f235e8f;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLDialog$dialog *object = [[TLDialog$dialog alloc] init];
    object.peer = metaObject->getObject((int32_t)0x9344c37d);
    object.top_message = metaObject->getInt32((int32_t)0x8cecb775);
    object.unread_count = metaObject->getInt32((int32_t)0xa6b586be);
    object.notify_settings = metaObject->getObject((int32_t)0xfa59265);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.peer;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9344c37d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.top_message;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x8cecb775, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.unread_count;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa6b586be, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.notify_settings;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xfa59265, value));
    }
}


@end

