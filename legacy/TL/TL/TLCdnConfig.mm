#import "TLCdnConfig.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLCdnConfig


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

@implementation TLCdnConfig$cdnConfig : TLCdnConfig


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x5725e40a;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xd033a8d7;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLCdnConfig$cdnConfig *object = [[TLCdnConfig$cdnConfig alloc] init];
    object.public_keys = metaObject->getArray((int32_t)0xae719ecd);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.public_keys;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xae719ecd, value));
    }
}


@end

