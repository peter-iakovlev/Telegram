#import "TLHighScore.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLHighScore


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

@implementation TLHighScore$highScore : TLHighScore


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x58fffcd0;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x60c9a4c9;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLHighScore$highScore *object = [[TLHighScore$highScore alloc] init];
    object.pos = metaObject->getInt32((int32_t)0xc46b441c);
    object.user_id = metaObject->getInt32((int32_t)0xafdf4073);
    object.score = metaObject->getInt32((int32_t)0xe2546678);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.pos;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc46b441c, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xafdf4073, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.score;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe2546678, value));
    }
}


@end

