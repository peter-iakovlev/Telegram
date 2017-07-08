#import "TLInlineBotSwitchPM.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLInlineBotSwitchPM


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

@implementation TLInlineBotSwitchPM$inlineBotSwitchPM : TLInlineBotSwitchPM


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x3c20629f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x17d7b5b9;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLInlineBotSwitchPM$inlineBotSwitchPM *object = [[TLInlineBotSwitchPM$inlineBotSwitchPM alloc] init];
    object.text = metaObject->getString((int32_t)0x94f1580d);
    object.start_param = metaObject->getString((int32_t)0x90d398cb);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.text;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x94f1580d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.start_param;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x90d398cb, value));
    }
}


@end

