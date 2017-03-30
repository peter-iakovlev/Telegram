#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLShippingOption : NSObject <TLObject>

@property (nonatomic, retain) NSString *n_id;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSArray *prices;

@end

@interface TLShippingOption$shippingOption : TLShippingOption


@end

