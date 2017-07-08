#import "TLcontacts_TopPeers.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLcontacts_TopPeers


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

@implementation TLcontacts_TopPeers$contacts_topPeersNotModified : TLcontacts_TopPeers


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xde266ef5;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x117aade4;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLcontacts_TopPeers$contacts_topPeersNotModified *object = [[TLcontacts_TopPeers$contacts_topPeersNotModified alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLcontacts_TopPeers$contacts_topPeers : TLcontacts_TopPeers


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x70b772a8;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x53b8afb8;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLcontacts_TopPeers$contacts_topPeers *object = [[TLcontacts_TopPeers$contacts_topPeers alloc] init];
    object.categories = metaObject->getArray((int32_t)0xbf9f79e5);
    object.chats = metaObject->getArray((int32_t)0x4240ad02);
    object.users = metaObject->getArray((int32_t)0x933e5ff3);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.categories;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xbf9f79e5, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.chats;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4240ad02, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.users;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x933e5ff3, value));
    }
}


@end

