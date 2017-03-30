/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

@interface TGDateUtils : NSObject

+ (void)reset;

+ (NSString *)stringForShortTime:(int)time;
+ (NSString *)stringForShortTime:(int)time daytimeVariant:(int *)daytimeVariant;
+ (NSString *)stringForDialogTime:(int)time;
+ (NSString *)stringForDayOfWeek:(int)date;
+ (NSString *)stringForMonthOfYear:(int)date;
+ (NSString *)stringForPreciseDate:(int)date;
+ (NSString *)stringForMessageListDate:(int)date;
+ (NSString *)stringForLastSeen:(int)date;
+ (NSString *)stringForApproximateDate:(int)date;
+ (NSString *)stringForRelativeLastSeen:(int)date;
+ (NSString *)stringForFullDate:(int)date;
+ (NSString *)stringForCallsListDate:(int)date;

@end

#ifdef __cplusplus
extern "C" {
#endif

bool TGUse12hDateFormat();
    
NSString *TGWeekdayNameFull(int number);
NSString *TGMonthNameFull(int number);
NSString *TGMonthNameShort(int number);
    
#ifdef __cplusplus
}
#endif
