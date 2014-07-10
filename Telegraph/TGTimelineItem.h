/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

#import "TGImageInfo.h"

#import "TL/TLMetaScheme.h"

@interface TGTimelineItem : NSObject

@property (nonatomic) int64_t itemId;
@property (nonatomic) NSTimeInterval date;
@property (nonatomic, strong) TGImageInfo *imageInfo;
@property (nonatomic) bool hasLocation;
@property (nonatomic) double locationLatitude;
@property (nonatomic) double locationLongitude;
@property (nonatomic, strong) NSDictionary *locationComponents;

@property (nonatomic, strong) id cachedLayoutData;

@property (nonatomic) bool uploading;

@property (nonatomic, strong) NSString *localImageUrl;

- (id)initWithDescription:(TLPhoto *)photoDesc;

@end
