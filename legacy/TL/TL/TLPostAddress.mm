#import "TLPostAddress.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLPostAddress


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

@implementation TLPostAddress$postAddress : TLPostAddress


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x1e8caaeb;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x717ef6b0;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLPostAddress$postAddress *object = [[TLPostAddress$postAddress alloc] init];
    object.street_line1 = metaObject->getString((int32_t)0xa7374fff);
    object.street_line2 = metaObject->getString((int32_t)0xf1878ba4);
    object.city = metaObject->getString((int32_t)0x11a65ceb);
    object.state = metaObject->getString((int32_t)0x449b9b4e);
    object.country_iso2 = metaObject->getString((int32_t)0x81e9949e);
    object.post_code = metaObject->getString((int32_t)0x75b7bb12);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.street_line1;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa7374fff, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.street_line2;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xf1878ba4, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.city;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x11a65ceb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.state;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x449b9b4e, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.country_iso2;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x81e9949e, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.post_code;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x75b7bb12, value));
    }
}


@end

