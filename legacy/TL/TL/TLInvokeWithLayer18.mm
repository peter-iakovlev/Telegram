#import "TLInvokeWithLayer18.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLInvokeWithLayer18


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

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TGLog(@"TLbuildFromMetaObject is not implemented for base type");
    return nil;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
    TGLog(@"TLfillFieldsWithValues is not implemented for base type");
}


@end

@implementation TLInvokeWithLayer18$invokeWithLayer18 : TLInvokeWithLayer18


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x1c900537;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x4e9cb73e;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLInvokeWithLayer18$invokeWithLayer18 *object = [[TLInvokeWithLayer18$invokeWithLayer18 alloc] init];
    object.query = metaObject->getObject((int32_t)0x5de9dcb1);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.query;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5de9dcb1, value));
    }
}


@end

