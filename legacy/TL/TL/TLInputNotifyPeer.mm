#import "TLInputNotifyPeer.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputPeer.h"

@implementation TLInputNotifyPeer


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

@implementation TLInputNotifyPeer$inputNotifyPeer : TLInputNotifyPeer


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xb8bc5b0c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb7c88cfb;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLInputNotifyPeer$inputNotifyPeer *object = [[TLInputNotifyPeer$inputNotifyPeer alloc] init];
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

@implementation TLInputNotifyPeer$inputNotifyUsers : TLInputNotifyPeer


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x193b4417;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x8682a419;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLInputNotifyPeer$inputNotifyUsers *object = [[TLInputNotifyPeer$inputNotifyUsers alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLInputNotifyPeer$inputNotifyChats : TLInputNotifyPeer


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x4a95e84e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xdf8b004e;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLInputNotifyPeer$inputNotifyChats *object = [[TLInputNotifyPeer$inputNotifyChats alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLInputNotifyPeer$inputNotifyAll : TLInputNotifyPeer


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa429b886;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x637348;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLInputNotifyPeer$inputNotifyAll *object = [[TLInputNotifyPeer$inputNotifyAll alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

