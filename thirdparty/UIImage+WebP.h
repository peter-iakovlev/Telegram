//
//  UIImage+WebP.h
//  iOS-WebP
//
//  Created by Sean Ooi on 12/21/13.
//  Copyright (c) 2013 Sean Ooi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (WebP)

+ (UIImage *)convertFromWebP:(NSString *)filePath compressedData:(__autoreleasing NSData **)compressedData error:(NSError **)error;
+ (UIImage *)convertFromGZippedData:(NSString *)filePath size:(CGSize)size;

@end
