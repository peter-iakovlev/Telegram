#import "TLNearestDc.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLNearestDc


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

@implementation TLNearestDc$nearestDc : TLNearestDc


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x8e1a1775;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xe44a03ed;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLNearestDc$nearestDc *object = [[TLNearestDc$nearestDc alloc] init];
    object.country = metaObject->getString((int32_t)0xbf857ba3);
    object.this_dc = metaObject->getInt32((int32_t)0x1b29ec36);
    object.nearest_dc = metaObject->getInt32((int32_t)0x20f5dbe);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.country;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xbf857ba3, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.this_dc;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1b29ec36, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.nearest_dc;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x20f5dbe, value));
    }
}


@end

