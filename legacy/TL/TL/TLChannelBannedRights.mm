#import "TLChannelBannedRights.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLChannelBannedRights


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

@implementation TLChannelBannedRights$channelBannedRights : TLChannelBannedRights


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x58cf4249;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x72175418;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLChannelBannedRights$channelBannedRights *object = [[TLChannelBannedRights$channelBannedRights alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.until_date = metaObject->getInt32((int32_t)0xbf578ee4);
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
        value.primitive.int32Value = self.until_date;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xbf578ee4, value));
    }
}


@end

