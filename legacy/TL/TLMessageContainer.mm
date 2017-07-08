#import "TLMessageContainer.h"

#import "NSInputStream+TL.h"
#import "NSOutputStream+TL.h"

#import "TLMetaClassStore.h"

#import "TLProtoMessage.h"

@implementation TLMessageContainer

@synthesize messages = _messages;

- (int32_t)TLconstructorSignature
{
    TGLog(@"TLconstructorSignature is not implemented for base type");
    return 0;
}

- (int32_t)TLconstructorName
{
    TGLog(@"TLconstructorName is not implemented for base type");
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

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(NSError *__autoreleasing *)error
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setValue:@"TLdeserialize is not implemented for base type" forKey:NSLocalizedDescriptionKey];
    if (error != NULL)
        *error = [[NSError alloc] initWithDomain:@"TL" code:-1 userInfo:userInfo];
    return nil;
}


- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"TLserialize is not implemented for base type");
}

@end

@implementation TLMessageContainer$msg_container : TLMessageContainer


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x73f1f8dc;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x3916ef8b;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageContainer$msg_container *object = [[TLMessageContainer$msg_container alloc] init];
    
    object.messages = metaObject->getArray(0x8c97b94f);
    
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.messages;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x8c97b94f, value));
    }
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)signature environment:(id<TLSerializationEnvironment>)environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)error
{
    if (signature != (int32_t)0x73f1f8dc)
    {
        if (error != NULL)
        {
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
            [userInfo setValue:[NSString stringWithFormat:@"Invalid signature %.8x (should be 0x73f1f8dc)", signature] forKey:NSLocalizedDescriptionKey];
            *error = [[NSError alloc] initWithDomain:@"TL" code:-1 userInfo:userInfo];
        }
        return nil;
    }

    TLMessageContainer$msg_container *object = [[TLMessageContainer$msg_container alloc] init];
    {
        int count1 = [is readInt32];
        NSMutableArray *array1 = [[NSMutableArray alloc] initWithCapacity:count1];
        for (int i1 = 0; i1 < count1; i1++)
        {
            id item1 = nil;
            {
                TLProtoMessage$protoMessage *message = [[TLProtoMessage$protoMessage alloc] init];
                {
                    message.msg_id = [is readInt64];
                }
                {
                    message.seqno = [is readInt32];
                }
                {
                    message.bytes = [is readInt32];
                }
                NSError *localError = nil;
                NSData *data = [is readData:message.bytes];
                NSInputStream *messageIs = [[NSInputStream alloc] initWithData:data];
                [messageIs open];
                {
                    int32_t sig1 = [messageIs readInt32];
                    message.body = TLMetaClassStore::constructObject(messageIs, sig1, environment, nil, &localError);
                }
                [messageIs close];
                
                item1 = message;
                
                if (localError != nil)
                    TGLog(@"Error parsing message in container: %@", localError);
            }
            if (item1 != nil && item1 != [NSNull null])
                [array1 addObject:item1];
            
        }
        object.messages = array1;
    }
    return object;
}

@end

