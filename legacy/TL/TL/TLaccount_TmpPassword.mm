#import "TLaccount_TmpPassword.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLaccount_TmpPassword


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

@implementation TLaccount_TmpPassword$account_tmpPassword : TLaccount_TmpPassword


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xdb64fd34;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xe1e01797;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLaccount_TmpPassword$account_tmpPassword *object = [[TLaccount_TmpPassword$account_tmpPassword alloc] init];
    object.tmp_password = metaObject->getBytes((int32_t)0xfdc77144);
    object.valid_until = metaObject->getInt32((int32_t)0x46f4d603);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.tmp_password;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xfdc77144, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.valid_until;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x46f4d603, value));
    }
}


@end

