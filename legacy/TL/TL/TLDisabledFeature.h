#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLDisabledFeature : NSObject <TLObject>

@property (nonatomic, retain) NSString *feature;
@property (nonatomic, retain) NSString *n_description;

@end

@interface TLDisabledFeature$disabledFeature : TLDisabledFeature


@end

