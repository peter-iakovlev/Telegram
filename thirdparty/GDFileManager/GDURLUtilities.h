//
//  GDURLUtilities.h
//  GDFileManagerExample
//
//  Created by Graham Dennis on 21/06/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * GDURLQueryStringFromParametersWithEncoding(NSDictionary *parameters, NSStringEncoding encoding);
extern NSDictionary *GDParametersFromURLQueryStringWithEncoding(NSString *queryString, NSStringEncoding encoding);
