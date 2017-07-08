#import "TLCompressedObject.h"

@implementation TLCompressedObject

@synthesize compressedData = _compressedData;

- (int32_t)TLconstructorSignature
{
    return 0x3072cfa1;
}

- (int32_t)TLconstructorName
{
    return 0;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    return nil;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}

@end
