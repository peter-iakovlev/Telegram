#import "TLRPChelp_getInviteText.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLhelp_InviteText.h"

@implementation TLRPChelp_getInviteText


- (Class)responseClass
{
    return [TLhelp_InviteText class];
}

- (int)impliedResponseSignature
{
    return (int)0x18cb9f78;
}

- (int)layerVersion
{
    return 8;
}

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

@implementation TLRPChelp_getInviteText$help_getInviteText : TLRPChelp_getInviteText


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa4a95186;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x35425749;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPChelp_getInviteText$help_getInviteText *object = [[TLRPChelp_getInviteText$help_getInviteText alloc] init];
    object.lang_code = metaObject->getString((int32_t)0x2ccfcaf3);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.lang_code;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x2ccfcaf3, value));
    }
}


@end

