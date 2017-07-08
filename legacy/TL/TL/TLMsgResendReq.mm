#import "TLMsgResendReq.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLMsgResendReq


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

@implementation TLMsgResendReq$msg_resend_req : TLMsgResendReq


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x7d861a08;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xe14fdee1;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMsgResendReq$msg_resend_req *object = [[TLMsgResendReq$msg_resend_req alloc] init];
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

