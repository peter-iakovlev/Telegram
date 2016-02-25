#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLReportReason : NSObject <TLObject>


@end

@interface TLReportReason$inputReportReasonSpam : TLReportReason


@end

@interface TLReportReason$inputReportReasonViolence : TLReportReason


@end

@interface TLReportReason$inputReportReasonPornography : TLReportReason


@end

@interface TLReportReason$inputReportReasonOther : TLReportReason

@property (nonatomic, retain) NSString *text;

@end

