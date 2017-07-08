#import "TLDisabledFeature.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLDisabledFeature


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

@implementation TLDisabledFeature$disabledFeature : TLDisabledFeature


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xae636f24;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x35db1f63;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLDisabledFeature$disabledFeature *object = [[TLDisabledFeature$disabledFeature alloc] init];
    object.feature = metaObject->getString((int32_t)0x29359cac);
    object.n_description = metaObject->getString((int32_t)0x9e47ce86);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.feature;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x29359cac, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.n_description;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9e47ce86, value));
    }
}


@end

