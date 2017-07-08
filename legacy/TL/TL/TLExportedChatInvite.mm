#import "TLExportedChatInvite.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLExportedChatInvite


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

@implementation TLExportedChatInvite$chatInviteEmpty : TLExportedChatInvite


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x69df3769;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x7d4b68cc;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLExportedChatInvite$chatInviteEmpty *object = [[TLExportedChatInvite$chatInviteEmpty alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLExportedChatInvite$chatInviteExported : TLExportedChatInvite


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xfc2e05bc;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x66a0cead;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLExportedChatInvite$chatInviteExported *object = [[TLExportedChatInvite$chatInviteExported alloc] init];
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

