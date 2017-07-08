#import "TLChannelAdminLogEventsFilter.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLChannelAdminLogEventsFilter


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

@implementation TLChannelAdminLogEventsFilter$channelAdminLogEventsFilter : TLChannelAdminLogEventsFilter


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xea107ae4;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xbf0b5d6b;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLChannelAdminLogEventsFilter$channelAdminLogEventsFilter *object = [[TLChannelAdminLogEventsFilter$channelAdminLogEventsFilter alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
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
}


@end

