#import "TLUserStatus.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLUserStatus


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

@implementation TLUserStatus$userStatusEmpty : TLUserStatus


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x9d05049;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa7e91cbf;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLUserStatus$userStatusEmpty *object = [[TLUserStatus$userStatusEmpty alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLUserStatus$userStatusOnline : TLUserStatus


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xedb93949;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa545e562;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLUserStatus$userStatusOnline *object = [[TLUserStatus$userStatusOnline alloc] init];
    object.expires = metaObject->getInt32((int32_t)0x4743fb6b);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.expires;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4743fb6b, value));
    }
}


@end

@implementation TLUserStatus$userStatusOffline : TLUserStatus


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x8c703f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xc74fd9f;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLUserStatus$userStatusOffline *object = [[TLUserStatus$userStatusOffline alloc] init];
    object.was_online = metaObject->getInt32((int32_t)0xb68b1788);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.was_online;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb68b1788, value));
    }
}


@end

@implementation TLUserStatus$userStatusRecently : TLUserStatus


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xe26f42f1;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x87ba0780;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLUserStatus$userStatusRecently *object = [[TLUserStatus$userStatusRecently alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLUserStatus$userStatusLastWeek : TLUserStatus


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x7bf09fc;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa4dc11f5;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLUserStatus$userStatusLastWeek *object = [[TLUserStatus$userStatusLastWeek alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLUserStatus$userStatusLastMonth : TLUserStatus


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x77ebc742;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xd9c9a73a;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLUserStatus$userStatusLastMonth *object = [[TLUserStatus$userStatusLastMonth alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

