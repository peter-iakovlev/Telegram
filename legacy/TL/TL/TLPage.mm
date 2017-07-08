#import "TLPage.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLPage


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

@implementation TLPage$pagePart : TLPage


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x8e3f9ebe;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x8f4cfe36;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLPage$pagePart *object = [[TLPage$pagePart alloc] init];
    object.blocks = metaObject->getArray((int32_t)0x277ee766);
    object.photos = metaObject->getArray((int32_t)0x26b9c95f);
    object.documents = metaObject->getArray((int32_t)0xbf7d927d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.blocks;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x277ee766, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.photos;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x26b9c95f, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.documents;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xbf7d927d, value));
    }
}


@end

@implementation TLPage$pageFull : TLPage


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x556ec7aa;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xcd6b246c;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLPage$pageFull *object = [[TLPage$pageFull alloc] init];
    object.blocks = metaObject->getArray((int32_t)0x277ee766);
    object.photos = metaObject->getArray((int32_t)0x26b9c95f);
    object.documents = metaObject->getArray((int32_t)0xbf7d927d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.blocks;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x277ee766, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.photos;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x26b9c95f, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.documents;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xbf7d927d, value));
    }
}


@end

