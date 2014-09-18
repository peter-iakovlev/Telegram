#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLSchemeType : NSObject <TLObject>

@property (nonatomic) int32_t n_id;
@property (nonatomic, retain) NSString *predicate;
@property (nonatomic, retain) NSArray *params;
@property (nonatomic, retain) NSString *type;

@end

@interface TLSchemeType$schemeType : TLSchemeType


@end

