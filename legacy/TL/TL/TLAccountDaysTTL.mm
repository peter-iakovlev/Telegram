#import "TLAccountDaysTTL.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLAccountDaysTTL


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

@implementation TLAccountDaysTTL$accountDaysTTL : TLAccountDaysTTL


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xb8d0afdf;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x2aca3801;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLAccountDaysTTL$accountDaysTTL *object = [[TLAccountDaysTTL$accountDaysTTL alloc] init];
    object.days = metaObject->getInt32((int32_t)0xce6cb313);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.days;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xce6cb313, value));
    }
}


@end

