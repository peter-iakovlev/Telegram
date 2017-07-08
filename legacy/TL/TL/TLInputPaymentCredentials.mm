#import "TLInputPaymentCredentials.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLDataJSON.h"

@implementation TLInputPaymentCredentials


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

@implementation TLInputPaymentCredentials$inputPaymentCredentialsSaved : TLInputPaymentCredentials


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xc10eb2cf;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb4b18174;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLInputPaymentCredentials$inputPaymentCredentialsSaved *object = [[TLInputPaymentCredentials$inputPaymentCredentialsSaved alloc] init];
    object.n_id = metaObject->getString((int32_t)0x7a5601fb);
    object.tmp_password = metaObject->getBytes((int32_t)0xfdc77144);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7a5601fb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.tmp_password;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xfdc77144, value));
    }
}


@end

@implementation TLInputPaymentCredentials$inputPaymentCredentials : TLInputPaymentCredentials


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x3417d728;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xe941b9bc;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLInputPaymentCredentials$inputPaymentCredentials *object = [[TLInputPaymentCredentials$inputPaymentCredentials alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.data = metaObject->getObject((int32_t)0xa361765d);
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
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.data;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa361765d, value));
    }
}


@end

