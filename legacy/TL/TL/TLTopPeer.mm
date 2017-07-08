#import "TLTopPeer.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLPeer.h"

@implementation TLTopPeer


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

@implementation TLTopPeer$topPeer : TLTopPeer


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xedcdc05b;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xf8cee3e4;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLTopPeer$topPeer *object = [[TLTopPeer$topPeer alloc] init];
    object.peer = metaObject->getObject((int32_t)0x9344c37d);
    object.rating = metaObject->getDouble((int32_t)0x390d4933);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.peer;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9344c37d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveDouble;
        value.primitive.doubleValue = self.rating;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x390d4933, value));
    }
}


@end

