#import "TLPageBlock.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLRichText.h"
#import "TLPageBlock.h"
#import "TLChat.h"

@implementation TLPageBlock


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

@implementation TLPageBlock$pageBlockTitle : TLPageBlock


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x70abc3fd;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1c50d52c;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLPageBlock$pageBlockTitle *object = [[TLPageBlock$pageBlockTitle alloc] init];
    object.text = metaObject->getObject((int32_t)0x94f1580d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.text;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x94f1580d, value));
    }
}


@end

@implementation TLPageBlock$pageBlockSubtitle : TLPageBlock


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x8ffa9a1f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xc128b427;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLPageBlock$pageBlockSubtitle *object = [[TLPageBlock$pageBlockSubtitle alloc] init];
    object.text = metaObject->getObject((int32_t)0x94f1580d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.text;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x94f1580d, value));
    }
}


@end

@implementation TLPageBlock$pageBlockHeader : TLPageBlock


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xbfd064ec;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x2a05cd39;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLPageBlock$pageBlockHeader *object = [[TLPageBlock$pageBlockHeader alloc] init];
    object.text = metaObject->getObject((int32_t)0x94f1580d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.text;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x94f1580d, value));
    }
}


@end

@implementation TLPageBlock$pageBlockSubheader : TLPageBlock


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xf12bb6e1;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x5724a932;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLPageBlock$pageBlockSubheader *object = [[TLPageBlock$pageBlockSubheader alloc] init];
    object.text = metaObject->getObject((int32_t)0x94f1580d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.text;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x94f1580d, value));
    }
}


@end

@implementation TLPageBlock$pageBlockParagraph : TLPageBlock


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x467a0766;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xf763f6;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLPageBlock$pageBlockParagraph *object = [[TLPageBlock$pageBlockParagraph alloc] init];
    object.text = metaObject->getObject((int32_t)0x94f1580d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.text;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x94f1580d, value));
    }
}


@end

@implementation TLPageBlock$pageBlockPreformatted : TLPageBlock


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xc070d93e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb42c6a2e;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLPageBlock$pageBlockPreformatted *object = [[TLPageBlock$pageBlockPreformatted alloc] init];
    object.text = metaObject->getObject((int32_t)0x94f1580d);
    object.language = metaObject->getString((int32_t)0x672497b4);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.text;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x94f1580d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.language;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x672497b4, value));
    }
}


@end

@implementation TLPageBlock$pageBlockFooter : TLPageBlock


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x48870999;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x5cd504e7;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLPageBlock$pageBlockFooter *object = [[TLPageBlock$pageBlockFooter alloc] init];
    object.text = metaObject->getObject((int32_t)0x94f1580d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.text;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x94f1580d, value));
    }
}


@end

@implementation TLPageBlock$pageBlockDivider : TLPageBlock


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xdb20b188;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x71a070b;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLPageBlock$pageBlockDivider *object = [[TLPageBlock$pageBlockDivider alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLPageBlock$pageBlockList : TLPageBlock


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x3a58c7f4;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xf4ace92d;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLPageBlock$pageBlockList *object = [[TLPageBlock$pageBlockList alloc] init];
    object.ordered = metaObject->getBool((int32_t)0x6fd9c719);
    object.items = metaObject->getArray((int32_t)0x18406025);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.ordered;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x6fd9c719, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.items;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x18406025, value));
    }
}


@end

@implementation TLPageBlock$pageBlockBlockquote : TLPageBlock


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x263d7c26;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x8ebaca59;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLPageBlock$pageBlockBlockquote *object = [[TLPageBlock$pageBlockBlockquote alloc] init];
    object.text = metaObject->getObject((int32_t)0x94f1580d);
    object.caption = metaObject->getObject((int32_t)0x9bcfcf5a);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.text;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x94f1580d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.caption;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9bcfcf5a, value));
    }
}


@end

@implementation TLPageBlock$pageBlockPullquote : TLPageBlock


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x4f4456d3;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x9d8ee9fd;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLPageBlock$pageBlockPullquote *object = [[TLPageBlock$pageBlockPullquote alloc] init];
    object.text = metaObject->getObject((int32_t)0x94f1580d);
    object.caption = metaObject->getObject((int32_t)0x9bcfcf5a);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.text;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x94f1580d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.caption;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9bcfcf5a, value));
    }
}


@end

@implementation TLPageBlock$pageBlockPhoto : TLPageBlock


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xe9c69982;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x4c5df270;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLPageBlock$pageBlockPhoto *object = [[TLPageBlock$pageBlockPhoto alloc] init];
    object.photo_id = metaObject->getInt64((int32_t)0xa4b26129);
    object.caption = metaObject->getObject((int32_t)0x9bcfcf5a);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.photo_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa4b26129, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.caption;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9bcfcf5a, value));
    }
}


@end

@implementation TLPageBlock$pageBlockVideo : TLPageBlock


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xd9d71866;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x9a2d2fce;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLPageBlock$pageBlockVideo *object = [[TLPageBlock$pageBlockVideo alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.video_id = metaObject->getInt64((int32_t)0xa09c03ef);
    object.caption = metaObject->getObject((int32_t)0x9bcfcf5a);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.flags;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x81915c23, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.video_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa09c03ef, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.caption;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9bcfcf5a, value));
    }
}


