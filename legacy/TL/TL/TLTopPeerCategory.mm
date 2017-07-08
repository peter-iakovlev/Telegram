#import "TLTopPeerCategory.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLTopPeerCategory


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

@implementation TLTopPeerCategory$topPeerCategoryBotsPM : TLTopPeerCategory


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xab661b5b;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x22cb4913;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLTopPeerCategory$topPeerCategoryBotsPM *object = [[TLTopPeerCategory$topPeerCategoryBotsPM alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLTopPeerCategory$topPeerCategoryBotsInline : TLTopPeerCategory


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x148677e2;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xc769f11d;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLTopPeerCategory$topPeerCategoryBotsInline *object = [[TLTopPeerCategory$topPeerCategoryBotsInline alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLTopPeerCategory$topPeerCategoryCorrespondents : TLTopPeerCategory


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x637b7ed;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x504523b9;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLTopPeerCategory$topPeerCategoryCorrespondents *object = [[TLTopPeerCategory$topPeerCategoryCorrespondents alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLTopPeerCategory$topPeerCategoryGroups : TLTopPeerCategory


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xbd17a14a;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xd4870810;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLTopPeerCategory$topPeerCategoryGroups *object = [[TLTopPeerCategory$topPeerCategoryGroups alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLTopPeerCategory$topPeerCategoryChannels : TLTopPeerCategory


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x161d9628;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x861caef;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLTopPeerCategory$topPeerCategoryChannels *object = [[TLTopPeerCategory$topPeerCategoryChannels alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

