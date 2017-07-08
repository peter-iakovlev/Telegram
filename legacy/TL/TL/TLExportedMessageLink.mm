#import "TLExportedMessageLink.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLExportedMessageLink


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

@implementation TLExportedMessageLink$exportedMessageLink : TLExportedMessageLink


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x1f486803;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xcc4d4449;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLExportedMessageLink$exportedMessageLink *object = [[TLExportedMessageLink$exportedMessageLink alloc] init];
    object.link = metaObject->getString((int32_t)0xc58224f9);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.link;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc58224f9, value));
    }
}


@end

