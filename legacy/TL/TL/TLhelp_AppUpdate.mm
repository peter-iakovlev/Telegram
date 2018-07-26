#import "TLhelp_AppUpdate.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLhelp_AppUpdate


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

@implementation TLhelp_AppUpdate$help_appUpdateMeta : TLhelp_AppUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x8987f311;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x11b83f18;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLhelp_AppUpdate$help_appUpdateMeta *object = [[TLhelp_AppUpdate$help_appUpdateMeta alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
}


@end

@implementation TLhelp_AppUpdate$help_noAppUpdate : TLhelp_AppUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xc45a6536;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xf22462b1;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLhelp_AppUpdate$help_noAppUpdate *object = [[TLhelp_AppUpdate$help_noAppUpdate alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

