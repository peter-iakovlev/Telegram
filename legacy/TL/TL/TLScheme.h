#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLScheme : NSObject <TLObject>


@end

@interface TLScheme$scheme : TLScheme

@property (nonatomic, retain) NSString *scheme_raw;
@property (nonatomic, retain) NSArray *types;
@property (nonatomic, retain) NSArray *methods;
@property (nonatomic) int32_t version;

@end

@interface TLScheme$schemeNotModified : TLScheme


@end

