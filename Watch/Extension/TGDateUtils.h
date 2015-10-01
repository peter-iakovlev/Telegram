#import <Foundation/Foundation.h>

typedef enum
{
    TGDateRelativeSpanLately = -2,
    TGDateRelativeSpanWithinAWeek = -3,
    TGDateRelativeSpanWithinAMonth = -4,
    TGDateRelativeSpanALongTimeAgo = -5
} TGDateRelativeSpan;

@interface TGDateUtils : NSObject

+ (NSString *)stringForFullDate:(int)date;
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

@end
