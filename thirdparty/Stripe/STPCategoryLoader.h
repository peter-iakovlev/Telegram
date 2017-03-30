//
//  STPCategoryLoader.h
//  Stripe
//
//  Created by Jack Flintermann on 10/19/15.
//  Copyright © 2015 Stripe, Inc. All rights reserved.
//

#ifdef STP_STATIC_LIBRARY_BUILD

#import <Foundation/Foundation.h>

@interface STPCategoryLoader : NSObject

+ (void)loadCategories;

@end

#endif