@end

@implementation TLPageBlock$pageBlockCover : TLPageBlock


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x39f23300;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xfcc73ba5;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLPageBlock$pageBlockCover *object = [[TLPageBlock$pageBlockCover alloc] init];
    object.cover = metaObject->getObject((int32_t)0x7c051309);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.cover;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7c051309, value));
    }
}


@end

@implementation TLPageBlock$pageBlockEmbedPost : TLPageBlock


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x292c7be9;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x10b2cd34;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLPageBlock$pageBlockEmbedPost *object = [[TLPageBlock$pageBlockEmbedPost alloc] init];
    object.url = metaObject->getString((int32_t)0xeaf7861e);
    object.webpage_id = metaObject->getInt64((int32_t)0xcf81f3f);
    object.author_photo_id = metaObject->getInt64((int32_t)0xa932b003);
    object.author = metaObject->getString((int32_t)0x476841e7);
    object.date = metaObject->getInt32((int32_t)0xb76958ba);
    object.blocks = metaObject->getArray((int32_t)0x277ee766);
    object.caption = metaObject->getObject((int32_t)0x9bcfcf5a);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.url;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xeaf7861e, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.webpage_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xcf81f3f, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.author_photo_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa932b003, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.author;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x476841e7, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.date;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb76958ba, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.blocks;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x277ee766, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.caption;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9bcfcf5a, value));
    }
}


@end

@implementation TLPageBlock$pageBlockCollage : TLPageBlock


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x8b31c4f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x4bc2a414;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLPageBlock$pageBlockCollage *object = [[TLPageBlock$pageBlockCollage alloc] init];
    object.items = metaObject->getArray((int32_t)0x18406025);
    object.caption = metaObject->getObject((int32_t)0x9bcfcf5a);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.items;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x18406025, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.caption;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9bcfcf5a, value));
    }
}


@end

@implementation TLPageBlock$pageBlockSlideshow : TLPageBlock


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x130c8963;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1974634a;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLPageBlock$pageBlockSlideshow *object = [[TLPageBlock$pageBlockSlideshow alloc] init];
    object.items = metaObject->getArray((int32_t)0x18406025);
    object.caption = metaObject->getObject((int32_t)0x9bcfcf5a);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.items;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x18406025, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.caption;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9bcfcf5a, value));
    }
}


@end

@implementation TLPageBlock$pageBlockUnsupported : TLPageBlock


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x13567e8a;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xc81baebc;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLPageBlock$pageBlockUnsupported *object = [[TLPageBlock$pageBlockUnsupported alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLPageBlock$pageBlockAnchor : TLPageBlock


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xce0d37b0;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xebe5709d;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLPageBlock$pageBlockAnchor *object = [[TLPageBlock$pageBlockAnchor alloc] init];
    object.name = metaObject->getString((int32_t)0x798b364a);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.name;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x798b364a, value));
    }
}


@end

@implementation TLPageBlock$pageBlockEmbedMeta : TLPageBlock


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xe78f3d36;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x9211319e;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLPageBlock$pageBlockEmbedMeta *object = [[TLPageBlock$pageBlockEmbedMeta alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.url = metaObject->getString((int32_t)0xeaf7861e);
    object.html = metaObject->getString((int32_t)0x914719f6);
    object.poster_photo_id = metaObject->getInt64((int32_t)0x40c1ba91);
    object.w = metaObject->getInt32((int32_t)0x98407fc3);
    object.h = metaObject->getInt32((int32_t)0x27243f49);
    object.caption = metaObject->getObject((int32_t)0x9bcfcf5a);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.flags;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x81915c23, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.url;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xeaf7861e, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.html;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x914719f6, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.poster_photo_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x40c1ba91, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.w;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x98407fc3, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.h;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x27243f49, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.caption;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9bcfcf5a, value));
    }
}


@end

@implementation TLPageBlock$pageBlockAuthorDate : TLPageBlock


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xbaafe5e0;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x33f71e25;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLPageBlock$pageBlockAuthorDate *object = [[TLPageBlock$pageBlockAuthorDate alloc] init];
    object.author = metaObject->getObject((int32_t)0x476841e7);
    object.published_date = metaObject->getInt32((int32_t)0x1e4acaf);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.author;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x476841e7, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.published_date;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1e4acaf, value));
    }
}


@end

@implementation TLPageBlock$pageBlockChannel : TLPageBlock


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xef1751b5;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xdc17e55d;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLPageBlock$pageBlockChannel *object = [[TLPageBlock$pageBlockChannel alloc] init];
    object.channel = metaObject->getObject((int32_t)0xe11f3d41);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.channel;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe11f3d41, value));
    }
}


@end

@implementation TLPageBlock$pageBlockAudio : TLPageBlock


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x31b81a7f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x6f27310a;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLPageBlock$pageBlockAudio *object = [[TLPageBlock$pageBlockAudio alloc] init];
    object.audio_id = metaObject->getInt64((int32_t)0xda4b2e15);
    object.caption = metaObject->getObject((int32_t)0x9bcfcf5a);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.audio_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xda4b2e15, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.caption;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9bcfcf5a, value));
    }
}


@end

