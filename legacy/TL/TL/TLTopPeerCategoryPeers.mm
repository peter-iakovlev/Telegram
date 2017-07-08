#import "TLTopPeerCategoryPeers.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLTopPeerCategory.h"

@implementation TLTopPeerCategoryPeers


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

@implementation TLTopPeerCategoryPeers$topPeerCategoryPeers : TLTopPeerCategoryPeers


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xfb834291;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xd125dd73;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLTopPeerCategoryPeers$topPeerCategoryPeers *object = [[TLTopPeerCategoryPeers$topPeerCategoryPeers alloc] init];
    object.category = metaObject->getObject((int32_t)0xa9546794);
    object.count = metaObject->getInt32((int32_t)0x5fa6aa74);
    object.peers = metaObject->getArray((int32_t)0x7cd8de36);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.category;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa9546794, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.count;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5fa6aa74, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.peers;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7cd8de36, value));
    }
}


@end

