#import "TLMsgsStateReq.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLMsgsStateReq


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

@implementation TLMsgsStateReq$msgs_state_req : TLMsgsStateReq


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xda69fb52;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xe51d7069;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMsgsStateReq$msgs_state_req *object = [[TLMsgsStateReq$msgs_state_req alloc] init];
    object.msg_ids = metaObject->getArray((int32_t)0x56f5f04c);
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
}


@end

