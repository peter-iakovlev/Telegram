#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLLabeledPrice : NSObject <TLObject>

@property (nonatomic, retain) NSString *label;
@property (nonatomic) int64_t amount;

@end

@interface TLLabeledPrice$labeledPrice : TLLabeledPrice


@end

