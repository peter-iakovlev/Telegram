#import "TLNotifyPeer.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLPeer.h"

@implementation TLNotifyPeer


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

@implementation TLNotifyPeer$notifyPeer : TLNotifyPeer


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x9fd40bd8;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x3164b8c;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLNotifyPeer$notifyPeer *object = [[TLNotifyPeer$notifyPeer alloc] init];
    object.peer = metaObject->getObject((int32_t)0x9344c37d);
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
}


@end

@implementation TLNotifyPeer$notifyUsers : TLNotifyPeer


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xb4c83b4c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xd6283d7f;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLNotifyPeer$notifyUsers *object = [[TLNotifyPeer$notifyUsers alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLNotifyPeer$notifyChats : TLNotifyPeer


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xc007cec3;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xfc446803;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLNotifyPeer$notifyChats *object = [[TLNotifyPeer$notifyChats alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLNotifyPeer$notifyAll : TLNotifyPeer


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x74d07c60;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x9794324d;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLNotifyPeer$notifyAll *object = [[TLNotifyPeer$notifyAll alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

