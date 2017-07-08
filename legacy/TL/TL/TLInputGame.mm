#import "TLInputGame.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputUser.h"

@implementation TLInputGame


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

@implementation TLInputGame$inputGameID : TLInputGame


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x32c3e77;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x36fc6ad3;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLInputGame$inputGameID *object = [[TLInputGame$inputGameID alloc] init];
    object.n_id = metaObject->getInt64((int32_t)0x7a5601fb);
    object.access_hash = metaObject->getInt64((int32_t)0x8f305224);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7a5601fb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.access_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x8f305224, value));
    }
}


@end

@implementation TLInputGame$inputGameShortName : TLInputGame


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xc331e80a;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa326b4d4;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLInputGame$inputGameShortName *object = [[TLInputGame$inputGameShortName alloc] init];
    object.bot_id = metaObject->getObject((int32_t)0x214f3dba);
    object.short_name = metaObject->getString((int32_t)0xfccec594);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.bot_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x214f3dba, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.short_name;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xfccec594, value));
    }
}


@end

