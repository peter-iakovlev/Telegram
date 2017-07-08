#import "TLaccount_Password.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLaccount_Password


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

@implementation TLaccount_Password$account_noPassword : TLaccount_Password


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x96dabc18;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xaa4f01c3;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLaccount_Password$account_noPassword *object = [[TLaccount_Password$account_noPassword alloc] init];
    object.n_new_salt = metaObject->getBytes((int32_t)0x6b0fed36);
    object.email_unconfirmed_pattern = metaObject->getString((int32_t)0x286c37b0);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.n_new_salt;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x6b0fed36, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.email_unconfirmed_pattern;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x286c37b0, value));
    }
}


@end

@implementation TLaccount_Password$account_password : TLaccount_Password


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x7c18141c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xff523bc6;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLaccount_Password$account_password *object = [[TLaccount_Password$account_password alloc] init];
    object.current_salt = metaObject->getBytes((int32_t)0x80e59b22);
    object.n_new_salt = metaObject->getBytes((int32_t)0x6b0fed36);
    object.hint = metaObject->getString((int32_t)0xb8a444ca);
    object.has_recovery = metaObject->getBool((int32_t)0xc1620e28);
    object.email_unconfirmed_pattern = metaObject->getString((int32_t)0x286c37b0);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.current_salt;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x80e59b22, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.n_new_salt;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x6b0fed36, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.hint;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb8a444ca, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.has_recovery;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc1620e28, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.email_unconfirmed_pattern;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x286c37b0, value));
    }
}


@end

