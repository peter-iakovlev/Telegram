#import "TLauth_Authorization.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLUser.h"

@implementation TLauth_Authorization


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

@implementation TLauth_Authorization$auth_authorizationMeta : TLauth_Authorization


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xb1937d19;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xbd12e422;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLauth_Authorization$auth_authorizationMeta *object = [[TLauth_Authorization$auth_authorizationMeta alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.tmp_sessions = metaObject->getInt32((int32_t)0xe9a8fb12);
    object.user = metaObject->getObject((int32_t)0x2275eda7);
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
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.tmp_sessions;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe9a8fb12, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.user;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x2275eda7, value));
    }
}


@end

