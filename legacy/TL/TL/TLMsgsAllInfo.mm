#import "TLMsgsAllInfo.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLMsgsAllInfo


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

@implementation TLMsgsAllInfo$msgs_all_info : TLMsgsAllInfo


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x8cc0d131;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x6981e335;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMsgsAllInfo$msgs_all_info *object = [[TLMsgsAllInfo$msgs_all_info alloc] init];
    object.msg_ids = metaObject->getArray((int32_t)0x56f5f04c);
    object.info = metaObject->getString((int32_t)0x3928e0e2);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.msg_ids;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x56f5f04c, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.info;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x3928e0e2, value));
    }
}


@end

