#import "TLhelp_Support.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLUser.h"

@implementation TLhelp_Support


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

@implementation TLhelp_Support$help_support : TLhelp_Support


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x17c6b5f6;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x3e56b684;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLhelp_Support$help_support *object = [[TLhelp_Support$help_support alloc] init];
    object.phone_number = metaObject->getString((int32_t)0xaecb6c79);
    object.user = metaObject->getObject((int32_t)0x2275eda7);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.phone_number;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xaecb6c79, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.user;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x2275eda7, value));
    }
}


@end

