//
//  GDGoogleDriveAccountInfo.m
//  GDFileManagerExample
//
//  Created by Graham Dennis on 24/06/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDGoogleDriveAccountInfo.h"

@implementation GDGoogleDriveAccountInfo

- (NSString *)userID
{
    return [self objectForKey:@"id"];
}

@end
