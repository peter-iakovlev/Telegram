//
//  JPNG.h
//
//  Version 1.2.1
//
//  Created by Nick Lockwood on 05/01/2013.
//  Copyright 2013 Charcoal Design
//
//  Distributed under the permissive zlib license
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/JPNG
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <TargetConditionals.h>
#import <ImageIO/ImageIO.h>


#ifndef JPNG_SWIZZLE_ENABLED
#define JPNG_SWIZZLE_ENABLED 1
#endif


#ifndef JPNG_ALWAYS_FORCE_DECOMPRESSION
#define JPNG_ALWAYS_FORCE_DECOMPRESSION 0
#endif


extern uint32_t JPNGIdentifier;


typedef struct
{ 
    uint32_t imageSize;
    uint32_t maskSize;
    uint16_t footerSize;
    uint8_t majorVersion;
    uint8_t minorVersion;
    uint32_t identifier;
}
JPNGFooter;


//cross-platform implementation

CGImageRef CGImageCreateWithJPNGData(NSData *data, BOOL forceDecompression);
NSData *CGImageJPNGRepresentation(CGImageRef image, CGFloat quality);


#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>


//iOS implementation

UIImage *UIImageWithJPNGData(NSData *data, CGFloat scale, UIImageOrientation orientation);
NSData *UIImageJPNGRepresentation(UIImage *image, CGFloat quality);


#else
#import <AppKit/AppKit.h>


//Mac OS implementation

NSImage *NSImageWithJPNGData(NSData *data, CGFloat scale);
NSData *NSImageJPNGRepresentation(NSImage *image, CGFloat quality);


#endif
