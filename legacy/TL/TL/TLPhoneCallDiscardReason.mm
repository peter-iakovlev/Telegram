#import "TLPhoneCallDiscardReason.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLPhoneCallDiscardReason


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

@implementation TLPhoneCallDiscardReason$phoneCallDiscardReasonMissed : TLPhoneCallDiscardReason


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x85e42301;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x45f41192;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLPhoneCallDiscardReason$phoneCallDiscardReasonMissed *object = [[TLPhoneCallDiscardReason$phoneCallDiscardReasonMissed alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLPhoneCallDiscardReason$phoneCallDiscardReasonDisconnect : TLPhoneCallDiscardReason


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xe095c1a0;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x957ab535;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLPhoneCallDiscardReason$phoneCallDiscardReasonDisconnect *object = [[TLPhoneCallDiscardReason$phoneCallDiscardReasonDisconnect alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLPhoneCallDiscardReason$phoneCallDiscardReasonHangup : TLPhoneCallDiscardReason


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x57adc690;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x36169835;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLPhoneCallDiscardReason$phoneCallDiscardReasonHangup *object = [[TLPhoneCallDiscardReason$phoneCallDiscardReasonHangup alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLPhoneCallDiscardReason$phoneCallDiscardReasonBusy : TLPhoneCallDiscardReason


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xfaf7e8c9;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xcce41369;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLPhoneCallDiscardReason$phoneCallDiscardReasonBusy *object = [[TLPhoneCallDiscardReason$phoneCallDiscardReasonBusy alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

