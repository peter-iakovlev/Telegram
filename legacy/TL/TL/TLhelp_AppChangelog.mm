#import "TLhelp_AppChangelog.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLhelp_AppChangelog


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

@implementation TLhelp_AppChangelog$help_appChangelogEmpty : TLhelp_AppChangelog


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xaf7e0394;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x308647de;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLhelp_AppChangelog$help_appChangelogEmpty *object = [[TLhelp_AppChangelog$help_appChangelogEmpty alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLhelp_AppChangelog$help_appChangelog : TLhelp_AppChangelog


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x4668e6bd;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xf6885eca;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLhelp_AppChangelog$help_appChangelog *object = [[TLhelp_AppChangelog$help_appChangelog alloc] init];
    object.text = metaObject->getString((int32_t)0x94f1580d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.text;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x94f1580d, value));
    }
}


@end

