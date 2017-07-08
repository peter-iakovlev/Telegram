/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGViewController.h"

#import "ASWatcher.h"

@interface TGLoginCountriesController : TGViewController

@property (nonatomic, strong) ASHandle *watcherHandle;
@property (nonatomic, copy) void (^countrySelected)(int code, NSString *name, NSString *countryId);

- (id)initWithCodes:(bool)displayCodes;

+ (NSString *)countryNameByCode:(int)code;
+ (NSString *)countryIdByCode:(int)code;
+ (NSString *)countryNameByCountryId:(NSString *)countryId code:(int *)code;

@end
