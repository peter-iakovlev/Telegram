#import "TLWebPage.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLWebPage


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

@implementation TLWebPage$webPageEmpty : TLWebPage


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xeb1477e8;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x9d3e7f82;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLWebPage$webPageEmpty *object = [[TLWebPage$webPageEmpty alloc] init];
    object.n_id = metaObject->getInt64((int32_t)0x7a5601fb);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7a5601fb, value));
    }
}


@end

@implementation TLWebPage$webPagePending : TLWebPage


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xc586da1c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xf3e5a76c;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLWebPage$webPagePending *object = [[TLWebPage$webPagePending alloc] init];
    object.n_id = metaObject->getInt64((int32_t)0x7a5601fb);
    object.date = metaObject->getInt32((int32_t)0xb76958ba);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7a5601fb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.date;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb76958ba, value));
    }
}


@end

@implementation TLWebPage$webPage : TLWebPage


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xcde7d21;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x5607474b;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLWebPage$webPage *object = [[TLWebPage$webPage alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLWebPage$webPageNotModified : TLWebPage


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x85849473;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1a1d275f;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLWebPage$webPageNotModified *object = [[TLWebPage$webPageNotModified alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

