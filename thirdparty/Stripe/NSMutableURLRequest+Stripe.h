//
//  NSMutableURLRequest+Stripe.h
//  Stripe
//
//  Created by Ben Guo on 4/22/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableURLRequest (Stripe)

- (void)stp_addParametersToURL:(NSDictionary *)parameters;
- (void)stp_setFormPayload:(NSDictionary *)formPayload;

@end

void linkNSMutableURLRequestCategory(void);
