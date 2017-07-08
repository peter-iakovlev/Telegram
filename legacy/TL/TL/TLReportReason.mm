#import "TLReportReason.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLReportReason


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

@implementation TLReportReason$inputReportReasonSpam : TLReportReason


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x58dbcab8;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xed7d341e;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLReportReason$inputReportReasonSpam *object = [[TLReportReason$inputReportReasonSpam alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLReportReason$inputReportReasonViolence : TLReportReason


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x1e22c78d;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xc48824f5;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLReportReason$inputReportReasonViolence *object = [[TLReportReason$inputReportReasonViolence alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLReportReason$inputReportReasonPornography : TLReportReason


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x2e59d922;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xebc89a31;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLReportReason$inputReportReasonPornography *object = [[TLReportReason$inputReportReasonPornography alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLReportReason$inputReportReasonOther : TLReportReason


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xe1746d0a;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xc92626ed;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLReportReason$inputReportReasonOther *object = [[TLReportReason$inputReportReasonOther alloc] init];
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

